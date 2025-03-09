import 'package:flutter/material.dart';
import 'package:mangaverse/controllers/bookmark_controller.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../controllers/manga_controller.dart';
import '../controllers/history_controller.dart';
import '../models/manga.dart';
import '../models/history.dart';
import 'manga_details_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load initial data when the screen is first loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MangaController>(context, listen: false).fetchPopularManga();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: _buildSearchButton(context),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text('MangaVerse'),
      actions: [
        IconButton(
          icon: Icon(Icons.search),
          onPressed: () => _showSearch(context),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return RefreshIndicator(
      onRefresh: () async {
        await Provider.of<MangaController>(context, listen: false).fetchPopularManga();
      },
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildPopularMangaSection(),
            _buildHistorySection(),
            _buildBookmarksSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularMangaSection() {
    return Consumer<MangaController>(
      builder: (context, controller, _) {
        if (controller.isLoading) {
          return _buildLoadingGrid();
        }
        if (controller.mangaList.isEmpty) {
          return _buildEmptyState();
        }
        return GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          padding: EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.7,
          ),
          itemCount: controller.mangaList.length,
          itemBuilder: (context, index) => _MangaGridItem(manga: controller.mangaList[index]),
        );
      },
    );
  }

  Widget _buildHistorySection() {
    return Consumer<HistoryController>(
      builder: (context, controller, _) {
        if (controller.history.isEmpty) {
          return SizedBox();
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Continue Reading',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16),
                itemCount: controller.history.length,
                itemBuilder: (context, index) => _HistoryItem(history: controller.history[index]),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBookmarksSection() {
    return Consumer<BookmarkController>(
      builder: (context, controller, _) {
        if (controller.bookmarks.isEmpty) {
          return SizedBox(); // Don't show section if no bookmarks
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Your Bookmarks',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16),
                itemCount: controller.bookmarks.length,
                itemBuilder: (context, index) => _BookmarkItem(
                  bookmark: controller.bookmarks[index],
                ),
              ),
            ),
            SizedBox(height: 24),
          ],
        );
      },
    );
  }

  Widget _buildLoadingGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.7,
      ),
      itemCount: 4, // Show 4 loading placeholders
      itemBuilder: (context, index) {
        return Card(
          color: Colors.grey[300],
          child: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'No manga found. Check your connection.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ),
    );
  }

  FloatingActionButton _buildSearchButton(BuildContext context) {
    return FloatingActionButton(
      child: Icon(Icons.search),
      onPressed: () => _showSearch(context),
    );
  }

  void _showSearch(BuildContext context) {
    showSearch(
      context: context,
      delegate: MangaSearchDelegate(
        Provider.of<MangaController>(context, listen: false),
        Provider.of<HistoryController>(context, listen: false),
      ),
    );
  }
}

class _MangaGridItem extends StatelessWidget {
  final Manga manga;

  const _MangaGridItem({required this.manga});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToDetails(context),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                child: CachedNetworkImage(
                  imageUrl: 'https://uploads.mangadex.org/covers/${manga.id}/${manga.coverFileName}',
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                manga.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToDetails(BuildContext context) {
    Provider.of<HistoryController>(context, listen: false).addToHistory(manga);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MangaDetailsScreen(manga: manga),
      ),
    );
  }
}

class _HistoryItem extends StatelessWidget {
  final History history;

  const _HistoryItem({required this.history});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToDetails(context),
      child: Container(
        width: 120,
        margin: EdgeInsets.only(right: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Prevent overflow
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: 'https://uploads.mangadex.org/covers/${history.manga.id}/${history.manga.coverFileName}',
                height: 150,
                width: 120,
                fit: BoxFit.cover,
                placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            ),
            SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                history.manga.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MangaDetailsScreen(manga: history.manga),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final History history;

  const _HistoryCard({required this.history});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToDetails(context),
      child: Container(
        width: 140, // Increased width
        margin: EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: 'https://uploads.mangadex.org/covers/${history.manga.id}/${history.manga.coverFileName}',
                    height: 180, // Increased height
                    width: 140,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: LinearProgressIndicator(
                    value: 0.75,
                    backgroundColor: Colors.grey[800],
                    valueColor: AlwaysStoppedAnimation(Colors.blueAccent),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4), // Added padding
              child: Text(
                'Ch. 123',
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToDetails(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(
      builder: (context) => MangaDetailsScreen(manga: history.manga),
    ));
  }
}

class _MangaGridCard extends StatelessWidget {
  final Manga manga;

  const _MangaGridCard({required this.manga});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToDetails(context),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.grey[900],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                child: CachedNetworkImage(
                  imageUrl: 'https://uploads.mangadex.org/covers/${manga.id}/${manga.coverFileName}',
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(color: Colors.grey[800]),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    manga.title,
                    maxLines: 1,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 16),
                      SizedBox(width: 4),
                      Text('4.8', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToDetails(BuildContext context) {
    Provider.of<HistoryController>(context, listen: false).addToHistory(manga);
    Navigator.push(context, MaterialPageRoute(
      builder: (context) => MangaDetailsScreen(manga: manga),
    ));
  }
}

// Add this new widget for bookmark items
class _BookmarkItem extends StatelessWidget {
  final Bookmark bookmark;

  const _BookmarkItem({required this.bookmark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToDetails(context),
      child: Container(
        width: 120,
        margin: EdgeInsets.only(right: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl:
                'https://uploads.mangadex.org/covers/${bookmark.manga.id}/${bookmark.manga.coverFileName}',
                height: 150,
                width: 120,
                fit: BoxFit.cover,
                placeholder: (context, url) => Center(
                  child: CircularProgressIndicator(),
                ),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            ),
            SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                bookmark.manga.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MangaDetailsScreen(manga: bookmark.manga),
      ),
    );
  }
}
// Keep your existing MangaSearchDelegate class unchanged
class MangaSearchDelegate extends SearchDelegate<String> {
  final MangaController mangaController;
  final HistoryController historyController;

  MangaSearchDelegate(this.mangaController, this.historyController);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: Icon(Icons.clear, color: Colors.white),
          onPressed: () {
            query = "";
            showSuggestions(context);
          },
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back, color: Colors.white),
      onPressed: () {
        close(context, null!);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    if (query.isEmpty) {
      return Center(
        child: Text(
          'Enter a manga title to search.',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return FutureBuilder<List<Manga>>(
      future: mangaController.searchManga(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildShimmerLoading(context); // Pass context here
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: TextStyle(color: Colors.red),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              'No results found for "$query"',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        // Sort and display results
        final mangaList = _sortSearchResults(snapshot.data!, query);
        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: mangaList.length,
          itemBuilder: (context, index) {
            final manga = mangaList[index];
            return Card(
              margin: EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: Colors.grey[900],
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  // Add manga to history when tapped
                  historyController.addToHistory(manga);

                  // Navigate to details
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MangaDetailsScreen(manga: manga),
                    ),
                  );
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Manga Cover Image
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                      child: CachedNetworkImage(
                        imageUrl:
                        'https://uploads.mangadex.org/covers/${manga.id}/${manga.coverFileName}',
                        width: 100,
                        height: 150,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                      ),
                    ),
                    // Manga Details
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              manga.title,
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 8),
                            Text(
                              manga.description,
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[400]),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildShimmerLoading(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: 5, // Show 5 shimmer placeholders
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[800]!,
          highlightColor: Colors.grey[700]!,
          child: Card(
            margin: EdgeInsets.only(bottom: 16),
            color: Colors.grey[900],
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 100,
                  height: 150,
                  color: Colors.grey[800],
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 20,
                          color: Colors.grey[800],
                        ),
                        SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          height: 16,
                          color: Colors.grey[800],
                        ),
                        SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          height: 16,
                          color: Colors.grey[800],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Manga> _sortSearchResults(List<Manga> results, String query) {
    final lowerQuery = query.toLowerCase();
    return results..sort((a, b) {
      final aTitle = a.title.toLowerCase();
      final bTitle = b.title.toLowerCase();

      // Prioritize exact matches first
      if (aTitle == lowerQuery) return -1;
      if (bTitle == lowerQuery) return 1;

      // Then titles starting with the query
      final aStartsWith = aTitle.startsWith(lowerQuery) ? 0 : 1;
      final bStartsWith = bTitle.startsWith(lowerQuery) ? 0 : 1;
      if (aStartsWith != bStartsWith) return aStartsWith - bStartsWith;

      // Finally, sort by how early the query appears in the title
      return aTitle.indexOf(lowerQuery).compareTo(bTitle.indexOf(lowerQuery));
    });
  }
}