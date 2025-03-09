import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/chapter_controller.dart';

class MangaReaderScreen extends StatelessWidget {
  final String chapterId;

  MangaReaderScreen({required this.chapterId});

  @override
  Widget build(BuildContext context) {
    final chapterController = Provider.of<ChapterController>(context, listen: false);

    // Fetch pages when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      chapterController.fetchChapterPages(chapterId);
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Manga Reader'),
        backgroundColor: Colors.grey[900],
      ),
      backgroundColor: Colors.black,
      body: Consumer<ChapterController>(
        builder: (context, chapterController, child) {
          if (chapterController.isLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (chapterController.chapterPages.isEmpty) {
            return Center(child: Text('No pages found.', style: TextStyle(color: Colors.white)));
          } else {
            return ListView.builder(
              itemCount: chapterController.chapterPages.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: InteractiveViewer(
                    child: Image.network(
                      chapterController.chapterPages[index],
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(Icons.error, color: Colors.red),
                        );
                      },
                    ),
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