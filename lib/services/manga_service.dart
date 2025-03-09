import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/manga.dart';

class MangaService {
  final String baseUrl = "https://api.mangadex.org";

  Future<List<Manga>> fetchPopularManga() async {
    final response = await http.get(
      Uri.parse(
          '$baseUrl/manga'
              '?limit=10'
              '&includes[]=cover_art'
              '&order[followedCount]=desc' // Fixed bracket typo
              '&contentRating[]=safe'
              '&contentRating[]=suggestive'
              '&hasAvailableChapters=true'
              '&includes[]=alt_title' // Correct parameter name
      ),
    );

    print('Popular Manga API Status: ${response.statusCode}'); // Add debug log
    print('Response Body: ${response.body}'); // Log response

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> mangaList = data['data'];
      return mangaList.map((json) => Manga.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load popular manga: ${response.statusCode}');
    }
  }

  Future<List<Manga>> searchManga(String query) async {
    final encodedQuery = Uri.encodeQueryComponent(query);
    final url = '$baseUrl/manga?title=$encodedQuery&limit=50&includes[]=cover_art';
    print('Search URL: $url'); // Debug log

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('API Response: ${data['data']}'); // Debug log
      final List<dynamic> mangaList = data['data'];
      return mangaList.map((json) => Manga.fromJson(json)).toList();
    } else {
      print('API Error: ${response.statusCode}'); // Debug log
      throw Exception('Failed to search manga: ${response.statusCode}');
    }
  }
}