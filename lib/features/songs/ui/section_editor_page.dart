import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/app_database.dart';
import '../../../core/music/chord_parser.dart';
import '../data/providers.dart';

class SectionEditorPage extends ConsumerStatefulWidget {
  const SectionEditorPage({super.key, required this.songId, required this.sectionId});

  final String songId;
  final String sectionId;

  @override
  ConsumerState<SectionEditorPage> createState() => _SectionEditorPageState();
}

class _SectionEditorPageState extends ConsumerState<SectionEditorPage> {
  final Map<String, TextEditingController> _lineControllers = {};
  TextEditingController? _sectionNameController;

  @override
  void dispose() {
    for (final controller in _lineControllers.values) {
      controller.dispose();
    }
    _sectionNameController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sectionAsync = ref.watch(sectionProvider(widget.sectionId));
    final linesAsync = ref.watch(linesForSectionProvider(widget.sectionId));

    sectionAsync.whenData((section) {
      if (section != null && _sectionNameController == null) {
        _sectionNameController = TextEditingController(text: section.name);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar sección'),
      ),
      body: sectionAsync.when(
        data: (section) {
          if (section == null) {
            return const Center(child: Text('Sección no encontrada'));
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextFormField(
                  controller: _sectionNameController,
                  decoration: const InputDecoration(labelText: 'Nombre de sección'),
                  onChanged: (value) {
                    final updated = section.copyWith(name: value, order: section.order);
                    ref.read(sectionRepositoryProvider).updateSection(updated);
                  },
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: linesAsync.when(
                    data: (lines) {
                      if (lines.isEmpty) {
                        return const Center(child: Text('Sin líneas. Agrega una.'));
                      }

                      return ListView.separated(
                        itemCount: lines.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final line = lines[index];
                          final controller = _lineControllers.putIfAbsent(
                            line.id,
                            () => TextEditingController(text: line.rawText),
                          );

                          if (controller.text != line.rawText) {
                            controller.text = line.rawText;
                          }

                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Línea ${index + 1}'),
                                  TextField(
                                    controller: controller,
                                    maxLines: null,
                                    decoration: const InputDecoration(
                                      hintText: 'Escribe acordes con [C] y texto',
                                    ),
                                    onChanged: (value) {
                                      final updated = line.copyWith(rawText: value);
                                      ref
                                          .read(lineRepositoryProvider)
                                          .updateLine(updated);
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                  ValueListenableBuilder<TextEditingValue>(
                                    valueListenable: controller,
                                    builder: (context, value, _) {
                                      return _ChordPreview(rawText: value.text);
                                    },
                                  ),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: IconButton(
                                      icon: const Icon(Icons.delete_outline),
                                      onPressed: () =>
                                          ref.read(lineRepositoryProvider).deleteLine(line.id),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (error, _) => Center(
                      child: Text('Error cargando líneas: $error'),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Agregar línea'),
                        onPressed: () => _addLine(ref, linesAsync.valueOrNull ?? []),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => context.goNamed(
                          'songDetail',
                          pathParameters: {'id': widget.songId},
                        ),
                        child: const Text('Volver al detalle'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text('Error cargando sección: $error'),
        ),
      ),
    );
  }

  Future<void> _addLine(WidgetRef ref, List<Line> existing) async {
    final id = ref.read(uuidProvider).v4();
    final entry = LinesCompanion(
      id: Value(id),
      sectionId: Value(widget.sectionId),
      order: Value(existing.length),
      rawText: const Value(''),
    );
    await ref.read(lineRepositoryProvider).createLine(entry);
  }
}

class _ChordPreview extends StatelessWidget {
  const _ChordPreview({required this.rawText});

  final String rawText;

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
        final message = 'Falta cerrar corchete de acorde';
        final display = chordRaw.isEmpty ? 'acorde inválido' : chordRaw;
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: Tooltip(
              message: message,
              child: Text(display, style: errorStyle),
            ),
          ),
        );
        break;
      }

      final chordRaw = rawText.substring(start + 1, end).trim();

      if (chordRaw.isEmpty) {
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: Tooltip(
              message: 'Acorde vacío',
              child: Text('acorde inválido', style: errorStyle),
            ),
          ),
        );
      } else {
        try {
          parseChord(chordRaw);
          spans.add(TextSpan(text: chordRaw, style: chordStyle));
        } on FormatException catch (e) {
          spans.add(
            WidgetSpan(
              alignment: PlaceholderAlignment.baseline,
              baseline: TextBaseline.alphabetic,
              child: Tooltip(
                message: e.message ?? 'Acorde inválido',
                child: Text(chordRaw, style: errorStyle),
              ),
            ),
          );
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
}

