import 'package:flutter/material.dart';

import '../models/comment.dart';

class CommentItem extends StatelessWidget {
  final Comment comment;

  const CommentItem({
    super.key,
    required this.comment,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // =========================
          // FOTO / AVATAR
          // =========================
          CircleAvatar(
            radius: 22,
            child: Text(
              comment.author.isNotEmpty
                  ? comment.author[0].toUpperCase()
                  : '?',
            ),
          ),

          const SizedBox(width: 12),

          // =========================
          // KOMENTAR
          // =========================
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    comment.author,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    comment.content,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    comment.createdAt,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}