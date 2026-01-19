import 'package:flutter/foundation.dart';
import '../data/models/episode.dart';
import '../data/services/api_service.dart';

/// ViewModel for the episode list page.
class EpisodeListViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Episode> _episodes = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMore = true;
  String _nameFilter = '';
  String _episodeFilter = '';

  List<Episode> get episodes => _episodes;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;
  bool get isEmpty => _episodes.isEmpty && !_isLoading;

  EpisodeListViewModel() {
    loadEpisodes();
  }

  /// Sets the filter for the episode list.
  void setFilter({String? name, String? episode}) {
    if ((name != null && name != _nameFilter) ||
        (episode != null && episode != _episodeFilter)) {
      if (name != null) _nameFilter = name;
      if (episode != null) _episodeFilter = episode;

      _episodes = [];
      _currentPage = 1;
      _hasMore = true;
      loadEpisodes();
    }
  }

  /// Loads the initial page of episodes.
  Future<void> loadEpisodes() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.getEpisodes(
        page: _currentPage,
        name: _nameFilter,
        episode: _episodeFilter,
      );

      if (_currentPage == 1) {
        _episodes = response.episodes;
      } else {
        _episodes.addAll(response.episodes);
      }

      _hasMore = response.hasNextPage;
    } catch (e) {
      _error = 'Erro ao carregar episódios. Tente novamente.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Loads the next page of episodes.
  Future<void> loadMore() async {
    if (_isLoading || !_hasMore) return;

    _isLoading = true;
    notifyListeners();

    try {
      final nextPage = _currentPage + 1;
      final response = await _apiService.getEpisodes(
        page: nextPage,
        name: _nameFilter,
        episode: _episodeFilter,
      );
      _episodes.addAll(response.episodes);
      _hasMore = response.hasNextPage;
      _currentPage = nextPage;
    } catch (e) {
      _hasMore = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
