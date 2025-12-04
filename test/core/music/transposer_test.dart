import 'package:flutter_test/flutter_test.dart';
import 'package:songwriter/core/database/app_database.dart';
import 'package:songwriter/core/music/chord.dart';
import 'package:songwriter/core/music/chord_parser.dart';
import 'package:songwriter/core/music/transposer.dart';

void main() {
  group('transposeNote', () {
    test('shifts natural and accidental notes', () {
      expect(transposeNote(Note.parse('C'), 2).symbol, 'D');
      expect(transposeNote(Note.parse('Bb'), 2).symbol, 'C');
      expect(transposeNote(Note.parse('F#'), -1).symbol, 'F');
      expect(transposeNote(Note.parse('Eb'), 1).symbol, 'E');
    });
  });

  group('transposeChord', () {
    test('preserves quality, extensions and slash', () {
      final chord = parseChord('D/F#');
      final transposed = transposeChord(chord, 2);
      expect(chordToString(transposed), 'E/G#');

      final altered = parseChord('F#m7');
      final alteredTransposed = transposeChord(altered, -1);
      expect(chordToString(alteredTransposed), 'Fm7');
    });

    test('keeps extensions intact', () {
      final chord = parseChord('Bbmaj7(#11)');
      final transposed = transposeChord(chord, 2, preferFlats: true);
      expect(chordToString(transposed), 'Cmaj7#11');
    });
  });

  group('transposeSong', () {
    test('transposes all lines and updates keys', () async {
      final song = Song(
        id: '1',
        title: 'Test song',
        artist: null,
        originalKey: 'C',
        currentKey: 'C',
        tempoBpm: null,
        createdAt: DateTime(2024),
        updatedAt: DateTime(2024),
      );

      final lines = [
        Line(
          id: 'l1',
          sectionId: 's1',
          order: 0,
          rawText: 'Hoy [C]es [Am]un buen [F]día',
        ),
        Line(
          id: 'l2',
          sectionId: 's1',
          order: 1,
          rawText: '[D/F#] lleva a [G7(#9)]',
        ),
      ];

      final result = transposeSong(
        song,
        KeySignature(tonic: Note.parse('D')),
        lines: lines,
      );

      expect(result.song.currentKey, 'D');
      expect(result.lines[0].rawText, 'Hoy [D]es [Bm]un buen [G]día');
      expect(result.lines[1].rawText, '[E/G#] lleva a [A7#9]');
    });
  });

  group('buildDiatonicScale', () {
    test('builds major scale respecting accidentals', () {
      final key = KeySignature(tonic: Note.parse('D'));
      final scale = buildDiatonicScale(key).map((n) => n.symbol).toList();

      expect(scale, ['D', 'E', 'F#', 'G', 'A', 'B', 'C#']);
    });

    test('builds minor scale with flats when appropriate', () {
      final key = KeySignature(tonic: Note.parse('Bb'), isMinor: true);
      final scale = buildDiatonicScale(key).map((n) => n.symbol).toList();

      expect(scale, ['Bb', 'C', 'Db', 'Eb', 'F', 'Gb', 'Ab']);
    });
  });

  group('getDegree', () {
    test('returns roman numeral for diatonic chords in major', () {
      final key = KeySignature(tonic: Note.parse('C'));

      expect(getDegree(parseChord('C'), key), RomanDegree.diatonic('I'));
      expect(getDegree(parseChord('Am'), key), RomanDegree.diatonic('vi'));
      expect(getDegree(parseChord('Bdim'), key), RomanDegree.diatonic('vii°'));
    });

    test('returns roman numeral for diatonic chords in minor', () {
      final key = KeySignature(tonic: Note.parse('A'), isMinor: true);

      expect(getDegree(parseChord('Am'), key), RomanDegree.diatonic('i'));
      expect(getDegree(parseChord('Bdim'), key), RomanDegree.diatonic('ii°'));
      expect(getDegree(parseChord('C'), key), RomanDegree.diatonic('III'));
    });

    test('marks non-diatonic chords', () {
      final key = KeySignature(tonic: Note.parse('C'));

      expect(getDegree(parseChord('F#'), key).isDiatonic, false);
      expect(getDegree(parseChord('E'), key).symbol, 'ND');
    });
  });

  group('inferKeyFromChords', () {
    test('prefers key with most diatonic matches', () {
      final chords = [
        parseChord('C'),
        parseChord('Am'),
        parseChord('F'),
        parseChord('G'),
      ];

      final inferred = inferKeyFromChords(chords);

      expect(inferred, KeySignature(tonic: Note.parse('C')));
    });

    test('counts borrowed chords with lower weight', () {
      final chords = [
        parseChord('G'),
        parseChord('C'),
        parseChord('F'), // bVII in G
      ];

      final inferred = inferKeyFromChords(chords);

      expect(inferred, KeySignature(tonic: Note.parse('G')));
    });

    test('recognizes V/vi pattern as hint', () {
      final chords = [
        parseChord('C'),
        parseChord('E'), // V/vi in C
        parseChord('Am'),
      ];

      final inferred = inferKeyFromChords(chords);

      expect(inferred, KeySignature(tonic: Note.parse('C')));
    });
  });
}
