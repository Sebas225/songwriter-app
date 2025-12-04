import 'package:flutter/material.dart';

import '../../../../core/music/chord.dart';
import '../../../../core/music/chord_parser.dart';
import '../../../../core/music/transposer.dart';

class ChordInlineText extends StatelessWidget {
  const ChordInlineText({
    super.key,
    required this.rawText,
    required this.keySignature,
    this.showErrors = true,
  });

  final String rawText;
  final KeySignature keySignature;
  final bool showErrors;

  @override
  Widget build(BuildContext context) {
    final defaultStyle = Theme.of(context).textTheme.bodyMedium;
    final chordStyle = defaultStyle?.copyWith(fontWeight: FontWeight.bold);
    final errorStyle = chordStyle?.copyWith(color: Colors.red);

    final spans = <InlineSpan>[];
    var index = 0;

    while (index < rawText.length) {
      final start = rawText.indexOf('[', index);
      if (start == -1) {
        spans.add(TextSpan(text: rawText.substring(index)));
        break;
      }

      if (start > index) {
        spans.add(TextSpan(text: rawText.substring(index, start)));
      }

      final end = rawText.indexOf(']', start + 1);
      if (end == -1) {
        final chordRaw = rawText.substring(start + 1).trim();
        if (showErrors) {
          final display = chordRaw.isEmpty ? 'acorde inválido' : chordRaw;
          spans.add(
            _buildInvalidSpan(display, 'Cierra el acorde con ]', errorStyle),
          );
        } else {
          spans.add(TextSpan(text: rawText.substring(start)));
        }
        break;
      }

      final chordRaw = rawText.substring(start + 1, end).trim();

      if (chordRaw.isEmpty) {
        spans.add(_buildInvalidSpan('acorde inválido', 'Escribe un acorde', errorStyle));
      } else {
        try {
          final chord = parseChord(chordRaw);
          final degree = getDegree(chord, keySignature);
          spans.add(
            TextSpan(
              children: [
                TextSpan(text: chordRaw, style: chordStyle),
                TextSpan(text: ' (${degree.symbol})'),
              ],
            ),
          );
        } on FormatException catch (e) {
          spans.add(_buildInvalidSpan(chordRaw, e.message ?? 'No reconozco el acorde', errorStyle));
        }
      }

      index = end + 1;
    }

    return RichText(
      text: TextSpan(
        style: defaultStyle,
        children: spans.isEmpty ? [const TextSpan(text: '')] : spans,
      ),
    );
  }

  InlineSpan _buildInvalidSpan(String text, String message, TextStyle? style) {
    if (!showErrors) return TextSpan(text: text, style: style);
    return WidgetSpan(
      alignment: PlaceholderAlignment.baseline,
      baseline: TextBaseline.alphabetic,
      child: Tooltip(
        message: message,
        child: Text(text, style: style),
      ),
    );
  }
}
