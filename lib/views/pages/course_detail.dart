import 'package:coursecompanion/providers/course_provider.dart';
import 'package:coursecompanion/views/pages/add_note_screen.dart';
import 'package:coursecompanion/views/pages/edit_course_screen.dart';
import 'package:coursecompanion/views/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as path;
import 'package:coursecompanion/models/course_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:coursecompanion/providers/note_provider.dart';

class CourseDetailPage extends StatefulWidget {
  final Course course;

  const CourseDetailPage({super.key, required this.course});

  @override
  State<CourseDetailPage> createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage> {
  late List<PlatformFile> attachments;

  @override
  void initState() {
    super.initState();
    attachments = widget.course.attachments ?? [];
  }

  Map<String, List<PlatformFile>> groupFiles(List<PlatformFile> files) {
    final Map<String, List<PlatformFile>> grouped = {
      'Documents': [],
      'Images': [],
      'Videos': [],
      'Audios': [],
      'Others': [],
    };

    for (var file in files) {
      final ext = path.extension(file.name).toLowerCase();
      if (['.pdf', '.doc', '.docx', '.txt', '.pptx'].contains(ext)) {
        grouped['Documents']!.add(file);
      } else if (['.png', '.jpg', '.jpeg', '.gif'].contains(ext)) {
        grouped['Images']!.add(file);
      } else if (['.mp4', '.mov', '.avi'].contains(ext)) {
        grouped['Videos']!.add(file);
      } else if (['.mp3', '.wav', '.aac'].contains(ext)) {
        grouped['Audios']!.add(file);
      } else {
        grouped['Others']!.add(file);
      }
    }
    return grouped;
  }

  IconData folderIcon(String type) {
    switch (type) {
      case 'Documents':
        return Icons.folder_open;
      case 'Images':
        return Icons.image;
      case 'Videos':
        return Icons.video_library;
      case 'Audios':
        return Icons.audiotrack;
      default:
        return Icons.insert_drive_file;
    }
  }

  void openFile(PlatformFile file) {
    if (file.path != null) OpenFile.open(file.path);
  }

  Future<void> pickFileForFolder(String folder) async {
    FileType type;
    switch (folder) {
      case 'Documents':
        type = FileType.custom;
        break;
      case 'Images':
        type = FileType.image;
        break;
      case 'Videos':
        type = FileType.video;
        break;
      case 'Audios':
        type = FileType.audio;
        break;
      default:
        type = FileType.any;
    }

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: type == FileType.custom ? FileType.custom : type,
        allowedExtensions: folder == 'Documents' ? ['pdf', 'doc', 'docx', 'txt', 'pptx'] : null,
      );
      if (result != null && result.files.isNotEmpty) {
        setState(() {
          attachments.addAll(result.files);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick files. Please try again.')),
      );
    }
  }

  void _confirmDeleteCourse(BuildContext context, Course course) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Course'),
        content: const Text('Are you sure you want to delete this course? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Provider.of<CourseProvider>(context, listen: false).removeCourse(course.id);
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String formatSchedule(List<Map<String, String>> schedule) {
    if (schedule.isEmpty) return 'Unscheduled';
    return schedule.map((s) => "${s['day']} at ${s['time']}").join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final courseProvider = Provider.of<CourseProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final updatedCourse = courseProvider.courses.firstWhere((c) => c.id == widget.course.id, orElse: () => widget.course);
    final groupedAttachments = groupFiles(attachments);
    final noteProvider = Provider.of<NoteProvider>(context);
    final courseNotes = noteProvider.notes.where((note) => note.course == updatedCourse.title).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(updatedCourse.title),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [updatedCourse.color, updatedCourse.color.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Course',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => EditCourseScreen(course: updatedCourse)),
              );
              setState(() {});
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Delete Course',
            onPressed: () => _confirmDeleteCourse(context, updatedCourse),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text('Course Code: ${updatedCourse.code}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Instructor: ${updatedCourse.instructor}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Schedule: ${formatSchedule(updatedCourse.schedule)}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Divider(thickness: 5, color: Colors.grey),
            Text('Attachments', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ...groupedAttachments.entries.map((entry) {
              final folder = entry.key;
              final files = entry.value;
              return ExpansionTile(
                leading: Icon(folderIcon(folder), color: updatedCourse.color),
                title: Text(folder, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                trailing: IconButton(icon: Icon(Icons.add), onPressed: () => pickFileForFolder(folder)),
                children: files.map((file) {
                  return ListTile(
                    leading: Icon(Icons.insert_drive_file),
                    title: Text(file.name),
                    subtitle: Text("${(file.size / 1024).toStringAsFixed(2)} KB"),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => setState(() => attachments.remove(file)),
                    ),
                    onTap: () => openFile(file),
                  );
                }).toList(),
              );
            }),
            SizedBox(height: 16),
            Divider(thickness: 1),
            ExpansionTile(
              leading: Icon(Icons.note, color: updatedCourse.color),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Notes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: Icon(Icons.add, color: updatedCourse.color),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => AddNoteScreen(course: updatedCourse.title)),
                      );
                    },
                  ),
                ],
              ),
              children: courseNotes.isEmpty
                  ? [Padding(padding: const EdgeInsets.all(12.0), child: Text('No notes found for this course.'))]
                  : courseNotes.map((note) {
                      return ListTile(
                        leading: Icon(Icons.description),
                        title: Text(note.title),
                        subtitle: Text('Created: ${note.createdAt.toLocal().toString().split(' ')[0]}', style: TextStyle(fontSize: 12)),
                        onTap: () => showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: Text(note.title),
                            content: SingleChildScrollView(child: Text(note.content)),
                            actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text("Close"))],
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => AddNoteScreen(course: updatedCourse.title, noteToEdit: note)),
                                );
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => Provider.of<NoteProvider>(context, listen: false).deleteNote(note),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
