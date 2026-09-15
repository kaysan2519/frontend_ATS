class Post {
  final int id;
  final String title;
  final String content;
  final String author;
  final String image;
  final int categoryId;
  final String categoryName;
  int likes;
  bool isLiked;

  Post({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.image,
    required this.categoryId,
    required this.categoryName,
    this.likes = 0,
    this.isLiked = false,
  });

  Post copyWith({
    int? id,
    String? title,
    String? content,
    String? author,
    String? image,
    int? categoryId,
    String? categoryName,
    int? likes,
    bool? isLiked,
  }) {
    return Post(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      author: author ?? this.author,
      image: image ?? this.image,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      likes: likes ?? this.likes,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}