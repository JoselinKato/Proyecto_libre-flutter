import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kanban_app/features/kanban/presentation/providers/home_provider.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Cargar los tableros al iniciar la página
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeProvider>().loadBoards();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Mis Tableros Kanban')),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.boards.isEmpty
              ? _buildEmptyState(context)
              : _buildBoardList(context, provider),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddBoardDialog(context),
        tooltip: 'Nuevo Tablero',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBoardList(BuildContext context, HomeProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: provider.boards.length,
      itemBuilder: (context, index) {
        final board = provider.boards[index];
        return Card(
          elevation: 0,
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          margin: const EdgeInsets.symmetric(vertical: 6.0),
          child: ListTile(
            title: Text(
              board.title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            subtitle: Text('${board.columns.length} columnas'),
            trailing: IconButton(
              icon: Icon(
                Icons.delete_outline,
                color: Theme.of(context).colorScheme.error,
              ),
              onPressed: () => _showDeleteConfirmDialog(context, board.id),
            ),
            onTap: () {
              //go_router con parámetros
              context.push('/board/${board.id}');
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.dashboard_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.secondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No tienes tableros',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Presiona el botón + para crear tu primer tablero.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  void _showAddBoardDialog(BuildContext context) {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nuevo Tablero'),
          content: TextField(
            controller: textController,
            decoration: const InputDecoration(hintText: 'Nombre del tablero'),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                if (textController.text.isNotEmpty) {
                  context.read<HomeProvider>().createNewBoard(
                        textController.text,
                      );
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Crear'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, String boardId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar Tablero'),
          content: const Text(
            '¿Estás seguro de que quieres eliminar este tablero? Esta acción no se puede deshacer.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton.tonal(
              onPressed: () {
                context.read<HomeProvider>().deleteBoard(boardId);
                Navigator.of(context).pop();
              },
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.errorContainer,
              ),
              child: Text(
                'Eliminar',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
