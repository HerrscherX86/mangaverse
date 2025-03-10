import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/history.dart';
import '../models/manga.dart';

class HistoryController with ChangeNotifier {
  List<History> _history = [];
  static const String _storageKey = 'readHistory';

  List<History> get history => _history;

  HistoryController() {
    _loadHistory();
  }

  // Load history from SharedPreferences
  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getStringList(_storageKey) ?? [];
    _history = historyJson
        .map((jsonStr) {
      try {
        return History.fromJson(jsonDecode(jsonStr));
      } catch (e) {
        print('Error loading history item: $e');
        return null;
      }
    })
        .whereType<History>() // Filter out null values
        .toList();
    notifyListeners();
  }

  // Add manga to history and save
  Future<void> addToHistory(Manga manga) async {
    // Remove duplicates
    _history.removeWhere((h) => h.manga.id == manga.id);

    // Add new entry at the top
    _history.insert(0, History(manga: manga, readAt: DateTime.now()));

    // Limit to last 50 items
    if (_history.length > 50) _history = _history.sublist(0, 50);

    await _saveHistory();
    notifyListeners();
  }

  // Save history to SharedPreferences
  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = _history
        .map((history) => jsonEncode(history.toJson()))
        .toList();
    await prefs.setStringList(_storageKey, historyJson);
  }
}