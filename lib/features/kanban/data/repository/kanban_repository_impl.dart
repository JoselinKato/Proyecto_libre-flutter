import 'package:kanban_app/features/kanban/data/datasources/kanban_local_datasource.dart';
import 'package:kanban_app/features/kanban/data/models/board_models.dart';
import 'package:kanban_app/features/kanban/domain/entities/board_entities.dart';
import 'package:kanban_app/features/kanban/domain/repository/kanban_repository.dart';

/// Implementación del Repositorio.
/// Conecta la fuente de datos (DataSource) con el dominio (UseCases).

/// Se encarga de mapear entre Modelos (data) y Entidades (domain).
class KanbanRepositoryImpl implements KanbanRepository {
  final KanbanLocalDataSource localDataSource;

  KanbanRepositoryImpl({required this.localDataSource});

  @override
  Future<List<Board>> getAllBoards() async {
    try {
      final boardModels = await localDataSource.getAllBoards();
      // Mapea de Model (datos) a Entity (dominio)
      return boardModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      // Manejo básico de errores
      print('Error en Repository (getAllBoards): $e');
      return [];
    }
  }

  @override
  Future<Board?> getBoard(String id) async {
    try {
      final boardModel = await localDataSource.getBoard(id);
      // Mapea de Model (datos) a Entity (dominio) si no es nulo
      return boardModel?.toEntity();
    } catch (e) {
      print('Error en Repository (getBoard): $e');
      return null;
    }
  }

  @override
  Future<void> saveBoard(Board board) async {
    try {
      // Mapea de Entity (dominio) a Model (datos)
      final boardModel = BoardModel.fromEntity(board);
      await localDataSource.saveBoard(boardModel);
    } catch (e) {
      print('Error en Repository (saveBoard): $e');
    }
  }

  @override
  Future<void> deleteBoard(String id) async {
    try {
      await localDataSource.deleteBoard(id);
    } catch (e) {
      print('Error en Repository (deleteBoard): $e');
    }
  }
}
