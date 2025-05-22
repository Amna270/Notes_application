import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'note_model.dart';

class AddNoteScreen extends StatefulWidget {
  final Note? note;
  final VoidCallback? onDelete; // Add onDelete callback

  const AddNoteScreen({super.key, this.note, this.onDelete});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  int? _selectedCategoryId;

  final List<Map<String, dynamic>> categories = [
    {'id': 1, 'name': 'Work'},
    {'id': 2, 'name': 'Personal'},
    {'id': 3, 'name': 'Ideas'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleCtrl.text = widget.note!.title;
      _contentCtrl.text = widget.note!.content;
      _selectedCategoryId = widget.note!.categoryId;
    }
  }

  void _saveNote() async {
    if (_formKey.currentState!.validate() && _selectedCategoryId != null) {
      final newNote = Note(
        id: widget.note?.id,
        title: _titleCtrl.text,
        content: _contentCtrl.text,
        categoryId: _selectedCategoryId!,
      );

      if (widget.note == null) {
        await DBHelper().insertNote(newNote.toMap());
      } else {
        await DBHelper().updateNote(newNote.toMap());
      }

      if (mounted) Navigator.pop(context);
    }
  }

  void _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirmed == true) {
      if (widget.note?.id != null) {
        await DBHelper().deleteNote(widget.note!.id!);
        widget.onDelete?.call(); // Call the passed onDelete callback if any
        if (mounted) Navigator.pop(context); // Pop back after deletion
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF5EC), // Soft green background
      appBar: AppBar(
        title: Text(
          widget.note == null ? 'Add Note' : 'Edit Note',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF6DBF67), // Soft green
        actions: [
          if (widget.note != null) // Show delete icon only if editing existing note
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _confirmDelete,
              tooltip: 'Delete Note',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 5,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Task Name',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _titleCtrl,
                        decoration: InputDecoration(
                          hintText: 'Enter task name',
                          filled: true,
                          fillColor: const Color(0xFFF6F8FA),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (val) =>
                            val == null || val.isEmpty ? 'Enter title' : null,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _contentCtrl,
                        decoration: InputDecoration(
                          hintText: 'Enter description',
                          filled: true,
                          fillColor: const Color(0xFFF6F8FA),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        maxLines: 5,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Category',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<int>(
                        value: _selectedCategoryId,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFF6F8FA),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        items: categories
                            .map((cat) => DropdownMenuItem<int>(
                                  value: cat['id'],
                                  child: Text(cat['name']),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategoryId = value!;
                          });
                        },
                        validator: (val) =>
                            val == null ? 'Select a category' : null,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6DBF67),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: _saveNote,
                child: const Text(
                  'Save Note',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
