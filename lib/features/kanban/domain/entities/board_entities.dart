import 'package:flutter/foundation.dart'; // Para @immutable

/// Entidad para una tarjeta de tarea.
@immutable
class TaskCard {
  final String id;
  final String title;
  final String description;
  final DateTime createdAt;

  const TaskCard({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
  });
}

/// Entidad para una columna del tablero.
@immutable
class TaskColumn {
  final String id;
  final String title;
  final List<TaskCard> tasks;

  const TaskColumn({
    required this.id,
    required this.title,
    required this.tasks,
  });
}

/// Entidad principal para un tablero (proyecto).
@immutable
class Board {
  final String id;
  final String title;
  final List<TaskColumn> columns;

  const Board({required this.id, required this.title, required this.columns});
}
