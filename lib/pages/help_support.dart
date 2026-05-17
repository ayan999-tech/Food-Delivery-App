import 'package:flutter/material.dart';

class HelpSupport extends StatelessWidget {
  const HelpSupport({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        title: const Text("Help & Support"),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [

            const SizedBox(height: 16),

            _sectionTitle("Frequently Asked Questions"),

            _faqTile(
              question: "How do I place an order?",
              answer:
              "Select a restaurant, add items to your cart, and proceed to checkout.",
            ),
            _faqTile(
              question: "Can I cancel an order?",
              answer:
              "Once an order is placed, it cannot be canceled.",
            ),
            _faqTile(
              question: "How can I view my past orders?",
              answer:
              "Go to Profile → Order History to view all past orders.",
            ),
            _faqTile(
              question: "Why can I order from only one restaurant?",
              answer:
              "Each order can be placed from one restaurant at a time.",
            ),

            const SizedBox(height: 20),

            _sectionTitle("Contact Support"),

            _infoTile(
              icon: Icons.email,
              title: "Email Support",
              subtitle: "support@quickbite.com",
            ),
            _infoTile(
              icon: Icons.phone,
              title: "Phone Support",
              subtitle: "+92 334 1228426",
            ),
            _infoTile(
              icon: Icons.access_time,
              title: "Support Hours",
              subtitle: "10:00 AM – 10:00 PM",
            ),

            const SizedBox(height: 20),


            const Text(
              "QuickBite v1.0.0\nPowered by Flutter",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 20),
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

  Widget _faqTile({required String question, required String answer}) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        leading: const Icon(Icons.help_outline, color: Colors.red),
        title: Text(
          question,
          style: const TextStyle(color: Colors.black),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              answer,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.red),
        title: Text(title, style: const TextStyle(color: Colors.black)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.black54)),
      ),
    );
  }

  Widget _actionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  } ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
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

