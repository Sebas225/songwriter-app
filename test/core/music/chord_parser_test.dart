import 'package:flutter_test/flutter_test.dart';
import 'package:songwriter/core/music/chord.dart';
import 'package:songwriter/core/music/chord_parser.dart';

void main() {
  Chord expectChord(
    String input, {
    required String root,
    required Quality quality,
    List<String> extensions = const [],
    String? bass,
  }) {
    final chord = parseChord(input);
    expect(chord.root.symbol, root);
    expect(chord.quality, quality);
    expect(chord.extensions.map((e) => e.symbol).toList(), extensions);
    if (bass == null) {
      expect(chord.bass, isNull);
    } else {
      expect(chord.bass?.symbol, bass);
    }
    return chord;
  }

  group('parseChord - valid cases', () {
    test('parses root notes and qualities', () {
      expectChord('C', root: 'C', quality: Quality.major);
      expectChord('Cm', root: 'C', quality: Quality.minor);
      expectChord('Cmin', root: 'C', quality: Quality.minor);
      expectChord('C-', root: 'C', quality: Quality.minor);
      expectChord('Caug', root: 'C', quality: Quality.augmented);
      expectChord('C+', root: 'C', quality: Quality.augmented);
      expectChord('Cdim', root: 'C', quality: Quality.diminished);
      expectChord('C°', root: 'C', quality: Quality.diminished);
      expectChord('Csus2', root: 'C', quality: Quality.suspended2);
      expectChord('Csus4', root: 'C', quality: Quality.suspended4);
      expectChord('C5', root: 'C', quality: Quality.power);
      expectChord('Bb', root: 'Bb', quality: Quality.major);
      expectChord('A#', root: 'A#', quality: Quality.major);
      expectChord('F#', root: 'F#', quality: Quality.major);
      expectChord('Dbm', root: 'Db', quality: Quality.minor);
    });

    test('parses extensions without parentheses', () {
      expectChord('Gmaj7',
          root: 'G', quality: Quality.major, extensions: ['maj7']);
      expectChord('Fmaj9',
          root: 'F', quality: Quality.major, extensions: ['maj9']);
      expectChord('D7', root: 'D', quality: Quality.major, extensions: ['7']);
      expectChord('G9', root: 'G', quality: Quality.major, extensions: ['9']);
      expectChord('E11', root: 'E', quality: Quality.major, extensions: ['11']);
      expectChord('F13', root: 'F', quality: Quality.major, extensions: ['13']);
      expectChord('Cadd9',
          root: 'C', quality: Quality.major, extensions: ['add9']);
      expectChord('Cadd11',
          root: 'C', quality: Quality.major, extensions: ['add11']);
      expectChord('F#m7b5',
          root: 'F#', quality: Quality.minor, extensions: ['7', 'b5']);
      expectChord('Eb7b9#11',
          root: 'Eb', quality: Quality.major, extensions: ['7', 'b9', '#11']);
    });

    test('parses extensions with parentheses', () {
      expectChord('E7(#9)',
          root: 'E', quality: Quality.major, extensions: ['7', '#9']);
      expectChord('E7#9',
          root: 'E', quality: Quality.major, extensions: ['7', '#9']);
      expectChord('Am7(b5)',
          root: 'A', quality: Quality.minor, extensions: ['7', 'b5']);
      expectChord('G7(#9)',
          root: 'G', quality: Quality.major, extensions: ['7', '#9']);
      expectChord('Cmaj7(add9)',
          root: 'C', quality: Quality.major, extensions: ['maj7', 'add9']);
      expectChord('Bbmaj7(#11)',
          root: 'Bb', quality: Quality.major, extensions: ['maj7', '#11']);
      expectChord('Eb7(b9#11)',
          root: 'Eb', quality: Quality.major, extensions: ['7', 'b9', '#11']);
      expectChord('Gsus4(add9)',
          root: 'G', quality: Quality.suspended4, extensions: ['add9']);
      expectChord('A6', root: 'A', quality: Quality.major, extensions: ['6']);
      expectChord('Bmaj7(#11)',
          root: 'B', quality: Quality.major, extensions: ['maj7', '#11']);
      expectChord('C#dim7',
          root: 'C#', quality: Quality.diminished, extensions: ['7']);
      expectChord('Abaug7',
          root: 'Ab', quality: Quality.augmented, extensions: ['7']);
      expectChord('Gm13', root: 'G', quality: Quality.minor, extensions: ['13']);
    });

    test('parses slash chords', () {
      expectChord('D/F#',
          root: 'D', quality: Quality.major, bass: 'F#', extensions: []);
      expectChord('Bbmaj7/D',
          root: 'Bb', quality: Quality.major, bass: 'D', extensions: ['maj7']);
      expectChord('Am7/E',
          root: 'A', quality: Quality.minor, bass: 'E', extensions: ['7']);
      expectChord('Ebsus2/G',
          root: 'Eb', quality: Quality.suspended2, bass: 'G');
      expectChord('Cmaj7(add9)/E',
          root: 'C',
          quality: Quality.major,
          bass: 'E',
          extensions: ['maj7', 'add9']);
    });

    test('supports lowercase input and trimming', () {
      expectChord('  g7(#9) ',
          root: 'G', quality: Quality.major, extensions: ['7', '#9']);
      expectChord('am', root: 'A', quality: Quality.minor);
      expectChord('f#dim7',
          root: 'F#', quality: Quality.diminished, extensions: ['7']);
      expectChord('dbsus4', root: 'Db', quality: Quality.suspended4);
    });
  });

  group('parseChord - invalid cases', () {
    test('rejects empty or malformed notes', () {
      expect(() => parseChord(''), throwsFormatException);
      expect(() => parseChord('H7'), throwsFormatException);
      expect(() => parseChord('Cb#'), throwsFormatException);
      expect(() => parseChord('C##'), throwsFormatException);
    });

    test('rejects unsupported extensions or formats', () {
      expect(() => parseChord('Cmaj8'), throwsFormatException);
      expect(() => parseChord('C7(b9'), throwsFormatException);
      expect(() => parseChord('C/'), throwsFormatException);
      expect(() => parseChord('C(add#)'), throwsFormatException);
      expect(() => parseChord('M7'), throwsFormatException);
      expect(() => parseChord('C7(h11)'), throwsFormatException);
    });
  });

  group('extractChords', () {
    test('extracts multiple chords with positions', () {
      const line = 'Hoy [C]es [Am]un buen [F]día';
      final tokens = extractChords(line);
      expect(tokens, hasLength(3));

      expect(tokens[0].startIndex, 4);
      expect(tokens[0].endIndex, 6);
      expect(tokens[0].chord.root.symbol, 'C');

      expect(tokens[1].startIndex, 10);
      expect(tokens[1].endIndex, 13);
      expect(tokens[1].chord.root.symbol, 'A');
      expect(tokens[1].chord.quality, Quality.minor);

      expect(tokens[2].chord.root.symbol, 'F');
    });

    test('handles slash chords and extensions', () {
      const line = '[D/F#] leads to [G7(#9)] in this line';
      final tokens = extractChords(line);
      expect(tokens, hasLength(2));

      expect(tokens[0].chord.bass?.symbol, 'F#');
      expect(tokens[1].chord.extensions.map((e) => e.symbol), ['7', '#9']);
    });

    test('throws on invalid lines', () {
      expect(() => extractChords('Missing closing [C'), throwsFormatException);
      expect(() => extractChords('Invalid [H] chord'), throwsFormatException);
    });
  });
}
