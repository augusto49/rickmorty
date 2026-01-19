import 'package:flutter/foundation.dart';
import '../data/models/character.dart';
import '../data/services/api_service.dart';

/// ViewModel para a página de lista de personagens.
///
/// Gerencia estado de carregamento, paginação e dados dos personagens.
class CharacterListViewModel extends ChangeNotifier {
  final ApiService _apiService;

  List<Character> _characters = [];
  bool _isLoading = false;
  bool _hasMore = true;
  String? _error;
  int _currentPage = 1;

  CharacterListViewModel({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  /// Lista de personagens carregados.
  List<Character> get characters => _characters;

  /// Indica se os dados estão sendo carregados.
  bool get isLoading => _isLoading;

  /// Indica se existem mais páginas para carregar.
  bool get hasMore => _hasMore;

  /// Mensagem de erro se o carregamento falhar.
  String? get error => _error;

  /// Indica se a lista está vazia e não está carregando.
  bool get isEmpty => _characters.isEmpty && !_isLoading;

  String _nameFilter = '';
  String _statusFilter = '';

  String get statusFilter => _statusFilter;

  /// Define o filtro para a lista de personagens.
  ///
  /// A lógica de debounce deve ser tratada pela UI ou um helper de debounce.
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

  /// Carrega a página inicial de personagens (com filtros opcionais).
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

  /// Carrega a próxima página de personagens (rolagem infinita).
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

  /// Atualiza a lista de personagens (pull-to-refresh).
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
