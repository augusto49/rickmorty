/// Episode model from Rick and Morty API.
class Episode {
  final int id;
  final String name;
  final String airDate;
  final String episodeCode;
  final List<String> characters;
  final String url;
  final String created;

  const Episode({
    required this.id,
    required this.name,
    required this.airDate,
    required this.episodeCode,
    required this.characters,
    required this.url,
    required this.created,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      id: json['id'] as int,
      name: json['name'] as String,
      airDate: json['air_date'] as String,
      episodeCode: json['episode'] as String,
      characters: (json['characters'] as List).cast<String>(),
      url: json['url'] as String,
      created: json['created'] as String,
    );
  }
}
