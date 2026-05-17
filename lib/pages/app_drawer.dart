import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login.dart';
import 'History.dart';
import 'profile.dart';
import 'Homescreen.dart';
import 'help_support.dart';

class AppDrawer extends StatelessWidget {
  AppDrawer({super.key});

  final User? user = FirebaseAuth.instance.currentUser;


  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [

          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.red,
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                user != null ? user!.email![0].toUpperCase() : "U",
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ),
            accountName: const Text(
              "User",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            accountEmail: Text(
              user?.email ?? "No Email",
              style: const TextStyle(color: Colors.white),
            ),
          ),

          _drawerTile(
            icon: Icons.home,
            title: "Home",
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            },
          ),

          _drawerTile(
            icon: Icons.receipt_long,
            title: "Order History",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const History()),
              );
            },
          ),

          _drawerTile(
            icon: Icons.person,
            title: "Profile",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Profile()),
              );
            },
          ),

          const Divider(),



          _drawerTile(
            icon: Icons.help_outline,
            title: "Help & Support",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HelpSupport()),
              );
            },
          ),

          _drawerTile(
            icon: Icons.info_outline,
            title: "About App",
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: "QuickBite",
                applicationVersion: "1.0.0",
                applicationIcon: const Icon(Icons.fastfood, color: Colors.red),
                children: const [
                  Text("QuickBite is a food delivery app built using Flutter."),
                ],
              );
            },
          ),

          const Spacer(),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              "Logout",
              style: TextStyle(color: Colors.red),
            ),
            onTap: () => _logout(context),
          ),

          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _drawerTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.red),
      title: Text(title, style: const TextStyle(color: Colors.black)),
      onTap: onTap,
    );
  }
}
