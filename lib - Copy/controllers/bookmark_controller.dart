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

  Map<String, dynamic> _mangaToJson(Manga manga) => {
    'id': manga.id,
    'title': manga.title,
    'description': manga.description,
    'coverFileName': manga.coverFileName,
    'status': manga.status.toString().split('.').last,
    'contentRating': manga.contentRating.toString().split('.').last,
  };

  factory Bookmark.fromJson(Map<String, dynamic> json) => Bookmark(
    manga: Manga.fromJson(json['manga']),
    savedAt: DateTime.parse(json['savedAt']),
  );
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
        .map((jsonStr) => Bookmark.fromJson(jsonDecode(jsonStr)))
        .toList();
    notifyListeners();
  }

  Future<void> addBookmark(Manga manga) async {
    _bookmarks.removeWhere((b) => b.manga.id == manga.id);
    _bookmarks.insert(0, Bookmark(manga: manga, savedAt: DateTime.now()));
    await _saveBookmarks();
  }

  Future<void> removeBookmark(String mangaId) async {
    _bookmarks.removeWhere((b) => b.manga.id == mangaId);
    await _saveBookmarks();
  }

  Future<void> _saveBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarksJson = _bookmarks
        .map((bookmark) => jsonEncode(bookmark.toJson()))
        .toList();
    await prefs.setStringList(_storageKey, bookmarksJson);
    notifyListeners();
  }
}