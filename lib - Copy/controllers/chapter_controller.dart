import 'package:flutter/material.dart';
import '../models/chapter.dart';
import '../services/chapter_service.dart';

class ChapterController with ChangeNotifier {
  List<Chapter> _chapters = [];
  List<String> _chapterPages = [];
  String _translatedLanguage = 'en'; // Default language
  String? _selectedChapterId; // Track selected chapter
  bool _isLoading = false;

  List<Chapter> get chapters => _chapters;
  List<String> get chapterPages => _chapterPages;
  String get translatedLanguage => _translatedLanguage;
  String? get selectedChapterId => _selectedChapterId;
  bool get isLoading => _isLoading;

  final ChapterService _chapterService = ChapterService();

  // Fetch chapters for a manga in the selected language
  Future<void> fetchChapters(String mangaId) async {
    _isLoading = true;
    _chapters = []; // Clear old chapters
    notifyListeners();

    try {
      _chapters = await _chapterService.fetchChapters(
        mangaId,
        translatedLanguage: _translatedLanguage,
      );

      // Auto-select the first chapter if available
      if (_chapters.isNotEmpty) {
        _selectedChapterId = _chapters.first.id;
      }
    } catch (e) {
      print('Error fetching chapters: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch pages for a chapter
  Future<void> fetchChapterPages(String chapterId) async {
    _isLoading = true;
    _chapterPages = []; // Clear old pages
    notifyListeners();

    try {
      _chapterPages = await _chapterService.fetchChapterPages(chapterId);
    } catch (e) {
      print('Error fetching pages: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Change the translated language (e.g., 'en' or 'id')
  void setTranslatedLanguage(String language) {
    _translatedLanguage = language;
    _selectedChapterId = null; // Reset selected chapter
    notifyListeners();
  }

  // Manually select a chapter
  void setSelectedChapter(String chapterId) {
    _selectedChapterId = chapterId;
    notifyListeners();
  }
}