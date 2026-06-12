import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:integration_test/integration_test.dart';

import 'package:flutter_sticky_notes_kanban/data/note_store.dart';
import 'package:flutter_sticky_notes_kanban/ui/board_screen.dart';
import 'package:flutter_sticky_notes_kanban/ui/note_zoom_sheet.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> shoot(WidgetTester tester, String name) async {
    await binding.convertFlutterSurfaceToImage();
    await tester.pumpAndSettle();
    await binding.takeScreenshot(name);
  }

  setUpAll(() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(StickyNoteAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(PriorityAdapter());
    }
    await Hive.deleteBoxFromDisk('notes');
    final box = await Hive.openBox<StickyNote>('notes');

    final seed = <StickyNote>[
      StickyNote(
          id: 'n1',
          text: 'Ship release\nv0.1.0',
          dx: 8,
          dy: 10,
          weekSlot: 0,
          priority: Priority.high),
      StickyNote(
          id: 'n2',
          text: 'Design\nreview',
          dx: 8,
          dy: 92,
          weekSlot: 1,
          priority: Priority.medium),
      StickyNote(
          id: 'n3',
          text: 'Sync with\nclient',
          dx: 8,
          dy: 14,
          weekSlot: 2,
          priority: Priority.low),
      StickyNote(
          id: 'n4',
          text: 'Write\ntests',
          dx: 8,
          dy: 12,
          weekSlot: 1,
          priority: Priority.high),
      StickyNote(
          id: 'n5',
          text: 'Demo\nday',
          dx: 8,
          dy: 96,
          weekSlot: 0,
          priority: Priority.medium),
      StickyNote(
          id: 'n6',
          text: 'Plan next\nsprint',
          dx: 8,
          dy: 90,
          weekSlot: 2,
          priority: Priority.low),
    ];
    for (final n in seed) {
      await box.put(n.id, n);
    }
  });

  testWidgets('capture sticky notes kanban flow', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: BoardScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await shoot(tester, '01-week-board');

    // Open the full-screen zoom editor for a seeded note.
    final box = Hive.box<StickyNote>('notes');
    final note = box.get('n1')!;
    final navKey = tester.element(find.byType(BoardScreen));
    showModalBottomSheet(
      context: navKey,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => NoteZoomSheet(note: note),
    );
    await tester.pumpAndSettle();
    await shoot(tester, '02-zoom-editor');

    // Switch the priority swatch to low (blue) to show the picker interaction.
    // Each swatch is a 36x36 circular Container inside a GestureDetector.
    final swatch = find.byWidgetPredicate((w) =>
        w is Container &&
        w.constraints == const BoxConstraints.tightFor(width: 36, height: 36));
    expect(swatch, findsWidgets);
    await tester.tap(swatch.first, warnIfMissed: false);
    await tester.pumpAndSettle();
    await shoot(tester, '03-priority-picker');
  });
}
