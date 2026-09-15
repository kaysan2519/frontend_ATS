import 'package:flutter/material.dart';

import '../models/post.dart';
import '../services/api_service.dart';
import '../widgets/post_card.dart';
import '../widgets/search_bar.dart';
import 'detail_post_screen.dart';
import 'create_post_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController searchController = TextEditingController();

  String searchText = '';
  List<Post> posts = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadPosts();
  }

  // =========================
  // LOAD DATA DARI API
  // =========================

  Future<void> loadPosts() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final data = await ApiService.getPosts();
      setState(() {
        posts = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Gagal memuat artikel. Coba lagi.';
      });
    }
  }

  // =========================
  // SEARCH
  // =========================

  List<Post> get filteredPosts {
    if (searchText.trim().isEmpty) {
      return posts;
    }

    return posts.where((post) {
      final title = post.title.toLowerCase();
      final content = post.content.toLowerCase();
      final category = post.categoryName.toLowerCase();

      final keyword = searchText.toLowerCase();

      return title.contains(keyword) ||
          content.contains(keyword) ||
          category.contains(keyword);
    }).toList();
  }

  // =========================
  // BUKA CREATE
  // =========================

  Future<void> openCreatePost() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreatePostScreen()),
    );

    if (result == true) {
      loadPosts();
    }
  }

  // =========================
  // LIKE
  // =========================

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
        // Rollback jika gagal
        setState(() {
          posts[index].isLiked = wasLiked;
          posts[index].likes = wasLiked ? 1 : 0;
        });
      }
    } catch (e) {
      if (mounted) {
        // Rollback jika error
        setState(() {
          posts[index].isLiked = wasLiked;
          posts[index].likes = wasLiked ? 1 : 0;
        });
      }
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = filteredPosts;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/images/logo.png',
                width: 32,
                height: 32,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'BlogApp',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: loadPosts,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background Logo Watermark di belakang artikel
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

          Column(
            children: [
              // =========================
              // HEADER
              // =========================
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '👋 Halo!',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text(
                  'Temukan artikel menarik untuk kamu',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 16),
                SearchBarWidget(
                  controller: searchController,
                  onChanged: (value) {
                    setState(() {
                      searchText = value;
                    });
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // =========================
          // JUMLAH ARTIKEL
          // =========================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Text(
                  'Artikel',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('${filtered.length}'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // =========================
          // DAFTAR ARTIKEL
          // =========================
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 60,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          errorMessage!,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: loadPosts,
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  )
                : filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.article_outlined,
                          size: 70,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          searchText.isEmpty
                              ? 'Belum ada artikel'
                              : 'Artikel tidak ditemukan',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: loadPosts,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 85),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final post = filtered[index];

                        return PostCard(
                          post: post,
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    DetailPostScreen(post: post),
                              ),
                            );

                            loadPosts();
                          },
                          onLike: () {
                            likePost(post.id);
                          },
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    ],
  ),

      floatingActionButton: Opacity(
        opacity: 0.82,
        child: FloatingActionButton.extended(
          elevation: 2,
          onPressed: openCreatePost,
          icon: const Icon(Icons.add),
          label: const Text('Buat Artikel'),
        ),
      ),
    );
  }
}
