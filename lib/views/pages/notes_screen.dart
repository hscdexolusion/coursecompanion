import 'package:coursecompanion/views/pages/add_note_screen.dart';
import 'package:coursecompanion/views/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:coursecompanion/providers/note_provider.dart';
import 'package:coursecompanion/views/theme/theme_provider.dart';

class NotesScreen extends StatelessWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final noteProvider = Provider.of<NoteProvider>(context);
    final notes = noteProvider.notes;

    return Scaffold(
      appBar: CustomAppBar(
        /*backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: const Text('Notes'),
        centerTitle: true,
        
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => themeProvider.toggleTheme(),
          ),
        ],*/
        title: 'Notes',
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge!.color,
              ),
              decoration: InputDecoration(
                hintText: "Search notes...",
                hintStyle: TextStyle(
                  color: Theme.of(context).hintColor,
                ),
                prefixIcon: Icon(Icons.search, color: Theme.of(context).iconTheme.color),
                filled: true,
                fillColor: Theme.of(context).cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: notes.isEmpty
                ? Center(
                    child: Text(
                      "You haven't created any notes yet.\nTap the + button to add your first note.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Theme.of(context).textTheme.bodyLarge!.color),
                    ),
                  )
                : ListView.builder(
                    itemCount: notes.length,
                    itemBuilder: (context, index) {
                      final note = notes[index];
                      return Card(
                        color: Theme.of(context).cardColor,
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          title: Text(
                            note.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).textTheme.titleLarge!.color,
                            ),
                          ),
                          subtitle: Text(
                            note.content,
                            style: TextStyle(
                              color: Theme.of(context).textTheme.bodyMedium!.color,
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
