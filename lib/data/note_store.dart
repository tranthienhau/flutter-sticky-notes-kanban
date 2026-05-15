import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

enum Priority { low, medium, high }

extension PriorityColor on Priority {
  Color get color => switch (this) {
        Priority.low => const Color(0xFFB8E1FF),
        Priority.medium => const Color(0xFFFFE08A),
        Priority.high => const Color(0xFFFF8A8A),
      };
}

class StickyNote extends HiveObject {
  String id;
  String text;
  double dx;
  double dy;
  int weekSlot;
  Priority priority;
  bool completed;

  StickyNote({
    required this.id,
    required this.text,
    required this.dx,
    required this.dy,
    required this.weekSlot,
    required this.priority,
    this.completed = false,
  });

  factory StickyNote.empty(int slot, Offset pos) => StickyNote(
        id: const Uuid().v4(),
        text: '',
        dx: pos.dx,
        dy: pos.dy,
        weekSlot: slot,
        priority: Priority.medium,
      );
}

class PriorityAdapter extends TypeAdapter<Priority> {
  @override
  final int typeId = 1;

  @override
  Priority read(BinaryReader reader) => Priority.values[reader.readByte()];

  @override
  void write(BinaryWriter writer, Priority obj) =>
      writer.writeByte(obj.index);
}

class StickyNoteAdapter extends TypeAdapter<StickyNote> {
  @override
  final int typeId = 0;

  @override
  StickyNote read(BinaryReader reader) => StickyNote(
        id: reader.readString(),
        text: reader.readString(),
        dx: reader.readDouble(),
        dy: reader.readDouble(),
        weekSlot: reader.readInt(),
        priority: Priority.values[reader.readByte()],
        completed: reader.readBool(),
      );

  @override
  void write(BinaryWriter writer, StickyNote obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.text);
    writer.writeDouble(obj.dx);
    writer.writeDouble(obj.dy);
    writer.writeInt(obj.weekSlot);
    writer.writeByte(obj.priority.index);
    writer.writeBool(obj.completed);
  }
}

class NoteStore extends StateNotifier<List<StickyNote>> {
  NoteStore() : super(Hive.box<StickyNote>('notes').values.toList());

  Box<StickyNote> get _box => Hive.box<StickyNote>('notes');

  Future<void> add(StickyNote n) async {
    await _box.put(n.id, n);
    state = _box.values.toList();
  }

  Future<void> update(StickyNote n) async {
    await n.save();
    state = _box.values.toList();
  }

  Future<void> remove(String id) async {
    await _box.delete(id);
    state = _box.values.toList();
  }
}

final noteStoreProvider =
    StateNotifierProvider<NoteStore, List<StickyNote>>((ref) => NoteStore());
