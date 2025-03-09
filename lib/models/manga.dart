class Manga {
  final String id;
  final String title;
  final String description;
  final String coverFileName;

  Manga({
    required this.id,
    required this.title,
    required this.description,
    required this.coverFileName,
  });

  factory Manga.fromJson(Map<String, dynamic> json) {
    final attributes = json['attributes'];
    final titleMap = attributes['title'] as Map<String, dynamic>? ?? {};
    final String title = titleMap['en'] ??
        titleMap['ja'] ??
        titleMap['ja-ro'] ??
        titleMap.values.firstWhere(
                (value) => value != null,
            orElse: () => 'No Title'
        );

    final descriptionMap = attributes['description'] as Map<String, dynamic>? ?? {};
    final String description = descriptionMap['en'] ??
        descriptionMap.values.firstWhere(
                (value) => value != null,
            orElse: () => 'No Description'
        );

    final relationships = json['relationships'] as List<dynamic>;
    final coverArt = relationships.firstWhere(
          (rel) => rel['type'] == 'cover_art',
      orElse: () => {'attributes': {'fileName': 'default_cover.jpg'}},
    );

    return Manga(
      id: json['id'],
      title: title,
      description: description,
      coverFileName: coverArt['attributes']['fileName'],
    );
  }
}