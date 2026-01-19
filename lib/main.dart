import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/character_list_viewmodel.dart';
import 'viewmodels/character_detail_viewmodel.dart';
import 'viewmodels/episode_list_viewmodel.dart';
import 'viewmodels/location_list_viewmodel.dart';
import 'viewmodels/episode_detail_viewmodel.dart';
import 'viewmodels/location_detail_viewmodel.dart';
import 'router/app_router.dart'; // Added import

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CharacterListViewModel()),
        ChangeNotifierProvider(create: (_) => CharacterDetailViewModel()),
        ChangeNotifierProvider(create: (_) => EpisodeListViewModel()),
        ChangeNotifierProvider(create: (_) => LocationListViewModel()),
        ChangeNotifierProvider(create: (_) => EpisodeDetailViewModel()),
        ChangeNotifierProvider(create: (_) => LocationDetailViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Rick and Morty',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1E1E1E),
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF97CE4C),
          secondary: const Color(0xFF00B5CC),
          surface: const Color(0xFF2D2D2D),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      routerConfig: routerConfig,
    );
  }
}
