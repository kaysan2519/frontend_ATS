import 'package:flutter/material.dart';
import '../models/post.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback? onTap;
  final VoidCallback? onLike;

  const PostCard({super.key, required this.post, this.onTap, this.onLike});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =========================
            // GAMBAR
            // =========================
            Image.network(
              post.image,
              width: double.infinity,
              height: 180,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 180,
                  color: Colors.blue.shade50,
                  child: Center(
                    child: Opacity(
                      opacity: 0.7,
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: 60,
                        height: 60,
                      ),
                    ),
                  ),
                );
              },
            ),

            // =========================
            // INFORMASI ARTIKEL
            // =========================
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Judul
                  Text(
                    post.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Kategori
                  Text(
                    post.categoryName,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Isi
                  Text(
                    post.content,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 14),

                  // =========================
                  // PENULIS + LIKE
                  // =========================
                  Row(
                    children: [
                      const Icon(Icons.person_outline, size: 18),

                      const SizedBox(width: 5),

                      Expanded(
                        child: Text(
                          post.author,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      // LIKE
                      InkWell(
                        onTap: onLike,
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: Row(
                            children: [
                              Icon(
                                post.isLiked
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: post.isLiked ? Colors.red : null,
                                size: 20,
                              ),

                              const SizedBox(width: 4),
                              Text('${post.likes}'),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // KOMENTAR
                      const Row(
                        children: [
                          Icon(Icons.comment_outlined, size: 20),

                          SizedBox(width: 4),

                          Text('Komentar'),
                        ],
                      ),
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
}
