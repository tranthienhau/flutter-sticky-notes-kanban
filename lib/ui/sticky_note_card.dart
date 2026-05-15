import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/note_store.dart';

class StickyNoteCard extends StatefulWidget {
  final StickyNote note;
  final VoidCallback onRip;
  final double size;

  const StickyNoteCard({
    super.key,
    required this.note,
    required this.onRip,
    this.size = 120,
  });

  @override
  State<StickyNoteCard> createState() => _StickyNoteCardState();
}

class _StickyNoteCardState extends State<StickyNoteCard>
    with SingleTickerProviderStateMixin {
  double _ripProgress = 0;

  @override
  Widget build(BuildContext context) {
    final c = widget.note.priority.color;
    return GestureDetector(
      onVerticalDragUpdate: (d) {
        setState(() {
          _ripProgress =
              (_ripProgress + d.delta.dy.abs() / widget.size).clamp(0.0, 1.0);
        });
        if (_ripProgress > 0.4 && _ripProgress < 0.6) {
          HapticFeedback.selectionClick();
        }
      },
      onVerticalDragEnd: (_) {
        if (_ripProgress > 0.8) {
          widget.onRip();
        } else {
          setState(() => _ripProgress = 0);
        }
      },
      child: Transform.rotate(
        angle: -0.04 + _ripProgress * 0.25,
        child: Container(
          width: widget.size,
          height: widget.size,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: c.withOpacity(1 - _ripProgress * 0.4),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
                offset: Offset(2, 4 - _ripProgress * 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              Text(
                widget.note.text.isEmpty ? 'Tap & hold to edit' : widget.note.text,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600),
              ),
              if (_ripProgress > 0.1)
                Positioned.fill(
                  child: CustomPaint(
                    painter: _RipPainter(_ripProgress),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RipPainter extends CustomPainter {
  final double progress;
  _RipPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..strokeWidth = 2;
    final yLine = size.height * progress;
    final path = Path()..moveTo(0, yLine);
    for (var x = 0.0; x < size.width; x += 8) {
      final dy = (x.toInt() % 16 == 0) ? -3.0 : 3.0;
      path.lineTo(x, yLine + dy);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_RipPainter old) => old.progress != progress;
}
