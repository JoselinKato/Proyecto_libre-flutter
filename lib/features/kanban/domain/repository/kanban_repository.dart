import 'package:kanban_app/features/kanban/domain/entities/board_entities.dart';

/// Interfaz (contrato) para el repositorio de Kanban.
abstract class KanbanRepository {
  /// Obtiene una lista de todos los tableros.
  Future<List<Board>> getAllBoards();

  /// Obtiene un tablero específico por su ID.
  Future<Board?> getBoard(String id);

  /// Guarda un tablero (crea o actualiza).
  Future<void> saveBoard(Board board);

  /// Elimina un tablero por su ID.
  Future<void> deleteBoard(String id);
}
