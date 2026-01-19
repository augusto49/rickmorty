import 'package:flutter/foundation.dart';
import '../data/models/character.dart';
import '../data/models/episode.dart';
import '../data/models/location.dart';
import '../data/services/api_service.dart';

/// ViewModel for the character detail page.
///
/// Can be initialized with an existing character or fetch by ID.
class CharacterDetailViewModel extends ChangeNotifier {
  final ApiService _apiService;

  Character? _character;
  bool _isLoading = false;
  String? _error;

  CharacterDetailViewModel({Character? character, ApiService? apiService})
    : _character = character,
      _apiService = apiService ?? ApiService();

  /// The character being displayed.
  Character? get character => _character;

  /// Whether data is being loaded.
  bool get isLoading => _isLoading;

  /// Error message if loading failed.
  String? get error => _error;

  List<Episode> _episodes = [];
  bool _isLoadingEpisodes = false;

  /// List of episodes where the character appears.
  List<Episode> get episodes => _episodes;
  bool get isLoadingEpisodes => _isLoadingEpisodes;

  Location? _originLocation;
  Location? _currentLocation;

  Location? get originLocation => _originLocation;
  Location? get currentLocation => _currentLocation;

  /// Loads character data and their episodes.
  Future<void> loadCharacter(int id) async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _character = await _apiService.getCharacter(id);
      await Future.wait([
        _loadEpisodesForCharacter(),
        _loadLocationsForCharacter(),
      ]);
    } catch (e) {
      _error = 'Erro ao carregar detalhes do personagem.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sets the character directly and loads their episodes.
  void setCharacter(Character character) {
    _character = character;
    _error = null;
    _episodes = [];
    _isLoadingEpisodes = true; // Prevent empty flash
    notifyListeners();
    _loadEpisodesForCharacter();
    _loadLocationsForCharacter();
  }

  Future<void> _loadEpisodesForCharacter() async {
    if (_character == null) return;

    _isLoadingEpisodes = true;
    notifyListeners();

    try {
      final episodeIds =
          _character!.episode
              .map((url) {
                try {
                  final uri = Uri.parse(url);
                  if (uri.pathSegments.isNotEmpty) {
                    return int.tryParse(uri.pathSegments.last);
                  }
                } catch (e) {
                  return null;
                }
                return null;
              })
              .where((id) => id != null)
              .cast<int>()
              .toSet()
              .toList();

      if (episodeIds.isNotEmpty) {
        // Sort IDs to show in chronological order essentially
        episodeIds.sort();
        _episodes = await _apiService.getMultipleEpisodes(episodeIds);
      }
    } catch (e) {
      // Silently fail for episodes part, main character data is visible
    } finally {
      _isLoadingEpisodes = false;
      notifyListeners();
    }
  }

  Future<void> _loadLocationsForCharacter() async {
    if (_character == null) return;

    _originLocation = null;
    _currentLocation = null;

    try {
      final List<int> locationIds = [];
      int? originId;
      int? locationId;

      if (_character!.origin.url.isNotEmpty) {
        final uri = Uri.parse(_character!.origin.url);
        if (uri.pathSegments.isNotEmpty) {
          originId = int.tryParse(uri.pathSegments.last);
          if (originId != null) locationIds.add(originId);
        }
      }

      if (_character!.location.url.isNotEmpty) {
        final uri = Uri.parse(_character!.location.url);
        if (uri.pathSegments.isNotEmpty) {
          locationId = int.tryParse(uri.pathSegments.last);
          if (locationId != null) locationIds.add(locationId);
        }
      }

      if (locationIds.isNotEmpty) {
        // Use set to avoid duplicates if origin == location
        final distinctIds = locationIds.toSet().toList();
        final locations = await _apiService.getMultipleLocations(distinctIds);

        if (originId != null) {
          _originLocation = locations.firstWhere(
            (l) => l.id == originId,
            orElse: () => locations.first,
          );
          // Note: simplify lookup safely
          try {
            _originLocation = locations.firstWhere((l) => l.id == originId);
          } catch (_) {}
        }

        if (locationId != null) {
          try {
            _currentLocation = locations.firstWhere((l) => l.id == locationId);
          } catch (_) {}
        }
      }
      notifyListeners();
    } catch (e) {
      // Ignore location loading errors
    }
  }

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }
}
