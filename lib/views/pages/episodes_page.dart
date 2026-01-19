import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../viewmodels/episode_list_viewmodel.dart';
import '../../data/models/episode.dart';
import '../widgets/skeleton_loader.dart';

class EpisodesPage extends StatefulWidget {
  const EpisodesPage({super.key});

  @override
  State<EpisodesPage> createState() => _EpisodesPageState();
}

class _EpisodesPageState extends State<EpisodesPage> {
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<EpisodeListViewModel>().loadMore();
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      final vm = context.read<EpisodeListViewModel>();
      // Heurística: se o formato for S01E01, filtra por código do episódio, senão por nome
      if (RegExp(r'^[sS]\d+[eE]\d+$').hasMatch(query)) {
        vm.setFilter(episode: query, name: '');
      } else {
        vm.setFilter(name: query, episode: '');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        title: const Text(
          'Episódios',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: Consumer<EpisodeListViewModel>(
              builder: (context, viewModel, _) {
                if (viewModel.error != null && viewModel.episodes.isEmpty) {
                  return Center(
                    child: Text(
                      viewModel.error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                if (viewModel.isLoading && viewModel.episodes.isEmpty) {
                  return _buildLoadingSkeleton();
                }

                if (viewModel.isEmpty) {
                  return const Center(
                    child: Text(
                      'Nenhum episódio encontrado.',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final isDesktop = constraints.maxWidth > 900;
                    final crossAxisCount = isDesktop ? 2 : 1;

                    return Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 1200),
                        child: GridView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                childAspectRatio: isDesktop ? 2.5 : 3.0,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                mainAxisExtent: 110,
                              ),
                          itemCount:
                              viewModel.episodes.length +
                              (viewModel.hasMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index >= viewModel.episodes.length) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFF97CE4C),
                                ),
                              );
                            }
                            return _buildEpisodeCard(viewModel.episodes[index]);
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        onChanged: _onSearchChanged,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Buscar (ex: Pilot ou S01E01)',
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: const Icon(Icons.search, color: Color(0xFF00B5CC)),
          filled: true,
          fillColor: const Color(0xFF2D2D2D),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
        ),
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 900;
        final crossAxisCount = isDesktop ? 2 : 1;

        return Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                mainAxisExtent: 110,
              ),
              itemCount: 8,
              itemBuilder: (_, __) => const EpisodeCardSkeleton(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEpisodeCard(Episode episode) {
    return GestureDetector(
      onTap: () {
        context.go('/episodes/detail', extra: episode);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF2D2D2D),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  episode.episodeCode.split('E').last,
                  style: const TextStyle(
                    color: Color(0xFF00B5CC),
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    episode.episodeCode,
                    style: const TextStyle(
                      color: Color(0xFF97CE4C),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    episode.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    episode.airDate,
                    style: TextStyle(color: Colors.grey[500], fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
