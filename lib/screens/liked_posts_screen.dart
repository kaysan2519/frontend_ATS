import 'package:flutter/material.dart';

import '../models/post.dart';
import '../services/api_service.dart';
import '../widgets/post_card.dart';
import 'detail_post_screen.dart';

class LikedPostsScreen extends StatefulWidget {
  const LikedPostsScreen({super.key});

  @override
  State<LikedPostsScreen> createState() => _LikedPostsScreenState();
}

class _LikedPostsScreenState extends State<LikedPostsScreen> {
  List<Post> likedPosts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadLikedPosts();
  }

  // =========================
  // LOAD POSTS DARI API
  // =========================

  Future<void> loadLikedPosts() async {
    setState(() {
      isLoading = true;
    });

    try {
      final allPosts = await ApiService.getPosts();
      setState(() {
        likedPosts = allPosts.where((p) => p.isLiked).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> toggleLike(Post post) async {
    final wasLiked = post.isLiked;

    setState(() {
      post.isLiked = !wasLiked;
      post.likes = post.isLiked ? 1 : 0;
      if (wasLiked) {
        likedPosts.removeWhere((p) => p.id == post.id);
      }
    });

    try {
      final success = wasLiked
          ? await ApiService.unlikePost(post.id)
          : await ApiService.likePost(post.id);

      if (!success && mounted) {
        loadLikedPosts();
      }
    } catch (_) {
      if (mounted) {
        loadLikedPosts();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Artikel Disukai')),
      body: Stack(
        children: [
          // Background Watermark Logo
          Positioned.fill(
            child: IgnorePointer(
              child: Center(
                child: Opacity(
                  opacity: 0.05,
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 280,
                    height: 280,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : likedPosts.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.favorite_border, size: 70, color: Colors.grey),
                      SizedBox(height: 12),
                      Text(
                        'Belum ada artikel disukai',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Artikel yang kamu like akan muncul di sini.',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: loadLikedPosts,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: likedPosts.length,
                    itemBuilder: (context, index) {
                      final post = likedPosts[index];

                      return PostCard(
                        post: post,
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailPostScreen(post: post),
                            ),
                          );
                          loadLikedPosts();
                        },
                        onLike: () {
                          toggleLike(post);
                        },
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }
}
