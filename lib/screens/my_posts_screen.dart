import 'package:flutter/material.dart';

import '../models/post.dart';
import '../services/api_service.dart';
import '../widgets/post_card.dart';
import 'detail_post_screen.dart';

class MyPostsScreen extends StatefulWidget {
  const MyPostsScreen({super.key});

  @override
  State<MyPostsScreen> createState() => _MyPostsScreenState();
}

class _MyPostsScreenState extends State<MyPostsScreen> {
  List<Post> posts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadMyPosts();
  }

  // =========================
  // LOAD POSTS DARI API
  // =========================

  Future<void> loadMyPosts() async {
    setState(() {
      isLoading = true;
    });

    try {
      final allPosts = await ApiService.getPosts();
      setState(() {
        posts = allPosts.toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> likePost(int postId) async {
    final index = posts.indexWhere((p) => p.id == postId);
    if (index == -1) return;

    final wasLiked = posts[index].isLiked;

    setState(() {
      posts[index].isLiked = !wasLiked;
      posts[index].likes = posts[index].isLiked ? 1 : 0;
    });

    try {
      final success = wasLiked
          ? await ApiService.unlikePost(postId)
          : await ApiService.likePost(postId);

      if (!success && mounted) {
        setState(() {
          posts[index].isLiked = wasLiked;
          posts[index].likes = wasLiked ? 1 : 0;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          posts[index].isLiked = wasLiked;
          posts[index].likes = wasLiked ? 1 : 0;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Artikel Saya')),
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
              : posts.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.article_outlined, size: 70, color: Colors.grey),
                      SizedBox(height: 12),
                      Text(
                        'Belum ada artikel',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: loadMyPosts,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final post = posts[index];

                      return PostCard(
                        post: post,
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailPostScreen(post: post),
                            ),
                          );
                          loadMyPosts();
                        },
                        onLike: () {
                          likePost(post.id);
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
