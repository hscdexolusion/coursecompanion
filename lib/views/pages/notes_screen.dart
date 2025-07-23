import 'package:coursecompanion/views/pages/add_note_screen.dart';
import 'package:coursecompanion/views/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:coursecompanion/providers/note_provider.dart';
import 'package:coursecompanion/views/theme/theme_provider.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final noteProvider = Provider.of<NoteProvider>(context);
    final notes = noteProvider.notes;

    final filteredNotes = notes.where((note) {
      final query = _searchQuery.toLowerCase();
      return note.title.toLowerCase().contains(query) ||
          note.content.toLowerCase().contains(query);
    }).toList();


  

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Notes',
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge!.color,
                ),
                decoration: InputDecoration(
                  hintText: "Search notes...",
                  hintStyle: TextStyle(
                    color: Theme.of(context).hintColor,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  
                  // Add visible borders that adapt to the theme (inverse logic)
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white70
                          : Colors.black54,
                      width: 1.2,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                      width: 1.5,
                    ),
                  ),
                ),
              ),

          ),
          Expanded(
            child: filteredNotes.isEmpty
                ? Center(
                    child: Text(
                      "No notes currently available.",
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).textTheme.bodyLarge!.color,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredNotes.length,
                    itemBuilder: (context, index) {
                      final note = filteredNotes[index];
                      return Container(
                        decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.blue, 
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(10),
                            //color: Theme.of(context).cardColor, 
                          ),
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Card(
                          //elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          child: ListTile(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: Text(note.title),
                                  content: SingleChildScrollView(
                                    child: Text(note.content),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context),
                                      child: const Text("Close"),
                                    ),
                                  ],
                                ),
                              );
                            },
                            title: Text(
                              note.title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context)
                                    .textTheme
                                    .titleLarge!
                                    .color,
                              ),
                            ),
                            subtitle: Text(
                              note.content,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .color,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.green),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            AddNoteScreen(noteToEdit: note),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        title: const Text("Delete Note"),
                                        content: const Text(
                                            "Are you sure you want to delete this note?"),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text("Cancel"),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Provider.of<NoteProvider>(
                                                      context,
                                                      listen: false)
                                                  .deleteNote(note);
                                              Navigator.pop(context);
                                            },
                                            child: const Text(
                                              "Delete",
                                              style: TextStyle(
                                                  color: Colors.red),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddNoteScreen()),
          );
        },
        tooltip: 'Add Note',
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
