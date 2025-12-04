import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/routes/app_router.dart';

class SongwriterApp extends ConsumerWidget {
  const SongwriterApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'Songwriter',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        textTheme: ThemeData().textTheme.apply(fontSizeFactor: 1.1),
      ),
      routerConfig: router,
    );
  }
}
