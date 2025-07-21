import 'dart:io';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as path;
import 'package:coursecompanion/models/course_model.dart';
import 'package:file_picker/file_picker.dart';

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
      if (['.pdf', '.doc', '.docx', '.txt'].contains(ext)) {
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
    if (file.path != null) {
      OpenFile.open(file.path);
    }
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
        type: type == FileType.custom
            ? FileType.custom
            : type,
        allowedExtensions: folder == 'Documents' ? ['pdf', 'doc', 'docx', 'txt'] : null,
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

  @override
  Widget build(BuildContext context) {
    final groupedAttachments = groupFiles(attachments);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.course.title),
        backgroundColor: widget.course.color,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text('Course Code: ${widget.course.code}', 
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
            SizedBox(height: 8),

            Text('Instructor: ${widget.course.instructor}', 
            style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold)),
            SizedBox(height: 8),

            Text('Schedule: ${widget.course.schedule}', 
            style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
             Divider(
              thickness: 1,
              endIndent: 50,
              color: Colors.grey,
             ),

            Text('Attachments', 
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

            ...groupedAttachments.entries.toList().asMap().entries.map((entry) {
                  final index = entry.key;
                  final folder = entry.value.key;
                  final files = entry.value.value;
                  final isLast = index == groupedAttachments.length - 1;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ExpansionTile(
                        leading: Icon(folderIcon(folder), color: widget.course.color),
                        title: Text(folder, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        trailing: IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () => pickFileForFolder(folder),
                        ),
                        children: files.map((file) {
                          return ListTile(
                            leading: Icon(Icons.insert_drive_file),
                            title: Text(file.name),
                            subtitle: Text("${(file.size / 1024).toStringAsFixed(2)} KB"),
                            trailing: IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text("Delete File"),
                                    content: Text("Are you sure you want to delete this file?"),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text("Cancel"),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          setState(() {
                                            attachments.remove(file);
                                          });
                                          Navigator.pop(context);
                                        },
                                        child: Text("Delete", style: TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            onTap: () => openFile(file),
                          );
                        }).toList(),
      ),
      if (!isLast) Divider(thickness: 1),
    ],
  );
}).toList(),

          ],
        ),
      ),
    );
  }
}
