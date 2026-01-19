import 'package:flutter/foundation.dart';
import '../data/models/location.dart';
import '../data/services/api_service.dart';

/// ViewModel para a página de lista de locais.
class LocationListViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Location> _locations = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMore = true;
  String _nameFilter = '';
  String _typeFilter = '';
  String _dimensionFilter = '';

  List<Location> get locations => _locations;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;
  bool get isEmpty => _locations.isEmpty && !_isLoading;

  LocationListViewModel() {
    loadLocations();
  }

  /// Define o filtro para a lista de locais.
  void setFilter({String? name, String? type, String? dimension}) {
    if ((name != null && name != _nameFilter) ||
        (type != null && type != _typeFilter) ||
        (dimension != null && dimension != _dimensionFilter)) {
      if (name != null) _nameFilter = name;
      if (type != null) _typeFilter = type;
      if (dimension != null) _dimensionFilter = dimension;

      _locations = [];
      _currentPage = 1;
      _hasMore = true;
      loadLocations();
    }
  }

  /// Carrega a página inicial de locais.
  Future<void> loadLocations() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.getLocations(
        page: _currentPage,
        name: _nameFilter,
        type: _typeFilter,
        dimension: _dimensionFilter,
      );

      if (_currentPage == 1) {
        _locations = response.locations;
      } else {
        _locations.addAll(response.locations);
      }

      _hasMore = response.hasNextPage;
    } catch (e) {
      _error = 'Erro ao carregar locais. Tente novamente.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Carrega a próxima página de locais.
  Future<void> loadMore() async {
    if (_isLoading || !_hasMore) return;

    _isLoading = true;
    notifyListeners();

    try {
      final nextPage = _currentPage + 1;
      final response = await _apiService.getLocations(
        page: nextPage,
        name: _nameFilter,
        type: _typeFilter,
        dimension: _dimensionFilter,
      );
      _locations.addAll(response.locations);
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
