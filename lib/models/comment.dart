class Comment {
  final int id;
  final int postId;
  final String author;
  final String content;
  final String createdAt;

  Comment({
    required this.id,
    required this.postId,
    required this.author,
    required this.content,
    required this.createdAt,
  });
}