import 'dart:io';
import 'dart:ui';

import 'package:equatable/equatable.dart';

abstract class DirectoryEvent extends Equatable {
  const DirectoryEvent();

  @override
  List<Object?> get props => [];
}

class ImportNotes extends DirectoryEvent {}

class ChangeGraphPath extends DirectoryEvent {
  final String path;

  ChangeGraphPath({required this.path});
}

class FetchDirectory extends DirectoryEvent {
  final String path;
  final String? title;

  const FetchDirectory({
    required this.path,
    this.title,
  });

  @override
  List<Object?> get props => [path];
}

class ToggleFolder extends DirectoryEvent {
  final String path;

  const ToggleFolder(this.path);

  @override
  List<Object?> get props => [path];
}

class SearchDirectory extends DirectoryEvent {
  final String rootPath;
  final String query;

  const SearchDirectory(this.rootPath, this.query);

  @override
  List<Object?> get props => [rootPath, query];
}
