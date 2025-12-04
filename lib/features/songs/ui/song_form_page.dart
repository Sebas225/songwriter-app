import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/app_database.dart';
import '../data/providers.dart';

class SongFormPage extends ConsumerStatefulWidget {
  const SongFormPage({super.key, this.songId});

  final String? songId;

  bool get isEditing => songId != null;

  @override
  ConsumerState<SongFormPage> createState() => _SongFormPageState();
}

class _SongFormPageState extends ConsumerState<SongFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _artistController;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _artistController = TextEditingController();
    _initialized = !widget.isEditing;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _artistController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final songAsync = widget.isEditing
        ? ref.watch(songProvider(widget.songId!))
        : const AsyncData<Song?>(null);

    songAsync.whenData((song) {
      if (song != null && !_initialized) {
        _titleController.text = song.title;
        _artistController.text = song.artist ?? '';
        _initialized = true;
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Editar canción' : 'Nueva canción'),
      ),
      body: songAsync.when(
        data: (_) => Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Título'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingresa un título';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _artistController,
                  decoration: const InputDecoration(labelText: 'Artista'),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    icon: const Icon(Icons.save),
                    label: Text(widget.isEditing ? 'Actualizar' : 'Crear'),
                    onPressed: () => _submit(context),
                  ),
                ),
              ],
            ),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }

  Future<void> _submit(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    final repository = ref.read(songRepositoryProvider);
    final now = DateTime.now();
    Song? createdOrUpdated;

    if (widget.isEditing) {
      final existing = ref.read(songProvider(widget.songId!)).value;
      if (existing != null) {
        final updated = existing.copyWith(
          title: _titleController.text.trim(),
          artist: Value(
            _artistController.text.trim().isEmpty
                ? null
                : _artistController.text.trim(),
          ),
          updatedAt: now,
        );
        await repository.updateSong(updated);
        createdOrUpdated = updated;
      }
    } else {
      final id = ref.read(uuidProvider).v4();
      final entry = SongsCompanion(
        id: Value(id),
        title: Value(_titleController.text.trim()),
        artist: Value(
          _artistController.text.trim().isEmpty
              ? null
              : _artistController.text.trim(),
        ),
        createdAt: Value(now),
        updatedAt: Value(now),
      );

      createdOrUpdated = await repository.createSong(entry);
    }

    if (createdOrUpdated != null && mounted) {
      context.goNamed(
        'songDetail',
        pathParameters: {'id': createdOrUpdated.id},
      );
    }
  }
}

