import 'package:flutter/foundation.dart';
import '../data/models/location.dart';
import '../data/models/character.dart';
import '../data/services/api_service.dart';

/// ViewModel for location details.
class LocationDetailViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  Location? _location;
  List<Character> _residents = [];
  bool _isLoading = false;
  String? _error;

  Location? get location => _location;
  List<Character> get residents => _residents;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Loads location details and its residents.
  Future<void> loadLocation(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _location = await _apiService.getLocation(id);
      await _loadResidentsForLocation();
    } catch (e) {
      _error = 'Erro ao carregar local.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sets location directly and loads residents.
  void setLocation(Location location) {
    _location = location;
    _residents = [];
    _error = null;
    _isLoading = true; // Prevent empty flash
    notifyListeners();

    _loadResidentsForLocation().then((_) {
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> _loadResidentsForLocation() async {
    if (_location == null) return;

    try {
      final charIds =
          _location!.residents.map((url) {
            final uri = Uri.parse(url);
            return int.parse(uri.pathSegments.last);
          }).toList();

      if (charIds.isNotEmpty) {
        _residents = await _apiService.getMultipleCharacters(charIds);
        notifyListeners();
      }
    } catch (e) {
      // Silently ignore
    }
  }
}
