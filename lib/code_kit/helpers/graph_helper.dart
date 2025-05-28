import 'dart:io';
import 'dart:ui';
import 'package:path/path.dart' as p;
class GraphHelper{
  List<Map<FileSystemEntity, int>> makeNodes({required String currentPath}){
    final List<FileSystemEntity> subPaths = Directory(currentPath).listSync(recursive: true);
    // Получаем уровень вложенности
    List<Map<FileSystemEntity, int>> result = getEntitiesWithLevels(subPaths);

    // Печатаем результат
    for (var entry in result) {
      entry.forEach((entity, level) {
        print('Level $level: ${p.basename(entity.path)}');
      });
    }

    return result;

  }

  List<Map<FileSystemEntity, int>> getEntitiesWithLevels(List<FileSystemEntity> entities) {
    List<Map<FileSystemEntity, int>> result = [];

    for (var entity in entities) {
      // Получаем уровень вложенности
      int level = getLevel(entity);

      // Добавляем в результат
      result.add({entity: level});
    }

    return result;
  }

  int getLevel(FileSystemEntity entity) {
    // Получаем путь к объекту
    String path = entity.path;

    // Считаем количество слешей, чтобы определить уровень вложенности
    return path.split(Platform.pathSeparator).length - 1; // -1, чтобы исключить корень
  }
}