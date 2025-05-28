import 'package:isar/isar.dart';

class NoteModel {
  final String noteTitle;
  final List<String> links;
  final String path;
  final Id id;

  NoteModel({
    required this.noteTitle,
    required this.links,
    required this.path,
    required this.id,
  });
}
