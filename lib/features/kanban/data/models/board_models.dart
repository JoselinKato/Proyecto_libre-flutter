import 'package:kanban_app/features/kanban/domain/entities/board_entities.dart';

class TaskCardModel {
  final String id;
  final String title;
  final String description;
  final String createdAt; // Guardamos como String

  TaskCardModel({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'createdAt': createdAt,
      };

  factory TaskCardModel.fromJson(Map<String, dynamic> json) => TaskCardModel(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        createdAt: json['createdAt'],
      );

  // Mapeo a Entidad
  TaskCard toEntity() => TaskCard(
        id: id,
        title: title,
        description: description,
        createdAt: DateTime.parse(createdAt),
      );

  // Mapeo desde Entidad
  factory TaskCardModel.fromEntity(TaskCard entity) => TaskCardModel(
        id: entity.id,
        title: entity.title,
        description: entity.description,
        createdAt: entity.createdAt.toIso8601String(),
      );
}

class TaskColumnModel {
  final String id;
  final String title;
  final List<TaskCardModel> tasks;

  TaskColumnModel({required this.id, required this.title, required this.tasks});

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'tasks': tasks.map((t) => t.toJson()).toList(),
      };

  factory TaskColumnModel.fromJson(Map<String, dynamic> json) =>
      TaskColumnModel(
        id: json['id'],
        title: json['title'],
        tasks: (json['tasks'] as List)
            .map((t) => TaskCardModel.fromJson(t))
            .toList(),
      );

  TaskColumn toEntity() => TaskColumn(
        id: id,
        title: title,
        tasks: tasks.map((t) => t.toEntity()).toList(),
      );

  factory TaskColumnModel.fromEntity(TaskColumn entity) => TaskColumnModel(
        id: entity.id,
        title: entity.title,
        tasks: entity.tasks.map((t) => TaskCardModel.fromEntity(t)).toList(),
      );
}

class BoardModel {
  final String id;
  final String title;
  final List<TaskColumnModel> columns;

  BoardModel({required this.id, required this.title, required this.columns});

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'columns': columns.map((c) => c.toJson()).toList(),
      };

  factory BoardModel.fromJson(Map<String, dynamic> json) => BoardModel(
        id: json['id'],
        title: json['title'],
        columns: (json['columns'] as List)
            .map((c) => TaskColumnModel.fromJson(c))
            .toList(),
      );

  Board toEntity() => Board(
        id: id,
        title: title,
        columns: columns.map((c) => c.toEntity()).toList(),
      );

  factory BoardModel.fromEntity(Board entity) => BoardModel(
        id: entity.id,
        title: entity.title,
        columns:
            entity.columns.map((c) => TaskColumnModel.fromEntity(c)).toList(),
      );
}
