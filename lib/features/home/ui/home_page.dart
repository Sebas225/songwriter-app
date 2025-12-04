import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/app_database.dart';
import '../../songs/data/providers.dart';

final songSearchQueryProvider = StateProvider<String>((ref) => '');

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchQuery = ref.watch(songSearchQueryProvider);
    final songsAsync = ref.watch(songsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Songwriter'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              style: const TextStyle(fontSize: 18),
              decoration: const InputDecoration(
                labelText: 'Busca por título o artista',
                hintText: 'Ej. “Cielito lindo”',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) =>
                  ref.read(songSearchQueryProvider.notifier).state = value,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: const Icon(Icons.add, size: 28),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  textStyle: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                label: const Text('Nueva canción'),
                onPressed: () => context.goNamed('songCreate'),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: songsAsync.when(
                data: (songs) {
                  final filtered = songs.where((song) {
                    if (searchQuery.isEmpty) return true;
                    final query = searchQuery.toLowerCase();
                    return song.title.toLowerCase().contains(query) ||
                        (song.artist?.toLowerCase().contains(query) ?? false);
                  }).toList();

                  if (filtered.isEmpty) {
                    return const Center(
                      child: Text(
                        'No hay canciones todavía. Toca “Nueva canción”.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18),
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final song = filtered[index];
                      return Card(
                        child: ListTile(
                          title: Text(
                            song.title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          subtitle: song.artist != null
                              ? Text(
                                  song.artist!,
                                  style: const TextStyle(fontSize: 16),
                                )
                              : const Text(
                                  'Artista desconocido',
                                  style: TextStyle(fontSize: 16),
                                ),
                          onTap: () => context.goNamed(
                            'songDetail',
                            pathParameters: {'id': song.id},
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            tooltip: 'Eliminar canción',
                            onPressed: () => _confirmDelete(context, ref, song),
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(
                  child: Text('Error al cargar canciones: $error'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Song song,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar canción'),
        content: Text('¿Quieres eliminar "${song.title}"?'),
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
      await ref.read(songRepositoryProvider).deleteSong(song.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Canción eliminada')),
        );
      }
    }
  }
}
