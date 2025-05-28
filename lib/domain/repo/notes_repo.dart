import 'package:md_notes/data/models/note_model.dart';
import 'package:md_notes/domain/dto/note_dto.dart';

abstract class NotesRepo {
  Future<void> importNotes(String appNotesPath);

  Future<void> exportAllNotesToZip(String appNotesPath);
}
