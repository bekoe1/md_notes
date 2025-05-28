import 'package:isar/isar.dart';

abstract class BaseEntity {
  final String title;
  final String path;
  final String id;

  BaseEntity({
    required this.title,
    required this.path,
    required this.id,
  });
}

class NoteDto extends BaseEntity {
  final String noteTitle;
  final List<String> links;
  final String path;
  final String id;

  NoteDto({
    required this.noteTitle,
    required this.links,
    required this.path,
    required this.id,
  }) : super(title: noteTitle, path: path, id: id);
}

class FolderDto extends BaseEntity {
  final String path;
  final String id;
  final String title;
  final List<String> children;

  FolderDto({
    required this.path,
    required this.id,
    required this.title,
    required this.children,
  }) : super(path: path, id: id, title: title);
}
