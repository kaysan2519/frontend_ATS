import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/post.dart';
import '../models/comment.dart';

class ApiService {
  // IP Wi-Fi / LAN komputer Anda saat ini
  static const String serverLanIp = '10.206.33.80';
  static const int port = 3000;

  static String _baseUrl =
      kIsWeb ? 'http://localhost:$port/api' : 'http://127.0.0.1:$port/api';
  static bool _discovered = false;

  /// Otomatis mendeteksi endpoint yang aktif secara paralel:
  /// - Web: http://localhost:3000/api
  /// - Android HP via Wi-Fi: http://192.168.1.92:3000/api
  /// - Android HP via USB (adb reverse): http://127.0.0.1:3000/api
  /// - Android Emulator: http://10.0.2.2:3000/api
  static Future<String> getBaseUrl() async {
    if (kIsWeb) {
      return 'http://localhost:$port/api';
    }

    if (_discovered) {
      return _baseUrl;
    }

    final candidates = [
      'http://$serverLanIp:$port/api', // HP Fisik via Wi-Fi
      'http://127.0.0.1:$port/api',    // USB via adb reverse
      'http://10.0.2.2:$port/api',     // Android Emulator
      'http://localhost:$port/api',    // Localhost
    ];

    try {
      final results = await Future.wait(
        candidates.map((candidate) async {
          try {
            final res = await http
                .get(Uri.parse('$candidate/health'))
                .timeout(const Duration(milliseconds: 2000));
            if (res.statusCode == 200) {
              return candidate;
            }
          } catch (_) {}
          return null;
        }),
      );

      final workingCandidate = results.firstWhere(
        (c) => c != null,
        orElse: () => null,
      );

      if (workingCandidate != null) {
        _baseUrl = workingCandidate;
        _discovered = true;
        debugPrint('[ApiService] Terhubung ke: $_baseUrl');
        return _baseUrl;
      }
    } catch (_) {}

    // Fallback jika belum terdeteksi (jangan kunci _discovered agar bisa coba lagi)
    return 'http://$serverLanIp:$port/api';
  }

  static String get baseUrl => _baseUrl;

  // =========================================================
  // GET POSTS
  // =========================================================

  static Future<List<Post>> getPosts() async {
    final base = await getBaseUrl();
    final response = await http.get(Uri.parse('$base/posts'));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);

      if (json['success'] ?? false) {
        final List<dynamic> data = json['data'] ?? [];

        return data
            .map(
              (item) => Post(
                id: item['id'],
                title: item['title'],
                content: item['content'],
                author: item['author'] ?? 'Admin',
                image:
                    item['image'] ??
                    'https://via.placeholder.com/500x300?text=Article',
                categoryId: item['categoryId'] ?? 1,
                categoryName:
                    item['category'] ?? item['categoryName'] ?? 'Umum',
                likes: item['likes'] ?? 0,
                isLiked: item['isLiked'] ?? false,
              ),
            )
            .toList();
      } else {
        throw Exception(json['message'] ?? 'Gagal memuat artikel');
      }
    } else {
      throw Exception('Gagal memuat artikel');
    }
  }

  // =========================================================
  // GET POST BY ID
  // =========================================================

  static Future<Post> getPostById(int id) async {
    final base = await getBaseUrl();
    final response = await http.get(Uri.parse('$base/posts/$id'));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);

      if (json['success'] ?? false) {
        final item = json['data'];

        return Post(
          id: item['id'],
          title: item['title'],
          content: item['content'],
          author: item['author'] ?? 'Admin',
          image:
              item['image'] ??
              'https://via.placeholder.com/500x300?text=Article',
          categoryId: item['categoryId'] ?? 1,
          categoryName: item['categoryName'] ?? 'Umum',
          likes: item['likes'] ?? 0,
          isLiked: item['isLiked'] ?? false,
        );
      } else {
        throw Exception(json['message'] ?? 'Gagal memuat artikel');
      }
    } else {
      throw Exception('Gagal memuat artikel');
    }
  }

  // =========================================================
  // CREATE POST
  // =========================================================

  static Future<Post> createPost({
    required String title,
    required String content,
    required int categoryId,
    String? imageUrl,
  }) async {
    final base = await getBaseUrl();
    try {
      if (imageUrl != null && imageUrl.isNotEmpty) {
        // Kirim dengan JSON, image adalah URL string
        final response = await http.post(
          Uri.parse('$base/posts'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'categoryId': categoryId,
            'title': title,
            'content': content,
            'image': imageUrl,
          }),
        );

        if (response.statusCode == 201 || response.statusCode == 200) {
          final json = jsonDecode(response.body);
          final item = json['data'];

          return Post(
            id: item['id'],
            title: item['title'] ?? title,
            content: item['content'] ?? content,
            author: 'Kaysan',
            image: item['image'] ?? imageUrl,
            categoryId: categoryId,
            categoryName: item['category'] ?? 'Umum',
            likes: 0,
            isLiked: false,
          );
        } else {
          throw Exception('Gagal membuat artikel');
        }
      } else {
        // Tanpa image
        final response = await http.post(
          Uri.parse('$base/posts'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'categoryId': categoryId,
            'title': title,
            'content': content,
          }),
        );

        if (response.statusCode == 201 || response.statusCode == 200) {
          final json = jsonDecode(response.body);
          final item = json['data'];

          return Post(
            id: item['id'],
            title: item['title'] ?? title,
            content: item['content'] ?? content,
            author: 'Kaysan',
            image:
                item['image'] ??
                'https://via.placeholder.com/500x300?text=Article',
            categoryId: categoryId,
            categoryName: item['category'] ?? 'Umum',
            likes: 0,
            isLiked: false,
          );
        } else {
          throw Exception('Gagal membuat artikel');
        }
      }
    } catch (e) {
      throw Exception('Gagal membuat artikel');
    }
  }

  // =========================================================
  // UPDATE POST
  // =========================================================

  static Future<Post> updatePost({
    required int id,
    required String title,
    required String content,
    required int categoryId,
    String? imageUrl,
  }) async {
    final base = await getBaseUrl();
    final Map<String, dynamic> body = {
      'categoryId': categoryId,
      'title': title,
      'content': content,
      'image': imageUrl,
    };

    final response = await http.put(
      Uri.parse('$base/posts/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final item = json['data'];

      return Post(
        id: item['id'] ?? id,
        title: item['title'] ?? title,
        content: item['content'] ?? content,
        author: item['author'] ?? 'Admin',
        image:
            item['image'] ?? 'https://via.placeholder.com/500x300?text=Article',
        categoryId: item['categoryId'] ?? categoryId,
        categoryName: item['category'] ?? item['categoryName'] ?? 'Umum',
        likes: item['likes'] ?? 0,
        isLiked: item['isLiked'] ?? false,
      );
    } else {
      throw Exception('Gagal memperbarui artikel');
    }
  }

  // =========================================================
  // DELETE POST
  // =========================================================

  static Future<bool> deletePost(int id) async {
    final base = await getBaseUrl();
    final response = await http.delete(Uri.parse('$base/posts/$id'));

    return response.statusCode == 200 || response.statusCode == 204;
  }

  // =========================================================
  // GET COMMENTS BY POST ID
  // =========================================================

  static Future<List<Comment>> getComments(int postId) async {
    final base = await getBaseUrl();
    final response = await http.get(Uri.parse('$base/comments/$postId'));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);

      if (json['success'] ?? false) {
        final List<dynamic> data = json['data'] ?? [];

        return data
            .map(
              (item) => Comment(
                id: item['id'],
                postId: item['postId'] ?? postId,
                author: item['name'] ?? 'Anonymous',
                content: item['comment'] ?? '',
                createdAt: item['createdAt'] ?? 'Baru saja',
              ),
            )
            .toList();
      } else {
        return [];
      }
    } else {
      return [];
    }
  }

  // =========================================================
  // GET CATEGORIES
  // =========================================================

  static Future<List<Map<String, dynamic>>> getCategories() async {
    final base = await getBaseUrl();
    final response = await http.get(Uri.parse('$base/categories'));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['success'] ?? false) {
        return List<Map<String, dynamic>>.from(json['data']);
      }
    }
    return [];
  }

  // =========================================================
  // DELETE COMMENT
  // =========================================================

  static Future<bool> deleteComment(int id) async {
    final base = await getBaseUrl();
    final response = await http.delete(Uri.parse('$base/comments/$id'));

    return response.statusCode == 200 || response.statusCode == 204;
  }

  // =========================================================
  // ADD COMMENT
  // =========================================================

  static Future<Comment> addComment({
    required int postId,
    required String author,
    required String content,
  }) async {
    final base = await getBaseUrl();
    final response = await http.post(
      Uri.parse('$base/comments/$postId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'name': author, 'comment': content}),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final item = json['data'];

      return Comment(
        id: item['id'] ?? DateTime.now().millisecondsSinceEpoch,
        postId: postId,
        author: author,
        content: content,
        createdAt: 'Baru saja',
      );
    } else {
      throw Exception('Gagal menambahkan komentar');
    }
  }

  // =========================================================
  // LIKE POST
  // =========================================================

  static Future<bool> likePost(int postId) async {
    final base = await getBaseUrl();
    final response = await http.post(Uri.parse('$base/likes/$postId'));

    return response.statusCode == 200 || response.statusCode == 201;
  }

  // =========================================================
  // UNLIKE POST
  // =========================================================

  static Future<bool> unlikePost(int postId) async {
    final base = await getBaseUrl();
    final response = await http.delete(Uri.parse('$base/likes/$postId'));

    return response.statusCode == 200 || response.statusCode == 204;
  }

  // =========================================================
  // GET LIKES
  // =========================================================

  static Future<int> getLikesCount(int postId) async {
    final base = await getBaseUrl();
    final response = await http.get(Uri.parse('$base/likes/$postId'));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['success'] ?? false) {
        if (json['data'] != null && json['data'] is Map) {
          return json['data']['likes'] ?? 0;
        }
        return json['likes'] ?? 0;
      }
    }
    return 0;
  }

  // =========================================================
  // FAVORITE POST
  // =========================================================

  static Future<bool> favoritePost(int postId) async {
    final base = await getBaseUrl();
    final response = await http.post(Uri.parse('$base/favorites/$postId'));

    return response.statusCode == 200 || response.statusCode == 201;
  }

  // =========================================================
  // UNFAVORITE POST
  // =========================================================

  static Future<bool> unfavoritePost(int postId) async {
    final base = await getBaseUrl();
    final response = await http.delete(Uri.parse('$base/favorites/$postId'));

    return response.statusCode == 200 || response.statusCode == 204;
  }

  // =========================================================
  // GET FAVORITES
  // =========================================================

  static Future<bool> isFavorited(int postId) async {
    final base = await getBaseUrl();
    final response = await http.get(Uri.parse('$base/favorites/$postId'));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['success'] ?? false) {
        return json['isFavorited'] ?? false;
      }
    }
    return false;
  }
}
