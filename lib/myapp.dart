import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:kanban_app/core/router/app_router.dart';
import 'package:kanban_app/features/kanban/data/datasources/kanban_local_datasource.dart';
import 'package:kanban_app/features/kanban/data/repository/kanban_repository_impl.dart';
import 'package:kanban_app/features/kanban/domain/repository/kanban_repository.dart';
import 'package:kanban_app/features/kanban/presentation/providers/home_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:uuid/uuid.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MultiProvider es el widget raíz para la Inyección de Dependencias (DI).
    return MultiProvider(
      providers: [
        Provider<Uuid>(create: (_) => const Uuid()),
        // Se provee la caja de Hive que ya se abrió en main.dart
        Provider<Box>(create: (_) => Hive.box('boards')),

        // El DataSource necesita la 'Box' de Hive para funcionar.
        ProxyProvider<Box, KanbanLocalDataSource>(
          update: (_, box, __) => KanbanLocalDataSourceImpl(boardBox: box),
        ),
        // El Repositorio necesita el 'DataSource' para funcionar.
        ProxyProvider<KanbanLocalDataSource, KanbanRepository>(
          update: (_, localDataSource, __) =>
              KanbanRepositoryImpl(localDataSource: localDataSource),
        ),

        // El HomeProvider (para la lista de tableros) necesita el 'Repository' y 'Uuid'.
        ChangeNotifierProvider<HomeProvider>(
          create: (context) => HomeProvider(
            repository: context.read<KanbanRepository>(),
            uuid: context.read<Uuid>(),
          ),
          // El BoardDetailProvider se crea en la propia página
          // 'board_detail_page.dart' porque necesita el 'boardId' de la ruta.
        ),
      ],
      child: MaterialApp.router(
        title: 'Kanban App',
        theme: ThemeData(
          colorSchemeSeed: Colors.blue,
          useMaterial3: true,
          brightness: Brightness.light,
        ),
        darkTheme: ThemeData(
          colorSchemeSeed: Colors.blue,
          useMaterial3: true,
          brightness: Brightness.dark,
        ),
        locale: const Locale('es', 'ES'),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('es', 'ES'),
        ],
        routerConfig: appRouter,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
