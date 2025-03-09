import 'package:mangaverse/models/manga.dart';

class History {
  final Manga manga;
  final DateTime readAt;

  History({required this.manga, required this.readAt});

  Map<String, dynamic> toJson() => {
    'manga': _mangaToJson(manga),
    'readAt': readAt.toIso8601String(),
  };

  Map<String, dynamic> _mangaToJson(Manga manga) => {
    'id': manga.id,
    'title': manga.title,
    'description': manga.description,
    'coverFileName': manga.coverFileName,
    'status': manga.status.toString().split('.').last,
    'contentRating': manga.contentRating.toString().split('.').last,
  };

  factory History.fromJson(Map<String, dynamic> json) => History(
    manga: Manga.fromJson(json['manga']),
    readAt: DateTime.parse(json['readAt']),
  );
}