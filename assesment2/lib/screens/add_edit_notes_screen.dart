import 'package:flutter/material.dart';
import '../db/db_helper.dart';
import '../models/note.dart';

class AddEditNoteScreen extends StatefulWidget {
  final Note? note;
  const AddEditNoteScreen({super.key, this.note});

  @override
  State<AddEditNoteScreen> createState() => _AddEditNoteScreenState();
}

class _AddEditNoteScreenState extends State<AddEditNoteScreen> {
  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final db = DBHelper();

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      titleCtrl.text = widget.note!.title;
      descCtrl.text = widget.note!.description;
    }
  }

  void _save() async {
    if (titleCtrl.text.isEmpty || descCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All fields are required')),
      );
      return;
    }
    final now = DateTime.now().toString();
    if (widget.note == null) {
      await db.insert(Note(
          title: titleCtrl.text,
          description: descCtrl.text,
          createdAt: now));
    } else {
      await db.update(Note(
          id: widget.note!.id,
          title: titleCtrl.text,
          description: descCtrl.text,
          createdAt: widget.note!.createdAt));
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? 'Add Note' : 'Edit Note'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: 'Note Title'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(labelText: 'Note Description'),
              maxLines: 6,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _save,
                    child: Text(widget.note == null ? 'Save' : 'Update'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
