import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'data/note_store.dart';
import 'ui/board_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(StickyNoteAdapter());
  Hive.registerAdapter(PriorityAdapter());
  await Hive.openBox<StickyNote>('notes');
  runApp(const ProviderScope(child: StickyNotesApp()));
}

class StickyNotesApp extends StatelessWidget {
  const StickyNotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sticky Notes Kanban',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFFFFD66B),
        scaffoldBackgroundColor: const Color(0xFFF4E9D2),
      ),
      home: const BoardScreen(),
    );
  }
}
