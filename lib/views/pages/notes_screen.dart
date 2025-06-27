import 'package:coursecompanion/views/pages/home_screen.dart';
import 'package:flutter/material.dart';
import '../widgets/empty_state.dart';
//import 'add_note_screen.dart';

class NotesScreen extends StatelessWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notes'), centerTitle: true),
      body: Column(
        children: const [
          Padding(
            padding: EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search notes...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: EmptyState(
              icon: Icons.description,
              message: "You haven't created any notes yet.\nTap the + button to add your first note.",
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}