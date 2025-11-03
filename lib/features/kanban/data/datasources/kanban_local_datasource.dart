import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:kanban_app/features/kanban/data/models/board_models.dart';

/// Interfaz para la fuente de datos local.
abstract class KanbanLocalDataSource {
  Future<List<BoardModel>> getAllBoards();
  Future<BoardModel?> getBoard(String id);
  Future<void> saveBoard(BoardModel board);
  Future<void> deleteBoard(String id);
}

/// Implementación de la fuente de datos con Hive.
class KanbanLocalDataSourceImpl implements KanbanLocalDataSource {
  final Box boardBox;

  KanbanLocalDataSourceImpl({required this.boardBox});

  @override
  Future<List<BoardModel>> getAllBoards() async {
    try {
      // Mapea todos los valores (strings JSON) en la caja
      return boardBox.values.map((boardJson) {
        return BoardModel.fromJson(jsonDecode(boardJson));
      }).toList();
    } catch (e) {
      // En caso de error de deserialización, devuelve lista vacía
      print('Error al cargar tableros: $e');
      return [];
    }
  }

  @override
  Future<BoardModel?> getBoard(String id) async {
    try {
      final boardJson = boardBox.get(id);
      if (boardJson != null) {
        return BoardModel.fromJson(jsonDecode(boardJson));
      }
      return null;
    } catch (e) {
      print('Error al cargar tablero $id: $e');
      return null;
    }
  }

  @override
  Future<void> saveBoard(BoardModel board) async {
    // Codifica el modelo a un string JSON
    final boardJson = jsonEncode(board.toJson());
    // Guarda usando el ID del tablero como clave
    await boardBox.put(board.id, boardJson);
  }

  @override
  Future<void> deleteBoard(String id) async {
    await boardBox.delete(id);
  }
}
