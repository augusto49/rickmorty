import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../viewmodels/episode_detail_viewmodel.dart';
import '../../data/models/episode.dart';
import '../../data/models/character.dart';
import '../../viewmodels/character_detail_viewmodel.dart';
import '../widgets/skeleton_loader.dart';
import 'package:go_router/go_router.dart';

class EpisodeDetailPage extends StatefulWidget {
  final Episode episode;

  const EpisodeDetailPage({super.key, required this.episode});

  @override
  State<EpisodeDetailPage> createState() => _EpisodeDetailPageState();
}

class _EpisodeDetailPageState extends State<EpisodeDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EpisodeDetailViewModel>().setEpisode(widget.episode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        title: Text(widget.episode.episodeCode),
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Consumer<EpisodeDetailViewModel>(
            builder: (context, viewModel, _) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(widget.episode),
                    const SizedBox(height: 24),
                    const Text(
                      'Personagens',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (viewModel.isLoading)
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isDesktop = constraints.maxWidth > 900;
                          final isTablet = constraints.maxWidth > 600;
                          final crossAxisCount =
                              isDesktop ? 4 : (isTablet ? 3 : 2);

                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  childAspectRatio: 0.8,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                ),
                            itemCount: 6,
                            itemBuilder:
                                (context, index) =>
                                    const CharacterCardSkeleton(),
                          );
                        },
                      )
                    else if (viewModel.characters.isEmpty)
                      const Text(
                        'Nenhum personagem encontrado.',
                        style: TextStyle(color: Colors.grey),
                      )
                    else
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isDesktop = constraints.maxWidth > 900;
                          final isTablet = constraints.maxWidth > 600;
                          final crossAxisCount =
                              isDesktop ? 4 : (isTablet ? 3 : 2);
                          return _buildCharacterGrid(
                            viewModel.characters,
                            crossAxisCount,
                          );
                        },
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Episode episode) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D2D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF00B5CC).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Text(
            episode.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Exibido em: ${episode.airDate}',
            style: TextStyle(color: Colors.grey[400], fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildCharacterGrid(List<Character> characters, int crossAxisCount) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: characters.length,
      itemBuilder: (context, index) {
        final character = characters[index];
        return GestureDetector(
          onTap: () {
            context.read<CharacterDetailViewModel>().setCharacter(character);
            context.push('/characters/detail', extra: character);
          },
          child: Column(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: character.image,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    placeholder:
                        (context, url) => Container(color: Colors.grey[800]),
                    errorWidget:
                        (context, url, error) => const Icon(Icons.error),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                character.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }
}
