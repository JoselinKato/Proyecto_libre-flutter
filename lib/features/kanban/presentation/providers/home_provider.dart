import 'package:flutter/material.dart';
import 'package:kanban_app/features/kanban/domain/entities/board_entities.dart';
import 'package:kanban_app/features/kanban/domain/repository/kanban_repository.dart';
import 'package:uuid/uuid.dart';

/// Provider para la página de inicio (lista de tableros).
class HomeProvider extends ChangeNotifier {
  final KanbanRepository repository;
  final Uuid uuid;

  HomeProvider({required this.repository, required this.uuid});

  List<Board> _boards = [];
  List<Board> get boards => _boards;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Carga todos los tableros desde la base de datos.
  Future<void> loadBoards() async {
    _isLoading = true;
    notifyListeners();

    _boards = await repository.getAllBoards();

    _isLoading = false;
    notifyListeners();
  }

  /// Crea un nuevo tablero con columnas por defecto.
  Future<void> createNewBoard(String title) async {
    final newBoard = Board(
      id: uuid.v4(),
      title: title,
      columns: [
        TaskColumn(id: uuid.v4(), title: 'Pendiente', tasks: []),
        TaskColumn(id: uuid.v4(), title: 'En Progreso', tasks: []),
        TaskColumn(id: uuid.v4(), title: 'Hecho', tasks: []),
      ],
    );

    await repository.saveBoard(newBoard);
    await loadBoards(); // Recargar la lista
  }

  /// Elimina un tablero.
  Future<void> deleteBoard(String id) async {
    await repository.deleteBoard(id);
    await loadBoards(); // Recargar la lista
  }
}
