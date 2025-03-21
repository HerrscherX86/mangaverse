import 'package:cached_network_image/cached_network_image.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:mangaverse/controllers/bookmark_controller.dart';
import 'package:provider/provider.dart';
import '../controllers/chapter_controller.dart';
import '../models/manga.dart';
import 'manga_reader_screen.dart';

class MangaDetailsScreen extends StatelessWidget {
  final Manga manga;

  const MangaDetailsScreen({required this.manga});

  @override
  Widget build(BuildContext context) {
    final chapterController = Provider.of<ChapterController>(context, listen: false);
    final textTheme = Theme.of(context).textTheme;

    // Fetch chapters when the screen is first loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      chapterController.fetchChapters(manga.id);
    });

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMetadataSection(textTheme, manga),
                  const SizedBox(height: 24),
                  _buildSynopsisSection(textTheme),
                  const SizedBox(height: 24),
                  _buildChapterControls(chapterController),
                  const SizedBox(height: 24),
                  _buildChapterList(chapterController, context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 300,
      stretch: true,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.blurBackground],
        background: Hero(
          tag: manga.id,
          child: CachedNetworkImage(
            imageUrl: 'https://uploads.mangadex.org/covers/${manga.id}/${manga.coverFileName}',
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(color: Colors.grey[900]),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
        ),
      ),
      pinned: true,
      actions: [
        IconButton(
          icon: Consumer<BookmarkController>(
            builder: (context, controller, _) {
              final isBookmarked = controller.bookmarks.any((b) => b.manga.id == manga.id);
              return Icon(
                isBookmarked ? Icons.bookmark_added : Icons.bookmark_add_outlined,
                color: Colors.white,
              );
            },
          ),
          onPressed: () => _addToBookmarks(context),
        ),
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: () => _shareManga(context),
        ),
      ],
    );
  }

  Widget _buildMetadataSection(TextTheme textTheme, Manga manga) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          manga.title,
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        if (manga.altTitles.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Also known as: ${manga.altTitles.join(', ')}',
              style: textTheme.bodyMedium?.copyWith(
                color: Colors.grey[400],
                fontStyle: FontStyle.italic,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        const SizedBox(height: 12),
      ],
    );
  }

  // Add number formatting helper
  String _formatNumber(int number) {
    if (number > 1000000) return '${(number / 1000000).toStringAsFixed(1)}M';
    if (number > 1000) return '${(number / 1000).toStringAsFixed(1)}K';
    return number.toString();
  }

  Widget _buildStatusRow() {
    return Row(
      children: [
        _buildStatusIndicator('Ongoing', Colors.green),
        const SizedBox(width: 8),
        _buildContentRating('18+', Colors.orange),
        const Spacer(),
        _buildFollowButton(),
      ],
    );
  }

  Widget _buildStatusIndicator(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, color: color, size: 12),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentRating(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildFollowButton() {
    return OutlinedButton.icon(
      icon: const Icon(Icons.notifications_none, size: 16),
      label: const Text('Follow'),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: Colors.white54),
        padding: const EdgeInsets.symmetric(horizontal: 12),
      ),
      onPressed: () {
        // Add follow functionality
      },
    );
  }

  Widget _buildMetadataChip(IconData icon, String text) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(text),
      backgroundColor: Colors.grey[900],
      labelStyle: const TextStyle(color: Colors.white),
      side: BorderSide.none,
    );
  }

  Widget _buildSynopsisSection(TextTheme textTheme) {
    return ExpansionTile(
      title: Text(
        'Synopsis',
        style: textTheme.titleLarge?.copyWith(color: Colors.white),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            manga.description.isNotEmpty ? manga.description : 'No description available',
            style: textTheme.bodyLarge?.copyWith(color: Colors.grey[400]),
          ),
        ),
      ],
    );
  }

  Widget _buildChapterControls(ChapterController controller) {
    return Consumer<ChapterController>(
      builder: (context, controller, _) {
        return Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: controller.translatedLanguage,
                dropdownColor: Colors.grey[900],
                decoration: InputDecoration(
                  labelText: 'Language',
                  filled: true,
                  fillColor: Colors.grey[900],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'en', child: Text('English')),
                  DropdownMenuItem(value: 'id', child: Text('Bahasa Indonesia')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    controller.setTranslatedLanguage(value);
                    controller.fetchChapters(manga.id);
                  }
                },
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.sort),
              label: const Text('Sort'),
              onPressed: () => _showSortOptions(context, controller),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[900],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildChapterList(ChapterController controller, BuildContext context) {
    return Consumer<ChapterController>(
      builder: (context, controller, _) {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.chapters.isEmpty) {
          return Center(
            child: Text(
              'No chapters available',
              style: TextStyle(color: Colors.grey[400]),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chapters (${controller.chapters.length})',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: controller.chapters.length,
              separatorBuilder: (context, index) => const Divider(height: 24),
              itemBuilder: (context, index) {
                final chapter = controller.chapters[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  tileColor: Colors.grey[900],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  leading: const Icon(Icons.article, color: Colors.white),
                  title: Text(
                    'Chapter ${chapter.chapterNumber}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    chapter.title,
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                  trailing: const Icon(Icons.chevron_right, color: Colors.white),
                  onTap: () {
                    controller.setSelectedChapter(chapter.id);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MangaReaderScreen(chapterId: chapter.id),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }

// Update sorting implementation
  void _showSortOptions(BuildContext context, ChapterController controller) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Sort Chapters',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Ascending'),
                leading: const Icon(Icons.arrow_upward),
                onTap: () {
                  controller.sortChapters(ascending: true);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Descending'),
                leading: const Icon(Icons.arrow_downward),
                onTap: () {
                  controller.sortChapters(ascending: false);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _addToBookmarks(BuildContext context) {
    final bookmarkController = Provider.of<BookmarkController>(context, listen: false);
    final isBookmarked = bookmarkController.bookmarks.any((b) => b.manga.id == manga.id);

    if (isBookmarked) {
      bookmarkController.removeBookmark(manga.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Removed from bookmarks')),
      );
    } else {
      bookmarkController.addBookmark(manga);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Added to bookmarks')),
      );
    }
  }

  void _shareManga(BuildContext context) {
    final String mangaDexUrl = 'https://mangadex.org/title/${manga.id}';

    // Copy to clipboard
    FlutterClipboard.copy(mangaDexUrl).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Copied to clipboard: $mangaDexUrl'),
          duration: Duration(seconds: 2),
        ),
      );
    });
  }
}