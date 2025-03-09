import 'package:flutter/material.dart';
import '../models/manga.dart';
import '../services/manga_service.dart';

class MangaController with ChangeNotifier {
  List<Manga> _mangaList = [];
  bool _isLoading = false;

  List<Manga> get mangaList => _mangaList;
  bool get isLoading => _isLoading;

  final MangaService _mangaService = MangaService();

  Future<void> fetchPopularManga() async {
    _isLoading = true;
    notifyListeners();

    try {
      _mangaList = await _mangaService.fetchPopularManga();
    } catch (e) {
      print('Error fetching popular manga: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Manga>> searchManga(String query) async {
    _isLoading = true;
    notifyListeners();

    try {
      _mangaList = await _mangaService.searchManga(query);
      return _mangaList; // Return the search results
    } catch (e) {
      print('Error searching manga: $e');
      return []; // Return an empty list on error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}