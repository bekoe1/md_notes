import 'package:isar/isar.dart';

class FolderModel {
  final String path;
  final Id id;
  final String title;
  final List<String> children;

  FolderModel({
    required this.path,
    required this.id,
    required this.title,
    required this.children,
  });
}
