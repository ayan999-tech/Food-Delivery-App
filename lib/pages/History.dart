import 'package:flutter/material.dart';
import 'database_helper.dart';

class History extends StatefulWidget {
  const History({Key? key}) : super(key: key);

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  late Future<List<Map<String, dynamic>>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  void _loadOrders() {
    setState(() {
      _ordersFuture = DatabaseHelper.instance.getOrders();
    });
  }

  void _deleteOrder(int orderId) async {
    await DatabaseHelper.instance.deleteOrder(orderId);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Order deleted")),
    );

    _loadOrders();
  }


  void _confirmDelete(int orderId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Order", style: TextStyle(color: Colors.black)),
        content: const Text(
          "Are you sure you want to delete this order?",
          style: TextStyle(color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.black54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              _deleteOrder(orderId);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  void _showOrderDetails(int orderId, String restaurant, double total) async {
    final items =
    await DatabaseHelper.instance.getOrderItems(orderId);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                restaurant,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 12),

              ...items.map((item) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          "${item['name']}  x${item['quantity']}",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Text(
                        "Rs. ${item['price'] * item['quantity']}",
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),

              const Divider(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Total",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    "Rs. $total",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        title: const Text("Order History"),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.red),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "No orders yet 🍔",
                style: TextStyle(fontSize: 18, color: Colors.black87),
              ),
            );
          }

          final orders = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];

              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.red,
                    child: Icon(Icons.receipt, color: Colors.white),
                  ),
                  title: Text(
                    order['restaurant'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  subtitle: Text(
                    order['date'].toString().substring(0, 16),
                    style: const TextStyle(color: Colors.black54),
                  ),

                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Rs. ${order['total']}",
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: () => _confirmDelete(order['id']),
                        child: const Icon(
                          Icons.delete,
                          color: Colors.grey,
                          size: 20,
                        ),
                      ),
                    ],
                  ),

                  onTap: () {
                    _showOrderDetails(
                      order['id'],
                      order['restaurant'],
                      order['total'],
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}