import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../viewmodels/location_detail_viewmodel.dart';
import '../../data/models/location.dart';
import '../../data/models/character.dart';
import '../../viewmodels/character_detail_viewmodel.dart';
import '../widgets/skeleton_loader.dart';
import 'package:go_router/go_router.dart';

class LocationDetailPage extends StatefulWidget {
  final Location location;

  const LocationDetailPage({super.key, required this.location});

  @override
  State<LocationDetailPage> createState() => _LocationDetailPageState();
}

class _LocationDetailPageState extends State<LocationDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LocationDetailViewModel>().setLocation(widget.location);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        title: Text(widget.location.name),
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Consumer<LocationDetailViewModel>(
            builder: (context, viewModel, _) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(widget.location),
                    const SizedBox(height: 24),
                    const Text(
                      'Residentes',
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
                    else if (viewModel.residents.isEmpty)
                      const Text(
                        'Nenhum residente encontrado.',
                        style: TextStyle(color: Colors.grey),
                      )
                    else
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isDesktop = constraints.maxWidth > 900;
                          final isTablet = constraints.maxWidth > 600;
                          final crossAxisCount =
                              isDesktop ? 4 : (isTablet ? 3 : 2);
                          return _buildResidentGrid(
                            viewModel.residents,
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

  Widget _buildHeader(Location location) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D2D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          const Icon(Icons.public, color: Colors.orange, size: 48),
          const SizedBox(height: 16),
          Text(
            location.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${location.type} • ${location.dimension}',
            style: TextStyle(color: Colors.grey[400], fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildResidentGrid(List<Character> residents, int crossAxisCount) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: residents.length,
      itemBuilder: (context, index) {
        final character = residents[index];
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
