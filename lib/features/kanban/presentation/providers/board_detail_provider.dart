import 'package:flutter/material.dart';
import 'package:kanban_app/features/kanban/domain/entities/board_entities.dart';
import 'package:kanban_app/features/kanban/domain/repository/kanban_repository.dart';
import 'package:uuid/uuid.dart';

/// Provider para la página de detalle (un solo tablero).
class BoardDetailProvider extends ChangeNotifier {
  final KanbanRepository repository;
  final Uuid uuid;
  final String boardId;

  BoardDetailProvider({
    required this.repository,
    required this.uuid,
    required this.boardId,
  }) {
    // Cargar el tablero tan pronto como se crea el provider
    loadBoard();
  }

  Board? _board;
  Board? get board => _board;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  /// Carga el tablero específico por su ID.
  Future<void> loadBoard() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    _board = await repository.getBoard(boardId);
    if (_board == null) {
      _error = 'No se encontró el tablero.';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Añade una nueva tarea a una columna específica.
  Future<void> addTask(String columnId, String title) async {
    if (_board == null) return;

    final newTask = TaskCard(
      id: uuid.v4(),
      title: title,
      description: '', // Se puede añadir un diálogo más complejo
      createdAt: DateTime.now(),
    );

    // Crea un nuevo estado inmutable del tablero
    final updatedColumns = _board!.columns.map((col) {
      if (col.id == columnId) {
        // Añade la nueva tarea a la lista de tareas
        final updatedTasks = [...col.tasks, newTask];
        return TaskColumn(id: col.id, title: col.title, tasks: updatedTasks);
      }
      return col;
    }).toList();

    _board = Board(
      id: _board!.id,
      title: _board!.title,
      columns: updatedColumns,
    );

    // Guardar en la DB y notificar
    await repository.saveBoard(_board!);
    notifyListeners();
  }

  /// Mueve una tarea de una columna a otra.
  Future<void> moveTaskToColumn(
    String oldColumnId,
    String newColumnId,
    int oldTaskIndex,
    int newTaskIndex,
  ) async {
    if (_board == null) return;

    //Encontrar y quitar la tarea de la columna antigua
    TaskCard? taskToMove;
    List<TaskColumn> tempColumns = [];

    for (var col in _board!.columns) {
      if (col.id == oldColumnId) {
        List<TaskCard> updatedTasks = List.from(col.tasks);
        taskToMove = updatedTasks.removeAt(oldTaskIndex);
        tempColumns.add(
          TaskColumn(id: col.id, title: col.title, tasks: updatedTasks),
        );
      } else {
        tempColumns.add(col);
      }
    }

    if (taskToMove == null) return; // No se encontró la tarea

    //Encontrar y añadir la tarea a la columna nueva
    List<TaskColumn> finalColumns = [];
    for (var col in tempColumns) {
      if (col.id == newColumnId) {
        List<TaskCard> updatedTasks = List.from(col.tasks);
        updatedTasks.insert(newTaskIndex, taskToMove);
        finalColumns.add(
          TaskColumn(id: col.id, title: col.title, tasks: updatedTasks),
        );
      } else {
        finalColumns.add(col);
      }
    }

    _board = Board(id: _board!.id, title: _board!.title, columns: finalColumns);

    // Guardar y notificar
    await repository.saveBoard(_board!);
    notifyListeners();
  }
}
