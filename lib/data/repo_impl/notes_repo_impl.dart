import 'dart:developer';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:md_notes/domain/repo/notes_repo.dart';
import 'package:path/path.dart' as p;

class NotesRepoImpl implements NotesRepo {
  NotesRepoImpl();

  @override
  Future<void> exportAllNotesToZip(String appNotesPath) async {}

  @override
  Future<void> importNotes(String appNotesPath) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        dialogTitle: 'Выберите файлы',
        allowMultiple: true,
      );

      if (result == null || result.files.isEmpty) return;

      final platformFiles = result.files;

      // Если выбран 1 файл и это ZIP
      if (platformFiles.length == 1 &&
          p.extension(platformFiles.first.path ?? '').toLowerCase() == '.zip') {
        final file = File(platformFiles.first.path!);
        await _importFromZip(file, appNotesPath);
      }
      // Если выбрано несколько файлов или 1 не-ZIP файл
      else {
        // Конвертируем PlatformFile в File и фильтруем null
        final files = platformFiles
            .where((pf) => pf.path != null)
            .map((pf) => File(pf.path!))
            .toList();

        await _importMdFiles(files, appNotesPath);
      }
    } catch (e) {
      log('Ошибка импорта: $e');
      // Можно добавить показ ошибки пользователю
      // ScaffoldMessenger.of(context).showSnackBar(...);
    }
  }

  bool _isArchiveByExtension(File file) {
    final ext = p.extension(file.path).toLowerCase();
    return ['.zip', '.rar', '.7z', '.tar', '.gz'].contains(ext);
  }

  Future<void> _importFromZip(File zipFile, String targetDirPath) async {
    try {
      // 1. Чтение и распаковка архива
      final bytes = await zipFile.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);

      // 2. Фильтрация только .md файлов
      final mdFiles = archive.files
          .where((file) =>
              file.isFile && p.extension(file.name).toLowerCase() == '.md')
          .toList();

      // 3. Преобразование путей и импорт
      for (final file in mdFiles) {
        // Нормализация пути (удаление ведущих слешей)
        final relativePath = file.name.replaceAll(RegExp(r'^/+|\\+'), '');
        final fullPath = p.join(targetDirPath, relativePath);

        // Создание поддиректорий
        await Directory(p.dirname(fullPath)).create(recursive: true);

        // Запись файла
        await File(fullPath).writeAsBytes(file.content as List<int>);
      }
    } catch (e) {
      throw Exception('Ошибка импорта ZIP: $e');
    }
  }

  /// Импорт списка .md файлов с сохранением структуры
  Future<void> _importMdFiles(List<File> files, String targetDirPath) async {
    for (final file in files) {
      if (p.extension(file.path).toLowerCase() != '.md') continue;

      try {
        final relativePath = p.relative(file.path, from: p.dirname(file.path));
        final fullPath = p.join(targetDirPath, p.basename(file.path));

        await Directory(p.dirname(fullPath)).create(recursive: true);
        print(fullPath);
        await file.copy(fullPath);
      } catch (e) {
        throw Exception('Ошибка импорта файла ${file.path}: $e');
      }
    }
  }
}
