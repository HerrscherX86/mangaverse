class Chapter {
  final String id;
  final String chapterNumber;
  final String title;
  final List<String> pageUrls;
  final DateTime? publishDate; // Add if available

  Chapter({
    required this.id,
    required this.chapterNumber,
    required this.title,
    required this.pageUrls,
    this.publishDate,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json['id'],
      chapterNumber: (json['attributes']['chapter'] ?? '0').toString(),
      title: json['attributes']['title'] ?? 'No Title',
      pageUrls: (json['pageUrls'] as List<dynamic>?)?.cast<String>() ?? [],
      publishDate: json['attributes']['publishAt'] != null
          ? DateTime.parse(json['attributes']['publishAt'])
          : null,
    );
  }
}