import 'package:flutter/material.dart';
import 'package:mangaverse/views/manga_reader_screen.dart';
import 'package:provider/provider.dart';
import '../controllers/chapter_controller.dart';
import '../models/chapter.dart';

class ChapterListScreen extends StatelessWidget {
  final String mangaId;

  ChapterListScreen({required this.mangaId});

  @override
  Widget build(BuildContext context) {
    final chapterController = Provider.of<ChapterController>(context, listen: false);

    // Fetch chapters when the screen is first loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      chapterController.fetchChapters(mangaId);
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Chapters'),
        centerTitle: true,
      ),
      body: Consumer<ChapterController>(
        builder: (context, chapterController, child) {
          if (chapterController.isLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (chapterController.chapters.isEmpty) {
            return Center(child: Text('No chapters found.'));
          } else {
            return ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: chapterController.chapters.length,
              itemBuilder: (context, index) {
                Chapter chapter = chapterController.chapters[index];
                return Card(
                  margin: EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16),
                    title: Text(
                      'Chapter ${chapter.chapterNumber}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      chapter.title,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    onTap: () {
                      // Navigate to the manga reader screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MangaReaderScreen(chapterId: chapter.id),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}