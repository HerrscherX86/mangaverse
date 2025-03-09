class Chapter {
  final String id;
  final String chapterNumber;
  final String title;
  final List<String> pageUrls;

  Chapter({
    required this.id,
    required this.chapterNumber,
    required this.title,
    required this.pageUrls,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json['id'],
      chapterNumber: json['attributes']['chapter'] ?? '0',
      title: json['attributes']['title'] ?? 'No Title',
      pageUrls: [],
    );
  }
}