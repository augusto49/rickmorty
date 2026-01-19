import 'package:flutter/foundation.dart';
import '../data/models/character.dart';
import '../data/services/api_service.dart';

/// ViewModel for the character list page.
///
/// Manages loading state, pagination, and character data.
class CharacterListViewModel extends ChangeNotifier {
  final ApiService _apiService;

  List<Character> _characters = [];
  bool _isLoading = false;
  bool _hasMore = true;
  String? _error;
  int _currentPage = 1;

  CharacterListViewModel({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  /// List of loaded characters.
  List<Character> get characters => _characters;

  /// Whether data is currently being loaded.
  bool get isLoading => _isLoading;

  /// Whether there are more pages to load.
  bool get hasMore => _hasMore;

  /// Error message if loading failed.
  String? get error => _error;

  /// Whether the list is empty and not loading.
  bool get isEmpty => _characters.isEmpty && !_isLoading;

  String _nameFilter = '';
  String _statusFilter = '';

  String get statusFilter => _statusFilter;

  /// Sets the filter for the character list.
  ///
  /// Debounce logic should be handled by the UI or a debouncer helper.
  void setFilter({String? name, String? status}) {
    // Only update if changes occurred
    if ((name != null && name != _nameFilter) ||
        (status != null && status != _statusFilter)) {
      if (name != null) _nameFilter = name;
      if (status != null) _statusFilter = status;

      // Reset list and reload
      _characters = [];
      _currentPage = 1;
      _hasMore = true;
      loadCharacters();
    }
  }

  /// Loads the initial page of characters (with optional filters).
  Future<void> loadCharacters() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.getCharacters(
        page: _currentPage,
        name: _nameFilter,
        status: _statusFilter,
      );

      // If page 1, replace list, otherwise append (though loadCharacters is usually page 1)
      if (_currentPage == 1) {
        _characters = response.characters;
      } else {
        _characters.addAll(response.characters);
      }

      _hasMore = response.hasNextPage;
    } catch (e) {
      _error = 'Erro ao carregar personagens. Tente novamente.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Loads the next page of characters (infinite scroll).
  Future<void> loadMore() async {
    if (_isLoading || !_hasMore) return;

    _isLoading = true;
    notifyListeners();

    try {
      final nextPage = _currentPage + 1;
      final response = await _apiService.getCharacters(
        page: nextPage,
        name: _nameFilter,
        status: _statusFilter,
      );
      _characters.addAll(response.characters);
      _hasMore = response.hasNextPage;
      _currentPage = nextPage;
    } catch (e) {
      // Don't show error for loadMore, just stop pagination
      _hasMore = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refreshes the character list (pull-to-refresh).
  Future<void> refresh() async {
    _characters = [];
    _hasMore = true;
    _currentPage = 1;
    await loadCharacters();
  }

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }
}
