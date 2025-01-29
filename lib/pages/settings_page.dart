import 'package:blook/component/bottom_nav_bar.dart';
import 'package:blook/component/my_setting_tile.dart';
import 'package:blook/services/auth/auth_gate.dart';
import 'package:blook/services/auth/auth_service.dart';
import 'package:blook/themes/theme_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../helper/navigation_pages.dart';

class SettingsPage extends StatelessWidget {
  final _auth = AuthService(); // Use your AuthService class

  SettingsPage({super.key});

  Future<void> logout(BuildContext context) async {
    try {
      print("Attempting to log out...");
      await _auth.logout(); // Await the asynchronous logout method
      print("Logout successful!");
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AuthGate(),
          )); // Redirect to login page
    } catch (e) {
      print("Logout failed: $e"); // Log any errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to log out: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text("Settings"),
        centerTitle: true,
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Column(
        children: [
          // Dark Mode Toggle
          MySettingsTile(
            title: "Dark Mode",
            action: CupertinoSwitch(
              value:
                  Provider.of<ThemeProvider>(context, listen: true).isDarkMode,
              onChanged: (value) =>
                  Provider.of<ThemeProvider>(context, listen: false)
                      .toggleTheme(),
            ),
          ),
          // Logout Button
          MySettingsTile(
            title: "Logout",
            action: IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => logout(context), // Use the async logout method
              tooltip: "Log out",
              color: Colors.red,
            ),
          ),
          MySettingsTile(
            title: "Blocked Users",
            action: GestureDetector(
              onTap: () => goToBlockedUserPage(context),
              child: Icon(Icons.arrow_forward, color: Theme.of(context).colorScheme.primary,),

            ),
          ),
          MySettingsTile(
            title: "Account Settings",
            action: IconButton(
              onPressed: () => goAccountSettingsPage(context),
              icon: Icon(Icons.settings, color: Theme.of(context).colorScheme.primary,),

            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNav(),
    );
  }
}
