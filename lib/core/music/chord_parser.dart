import 'chord.dart';

final RegExp _extensionPattern =
    RegExp(r'^(maj7|maj9|add11|add9|13|11|9|7|6|#5|b5|#9|b9|#11|b13)');

Chord parseChord(String input) {
  final text = input.trim();
  if (text.isEmpty) {
    throw const FormatException('Chord input cannot be empty');
  }

  final slashIndex = _findSlashOutsideParentheses(text);
  var chordText = text;
  Note? bass;
  if (slashIndex != -1) {
    final bassText = text.substring(slashIndex + 1);
    bass = Note.parse(bassText);
    chordText = text.substring(0, slashIndex);
  }

  if (chordText.isEmpty) {
    throw const FormatException('Chord root is missing');
  }

  final rootLetter = chordText[0].toUpperCase();
  if (!'ABCDEFG'.contains(rootLetter)) {
    throw FormatException('Invalid chord root: $rootLetter');
  }

  var rootSymbol = rootLetter;
  var offset = 1;
  if (chordText.length > 1) {
    final accidental = chordText[1];
    if (accidental == '#' || accidental == 'b') {
      rootSymbol += accidental;
      offset = 2;
    }
  }

  final root = Note.parse(rootSymbol);
  final remaining = chordText.substring(offset);

  final qualityParse = _parseQuality(remaining);
  final quality = qualityParse.quality;
  final leftover = qualityParse.remaining;

  final extensions = _parseExtensions(leftover);

  return Chord(
    root: root,
    quality: quality,
    extensions: extensions,
    bass: bass,
  );
}

List<ChordExtension> _parseExtensions(String input) {
  var rest = input.trim();
  final extensions = <ChordExtension>[];

  while (rest.isNotEmpty) {
    rest = rest.trimLeft();
    if (rest.isEmpty) break;

    if (rest.startsWith('(')) {
      final closeIndex = rest.indexOf(')');
      if (closeIndex == -1) {
        throw const FormatException('Unclosed parenthesis in chord extensions');
      }
      final segment = rest.substring(1, closeIndex);
      extensions.addAll(_parseExtensionSegment(segment));
      rest = rest.substring(closeIndex + 1);
      continue;
    }

    final match = _extensionPattern.firstMatch(rest);
    if (match == null) {
      throw FormatException('Unknown chord extension: $rest');
    }

    final symbol = match.group(1)!;
    extensions.add(ChordExtension(symbol));
    rest = rest.substring(symbol.length);
  }

  return extensions;
}

List<ChordExtension> _parseExtensionSegment(String segment) {
  var rest = segment.trim();
  final extensions = <ChordExtension>[];

  while (rest.isNotEmpty) {
    rest = rest.trimLeft();
    if (rest.isEmpty) break;

    if (rest.startsWith(',') || rest.startsWith(' ')) {
      rest = rest.substring(1);
      continue;
    }

    final match = _extensionPattern.firstMatch(rest);
    if (match == null) {
      throw FormatException('Unknown chord extension inside parentheses: $rest');
    }

    final symbol = match.group(1)!;
    extensions.add(ChordExtension(symbol));
    rest = rest.substring(symbol.length);
  }

  return extensions;
}

class _QualityParseResult {
  _QualityParseResult(this.quality, this.remaining);

  final Quality quality;
  final String remaining;
}

_QualityParseResult _parseQuality(String input) {
  final lower = input.toLowerCase();

  if (lower.startsWith('sus2')) {
    return _QualityParseResult(Quality.suspended2, input.substring(4));
  }
  if (lower.startsWith('sus4')) {
    return _QualityParseResult(Quality.suspended4, input.substring(4));
  }
  if (lower.startsWith('aug')) {
    return _QualityParseResult(Quality.augmented, input.substring(3));
  }
  if (input.startsWith('+')) {
    return _QualityParseResult(Quality.augmented, input.substring(1));
  }
  if (lower.startsWith('dim') || input.startsWith('°')) {
    final cut = lower.startsWith('dim') ? 3 : 1;
    return _QualityParseResult(Quality.diminished, input.substring(cut));
  }
  if (lower.startsWith('min')) {
    return _QualityParseResult(Quality.minor, input.substring(3));
  }
  if (lower.startsWith('m') && !lower.startsWith('maj')) {
    return _QualityParseResult(Quality.minor, input.substring(1));
  }
  if (input.startsWith('-')) {
    return _QualityParseResult(Quality.minor, input.substring(1));
  }
  if (input.startsWith('5')) {
    return _QualityParseResult(Quality.power, input.substring(1));
  }

  return _QualityParseResult(Quality.major, input);
}

int _findSlashOutsideParentheses(String input) {
  var depth = 0;
  for (var i = 0; i < input.length; i++) {
    final char = input[i];
    if (char == '(') {
      depth++;
    } else if (char == ')') {
      depth--;
    } else if (char == '/' && depth == 0) {
      return i;
    }
  }
  return -1;
}

List<ChordToken> extractChords(String rawLine) {
  final tokens = <ChordToken>[];
  var searchIndex = 0;

  while (true) {
    final start = rawLine.indexOf('[', searchIndex);
    if (start == -1) break;

    final end = rawLine.indexOf(']', start + 1);
    if (end == -1) {
      throw const FormatException('Unclosed chord bracket in line');
    }

    final chordText = rawLine.substring(start + 1, end);
    final chord = parseChord(chordText);
    tokens.add(ChordToken(chord: chord, startIndex: start, endIndex: end));

    searchIndex = end + 1;
  }

  return tokens;
}
