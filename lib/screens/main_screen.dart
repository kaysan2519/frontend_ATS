import 'package:flutter/material.dart';
import '../widgets/bottm_nav.dart';
import 'home_screen.dart';
import 'create_post_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;

  // Dipakai untuk memaksa Home refresh setelah membuat artikel
  int homeVersion = 0;

  List<Widget> get pages {
    return [
      HomeScreen(
        key: ValueKey('home_$homeVersion'),
      ),

      const SizedBox.shrink(),

      const ProfileScreen(),
    ];
  }

  Future<void> openCreatePost() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreatePostScreen(),
      ),
    );

    // Kalau artikel berhasil dibuat
    if (result == true && mounted) {
      setState(() {
        homeVersion++;
        currentIndex = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),

      bottomNavigationBar: BottomNav(
        currentIndex: currentIndex,
        onTap: (index) {
          // Tombol "Buat"
          if (index == 1) {
            openCreatePost();
            return;
          }

          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }
}