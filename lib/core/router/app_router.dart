import 'package:go_router/go_router.dart';
import 'package:kanban_app/features/kanban/presentation/pages/board_detail_page.dart';
import 'package:kanban_app/features/kanban/presentation/pages/home_page.dart';

/// Configuración de GoRouter para la navegación.
final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // Muestra la lista de tableros
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
    ),

    // Muestra un tablero específico
    GoRoute(
      path: '/board/:id',
      builder: (context, state) {
        final boardId = state.pathParameters['id'];

        // Manejo de error si el ID es nulo
        if (boardId == null) {
          return const HomePage();
        }

        return BoardDetailPage(boardId: boardId);
      },
    ),
  ],
);
