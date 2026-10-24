import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_disco/config/app_routes.dart';
import 'package:music_disco/features/discover/data/mock_discovery_repository.dart';

import '../helpers/test_app.dart';

Future<void> shot(WidgetTester tester, String name) async {
  await expectLater(find.byType(TestApp), matchesGoldenFile('out/$name.png'));
}

void main() {
  setUpAll(loadAppFonts);

  testWidgets('screens', (tester) async {
    final router = await pumpTestApp(
      tester,
      repository: MockDiscoveryRepository(latency: Duration.zero),
    );
    await shot(tester, '01_mood_top');
    await tester.dragFrom(const Offset(200, 600), const Offset(0, -600));
    await tester.pumpAndSettle();
    await shot(tester, '02_mood_bottom');

    await tester.tap(find.text('biraz yüksel'));
    await tester.pump(const Duration(milliseconds: 300));
    await shot(tester, '03_mood_flight');
    await tester.pumpAndSettle();
    await shot(tester, '04_mood_selected');

    await tester.tap(find.text('Bu hisle devam et'));
    await tester.pump(const Duration(milliseconds: 200));
    await shot(tester, '05_transition');
    await tester.pumpAndSettle();
    await shot(tester, '06_direction_top');
    await tester.tap(find.text('yükselt beni'));
    await tester.pump(const Duration(milliseconds: 280));
    await shot(tester, '07_direction_mid');
    await tester.pumpAndSettle();
    await shot(tester, '08_direction_lift');
    await tester.dragFrom(const Offset(200, 600), const Offset(0, -600));
    await tester.pumpAndSettle();
    await shot(tester, '09_direction_bottom');

    await tester.tap(find.text('İlk şarkımı bul'));
    await tester.pumpAndSettle();
    await shot(tester, '10_session_top');
    await tester.dragFrom(const Offset(200, 600), const Offset(0, -500));
    await tester.pumpAndSettle();
    await shot(tester, '11_session_bottom');
    await tester.tap(find.text('bana uymadı'));
    await tester.pumpAndSettle();
    await shot(tester, '12_session_feedback');
    await tester.tap(find.text('koleksiyonuma'));
    await tester.pump(const Duration(milliseconds: 350));
    await shot(tester, '13_save_flight');
    await tester.pumpAndSettle();
    await shot(tester, '14_saved');
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    await tester.dragFrom(const Offset(200, 300), const Offset(0, 800));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.keyboard_arrow_down_rounded));
    await tester.pumpAndSettle();
    await shot(tester, '15_sheet');
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();

    router.go(AppRoutes.collection);
    await tester.pumpAndSettle();
    await shot(tester, '16_collection');
  });
}
