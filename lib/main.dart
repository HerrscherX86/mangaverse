import 'package:flutter/material.dart';
import 'package:mangaverse/controllers/bookmark_controller.dart';
import 'package:mangaverse/controllers/history_controller.dart';
import 'package:provider/provider.dart';
import 'controllers/manga_controller.dart';
import 'controllers/chapter_controller.dart';
import 'views/home_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MangaController()),
        ChangeNotifierProvider(create: (_) => ChapterController()),
        ChangeNotifierProvider(create: (_) => HistoryController()),
        ChangeNotifierProvider(create: (_) => BookmarkController()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MangaVerse',
      theme: ThemeData.dark().copyWith(
        // Customize dark theme
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[900],
          elevation: 0,
          centerTitle: true,
        ),
        cardTheme: CardTheme(
          color: Colors.grey[900],
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        textTheme: TextTheme(
          headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(fontSize: 16, color: Colors.grey[400]),
        ),
      ),
      home: HomeScreen(),
    );
  }
}