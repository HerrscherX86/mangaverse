enum MangaStatus { ongoing, completed, hiatus, cancelled }
enum ContentRating { safe, suggestive, erotica, pornographic }

// Add these extensions for serialization
extension MangaStatusX on MangaStatus {
  String get name => toString().split('.').last;
}

extension ContentRatingX on ContentRating {
  String get name => toString().split('.').last;
}

class Manga {
  final String id;
  final String title;
  final String description;
  final String coverFileName;
  final MangaStatus status;
  final ContentRating contentRating;

  Manga({
    required this.id,
    required this.title,
    required this.description,
    required this.coverFileName,
    required this.status,
    required this.contentRating,
  });

  factory Manga.fromJson(Map<String, dynamic> json) {
    final attributes = json['attributes'];

    final statusMap = {
      'ongoing': MangaStatus.ongoing,
      'completed': MangaStatus.completed,
      'hiatus': MangaStatus.hiatus,
      'cancelled': MangaStatus.cancelled,
    };
    final statusString = (attributes['status'] ?? 'ongoing').toString().toLowerCase();
    final status = statusMap[statusString] ?? MangaStatus.ongoing;

    // Parse titles
    final titleMap = attributes['title'] as Map<String, dynamic>? ?? {};
    final String title = titleMap['en'] ??
        titleMap['ja'] ??
        titleMap['ja-ro'] ??
        titleMap.values.firstWhere(
                (value) => value != null,
            orElse: () => 'No Title'
        );

    final contentRatingMap = {
      'safe': ContentRating.safe,
      'suggestive': ContentRating.suggestive,
      'erotica': ContentRating.erotica,
      'pornographic': ContentRating.pornographic,
    };
    final contentRatingString = (attributes['contentRating'] ?? 'safe').toString().toLowerCase();
    final contentRating = contentRatingMap[contentRatingString] ?? ContentRating.safe;

    // Parse description
    final descriptionMap = attributes['description'] as Map<String, dynamic>? ?? {};
    final String description = descriptionMap['en'] ??
        descriptionMap.values.firstWhere(
                (value) => value != null,
            orElse: () => 'No Description'
        );

    return Manga(
      id: json['id'],
      title: title,
      description: description,
      coverFileName: _getCoverFileName(json['relationships']),
    status: MangaStatus.values.firstWhere(
    (e) => e.name == json['status'],
    orElse: () => MangaStatus.ongoing,
    ),
    contentRating: ContentRating.values.firstWhere(
    (e) => e.name == json['contentRating'],
    orElse: () => ContentRating.safe,
    ));
  }

  static String _getCoverFileName(List<dynamic> relationships) {
    try {
      return relationships
          .firstWhere((rel) => rel['type'] == 'cover_art')['attributes']['fileName'];
    } catch (e) {
      return 'default_cover.jpg';
    }
  }
}