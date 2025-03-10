import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/manga.dart';

class Bookmark {
  final Manga manga;
  final DateTime savedAt;

  Bookmark({required this.manga, required this.savedAt});

  Map<String, dynamic> toJson() => {
    'manga': _mangaToJson(manga),
    'savedAt': savedAt.toIso8601String(),
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

  factory Bookmark.fromJson(Map<String, dynamic> json) {
    try {
      return Bookmark(
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
        savedAt: DateTime.parse(json['savedAt'] ?? DateTime.now().toIso8601String()),
      );
    } catch (e) {
      print('Error parsing Bookmark from JSON: $e');
      return Bookmark(
        manga: Manga(
          id: '',
          title: 'Invalid Bookmark',
          altTitles: [], // Add empty list for invalid bookmark
          description: '',
          coverFileName: '',
          rating: 0.0,
          chapterCount: 0,
        ),
        savedAt: DateTime.now(),
      );
    }
  }
}

class BookmarkController with ChangeNotifier {
  List<Bookmark> _bookmarks = [];
  static const String _storageKey = 'bookmarks';

  List<Bookmark> get bookmarks => _bookmarks;

  BookmarkController() {
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarksJson = prefs.getStringList(_storageKey) ?? [];
    _bookmarks = bookmarksJson
        .map((jsonStr) {
      try {
        return Bookmark.fromJson(jsonDecode(jsonStr));
      } catch (e) {
        print('Error loading bookmark: $e');
        return null;
      }
    })
        .whereType<Bookmark>() // Filter out null values
        .toList();
    notifyListeners();
  }

  Future<void> addBookmark(Manga manga) async {
    _bookmarks.removeWhere((b) => b.manga.id == manga.id);
    _bookmarks.insert(0, Bookmark(manga: manga, savedAt: DateTime.now()));
    await _saveBookmarks();
    notifyListeners();
  }

  Future<void> removeBookmark(String mangaId) async {
    _bookmarks.removeWhere((b) => b.manga.id == mangaId);
    await _saveBookmarks();
    notifyListeners();
  }

  Future<void> _saveBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarksJson = _bookmarks
        .map((bookmark) => jsonEncode(bookmark.toJson()))
        .toList();
    await prefs.setStringList(_storageKey, bookmarksJson);
  }
}