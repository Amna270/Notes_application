import 'package:flutter/material.dart';
import 'add_note_screen.dart';
import 'db_helper.dart';
import 'note_model.dart';

class NoteListScreen extends StatefulWidget {
  const NoteListScreen({super.key});

  @override
  State<NoteListScreen> createState() => _NoteListScreenState();
}

class _NoteListScreenState extends State<NoteListScreen> {
  List<Note> _notes = [];
  int? _selectedCategory;
  String _searchQuery = '';

  final List<Map<String, dynamic>> categories = [
    {'id': 1, 'name': 'Work'},
    {'id': 2, 'name': 'Personal'},
    {'id': 3, 'name': 'Ideas'},
  ];

  String get _selectedCategoryName {
    if (_selectedCategory == null) return 'All Notes';
    return categories.firstWhere((c) => c['id'] == _selectedCategory)['name'];
  }

  @override
  void initState() {
    super.initState();
    _insertDefaultCategories();
    _loadNotes();
  }

  Future<void> _insertDefaultCategories() async {
    for (var category in categories) {
      await DBHelper().insertCategory(category['name']);
    }
  }

  Future<void> _loadNotes() async {
    final noteList = await DBHelper().getNotes(categoryId: _selectedCategory);
    setState(() {
      _notes = noteList
          .map((e) => Note.fromMap(e))
          .where((note) =>
              note.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              note.content.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    });
  }

  void _deleteNote(int id) async {
    await DBHelper().deleteNote(id);
    _loadNotes();
  }

  @override
  Widget build(BuildContext context) {
    final Color calmingGreen = const Color(0xFFA8D5BA);

    return Scaffold(
      backgroundColor: calmingGreen,
      appBar: AppBar(
        title: const Text('My Notes'),
        backgroundColor: const Color(0xFF81C784),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 4,
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                      _loadNotes();
                    },
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      prefixIcon: const Icon(Icons.search, color: Colors.black54),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 4.0, horizontal: 10.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 40,
                  width: 40,
                  child: ElevatedButton(
                    onPressed: () async {
                      int? selected = await showDialog<int>(
                        context: context,
                        builder: (_) => SimpleDialog(
                          title: const Text('Select Category'),
                          children: [
                            SimpleDialogOption(
                              child: const Text('All'),
                              onPressed: () => Navigator.pop(context, null),
                            ),
                            ...categories.map((cat) => SimpleDialogOption(
                                  child: Text(cat['name']),
                                  onPressed: () =>
                                      Navigator.pop(context, cat['id']),
                                )),
                          ],
                        ),
                      );
                      setState(() {
                        _selectedCategory = selected;
                      });
                      _loadNotes();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    child: const Icon(Icons.category, size: 20),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Added heading below search bar to show selected category
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _selectedCategoryName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: _notes.isEmpty
                  ? const Center(
                      child: Text('No notes available',
                          style: TextStyle(color: Colors.black54)),
                    )
                  : GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 3 / 2,
                      ),
                      itemCount: _notes.length,
                      itemBuilder: (_, index) {
                        final note = _notes[index];
                        final catName = categories
                            .firstWhere((c) => c['id'] == note.categoryId)['name'];
                        
                        return GestureDetector(
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AddNoteScreen(
                                  note: note,
                                  onDelete: () => _deleteNote(note.id!),
                                ),
                              ),
                            );
                            _loadNotes();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  note.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Expanded(
                                  child: Text(
                                    note.content,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: Colors.black87),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Category: $catName',
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.black54),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF388E3C),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddNoteScreen()),
          );
          _loadNotes();
        },
        child: const Icon(Icons.note_add, color: Colors.white,),
      ),
    );
  }
}
