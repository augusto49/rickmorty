import 'package:flutter/foundation.dart';
import '../data/models/episode.dart';
import '../data/models/character.dart';
import '../data/services/api_service.dart';

/// ViewModel for episode details.
class EpisodeDetailViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  Episode? _episode;
  List<Character> _characters = [];
  bool _isLoading = false;
  String? _error;

  Episode? get episode => _episode;
  List<Character> get characters => _characters;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Loads episode details and its characters.
  Future<void> loadEpisode(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _episode = await _apiService.getEpisode(id);
      await _loadCharactersForEpisode();
    } catch (e) {
      _error = 'Erro ao carregar episódio.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sets episode directly and loads characters.
  void setEpisode(Episode episode) {
    _episode = episode;
    _characters = [];
    _error = null;
    _isLoading = true;
    notifyListeners();

    _loadCharactersForEpisode().then((_) {
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> _loadCharactersForEpisode() async {
    if (_episode == null) return;

    try {
      final charIds =
          _episode!.characters.map((url) {
            final uri = Uri.parse(url);
            return int.parse(uri.pathSegments.last);
          }).toList();

      if (charIds.isNotEmpty) {
        _characters = await _apiService.getMultipleCharacters(charIds);
        notifyListeners();
      }
    } catch (e) {
      // Silently ignore
    }
  }
}
