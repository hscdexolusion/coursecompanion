
class Note {
  final String title;
  final String content;
  final DateTime createdAt;
  final String course;

  Note({
    required this.title,
    required this.content,
    required this.createdAt,
     this.course='unassigned',
  });
}
