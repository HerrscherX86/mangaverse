import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chapter.dart';

class ChapterService {
  final String baseUrl = "https://api.mangadex.org";

  Future<List<Chapter>> fetchChapters(String mangaId, {String translatedLanguage = 'en'}) async {
    final response = await http.get(
      Uri.parse(
          '$baseUrl/manga/$mangaId/feed'
              '?translatedLanguage[]=$translatedLanguage' // Use the provided language
              '&order[chapter]=asc'
              '&includes[]=scanlation_group'
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> chapterList = data['data'];
      return chapterList.map((json) => Chapter.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load chapters: ${response.statusCode}');
    }
  }

  Future<List<String>> fetchChapterPages(String chapterId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/at-home/server/$chapterId'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final String baseUrl = data['baseUrl'];
      final String hash = data['chapter']['hash'];
      final List<dynamic> pageData = data['chapter']['data'];
      return pageData.map((page) => '$baseUrl/data/$hash/$page').toList();
    } else {
      throw Exception('Failed to load pages: ${response.statusCode}');
    }
  }
}