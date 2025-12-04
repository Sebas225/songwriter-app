import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/ui/home_page.dart';
import '../../features/songs/ui/section_editor_page.dart';
import '../../features/songs/ui/song_detail_page.dart';
import '../../features/songs/ui/song_form_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomePage(),
        routes: [
          GoRoute(
            path: 'songs/new',
            name: 'songCreate',
            builder: (context, state) => const SongFormPage(),
          ),
          GoRoute(
            path: 'songs/:id',
            name: 'songDetail',
            builder: (context, state) =>
                SongDetailPage(songId: state.pathParameters['id']!),
            routes: [
              GoRoute(
                path: 'edit',
                name: 'songEdit',
                builder: (context, state) =>
                    SongFormPage(songId: state.pathParameters['id']!),
              ),
              GoRoute(
                path: 'sections/:sectionId',
                name: 'sectionEditor',
                builder: (context, state) => SectionEditorPage(
                  songId: state.pathParameters['id']!,
                  sectionId: state.pathParameters['sectionId']!,
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
