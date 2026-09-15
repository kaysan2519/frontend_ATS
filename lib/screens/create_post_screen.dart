import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final titleController = TextEditingController();
  final contentController = TextEditingController();

  int selectedCategoryId = 1;
  List<Map<String, dynamic>> categories = [];
  bool isLoadingCategories = true;
  bool isLoading = false;

  // Image state - hanyalah URL
  String? _imageUrl;
  bool _hasImage = false;

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  Future<void> loadCategories() async {
    final fetched = await ApiService.getCategories();
    setState(() {
      categories = fetched;
      if (categories.isNotEmpty) {
        selectedCategoryId = categories.first['id'] as int;
      }
      isLoadingCategories = false;
    });
  }

  // =========================
  // MASUKKAN URL GAMAR
  // =========================

  void _setImageFromUrl() {
    showDialog(
      context: context,
      builder: (context) {
        final urlController = TextEditingController();
        return AlertDialog(
          title: const Text('Masukkan URL Gambar'),
          content: TextField(
            controller: urlController,
            decoration: const InputDecoration(hintText: 'Masukkan URL gambar...'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _imageUrl = urlController.text.trim();
                  _hasImage = true;
                });
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // =========================
  // HAPUS GAMAR
  // =========================

  void _clearImage() {
    setState(() {
      _imageUrl = null;
      _hasImage = false;
    });
  }

  // =========================
  // PUBLISH POST KE API
  // =========================

  Future<void> publishPost() async {
    final title = titleController.text.trim();
    final content = contentController.text.trim();

    if (title.isEmpty) {
      showMessage('Judul artikel wajib diisi!');
      return;
    }

    if (content.isEmpty) {
      showMessage('Isi artikel wajib diisi!');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await ApiService.createPost(
        title: title,
        content: content,
        categoryId: selectedCategoryId,
        imageUrl: _imageUrl,
      );

      if (mounted) {
        showMessage('Artikel berhasil dipublikasikan!');
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        showMessage('Gagal mempublikasikan artikel');
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Artikel'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =========================
            // JUDUL
            // =========================

            const Text(
              'Judul Artikel',
              style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: titleController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                hintText: 'Masukkan judul artikel',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            // =========================
            // KATEGORI
            // =========================

            const Text(
              'Kategori',
              style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            isLoadingCategories
                ? const CircularProgressIndicator()
                : DropdownButtonFormField<int>(
                    initialValue: selectedCategoryId,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Pilih kategori',
                    ),
                    items: categories.map((category) {
                      return DropdownMenuItem<int>(
                        value: category['id'] as int,
                        child: Text(category['name'] as String),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCategoryId = value!;
                      });
                    },
                  ),

            const SizedBox(height: 20),

            // =========================
            // ISI ARTIKEL
            // =========================

            const Text(
              'Isi Artikel',
              style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: contentController,
              minLines: 10,
              maxLines: null,
              textAlignVertical: TextAlignVertical.top,
              decoration: const InputDecoration(
                hintText: 'Tulis isi artikel di sini...',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            // =========================
            // GAMAR ARTIKEL
            // =========================

            const Text(
              'Gambar Artikel',
              style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            // Image preview - hanya URL
            _hasImage
                ? Column(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 180,
                        color: Colors.grey.shade200,
                        child: _imageUrl != null
                            ? Image.network(
                                _imageUrl!,
                                width: double.infinity,
                                height: 180,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Center(
                                    child: Icon(
                                      Icons.image_not_supported,
                                      size: 50,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                              )
                            : const Center(
                                child: Icon(
                                  Icons.image_not_supported,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                              ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'URL: ${_imageUrl ?? ''}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: _clearImage,
                            child: const Text('Hapus Gambar'),
                          ),
                        ],
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _setImageFromUrl,
                        icon: const Icon(Icons.link),
                        label: const Text('Masukkan URL'),
                      ),
                    ],
                  ),

            const SizedBox(height: 24),

            // =========================
            // BUTTON PUBLISH
            // =========================

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : publishPost,
                icon: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.publish),
                label: Text(
                  isLoading ? 'Menyimpan...' : 'Publikasikan',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}