import 'package:flutter/foundation.dart';
import 'manga.dart';

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
  };

  factory History.fromJson(Map<String, dynamic> json) => History(
    manga: Manga(
      id: json['manga']['id'],
      title: json['manga']['title'],
      description: json['manga']['description'],
      coverFileName: json['manga']['coverFileName'],
    ),
    readAt: DateTime.parse(json['readAt']),
  );
}