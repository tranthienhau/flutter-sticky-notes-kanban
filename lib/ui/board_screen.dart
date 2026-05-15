import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/note_store.dart';
import 'sticky_note_card.dart';
import 'note_zoom_sheet.dart';

const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _slotWidth = 140.0;
const _laneHeight = 220.0;

class BoardScreen extends ConsumerWidget {
  const BoardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(noteStoreProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wall Planner'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: _slotWidth * 7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _WeekHeader(),
              SizedBox(
                height: _laneHeight,
                child: Stack(
                  children: [
                    _LaneDividers(),
                    ...notes.map((n) => SizedBox(
                          key: ValueKey(n.id),
                          child: _DraggableNote(note: n),
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          HapticFeedback.mediumImpact();
          final n = StickyNote.empty(0, const Offset(20, 20));
          await ref.read(noteStoreProvider.notifier).add(n);
          if (context.mounted) _openZoom(context, ref, n);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

void _openZoom(BuildContext context, WidgetRef ref, StickyNote n) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => NoteZoomSheet(note: n),
  );
}

class _WeekHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final d in _days)
          SizedBox(
            width: _slotWidth,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Text(d,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
      ],
    );
  }
}

class _LaneDividers extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        7,
        (i) => Container(
          width: _slotWidth,
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(color: Colors.brown.withOpacity(0.15)),
            ),
          ),
        ),
      ),
    );
  }
}

class _DraggableNote extends ConsumerStatefulWidget {
  final StickyNote note;
  const _DraggableNote({required this.note});

  @override
  ConsumerState<_DraggableNote> createState() => _DraggableNoteState();
}

class _DraggableNoteState extends ConsumerState<_DraggableNote> {
  late double _dx = widget.note.dx + widget.note.weekSlot * _slotWidth;
  late double _dy = widget.note.dy;
  bool _dragging = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration:
          _dragging ? Duration.zero : const Duration(milliseconds: 220),
      curve: Curves.easeOutBack,
      left: _dx,
      top: _dy,
      child: GestureDetector(
        onPanStart: (_) {
          HapticFeedback.selectionClick();
          setState(() => _dragging = true);
        },
        onPanUpdate: (d) => setState(() {
          _dx += d.delta.dx;
          _dy += d.delta.dy;
        }),
        onPanEnd: (_) {
          final slot = (_dx / _slotWidth).round().clamp(0, 6);
          HapticFeedback.mediumImpact();
          setState(() {
            _dx = slot * _slotWidth + 8;
            _dragging = false;
          });
          widget.note
            ..weekSlot = slot
            ..dx = 8
            ..dy = _dy;
          ref.read(noteStoreProvider.notifier).update(widget.note);
        },
        onLongPress: () => _zoom(context),
        child: StickyNoteCard(
          note: widget.note,
          onRip: () async {
            HapticFeedback.heavyImpact();
            await Future.delayed(const Duration(milliseconds: 150));
            HapticFeedback.heavyImpact();
            ref.read(noteStoreProvider.notifier).remove(widget.note.id);
          },
        ),
      ),
    );
  }

  void _zoom(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => NoteZoomSheet(note: widget.note),
    );
  }
}
