class Manga {
  final String id;
  final String title;
  final List<String> altTitles;
  final String description;
  final String coverFileName;
  final double rating;
  final int chapterCount;
  final int? viewCount; // Make nullable if not always available


  Manga({
    required this.id,
    required this.title,
    this.altTitles = const [],
    required this.description,
    required this.coverFileName,
    required this.rating,
    required this.chapterCount,
    this.viewCount,
  });

  factory Manga.fromJson(Map<String, dynamic> json) {
    final attributes = json['attributes'];

    // Add rating parsing (example structure - adjust according to API)
    final rating = (attributes['rating'] ?? 0.0).toDouble();

    // Add chapter count parsing
    final chapterCount = (attributes['chapterCount'] ?? 0).toInt();

    // Existing title parsing
    final titleMap = attributes['title'] as Map<String, dynamic>? ?? {};
    final String title = titleMap['en'] ??
        titleMap['ja'] ??
        titleMap['ja-ro'] ??
        titleMap.values.firstWhere(
                (value) => value != null,
            orElse: () => 'No Title'
        );

    // Add alternative titles parsing with proper type casting
    final List<String> altTitles = (attributes['altTitles'] as List<dynamic>?)
        ?.map((titleObj) {
      final langMap = titleObj as Map<String, dynamic>;
      return langMap.values.firstOrNull?.toString() ?? '';
    })
        .where((title) => title.isNotEmpty)
        .cast<String>() // Explicitly cast to List<String>
        .toList() ?? [];

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
      altTitles: altTitles,
      description: description,
      coverFileName: coverArt['attributes']['fileName'],
      rating: rating,
      chapterCount: chapterCount,
      viewCount: attributes['viewCount']?.toInt(),
    );
  }
}