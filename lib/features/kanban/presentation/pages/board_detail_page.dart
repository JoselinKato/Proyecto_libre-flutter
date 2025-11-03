import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kanban_app/features/kanban/domain/entities/board_entities.dart';
import 'package:kanban_app/features/kanban/domain/repository/kanban_repository.dart';
import 'package:kanban_app/features/kanban/presentation/providers/board_detail_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class BoardDetailPage extends StatelessWidget {
  final String boardId;
  const BoardDetailPage({super.key, required this.boardId});

  @override
  Widget build(BuildContext context) {
    // Creamos el Provider aquí, en la propia página,
    // pasándole el boardId que recibimos del router.
    return ChangeNotifierProvider<BoardDetailProvider>(
      create: (context) => BoardDetailProvider(
        repository: context.read<KanbanRepository>(),
        uuid: context.read<Uuid>(),
        boardId: boardId,
      ),
      child: Consumer<BoardDetailProvider>(
        builder: (context, provider, _) {
          // Usamos Consumer para reconstruir solo lo necesario
          final theme = Theme.of(context);
          return Scaffold(
            appBar: AppBar(
              title: Text(
                provider.isLoading
                    ? 'Cargando...'
                    : provider.board?.title ?? 'Error',
              ),
            ),
            body: _buildSimpleKanbanBody(context, provider, theme),
            floatingActionButton:
                provider.board != null && provider.board!.columns.isNotEmpty
                    ? FloatingActionButton(
                        // Añade a la primera columna por defecto
                        onPressed: () => _showAddTaskDialog(
                          context,
                          provider.board!.columns.first.id,
                        ),
                        tooltip: 'Nueva Tarea',
                        child: const Icon(Icons.add),
                      )
                    : null,
          );
        },
      ),
    );
  }

  Widget _buildSimpleKanbanBody(
    BuildContext context,
    BoardDetailProvider provider,
    ThemeData theme,
  ) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.error != null) {
      return Center(child: Text('Error: ${provider.error}'));
    }
    if (provider.board == null) {
      return const Center(child: Text('No se encontró el tablero.'));
    }

    // ListView horizontal para las columnas
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(16.0),
      itemCount: provider.board!.columns.length,
      itemBuilder: (context, index) {
        final column = provider.board!.columns[index];
        // Ancho para las columnas
        return SizedBox(
          width: 300,
          child: _buildKanbanColumn(context, column, theme),
        );
      },
    );
  }

  Widget _buildKanbanColumn(
    BuildContext context,
    TaskColumn column,
    ThemeData theme,
  ) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado de Columna
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      column.title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    tooltip: 'Añadir tarea',
                    onPressed: () => _showAddTaskDialog(context, column.id),
                  ),
                ],
              ),
            ),
            const Divider(),
            // Lista de Tareas
            Expanded(
              child: ListView.builder(
                itemCount: column.tasks.length,
                itemBuilder: (context, index) {
                  final task = column.tasks[index];
                  return _buildTaskCard(context, column.id, task, theme);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskCard(
    BuildContext context,
    String columnId,
    TaskCard task,
    ThemeData theme,
  ) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainer,
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        title: Text(task.title),
        subtitle: Text(
          'Creado: ${DateFormat.yMMMd('es_ES').format(task.createdAt)}',
        ),
        onTap: () {
          // Al tocar, mostramos opciones (Editar, Mover, Eliminar)
          _showTaskOptionsDialog(context, columnId, task);
        },
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context, String columnId) {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Nueva Tarea'),
          content: TextField(
            controller: textController,
            decoration: const InputDecoration(hintText: 'Nombre de la tarea'),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                if (textController.text.isNotEmpty) {
                  // Usamos context.read porque estamos en un callback
                  context.read<BoardDetailProvider>().addTask(
                        columnId,
                        textController.text,
                      );
                  Navigator.of(dialogContext).pop();
                }
              },
              child: const Text('Crear'),
            ),
          ],
        );
      },
    );
  }

  void _showTaskOptionsDialog(
    BuildContext context,
    String columnId,
    TaskCard task,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        // Obtenemos el provider SIN escuchar, solo para leer datos
        final provider = context.read<BoardDetailProvider>();
        final allColumns = provider.board?.columns ?? [];

        return AlertDialog(
          title: Text(task.title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Mover a:'),
              // Creamos botones para mover a otras columnas
              ...allColumns.where((col) => col.id != columnId).map((col) {
                return TextButton(
                  child: Text(col.title),
                  onPressed: () {
                    // Buscamos el índice de la tarea
                    final oldColumn = provider.board!.columns.firstWhere(
                      (c) => c.id == columnId,
                    );
                    final oldTaskIndex = oldColumn.tasks.indexWhere(
                      (t) => t.id == task.id,
                    );

                    if (oldTaskIndex != -1) {
                      provider.moveTaskToColumn(
                        columnId, // oldColumnId
                        col.id, // newColumnId
                        oldTaskIndex, // oldTaskIndex
                        0, // newTaskIndex (la movemos al inicio)
                      );
                      Navigator.of(dialogContext).pop();
                    }
                  },
                );
              }),
              const Divider(),
              TextButton.icon(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tarea eliminada.'),
                    ),
                  );
                },
                icon: Icon(
                  Icons.delete_outline,
                  color: Theme.of(context).colorScheme.error,
                ),
                label: Text(
                  'Eliminar Tarea',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }
}
