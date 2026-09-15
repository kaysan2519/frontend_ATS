import 'package:flutter/material.dart';

import '../models/post.dart';
import '../services/api_service.dart';

class EditPostScreen extends StatefulWidget {
  final Post post;

  const EditPostScreen({
    super.key,
    required this.post,
  });

  @override
  State<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  late TextEditingController titleController;
  late TextEditingController contentController;

  late int selectedCategoryId;
  bool isLoading = false;
  bool isLoadingCategories = true;

  List<Map<String, dynamic>> categories = [];

  String? _imageUrl;
  bool _hasImage = false;

  @override
  void initState() {
    super.initState();

    titleController = TextEditingController(text: widget.post.title);
    contentController = TextEditingController(text: widget.post.content);
    selectedCategoryId = widget.post.categoryId;

    if (widget.post.image.isNotEmpty &&
        !widget.post.image.contains('placeholder.com')) {
      _imageUrl = widget.post.image;
      _hasImage = true;
    }

    loadCategories();
  }

  Future<void> loadCategories() async {
    final fetched = await ApiService.getCategories();
    setState(() {
      categories = fetched;
      if (categories.isNotEmpty &&
          !categories.any((c) => c['id'] == selectedCategoryId)) {
        selectedCategoryId = categories.first['id'] as int;
      }
      isLoadingCategories = false;
    });
  }

  // =========================
  // MASUKKAN / UBAH URL GAMBAR
  // =========================

  void _setImageFromUrl() {
    showDialog(
      context: context,
      builder: (context) {
        final urlController = TextEditingController(text: _imageUrl ?? '');
        return AlertDialog(
          title: Text(_hasImage ? 'Ubah URL Gambar' : 'Masukkan URL Gambar'),
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
                final text = urlController.text.trim();
                setState(() {
                  if (text.isNotEmpty) {
                    _imageUrl = text;
                    _hasImage = true;
                  } else {
                    _imageUrl = null;
                    _hasImage = false;
                  }
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
  // HAPUS GAMBAR
  // =========================

  void _clearImage() {
    setState(() {
      _imageUrl = null;
      _hasImage = false;
    });
  }

  // =========================
  // UPDATE POST KE API
  // =========================

  Future<void> saveChanges() async {
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
      final category = categories.firstWhere(
        (c) => c['id'] == selectedCategoryId,
      );

      await ApiService.updatePost(
        id: widget.post.id,
        title: title,
        content: content,
        categoryId: category['id'],
        imageUrl: _hasImage ? _imageUrl : null,
      );

      if (mounted) {
        showMessage('Artikel berhasil diperbarui!');
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        showMessage('Gagal memperbarui artikel!');
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
        title: const Text('Edit Artikel'),
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
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: titleController,
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
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
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
            // ISI
            // =========================

            const Text(
              'Isi Artikel',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
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
            // GAMBAR ARTIKEL
            // =========================

            const Text(
              'Gambar Artikel',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
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
                            onPressed: _setImageFromUrl,
                            child: const Text('Ubah URL'),
                          ),
                          const SizedBox(width: 8),
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
            // BUTTON
            // =========================

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : saveChanges,
                icon: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(
                  isLoading ? 'Menyimpan...' : 'Simpan Perubahan',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
