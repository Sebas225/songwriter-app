import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:songwriter/app.dart';

void main() {
  testWidgets('renders home page', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: SongwriterApp()));

    await tester.pumpAndSettle();

    expect(find.text('Songwriter'), findsOneWidget);
  });
}
