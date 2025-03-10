import 'package:mangaverse/models/manga.dart';

class History {
  final Manga manga;
  final DateTime readAt;

  History({required this.manga, required this.readAt});

  Map<String, dynamic> toJson() => {
    'manga': _mangaToJson(manga),
    'readAt': readAt.toIso8601String(),
  };

  static Map<String, dynamic> _mangaToJson(Manga manga) => {
    'id': manga.id,
    'title': manga.title,
    'altTitles': manga.altTitles, // Add this line
    'description': manga.description,
    'coverFileName': manga.coverFileName,
    'rating': manga.rating,
    'chapterCount': manga.chapterCount,
  };

  factory History.fromJson(Map<String, dynamic> json) {
    try {
      return History(
        manga: Manga(
          id: json['manga']['id'] ?? '',
          title: json['manga']['title'] ?? 'Unknown Title',
          altTitles: (json['manga']['altTitles'] as List<dynamic>?) // Add this
              ?.cast<String>()
              .toList() ?? [],
          description: json['manga']['description'] ?? '',
          coverFileName: json['manga']['coverFileName'] ?? '',
          rating: (json['manga']['rating'] ?? 0.0).toDouble(),
          chapterCount: (json['manga']['chapterCount'] ?? 0).toInt(),
        ),
        readAt: DateTime.parse(json['readAt'] ?? DateTime.now().toIso8601String()),
      );
    } catch (e) {
      print('Error parsing History from JSON: $e');
      return History(
        manga: Manga(
          id: '',
          title: 'Invalid History',
          altTitles: [], // Add empty list for invalid history
          description: '',
          coverFileName: '',
          rating: 0.0,
          chapterCount: 0,
        ),
        readAt: DateTime.now(),
      );
    }
  }
}