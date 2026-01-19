import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../views/pages/home_page.dart';
import '../views/pages/character_list_page.dart';
import '../views/pages/character_detail_page.dart';
import '../views/pages/episodes_page.dart';
import '../views/pages/episode_detail_page.dart';
import '../views/pages/locations_page.dart';
import '../views/pages/location_detail_page.dart';
import '../data/models/character.dart';
import '../data/models/episode.dart';
import '../data/models/location.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

final routerConfig = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/characters',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return HomePage(navigationShell: navigationShell);
      },
      branches: [
        // Aba 1: Personagens
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/characters',
              builder: (context, state) => const CharacterListPage(),
              routes: [
                GoRoute(
                  path: 'detail',
                  builder: (context, state) {
                    final character = state.extra as Character;
                    return CharacterDetailPage(character: character);
                  },
                ),
              ],
            ),
          ],
        ),
        // Aba 2: Episódios
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/episodes',
              builder: (context, state) => const EpisodesPage(),
              routes: [
                GoRoute(
                  path: 'detail',
                  builder: (context, state) {
                    final episode = state.extra as Episode;
                    return EpisodeDetailPage(episode: episode);
                  },
                ),
              ],
            ),
          ],
        ),
        // Aba 3: Locais
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/locations',
              builder: (context, state) => const LocationsPage(),
              routes: [
                GoRoute(
                  path: 'detail',
                  builder: (context, state) {
                    final location = state.extra as Location;
                    return LocationDetailPage(location: location);
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);
