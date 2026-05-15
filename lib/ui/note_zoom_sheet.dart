import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/note_store.dart';

class NoteZoomSheet extends ConsumerStatefulWidget {
  final StickyNote note;
  const NoteZoomSheet({super.key, required this.note});

  @override
  ConsumerState<NoteZoomSheet> createState() => _NoteZoomSheetState();
}

class _NoteZoomSheetState extends ConsumerState<NoteZoomSheet> {
  late final _ctrl = TextEditingController(text: widget.note.text);
  late Priority _p = widget.note.priority;

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height * 0.85;
    return Hero(
      tag: widget.note.id,
      child: Material(
        color: Colors.transparent,
        child: Container(
          height: h,
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _p.color,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(color: Colors.black38, blurRadius: 16, offset: Offset(0, 8)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  maxLines: null,
                  autofocus: true,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'What needs doing?',
                  ),
                ),
              ),
              Row(
                children: [
                  for (final p in Priority.values)
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _p = p);
                      },
                      child: Container(
                        margin: const EdgeInsets.all(6),
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: p.color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _p == p ? Colors.black : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  const Spacer(),
                  FilledButton(
                    onPressed: () {
                      widget.note
                        ..text = _ctrl.text
                        ..priority = _p;
                      ref.read(noteStoreProvider.notifier).update(widget.note);
                      Navigator.pop(context);
                    },
                    child: const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
