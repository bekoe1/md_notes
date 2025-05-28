import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:md_notes/code_kit/enums/app_enums.dart';

class DirectoryState extends Equatable {
  final Map<String, List<String>> folderContents;
  final Set<String> openFolders;
  final bool isLoading;
  final String? errorMessage;
  final bool isSearching;
  final List<String>? searchResults;
  final String? searchErrorMessage;
  final String graphPath;
  final List<Map<FileSystemEntity, int>>? nodesWithLevels;
  final BlocStatesEnum status;

  const DirectoryState({
    this.folderContents = const {},
    this.openFolders = const {},
    this.isLoading = false,
    this.errorMessage,
    this.isSearching = false,
    this.searchResults,
    this.searchErrorMessage,
    required this.graphPath,
    this.nodesWithLevels,
    required this.status,
  });

  DirectoryState copyWith({
    Map<String, List<String>>? folderContents,
    Set<String>? openFolders,
    bool? isLoading,
    String? errorMessage,
    bool? isSearching,
    List<String>? searchResults,
    String? searchErrorMessage,
    String? graphPath,
    List<Map<FileSystemEntity, int>>? nodesWithLevels,
    BlocStatesEnum? status,
  }) {
    return DirectoryState(
      folderContents: folderContents ?? this.folderContents,
      openFolders: openFolders ?? this.openFolders,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isSearching: isSearching ?? this.isSearching,
      searchResults: searchResults ?? this.searchResults,
      searchErrorMessage: searchErrorMessage,
      graphPath: graphPath ?? this.graphPath,
      nodesWithLevels: nodesWithLevels ?? this.nodesWithLevels,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
        folderContents,
        openFolders,
        isLoading,
        errorMessage,
        isSearching,
        searchResults,
        searchErrorMessage,
        graphPath,
        status,
      ];
}
