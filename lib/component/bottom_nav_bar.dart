import 'package:blook/pages/homepage.dart';
import 'package:blook/pages/profile_page.dart';
import 'package:blook/pages/settings_page.dart';
import 'package:blook/services/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class CustomBottomNav extends StatefulWidget {
  CustomBottomNav({Key? key}) : super(key: key);

  @override
  State<CustomBottomNav> createState() => _CustomBottomNavState();
}

class _CustomBottomNavState extends State<CustomBottomNav> {
  final _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return GNav(
      gap: 8, // Reduced gap to make it more compact
      padding: const EdgeInsets.symmetric(
          horizontal: 12, vertical: 8), // Adjust padding
      tabBorderRadius: 16, // Make buttons look compact and modern
      tabBackgroundColor: Theme.of(context)
          .colorScheme
          .secondary
          .withOpacity(0.1), // Add a subtle background
      color: Theme.of(context).colorScheme.primary, // Icon color
      activeColor: Theme.of(context).colorScheme.primary, // Active icon color
      iconSize: 20, // Reduce icon size
      textStyle: const TextStyle(fontSize: 12), // Reduce text size
      tabs: [
        GButton(
          icon: Icons.home,
          text: 'Home',
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const HomePage(),
              ),
            );
          },
        ),
        GButton(
          icon: Icons.favorite_border,
          iconColor: Colors.pink,
          text: 'Likes',
          onPressed: () {},
        ),
        const GButton(
          icon: Icons.search,
          text: 'Search',
        ),
        GButton(
          icon: Icons.man,
          text: 'Profile',
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ProfilePage(uid: _auth.getCurrentUid()),
              ),
            );
          },
        ),
        GButton(
          icon: Icons.settings,
          text: 'Settings',
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => SettingsPage(),
              ),
            );
          },
        ),
      ],
    );
  }
}
