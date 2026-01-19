import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/character.dart';
import '../models/episode.dart';
import '../models/location.dart';

/// Service class for Rick and Morty API communication.
class ApiService {
  static const String _baseUrl = 'https://rickandmortyapi.com/api';

  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Fetches a paginated list of characters with optional filtering.
  Future<CharacterResponse> getCharacters({
    int page = 1,
    String? name,
    String? status,
  }) async {
    final queryParams = {
      'page': page.toString(),
      if (name != null && name.isNotEmpty) 'name': name,
      if (status != null && status.isNotEmpty) 'status': status,
    };

    final uri = Uri.parse(
      '$_baseUrl/character',
    ).replace(queryParameters: queryParams);
    final response = await _client.get(uri);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return CharacterResponse.fromJson(json);
    } else if (response.statusCode == 404) {
      // 404 means no results for filter
      return const CharacterResponse(
        characters: [],
        totalPages: 0,
        totalCount: 0,
        hasNextPage: false,
      );
    } else {
      throw ApiException(
        'Failed to load characters',
        statusCode: response.statusCode,
      );
    }
  }

  /// Fetches a single character by ID.
  Future<Character> getCharacter(int id) async {
    final uri = Uri.parse('$_baseUrl/character/$id');
    final response = await _client.get(uri);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return Character.fromJson(json);
    } else {
      throw ApiException(
        'Failed to load character',
        statusCode: response.statusCode,
      );
    }
  }

  /// Fetches multiple characters by IDs.
  Future<List<Character>> getMultipleCharacters(List<int> ids) async {
    if (ids.isEmpty) return [];

    final idsString = ids.join(',');
    final uri = Uri.parse('$_baseUrl/character/$idsString');
    final response = await _client.get(uri);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body is List) {
        return body.map((e) => Character.fromJson(e)).toList();
      } else {
        // Single character response
        return [Character.fromJson(body)];
      }
    } else {
      throw ApiException(
        'Failed to load characters',
        statusCode: response.statusCode,
      );
    }
  }

  /// Fetches multiple episodes by IDs.
  Future<List<Episode>> getMultipleEpisodes(List<int> ids) async {
    if (ids.isEmpty) return [];

    final idsString = ids.join(',');
    final uri = Uri.parse('$_baseUrl/episode/$idsString');
    final response = await _client.get(uri);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body is List) {
        return body.map((e) => Episode.fromJson(e)).toList();
      } else {
        // Single episode response
        return [Episode.fromJson(body)];
      }
    } else {
      throw ApiException(
        'Failed to load episodes',
        statusCode: response.statusCode,
      );
    }
  }

  /// Fetches a paginated list of episodes with optional filtering.
  Future<EpisodeResponse> getEpisodes({
    int page = 1,
    String? name,
    String? episode,
  }) async {
    final queryParams = {
      'page': page.toString(),
      if (name != null && name.isNotEmpty) 'name': name,
      if (episode != null && episode.isNotEmpty) 'episode': episode,
    };

    final uri = Uri.parse(
      '$_baseUrl/episode',
    ).replace(queryParameters: queryParams);
    final response = await _client.get(uri);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return EpisodeResponse.fromJson(json);
    } else if (response.statusCode == 404) {
      return const EpisodeResponse(
        episodes: [],
        totalPages: 0,
        totalCount: 0,
        hasNextPage: false,
      );
    } else {
      throw ApiException(
        'Failed to load episodes',
        statusCode: response.statusCode,
      );
    }
  }

  /// Fetches a single episode by ID.
  Future<Episode> getEpisode(int id) async {
    final uri = Uri.parse('$_baseUrl/episode/$id');
    final response = await _client.get(uri);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return Episode.fromJson(json);
    } else {
      throw ApiException(
        'Failed to load episode',
        statusCode: response.statusCode,
      );
    }
  }

  /// Fetches a paginated list of locations with optional filtering.
  Future<LocationResponse> getLocations({
    int page = 1,
    String? name,
    String? type,
    String? dimension,
  }) async {
    final queryParams = {
      'page': page.toString(),
      if (name != null && name.isNotEmpty) 'name': name,
      if (type != null && type.isNotEmpty) 'type': type,
      if (dimension != null && dimension.isNotEmpty) 'dimension': dimension,
    };

    final uri = Uri.parse(
      '$_baseUrl/location',
    ).replace(queryParameters: queryParams);
    final response = await _client.get(uri);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return LocationResponse.fromJson(json);
    } else if (response.statusCode == 404) {
      return const LocationResponse(
        locations: [],
        totalPages: 0,
        totalCount: 0,
        hasNextPage: false,
      );
    } else {
      throw ApiException(
        'Failed to load locations',
        statusCode: response.statusCode,
      );
    }
  }

  /// Fetches a single location by ID.
  Future<Location> getLocation(int id) async {
    final uri = Uri.parse('$_baseUrl/location/$id');
    final response = await _client.get(uri);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return Location.fromJson(json);
    } else {
      throw ApiException(
        'Failed to load location',
        statusCode: response.statusCode,
      );
    }
  }

  /// Fetches multiple locations by IDs.
  Future<List<Location>> getMultipleLocations(List<int> ids) async {
    if (ids.isEmpty) return [];

    final idsString = ids.join(',');
    final uri = Uri.parse('$_baseUrl/location/$idsString');
    final response = await _client.get(uri);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body is List) {
        return body.map((e) => Location.fromJson(e)).toList();
      } else {
        // Single location response
        return [Location.fromJson(body)];
      }
    } else {
      throw ApiException(
        'Failed to load locations',
        statusCode: response.statusCode,
      );
    }
  }

  void dispose() {
    _client.close();
  }
}

/// Response wrapper for paginated character list.
class CharacterResponse {
  final List<Character> characters;
  final int totalPages;
  final int totalCount;
  final bool hasNextPage;

  const CharacterResponse({
    required this.characters,
    required this.totalPages,
    required this.totalCount,
    required this.hasNextPage,
  });

  factory CharacterResponse.fromJson(Map<String, dynamic> json) {
    final info = json['info'] as Map<String, dynamic>;
    final results = json['results'] as List<dynamic>;

    return CharacterResponse(
      characters:
          results
              .map((e) => Character.fromJson(e as Map<String, dynamic>))
              .toList(),
      totalPages: info['pages'] as int,
      totalCount: info['count'] as int,
      hasNextPage: info['next'] != null,
    );
  }
}

/// Response wrapper for paginated episode list.
class EpisodeResponse {
  final List<Episode> episodes;
  final int totalPages;
  final int totalCount;
  final bool hasNextPage;

  const EpisodeResponse({
    required this.episodes,
    required this.totalPages,
    required this.totalCount,
    required this.hasNextPage,
  });

  factory EpisodeResponse.fromJson(Map<String, dynamic> json) {
    final info = json['info'] as Map<String, dynamic>;
    final results = json['results'] as List<dynamic>;

    return EpisodeResponse(
      episodes:
          results
              .map((e) => Episode.fromJson(e as Map<String, dynamic>))
              .toList(),
      totalPages: info['pages'] as int,
      totalCount: info['count'] as int,
      hasNextPage: info['next'] != null,
    );
  }
}

/// Response wrapper for paginated location list.
class LocationResponse {
  final List<Location> locations;
  final int totalPages;
  final int totalCount;
  final bool hasNextPage;

  const LocationResponse({
    required this.locations,
    required this.totalPages,
    required this.totalCount,
    required this.hasNextPage,
  });

  factory LocationResponse.fromJson(Map<String, dynamic> json) {
    final info = json['info'] as Map<String, dynamic>;
    final results = json['results'] as List<dynamic>;

    return LocationResponse(
      locations:
          results
              .map((e) => Location.fromJson(e as Map<String, dynamic>))
              .toList(),
      totalPages: info['pages'] as int,
      totalCount: info['count'] as int,
      hasNextPage: info['next'] != null,
    );
  }
}

/// Custom exception for API errors.
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException: $message (status: $statusCode)';
}
