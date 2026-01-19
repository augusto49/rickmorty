class Character {
  final int id;
  final String name;
  final String status;
  final String species;
  final String type;
  final String gender;
  final String image;
  final CharacterLocation origin;
  final CharacterLocation location;
  final List<String> episode;

  const Character({
    required this.id,
    required this.name,
    required this.status,
    required this.species,
    required this.type,
    required this.gender,
    required this.image,
    required this.origin,
    required this.location,
    required this.episode,
  });

  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      id: json['id'] as int,
      name: json['name'] as String,
      status: json['status'] as String,
      species: json['species'] as String,
      type: json['type'] as String? ?? '',
      gender: json['gender'] as String,
      image: json['image'] as String,
      origin: CharacterLocation.fromJson(
        json['origin'] as Map<String, dynamic>,
      ),
      location: CharacterLocation.fromJson(
        json['location'] as Map<String, dynamic>,
      ),
      episode: (json['episode'] as List).cast<String>(),
    );
  }

  /// Returns true if character is alive.
  bool get isAlive => status.toLowerCase() == 'alive';

  /// Returns true if character is dead.
  bool get isDead => status.toLowerCase() == 'dead';
}

/// Location model for character origin and current location.
class CharacterLocation {
  final String name;
  final String url;

  const CharacterLocation({required this.name, required this.url});

  factory CharacterLocation.fromJson(Map<String, dynamic> json) {
    return CharacterLocation(
      name: json['name'] as String? ?? 'Unknown',
      url: json['url'] as String? ?? '',
    );
  }
}
