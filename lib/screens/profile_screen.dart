import 'package:flutter/material.dart';
import 'my_posts_screen.dart';
import 'liked_posts_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
      ),
      body: Stack(
        children: [
          // Background Logo Watermark
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

          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
            const SizedBox(height: 20),

            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade200,
                image: const DecorationImage(
                  image: AssetImage('assets/images/orang_ganteng.jpeg'),
                  fit: BoxFit.cover,
                  // Atur posisi foto di sini:
                  // Alignment.topCenter  -> fokus atas (rambut/wajah atas)
                  // Alignment.center     -> fokus tengah
                  // Alignment(0, -0.3)   -> geser sedikit ke atas
                  alignment: Alignment(0,0.15),
                ),
              ),
            ),

            const SizedBox(height: 15),

            const Text(
              'Kaysan',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              'kaysan@email.com',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 35),

            Card(
              child: ListTile(
                leading: const Icon(Icons.article_outlined),
                title: const Text('Artikel Saya'),
                subtitle: const Text(
                  'Lihat artikel yang kamu buat',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const MyPostsScreen(),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            Card(
              child: ListTile(
                leading: const Icon(Icons.favorite_border),
                title: const Text('Artikel Disukai'),
                subtitle: const Text(
                  'Lihat artikel yang kamu sukai',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const LikedPostsScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ],
  ),
    );
  }
}