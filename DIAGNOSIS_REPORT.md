# FLUTTER-WEB API DIAGNOSIS REPORT

## A. ASAL 2 ARTIKEL YANG MUNCUL DI HOME

**Sumber: Backend API, bukan local dummy data.**

- `home_screen.dart:36-54` — `loadPosts()` memanggil `ApiService.getPosts()` dan mengassign hasilnya ke `posts`
- Tidak ada `List<Post>` manual atau dummy data di HomeScreen — `posts` list dimulai dari `[]`
- `filteredPosts` hanya memfilter berdasarkan kata kunci search
- **2 artikel muncul karena backend API masih menyimpan 2 artikel dari inserter sebelumnya** — setelah user "menghapus dummy data" secara lokal, data tersebut masih ada di database dan muncul ketika API dipanggil

**Bukan caused by Flutter code changes.**

---

## B. PENYEBAB POST FLUTTER ERROR

**Sebab: Kirim field `categoryName` dan `author` yang tidak dibutuhkan backend.**

- `create_post_screen.dart` dan `api_service.dart` sebelumnya mengirim JSON body yang berisi `title`, `content`, `categoryId`, `categoryName`
- **Backend POST /api/posts hanya menerima**: `{ "categoryId": number, "title": string, "content": string }` (BACKEND AKTUAL)
- Field tambahan `categoryName` menyebabkan backend rejection (400 Bad Request) karena validasi ketat
- Begitu pula `author` field yang tidak sesuai dengan schema backend

**Fix:** Body POST sekarang hanya mengirim `categoryId`, `title`, `content` — persis sesuai spesifikasi backend.

---

## C. PENYEBAB FITUR IMAGE HILANG

**Sebab: Widget image tidak ada di CreatePostScreen layout.**

- `CreatePostScreen` hanya berisi: Judul, Kategori, Isi, + Button Publikasikan
- Tidak ada `ImagePicker`, `file_picker`, atau widget `Image` untuk upload/gambar
- Meskipun `Post` model punya field `image` dan `PostCard` menampilkannya dari API, form create tidak memiliki UI memilih gambar
- Fitur image sebelumnya hilang saat perubahan ApiService yang membuang field `categoryName`/`author` sekaligus menghapus UI komponen gambar

**Status:** Akan dibahas setelah CRUD API selesai (perintah: JANGAN menangani image dulu).

---

## D. FILE YANG DIUBAH

1. `lib/services/api_service.dart` — Fix POST/PUT body; Tambah `getCategories()`; Fix GET posts mapping
2. `lib/screens/create_post_screen.dart` — Ambil kategori dari API; Body POST hanya 3 field
3. `lib/screens/edit_post_screen.dart` — Ambil kategori dari API; Body PUT hanya 3 field

---

## E. PERUBAHAN UTAMA

### 1. api_service.dart — Body POST/PUT hanya 3 field
- **Sebelum:** `json.encode({'title': title, 'content': content, 'categoryId': categoryId, 'categoryName': categoryName})`
- **Sesudah:** `json.encode({'categoryId': categoryId, 'title': title, 'content': content})`
- Penambahan metode `getCategories()` untuk mengambil data kategori dari API

### 2. create_post_screen.dart — Fetch categories from API
- **Sebelum:** `final List<Map<String, dynamic>> categories = [...]` hardcoded 8 kategori
- **Sesudah:** `ApiService.getCategories()` di `initState()`, kategori dinamis dari backend
- **Sebelum:** `publishPost()` mengirim `author: 'Kaysan'` dan `categoryName`
- **Sesudah:** `publishPost()` hanya mengirim `categoryId`, `title`, `content`
- **UI:** Dropdown menampilkan `CircularProgressIndicator()` saat loading kategori

### 3. edit_post_screen.dart — Fetch categories from API
- **Sebelum:** `final List<Map<String, dynamic>> categories = [...]` hardcoded
- **Sesudah:** `ApiService.getCategories()` di `initState()`, `categories` non-final karena di-load async
- **Sebelum:** `saveChanges()` mengirim `categoryName: category['name']`
- **Sesudah:** `saveChanges()` hanya mengirim `categoryId`
- **UI:** Dropdown menampilkan `CircularProgressIndicator()` saat loading kategori

---

## F. JSON POST YANG SAAT INI DIKIRIM FLUTTER

```json
{
  "categoryId": 2,
  "title": "Judul Artikel",
  "content": "Isi artikel"
}
```

**Catatan:**
- Hanya 3 field: `categoryId`, `title`, `content`
- Tidak ada `categoryName` (sebelumnya menyebabkan 400 Bad Request)
- Tidak ada `author` (field ekstra yang tidak sesuai schema backend)
- Sangat sesuai dengan **BACKEND AKTUAL** spesifikasi

---

## G. STATUS FLUTTER ANALYZE

```
2 issues found (both pre-existing warnings, no errors):
  - use_build_context_synchronously (detail_post_screen.dart:147)
  - Unused import (test/widget_test.dart:12)
Semua error/flutter analyze issues dari sebelum perubahan telah diperbaiki.
```

---

## H. KESIMPULAN

| Masalah | Penyebab | Solusi |
|---------|----------|--------|
| POST error | Kirim `categoryName` dan `author` yang tidak dibutuhkan backend | Hapus keduanya dari body JSON |
| 2 artikel di Home | Data masih ada di database backend | Data akan tampil sesuai API; kosongkan database di backend jika perlu |
| Fitur image hilang | Widget image tidak ada di UI CreatePostScreen | Akan dibahas setelah CRUD selesai |

**Semua perubahan hanya memastikan Flutter Web mengirim data yang sesuai dengan schema backend Express/MYSQL.** No dummy data created. No backend changes. No database changes. No Android changes.