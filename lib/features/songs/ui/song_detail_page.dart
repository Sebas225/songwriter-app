import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/app_database.dart';
import '../data/providers.dart';

class SongDetailPage extends ConsumerWidget {
  const SongDetailPage({super.key, required this.songId});

  final String songId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songAsync = ref.watch(songProvider(songId));
    final sectionsAsync = ref.watch(sectionsForSongProvider(songId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de canción'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.goNamed(
              'songEdit',
              pathParameters: {'id': songId},
            ),
          ),
        ],
      ),
      body: songAsync.when(
        data: (song) {
          if (song == null) {
            return const Center(child: Text('Canción no encontrada'));
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  song.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 4),
                Text(song.artist ?? 'Artista desconocido'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    FilledButton.icon(
                      icon: const Icon(Icons.playlist_add),
                      label: const Text('Agregar sección'),
                      onPressed: () => _createSection(context, ref, sectionsAsync),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: sectionsAsync.when(
                    data: (sections) {
                      if (sections.isEmpty) {
                        return const Center(
                          child: Text('Sin secciones. Añade la primera.'),
                        );
                      }

                      return ListView.separated(
                        itemCount: sections.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final section = sections[index];
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        section.name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                      ),
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit_note),
                                            tooltip: 'Editar sección',
                                            onPressed: () => context.goNamed(
                                              'sectionEditor',
                                              pathParameters: {
                                                'id': songId,
                                                'sectionId': section.id,
                                              },
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline),
                                            onPressed: () =>
                                                _deleteSection(context, ref, section),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Consumer(
                                    builder: (context, ref, _) {
                                      final linesAsync =
                                          ref.watch(linesForSectionProvider(
                                        section.id,
                                      ));

                                      return linesAsync.when(
                                        data: (lines) {
                                          if (lines.isEmpty) {
                                            return const Text('Sin líneas');
                                          }
                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: lines
                                                .map((line) => Text(line.rawText))
                                                .toList(),
                                          );
                                        },
                                        loading: () =>
                                            const LinearProgressIndicator(),
                                        error: (error, _) =>
                                            Text('Error: $error'),
                                      );
                                    },
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
                      child: Text('Error cargando secciones: $error'),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text('Error al cargar la canción: $error'),
        ),
      ),
    );
  }

  Future<void> _createSection(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<Section>> sectionsAsync,
  ) async {
    final existing = sectionsAsync.valueOrNull ?? [];
    final id = ref.read(uuidProvider).v4();
    final entry = SectionsCompanion(
      id: Value(id),
      songId: Value(songId),
      name: Value('Sección ${existing.length + 1}'),
      order: Value(existing.length),
    );
    await ref.read(sectionRepositoryProvider).createSection(entry);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sección creada')),
      );
    }
  }

  Future<void> _deleteSection(
    BuildContext context,
    WidgetRef ref,
    Section section,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar sección'),
        content: Text('¿Quieres eliminar "${section.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(sectionRepositoryProvider).deleteSection(section.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sección eliminada')),
        );
      }
    }
  }
}

