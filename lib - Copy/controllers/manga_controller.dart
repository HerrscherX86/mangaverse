import 'package:flutter/material.dart';
import '../models/manga.dart';
import '../services/manga_service.dart';
import 'dart:convert'; // For json decoding
import 'package:http/http.dart' as http; // For HTTP requests

class MangaController with ChangeNotifier {
  List<Manga> _mangaList = [];
  bool _isLoading = false;

  List<Manga> get mangaList => _mangaList;
  bool get isLoading => _isLoading;

  final MangaService _mangaService = MangaService();

  // In manga_controller.dart
  Future<Manga> fetchMangaDetails(String mangaId) async {
    try {
      // Make sure baseUrl is defined in your controller
      final baseUrl = "https://api.mangadex.org";

      final response = await http.get(
        Uri.parse('$baseUrl/manga/$mangaId?includes[]=cover_art'),
      );

      if (response.statusCode == 200) {
        // Parse the JSON response
        final jsonData = jsonDecode(response.body);

        // Ensure the response structure is correct
        if (jsonData['data'] != null) {
          return Manga.fromJson(jsonData['data']);
        }
      }

      // Fallback: Try to find the manga in the existing list
      return _mangaList.firstWhere(
            (m) => m.id == mangaId,
        orElse: () => Manga(
          id: mangaId,
          title: 'Unknown Manga',
          description: 'No description available',
          coverFileName: 'default_cover.jpg',
          status: MangaStatus.ongoing,
          contentRating: ContentRating.safe,
        ),
      );
    } catch (e) {
      // Fallback with error handling
      return _mangaList.firstWhere(
            (m) => m.id == mangaId,
        orElse: () => Manga(
          id: mangaId,
          title: 'Unknown Manga',
          description: 'No description available',
          coverFileName: 'default_cover.jpg',
          status: MangaStatus.ongoing,
          contentRating: ContentRating.safe,
        ),
      );
    }
  }

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