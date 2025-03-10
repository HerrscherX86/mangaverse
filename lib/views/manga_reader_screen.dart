import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../controllers/chapter_controller.dart';

class MangaReaderScreen extends StatefulWidget {
  final String chapterId;

  const MangaReaderScreen({required this.chapterId});

  @override
  _MangaReaderScreenState createState() => _MangaReaderScreenState();
}

class _MangaReaderScreenState extends State<MangaReaderScreen> {
  bool _isImmersive = true;

  @override
  void initState() {
    super.initState();
    _enableImmersiveMode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ChapterController>(context, listen: false)
          .fetchChapterPages(widget.chapterId);
    });
  }

  void _enableImmersiveMode() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  void _toggleImmersiveMode() {
    setState(() {
      _isImmersive = !_isImmersive;
      SystemChrome.setEnabledSystemUIMode(
        _isImmersive ? SystemUiMode.immersiveSticky : SystemUiMode.edgeToEdge,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleImmersiveMode,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              backgroundColor: Colors.black.withOpacity(0.9),
              elevation: 0,
              floating: true,
              snap: true,
              title: Text('Chapter Reader', style: TextStyle(fontSize: 18)),
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
          body: Consumer<ChapterController>(
            builder: (context, controller, _) {
              return ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: controller.chapterPages.isEmpty
                    ? 1
                    : controller.chapterPages.length + 1,
                itemBuilder: (context, index) {
                  if (index >= controller.chapterPages.length) {
                    return _buildLoadingPlaceholder();
                  }
                  return _buildPageItem(controller.chapterPages[index]);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPageItem(String imageUrl) {
    return InteractiveViewer(
      minScale: 1.0,
      maxScale: 4.0,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.contain,
        httpHeaders: {'Referer': 'https://mangadex.org'},
        progressIndicatorBuilder: (_, __, progress) => Center(
          child: CircularProgressIndicator(
            value: progress.progress,
            color: Colors.white,
          ),
        ),
        errorWidget: (_, url, error) => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(height: 8),
            TextButton(
              onPressed: () => Provider.of<ChapterController>(context, listen: false)
                  .fetchChapterPages(widget.chapterId),
              child: Text('Retry', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      height: MediaQuery.of(context).size.height,
      alignment: Alignment.center,
      child: CircularProgressIndicator(color: Colors.white),
    );
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }
}
