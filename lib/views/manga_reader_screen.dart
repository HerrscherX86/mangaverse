import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../controllers/chapter_controller.dart';

class MangaReaderScreen extends StatefulWidget {
  final String chapterId;

  const MangaReaderScreen({required this.chapterId});

  @override
  _MangaReaderScreenState createState() => _MangaReaderScreenState();
}

class _MangaReaderScreenState extends State<MangaReaderScreen> {
  late final ScrollController _scrollController;
  bool _showControls = true;
  bool _listenerAttached = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    // Fetch pages when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Provider.of<ChapterController>(context, listen: false);
      controller.fetchChapterPages(widget.chapterId);
    });

    // Attach scroll listener safely
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _scrollController.addListener(_handleScroll);
        setState(() => _listenerAttached = true);
      }
    });
  }

  void _handleScroll() {
    if (_showControls) {
      setState(() => _showControls = false);
    }
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _buildAppBar(),
      body: Consumer<ChapterController>(
          builder: (context, controller, _) {
            return GestureDetector(
              onTap: _toggleControls,
              child: Stack(
                children: [
                  _buildPageList(controller),
                  if (_showControls) _buildProgressIndicator(controller),
                ],
              ),
            );
          }
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.black.withOpacity(0.9),
      elevation: 0,
      title: Text(
        'Chapter Reader',
        style: TextStyle(fontSize: 18),
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.settings, color: Colors.white),
          onPressed: () => _showReaderSettings(context),
        ),
      ],
    );
  }

  void _showReaderSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black.withOpacity(0.9),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Reader Settings',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              SwitchListTile(
                title: Text(
                  'Vertical Scroll',
                  style: TextStyle(color: Colors.white),
                ),
                value: true,
                onChanged: (v) {
                  // Implement scroll direction change
                },
                activeColor: Colors.blue,
              ),
              SwitchListTile(
                title: Text(
                  'Show Progress',
                  style: TextStyle(color: Colors.white),
                ),
                value: _showControls,
                onChanged: (v) => setState(() => _showControls = v),
                activeColor: Colors.blue,
              ),
              SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Close',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPageList(ChapterController controller) {
    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.only(top: kToolbarHeight), // Account for app bar height
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
  }


  Widget _buildMainContent(ChapterController controller) {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverAppBar(
          backgroundColor: Colors.black.withOpacity(0.7),
          pinned: true,
          expandedHeight: 60,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              'Chapter Reader',
              style: TextStyle(fontSize: 16),
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
                (context, index) {
              if (index >= controller.chapterPages.length) {
                return _buildLoadingPlaceholder();
              }
              return _buildPageItem(controller.chapterPages[index]);
            },
            childCount: controller.chapterPages.isEmpty
                ? 1
                : controller.chapterPages.length + 1,
          ),
        ),
      ],
    );
  }

  Widget _buildPageItem(String imageUrl) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      child: InteractiveViewer(
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
          )],
          ),
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

  Widget _buildProgressIndicator(ChapterController controller) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: EdgeInsets.only(top: 8),
        child: Text(
          controller.chapterPages.isEmpty
              ? 'Loading...'
              : 'Page ${_currentPageIndex(controller) + 1} of ${controller.chapterPages.length}',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }

  int _currentPageIndex(ChapterController controller) {
    if (!_scrollController.hasClients || controller.chapterPages.isEmpty) return 0;
    final position = _scrollController.position;
    if (position.maxScrollExtent <= 0) return 0;

    return (position.pixels / position.maxScrollExtent *
        (controller.chapterPages.length - 1))
        .clamp(0, controller.chapterPages.length - 1)
        .round();
  }

  @override
  void dispose() {
    if (_listenerAttached) {
      _scrollController.removeListener(_handleScroll);
    }
    _scrollController.dispose();
    super.dispose();
  }
}