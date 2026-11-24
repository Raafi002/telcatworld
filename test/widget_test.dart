import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:telcat_world/core/theme/theme_controller.dart';
import 'package:telcat_world/features/cat_dex/data/repositories/mock_cat_repository.dart';
import 'package:telcat_world/main.dart';

void main() {
  testWidgets(
      'TelCat World app renders shell navigation, Kafe Kucing drag/tap, and Full Screen features',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const TelCatWorldApp());
    // Use bounded pump because CafeRoomStage runs continuous idle breathing loops
    await tester.pump(const Duration(milliseconds: 300));

    // Verify 3 bottom navigation labels & FAB
    expect(find.text('Cat-Dex'), findsWidgets);
    expect(find.text('Peta'), findsOneWidget);
    expect(find.text('Profil'), findsOneWidget);
    expect(find.text('Pindai QR'), findsOneWidget);

    // Verify interactive Kafe Kucing renders active cats & updates quote card on tap
    expect(find.text('Si Oyen'), findsOneWidget);
    await tester.tap(find.text('Si Oyen'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(
      find.text('"Kalau bawa ikan tongkol, kita langsung bestie!"'),
      findsOneWidget,
    );
    expect(find.text('Nama Permanen'), findsOneWidget);

    // Verify drag-and-drop on another cat updates quote card and snaps safely
    expect(find.text('Kuro'), findsOneWidget);
    final kuroCenter = tester.getCenter(find.text('Kuro'));
    final gesture = await tester.startGesture(kuroCenter);
    await tester.pump(const Duration(milliseconds: 30));
    await gesture.moveBy(const Offset(0, -120));
    await tester.pump(const Duration(milliseconds: 30));
    await gesture.up();
    await tester.pump(const Duration(milliseconds: 450));
    expect(
      find.text('"Jangan kaget kalau aku tiba-tiba muncul di pinggir danau ya!"'),
      findsOneWidget,
    );

    // Open Full Screen Mode
    expect(find.byIcon(Icons.fullscreen), findsOneWidget);
    await tester.tap(find.byIcon(Icons.fullscreen));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    // Verify Full Screen HUD, theme switcher, toys, and Photo Mode controls
    expect(find.byIcon(Icons.fullscreen_exit), findsOneWidget);
    expect(find.byIcon(Icons.palette_outlined), findsOneWidget);
    expect(find.byIcon(Icons.camera_alt_rounded), findsOneWidget);
    expect(find.text('Snack Ikan'), findsOneWidget);
    expect(find.text('Laser Pointer'), findsOneWidget);
    expect(find.text('Kafe Hangat'), findsOneWidget);

    // Cycle themes: Cozy -> Pastel -> Night
    await tester.tap(find.byIcon(Icons.palette_outlined));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('Taman Pastel'), findsWidgets);

    await tester.tap(find.byIcon(Icons.palette_outlined));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('Kafe Malam'), findsWidgets);

    // Trigger Snack Ikan & Laser Pointer toggle
    await tester.tap(find.text('Snack Ikan'));
    await tester.pump(const Duration(milliseconds: 250));
    await tester.tap(find.text('Laser Pointer'));
    await tester.pump(const Duration(milliseconds: 250));

    // Trigger Photo Mode & verify toast message + HUD restore after 1.5s
    await tester.tap(find.byIcon(Icons.camera_alt_rounded));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    expect(find.text('📸 Foto Kafe Tersimpan!'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 1600));

    // Exit Full Screen & confirm chosen theme persisted
    await tester.tap(find.byIcon(Icons.fullscreen_exit));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.byIcon(Icons.fullscreen_exit), findsNothing);
    expect(find.text('Kafe Malam'), findsOneWidget);

    // Switch to Katalog Cat-Dex & verify Catbook modal shows quote directly (no Suvenir / header)
    await tester.tap(find.text('Katalog Cat-Dex'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Kucing Putih #02').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('Dialog Si Kucing'), findsNothing);
    expect(
      find.text('"Kardus hangat ini adalah singgasana terbaikku!"'),
      findsOneWidget,
    );
    expect(find.textContaining('Suvenir'), findsNothing);
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    // Switch to Profil tab & verify dynamic title, Best Buddy, avatar picker, medal grid & header info
    await tester.tap(find.text('Profil'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Pawang Kucing Tel-U'), findsOneWidget);
    expect(find.text('Best Buddy: Si Oyen (5x)'), findsOneWidget);
    expect(find.text('TelCat World — Super App Kucing Kampus'), findsNothing);

    // Open avatar picker bottom sheet & select Luna
    await tester.tap(find.byIcon(Icons.edit_rounded));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Pilih Avatar Kucing'), findsOneWidget);
    await tester.tap(find.text('Luna').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(MockCatRepository().selectedAvatarCat?.id, 'cat_006');

    // Tap medal in 3-column grid & verify detail dialog
    expect(find.text('Sahabat Sejati'), findsOneWidget);
    expect(find.text('Penjaga Nama'), findsOneWidget);
    await tester.ensureVisible(find.text('Penjaga Nama'));
    await tester.pump();
    await tester.tap(find.text('Penjaga Nama'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('Terkunci • Progres 3 / 4'), findsOneWidget);
    await tester.tap(find.text('Mengerti'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    // Tap info icon in header & verify Capstone info dialog
    await tester.tap(find.byIcon(Icons.info_outline));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('Tentang TelCat World'), findsOneWidget);
    await tester.tap(find.text('Tutup'));
    await tester.pump();

    // Switch to Peta tab & verify 4 zones, atmosphere toggle, Easter Egg, & detail screen
    await tester.tap(find.text('Peta'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('🏢 TULT & Asrama'), findsOneWidget);
    expect(find.text('🏫 GKU'), findsOneWidget);
    expect(find.text('🏛️ Cacuk'), findsOneWidget);
    expect(find.text('🎓 Fakultas Depan'), findsOneWidget);

    // Cycle atmosphere mode: Otomatis -> Pagi -> Senja -> Malam
    expect(find.text('🕒 Otomatis'), findsOneWidget);
    await tester.tap(find.text('🕒 Otomatis'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('☀️ Pagi'), findsOneWidget);
    await tester.tap(find.text('☀️ Pagi'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('🌅 Senja'), findsOneWidget);
    await tester.tap(find.text('🌅 Senja'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('🌙 Malam'), findsOneWidget);

    // Tap Taman Tugu Easter Egg hotspot (0.53, 0.27) on the 1:1 map
    await tester.tap(find.byKey(const ValueKey('egg_monument')));
    await tester.pump(const Duration(milliseconds: 200));
    expect(
      find.byWidgetPredicate(
        (w) =>
            w is Text &&
            (w.data == 'Sssst... aku lagi sembunyi!' ||
                w.data == 'Angin di taman tugu sejuk banget buat tidur!' ||
                w.data == 'Meow! Ketahuan deh!'),
      ),
      findsOneWidget,
    );
    await tester.pump(const Duration(milliseconds: 2600));

    // Tap TULT & Asrama pin to open TerritoryDetailScreen
    await tester.tap(find.text('🏢 TULT & Asrama'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text('Kucing Penghuni Wilayah (2)'), findsOneWidget);
    expect(find.text('Si Oyen'), findsOneWidget);

    // Pop back to map & test Dark Mode toggle from header + Profil switch
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(ThemeController.instance.isDarkMode, isFalse);
    await tester.tap(find.byIcon(Icons.dark_mode_outlined).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(ThemeController.instance.isDarkMode, isTrue);
    expect(find.byIcon(Icons.light_mode_outlined), findsWidgets);

    // Switch back to Light Mode via Profil switch
    await tester.tap(find.text('Profil'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Mode Gelap'), findsOneWidget);
    await tester.ensureVisible(find.byType(Switch));
    await tester.pump();
    await tester.tap(find.byType(Switch));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(ThemeController.instance.isDarkMode, isFalse);
  });

  group('MockCatRepository V2 encounter & rename logic', () {
    test(
        'daily cooldown, 5x encounter unlock, unique case-insensitive rename, and reset',
        () {
      final repo = MockCatRepository();

      // Reset all cooldowns first
      repo.resetAllDailyCooldowns();
      expect(repo.isScannedToday('cat_003'), isFalse);

      // Simulate 4 encounters on cat_002
      repo.simulateFourEncounters('cat_002');
      var cat2 = repo.getCatById('cat_002');
      expect(cat2.encounterCount, 4);
      expect(cat2.canBeNamed, isFalse);
      expect(repo.isScannedToday('cat_002'), isFalse);

      // Record 5th encounter -> marks scanned today & unlocks rename
      cat2 = repo.recordEncounter('cat_002');
      expect(cat2.encounterCount, 5);
      expect(cat2.canBeNamed, isTrue);
      expect(repo.isScannedToday('cat_002'), isTrue);

      // Case-insensitive duplicate name rejection
      final duplicateError = repo.renameCat('cat_002', '  SI OYEN ');
      expect(
        duplicateError,
        'Nama ini sudah dipakai kucing lain, pilih nama lain ya!',
      );

      // Valid unique rename locks the name
      final successError = repo.renameCat('cat_002', 'Cimol Tel-U');
      expect(successError, isNull);
      final renamedCat = repo.getCatById('cat_002');
      expect(renamedCat.name, 'Cimol Tel-U');
      expect(renamedCat.isNameLocked, isTrue);
      expect(renamedCat.canBeNamed, isFalse);
      expect(repo.isNameTaken('cimol tel-u'), isTrue);

      // Reset cooldown makes cat scannable again today
      repo.resetAllDailyCooldowns();
      expect(repo.isScannedToday('cat_002'), isFalse);
    });
  });
}
