import 'package:flutter/material.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,

      destinations: [
        NavigationDestination(
          icon: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.asset(
              'assets/images/logo.png',
              width: 22,
              height: 22,
              color: Colors.grey.shade600,
              colorBlendMode: BlendMode.srcIn,
            ),
          ),
          selectedIcon: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.asset(
              'assets/images/logo.png',
              width: 24,
              height: 24,
            ),
          ),
          label: 'Home',
        ),

        const NavigationDestination(
          icon: Icon(Icons.add_box_outlined),
          selectedIcon: Icon(Icons.add_box),
          label: 'Buat',
        ),

        const NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Profil',
        ),
      ],
    );
  }
}