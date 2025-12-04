import 'package:drift/drift.dart' show Value;

import '../database/app_database.dart';
import 'chord.dart';
import 'chord_parser.dart';

class KeySignature {
  const KeySignature({required this.tonic, this.isMinor = false});

  final Note tonic;
  final bool isMinor;

  @override
  bool operator ==(Object other) {
    return other is KeySignature && other.tonic == tonic && other.isMinor == isMinor;
  }

  @override
  int get hashCode => Object.hash(tonic, isMinor);

  @override
  String toString() => keySignatureLabel(this);
}

class TranspositionResult {
  TranspositionResult({required this.song, required this.lines});

  final Song song;
  final List<Line> lines;
}

const _sharpNames = [
  'C',
  'C#',
  'D',
  'D#',
  'E',
  'F',
  'F#',
  'G',
  'G#',
  'A',
  'A#',
  'B',
];

const _flatNames = [
  'C',
  'Db',
  'D',
  'Eb',
  'E',
  'F',
  'Gb',
  'G',
  'Ab',
  'A',
  'Bb',
  'B',
];

const _noteToIndex = {
  'C': 0,
  'B#': 0,
  'C#': 1,
  'Db': 1,
  'D': 2,
  'D#': 3,
  'Eb': 3,
  'E': 4,
  'Fb': 4,
  'E#': 5,
  'F': 5,
  'F#': 6,
  'Gb': 6,
  'G': 7,
  'G#': 8,
  'Ab': 8,
  'A': 9,
  'A#': 10,
  'Bb': 10,
  'B': 11,
  'Cb': 11,
};

final List<KeySignature> allKeySignatures = (() {
  final keys = <KeySignature>{};

  for (final tonic in _sharpNames) {
    keys.add(KeySignature(tonic: Note.parse(tonic)));
    keys.add(KeySignature(tonic: Note.parse(tonic), isMinor: true));
  }

  for (final tonic in _flatNames.where((name) => !_sharpNames.contains(name))) {
    keys.add(KeySignature(tonic: Note.parse(tonic)));
    keys.add(KeySignature(tonic: Note.parse(tonic), isMinor: true));
  }

  final list = keys.toList();
  list.sort((a, b) => keySignatureLabel(a).compareTo(keySignatureLabel(b)));
  return list;
})();

int _wrapIndex(int index) {
  var wrapped = index % 12;
  if (wrapped < 0) wrapped += 12;
  return wrapped;
}

int noteToSemitone(Note note) {
  final value = _noteToIndex[note.symbol];
  if (value == null) {
    throw ArgumentError('Unknown note: ${note.symbol}');
  }
  return value;
}

Note _fromIndex(int index, {required bool preferFlats}) {
  final names = preferFlats ? _flatNames : _sharpNames;
  return Note.parse(names[_wrapIndex(index)]);
}

bool _preferFlats(Note note) => note.symbol.contains('b');

Note transposeNote(Note note, int semitones, {bool? preferFlats}) {
  final baseIndex = noteToSemitone(note);
  final targetIndex = baseIndex + semitones;
  return _fromIndex(targetIndex, preferFlats: preferFlats ?? _preferFlats(note));
}

Chord transposeChord(Chord chord, int semitones, {bool? preferFlats}) {
  final preferFlatAccidentals = preferFlats ?? _preferFlats(chord.root);
  final root = transposeNote(chord.root, semitones, preferFlats: preferFlatAccidentals);
  final bass = chord.bass == null
      ? null
      : transposeNote(chord.bass!, semitones, preferFlats: preferFlatAccidentals);
  return Chord(
    root: root,
    quality: chord.quality,
    extensions: chord.extensions,
    bass: bass,
  );
}

String chordToString(Chord chord) {
  final buffer = StringBuffer()..write(chord.root.symbol);
  buffer.write(_qualitySymbol(chord.quality));
  for (final ext in chord.extensions) {
    buffer.write(ext.symbol);
  }
  if (chord.bass != null) {
    buffer.write('/${chord.bass!.symbol}');
  }
  return buffer.toString();
}

String _qualitySymbol(Quality quality) {
  switch (quality) {
    case Quality.major:
      return '';
    case Quality.minor:
      return 'm';
    case Quality.augmented:
      return 'aug';
    case Quality.diminished:
      return 'dim';
    case Quality.suspended2:
      return 'sus2';
    case Quality.suspended4:
      return 'sus4';
    case Quality.power:
      return '5';
  }
}

String transposeRawText(String rawText, int semitones, {required bool preferFlats}) {
  final buffer = StringBuffer();
  var index = 0;

  while (index < rawText.length) {
    final start = rawText.indexOf('[', index);
    if (start == -1) {
      buffer.write(rawText.substring(index));
      break;
    }

    if (start > index) {
      buffer.write(rawText.substring(index, start));
    }

    final end = rawText.indexOf(']', start + 1);
    if (end == -1) {
      buffer.write(rawText.substring(start));
      break;
    }

    final chordRaw = rawText.substring(start + 1, end);
    try {
      final chord = parseChord(chordRaw);
      final transposed = transposeChord(chord, semitones, preferFlats: preferFlats);
      buffer.write('[${chordToString(transposed)}]');
    } on FormatException {
      buffer.write(rawText.substring(start, end + 1));
    }

    index = end + 1;
  }

  return buffer.toString();
}

String keySignatureLabel(KeySignature key) => '${key.tonic.symbol}${key.isMinor ? 'm' : ''}';

KeySignature? parseKeySignature(String? input) {
  if (input == null) return null;
  final text = input.trim();
  if (text.isEmpty) return null;
  final lower = text.toLowerCase();
  final isMinor = lower.endsWith('m');
  final tonicText = isMinor ? text.substring(0, text.length - 1) : text;
  return KeySignature(tonic: Note.parse(tonicText), isMinor: isMinor);
}

int semitoneDistance(KeySignature from, KeySignature to) {
  return noteToSemitone(to.tonic) - noteToSemitone(from.tonic);
}

bool preferFlatsForKey(KeySignature key) => _preferFlats(key.tonic);

TranspositionResult transposeSong(
  Song song,
  KeySignature newKey, {
  required List<Line> lines,
}) {
  final currentKey =
      parseKeySignature(song.currentKey ?? song.originalKey) ?? KeySignature(tonic: Note.parse('C'));
  final semitones = semitoneDistance(currentKey, newKey);
  final preferFlats = preferFlatsForKey(newKey);

  final updatedLines = lines
      .map(
        (line) => line.copyWith(
          rawText: transposeRawText(line.rawText, semitones, preferFlats: preferFlats),
        ),
      )
      .toList();

  final newKeyLabel = keySignatureLabel(newKey);
  final shouldSetOriginal = song.originalKey == null;
  final updatedSong = song.copyWith(
    originalKey: shouldSetOriginal ? Value(keySignatureLabel(currentKey)) : const Value.absent(),
    currentKey: Value(newKeyLabel),
    updatedAt: DateTime.now(),
  );

  return TranspositionResult(song: updatedSong, lines: updatedLines);
}
