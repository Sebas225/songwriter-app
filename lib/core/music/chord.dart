import 'package:collection/collection.dart';

enum Quality {
  major,
  minor,
  augmented,
  diminished,
  suspended2,
  suspended4,
  power,
}

class Note {
  const Note._(this.symbol);

  factory Note.parse(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      throw const FormatException('Empty note');
    }

    final letter = trimmed[0].toUpperCase();
    if (!'ABCDEFG'.contains(letter)) {
      throw FormatException('Invalid note letter: $letter');
    }

    String accidental = '';
    if (trimmed.length > 1) {
      final acc = trimmed[1];
      if (acc == '#' || acc == 'b') {
        accidental = acc;
        if (trimmed.length > 2) {
          throw FormatException('Too many accidental symbols in $input');
        }
      } else {
        throw FormatException('Invalid accidental in $input');
      }
    }

    return Note._('$letter$accidental');
  }

  final String symbol;

  @override
  bool operator ==(Object other) {
    return other is Note && other.symbol == symbol;
  }

  @override
  int get hashCode => symbol.hashCode;

  @override
  String toString() => symbol;
}

class ChordExtension {
  const ChordExtension(this.symbol);

  final String symbol;

  @override
  bool operator ==(Object other) {
    return other is ChordExtension && other.symbol == symbol;
  }

  @override
  int get hashCode => symbol.hashCode;

  @override
  String toString() => symbol;
}

class Chord {
  Chord({
    required this.root,
    required this.quality,
    List<ChordExtension>? extensions,
    this.bass,
  }) : extensions = List.unmodifiable(extensions ?? const []);

  final Note root;
  final Quality quality;
  final List<ChordExtension> extensions;
  final Note? bass;

  @override
  bool operator ==(Object other) {
    return other is Chord &&
        other.root == root &&
        other.quality == quality &&
        const ListEquality<ChordExtension>().equals(other.extensions, extensions) &&
        other.bass == bass;
  }

  @override
  int get hashCode => Object.hash(
        root,
        quality,
        const ListEquality<ChordExtension>().hash(extensions),
        bass,
      );

  @override
  String toString() {
    final extText = extensions.map((e) => e.symbol).join(',');
    final bassText = bass != null ? '/${bass!.symbol}' : '';
    final qualityText = quality.name;
    return 'Chord(root: ${root.symbol}, quality: $qualityText, extensions: [$extText]$bassText)';
  }
}

class ChordToken {
  ChordToken({
    required this.chord,
    required this.startIndex,
    required this.endIndex,
  });

  final Chord chord;
  final int startIndex;
  final int endIndex;

  @override
  bool operator ==(Object other) {
    return other is ChordToken &&
        other.chord == chord &&
        other.startIndex == startIndex &&
        other.endIndex == endIndex;
  }

  @override
  int get hashCode => Object.hash(chord, startIndex, endIndex);
}
