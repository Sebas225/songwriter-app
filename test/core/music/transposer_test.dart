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
}
