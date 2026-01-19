import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/character.dart';
import '../../data/models/location.dart';
import '../../viewmodels/character_detail_viewmodel.dart';
import '../widgets/skeleton_loader.dart';

/// Detail page showing full character information.
class CharacterDetailPage extends StatefulWidget {
  final Character character;

  const CharacterDetailPage({super.key, required this.character});

  @override
  State<CharacterDetailPage> createState() => _CharacterDetailPageState();
}

class _CharacterDetailPageState extends State<CharacterDetailPage> {
  @override
  void initState() {
    super.initState();
    // Initialize viewModel with the character data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CharacterDetailViewModel>().setCharacter(widget.character);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: CustomScrollView(
            slivers: [
              _buildSliverAppBar(context),
              SliverToBoxAdapter(child: _buildContent(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 400,
      pinned: true,
      backgroundColor: const Color(0xFF1E1E1E),
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black54,
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Hero(
          tag: 'character-${widget.character.id}',
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: widget.character.image,
                fit: BoxFit.cover,
                placeholder:
                    (context, url) => Container(
                      color: Colors.grey[800],
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF97CE4C),
                        ),
                      ),
                    ),
                errorWidget:
                    (context, url, error) => Container(
                      color: Colors.grey[800],
                      child: const Icon(
                        Icons.person,
                        size: 100,
                        color: Colors.grey,
                      ),
                    ),
              ),
              // Gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                    ],
                    stops: const [0.5, 1.0],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name (Header)
          Text(
            widget.character.name,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 24),

          // Core Stats Grid (Status, Species, Gender)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _InfoCard(
                  icon: Icons.favorite,
                  iconColor: _getStatusColor(widget.character.status),
                  title: 'Status',
                  value: _translateStatus(widget.character.status),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InfoCard(
                  icon: Icons.category,
                  iconColor: const Color(0xFF00B5CC),
                  title: 'Espécie',
                  value: widget.character.species,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _InfoCard(
                  icon: Icons.person,
                  iconColor: const Color(0xFF97CE4C),
                  title: 'Gênero',
                  value: _translateGender(widget.character.gender),
                ),
              ),
              // Spacer to keep layout balanced if we don't have a 4th item here
              const SizedBox(width: 12),
              const Expanded(child: SizedBox()),
            ],
          ),

          const SizedBox(height: 24),

          // Interactive Origin & Location
          Consumer<CharacterDetailViewModel>(
            builder: (context, viewModel, _) {
              return Column(
                children: [
                  _buildInteractiveInfoCard(
                    context,
                    icon: Icons.public,
                    iconColor: Colors.orange,
                    title: 'Origem',
                    value: widget.character.origin.name,
                    location: viewModel.originLocation,
                  ),
                  const SizedBox(height: 12),
                  _buildInteractiveInfoCard(
                    context,
                    icon: Icons.location_on,
                    iconColor: Colors.purple,
                    title: 'Última Localização',
                    value: widget.character.location.name,
                    location: viewModel.currentLocation,
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 32),

          const Text(
            'Episódios',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),

          // Episodes list - Vertical
          Consumer<CharacterDetailViewModel>(
            builder: (context, viewModel, _) {
              // Loading State with Skeletons
              if (viewModel.isLoadingEpisodes) {
                return ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: 5, // Show 5 skeletons
                  separatorBuilder:
                      (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) => const EpisodeCardSkeleton(),
                );
              }

              if (viewModel.episodes.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.tv_off, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        'Nenhum episódio encontrado.',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: viewModel.episodes.length,
                separatorBuilder:
                    (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final episode = viewModel.episodes[index];
                  return _buildEpisodeItem(context, episode);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEpisodeItem(BuildContext context, episode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2B2B2B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFF97CE4C).withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              episode.episodeCode,
              style: const TextStyle(
                color: Color(0xFF97CE4C),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  episode.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  episode.airDate,
                  style: TextStyle(color: Colors.grey[400], fontSize: 13),
                ),
              ],
            ),
          ),
          Icon(Icons.play_circle_outline, color: Colors.grey[600], size: 28),
        ],
      ),
    );
  }

  Widget _buildInteractiveInfoCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    Location? location,
  }) {
    final bool isInteractable = location != null;
    final bool isUnknown = value.toLowerCase() == 'unknown';

    return GestureDetector(
      onTap: () {
        if (isInteractable) {
          context.push('/locations/detail', extra: location);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          // Subtle gradient for premium feel
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [const Color(0xFF2D2D2D), const Color(0xFF252525)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                isInteractable
                    ? iconColor.withValues(alpha: 0.3)
                    : Colors.white.withValues(alpha: 0.05),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isUnknown ? 'Desconhecido' : value,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (location != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '${location.type} • ${location.dimension}',
                          style: TextStyle(
                            fontSize: 12,
                            color: iconColor.withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (isInteractable)
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: iconColor.withValues(alpha: 0.5),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'alive':
        return const Color(0xFF55CC44);
      case 'dead':
        return const Color(0xFFD63D2E);
      default:
        return Colors.grey;
    }
  }

  String _translateStatus(String status) {
    switch (status.toLowerCase()) {
      case 'alive':
        return 'Vivo';
      case 'dead':
        return 'Morto';
      case 'unknown':
        return 'Desconhecido';
      default:
        return status;
    }
  }

  String _translateGender(String gender) {
    switch (gender.toLowerCase()) {
      case 'male':
        return 'Masculino';
      case 'female':
        return 'Feminino';
      case 'genderless':
        return 'Sem Gênero';
      case 'unknown':
        return 'Desconhecido';
      default:
        return gender;
    }
  }
}

/// Simple info card for stats
class _InfoCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D2D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[400],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
