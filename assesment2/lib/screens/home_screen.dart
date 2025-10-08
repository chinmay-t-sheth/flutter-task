import 'package:flutter/material.dart';
import '../db/db_helper.dart';
import '../models/note.dart';
import 'add_edit_note_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final db = DBHelper();
  List<Note> notes = [];
  String search = '';

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final data = await db.getNotes();
    setState(() => notes = data);
  }

  void _deleteNote(int id) async {
    await db.delete(id);
    _loadNotes();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = notes
        .where((n) =>
    n.title.toLowerCase().contains(search.toLowerCase()) ||
        n.description.toLowerCase().contains(search.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Notes'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search...',
                filled: true,
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (val) => setState(() => search = val),
            ),
          ),
        ),
      ),
      body: filtered.isEmpty
          ? const Center(child: Text('No notes found'))
          : ListView.builder(
        itemCount: filtered.length,
        itemBuilder: (context, i) {
          final note = filtered[i];
          return Card(
            child: ListTile(
              title: Text(note.title,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(
                note.description.length > 50
                    ? '${note.description.substring(0, 50)}...'
                    : note.description,
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddEditNoteScreen(note: note),
                          ),
                        );
                        _loadNotes();
                      }),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Delete Note?'),
                            content: const Text(
                                'Are you sure you want to delete this note?'),
                            actions: [
                              TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context),
                                  child: const Text('Cancel')),
                              TextButton(
                                  onPressed: () {
                                    _deleteNote(note.id!);
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Delete')),
                            ],
                          ));
                    },
                  ),
                ],
              ),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddEditNoteScreen(note: note),
                  ),
                );
                _loadNotes();
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditNoteScreen()),
          );
          _loadNotes();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
