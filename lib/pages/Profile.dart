import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login.dart';
import 'History.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {

  final User? user = FirebaseAuth.instance.currentUser;

  bool _notificationsEnabled = true;


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
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: user == null
          ? const Center(
          child: Text(
            "No user logged in",
            style: TextStyle(color: Colors.black87),
          ))
          : SingleChildScrollView(
        child: Column(
          children: [

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30),
              decoration: const BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.white,
                    child: Text(
                      user!.email![0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "User",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user!.email!,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            _sectionTitle("Account Information"),
            _infoTile(Icons.email, "Email", user!.email!),
            _infoTile(
              Icons.perm_identity,
              "User ID",
              user!.uid.substring(0, 8) + "...",
            ),

            const SizedBox(height: 20),

            _sectionTitle("Orders"),
            _actionTile(
              icon: Icons.receipt_long,
              title: "Order History",
              subtitle: "View your past orders",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const History(),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),


            _sectionTitle("Settings"),

            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.notifications, color: Colors.red),
                title: const Text(
                  "Notifications",
                  style: TextStyle(color: Colors.black),
                ),
                subtitle: const Text(
                  "Manage notifications",
                  style: TextStyle(color: Colors.black54),
                ),
                trailing: Switch(
                  value: _notificationsEnabled,
                  activeColor: Colors.red,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                  },
                ),
              ),
            ),

            _actionTile(
              icon: Icons.lock,
              title: "Privacy",
              subtitle: "Account security",
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.lock, color: Colors.white),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Your account is secured using Firebase Authentication.",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 3),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),


            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text(
                    "Logout",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => _logout(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _infoTile(IconData icon, String title, String value) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.red),
        title: Text(title, style: const TextStyle(color: Colors.black)),
        subtitle: Text(value, style: const TextStyle(color: Colors.black54)),
      ),
    );
  }

  Widget _actionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.red),
        title: Text(title, style: const TextStyle(color: Colors.black)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.black54)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black54),
        onTap: onTap,
      ),
    );
  }
}


