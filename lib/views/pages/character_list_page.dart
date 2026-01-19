import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../viewmodels/character_list_viewmodel.dart';
import '../widgets/character_card.dart';
import '../widgets/skeleton_loader.dart';

/// Main page displaying the list of Rick and Morty characters.
class CharacterListPage extends StatefulWidget {
  const CharacterListPage({super.key});

  @override
  State<CharacterListPage> createState() => _CharacterListPageState();
}

class _CharacterListPageState extends State<CharacterListPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CharacterListViewModel>().loadCharacters();
    });

    // Setup infinite scroll
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<CharacterListViewModel>().loadMore();
    }
  }

  // Debounce timer
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<CharacterListViewModel>().setFilter(name: query);
    });
  }

  void _onStatusFilterChanged(String? status) {
    context.read<CharacterListViewModel>().setFilter(status: status ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildStatusFilters(),
          Expanded(
            child: Consumer<CharacterListViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.error != null && viewModel.characters.isEmpty) {
                  return _buildErrorState(viewModel);
                }

                if (viewModel.isLoading && viewModel.characters.isEmpty) {
                  return _buildLoadingState();
                }

                if (viewModel.isEmpty) {
                  return const Center(
                    child: Text(
                      'Nenhum personagem encontrado.',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                return _buildCharacterGrid(viewModel);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: TextField(
        onChanged: _onSearchChanged,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Buscar personagem...',
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: const Icon(Icons.search, color: Color(0xFF97CE4C)),
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

  Widget _buildStatusFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildFilterChip('Todos', ''),
          const SizedBox(width: 8),
          _buildFilterChip('Alive', 'alive'),
          const SizedBox(width: 8),
          _buildFilterChip('Dead', 'dead'),
          const SizedBox(width: 8),
          _buildFilterChip('Unknown', 'unknown'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    // Only simple implementation, ideally viewmodel exposes current filter
    return Consumer<CharacterListViewModel>(
      builder: (context, vm, _) {
        final isSelected = vm.statusFilter == value;
        return ActionChip(
          label: Text(label),
          onPressed: () => _onStatusFilterChanged(value),
          backgroundColor:
              isSelected ? const Color(0xFF97CE4C) : const Color(0xFF2D2D2D),
          labelStyle: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          side: BorderSide(
            color:
                isSelected
                    ? const Color(0xFF97CE4C)
                    : const Color(0xFF97CE4C).withValues(alpha: 0.5),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF1E1E1E),
      elevation: 0,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Portal icon
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [const Color(0xFF97CE4C), const Color(0xFF00B5CC)],
              ),
            ),
            child: const Icon(
              Icons.blur_circular,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Rick and Morty',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ],
      ),
      centerTitle: true,
    );
  }

  Widget _buildLoadingState() {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 2;
        if (constraints.maxWidth > 900) {
          crossAxisCount = 4;
        } else if (constraints.maxWidth > 600) {
          crossAxisCount = 3;
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 0.75,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: 8, // Initial skeleton count
          itemBuilder: (context, index) => const CharacterCardSkeleton(),
        );
      },
    );
  }

  Widget _buildErrorState(CharacterListViewModel viewModel) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
            const SizedBox(height: 16),
            Text(
              viewModel.error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: viewModel.loadCharacters,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar Novamente'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF97CE4C),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCharacterGrid(CharacterListViewModel viewModel) {
    return RefreshIndicator(
      onRefresh: viewModel.refresh,
      color: const Color(0xFF97CE4C),
      backgroundColor: const Color(0xFF2D2D2D),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Responsive column count
          int crossAxisCount = 2;
          if (constraints.maxWidth > 900) {
            crossAxisCount = 4;
          } else if (constraints.maxWidth > 600) {
            crossAxisCount = 3;
          }

          return GridView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: 0.75,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount:
                viewModel.characters.length + (viewModel.hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              // Loading indicator at the end
              // Loading indicator at the end
              if (index >= viewModel.characters.length) {
                return const CharacterCardSkeleton();
              }

              final character = viewModel.characters[index];
              return CharacterCard(
                character: character,
                onTap: () => _navigateToDetail(character),
              );
            },
          );
        },
      ),
    );
  }

  void _navigateToDetail(character) {
    context.go('/characters/detail', extra: character);
  }
}
