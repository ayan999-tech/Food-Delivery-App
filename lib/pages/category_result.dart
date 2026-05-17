import 'package:flutter/material.dart';

import 'KFC.dart';
import 'PizzaHut.dart';
import 'McDonald.dart';

class CategoryResult extends StatefulWidget {
  final String category;

  const CategoryResult({Key? key, required this.category}) : super(key: key);

  @override
  State<CategoryResult> createState() => _CategoryResultState();
}

class _CategoryResultState extends State<CategoryResult>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool restaurantHasCategory(String restaurantName) {
    if (widget.category == "Pizza" && restaurantName == "Pizza Hut") return true;
    if (widget.category == "Burgers" &&
        (restaurantName == "KFC" || restaurantName == "McDonald's")) return true;
    if (widget.category == "Drinks") return true;
    if (widget.category == "Desserts" && restaurantName == "McDonald's") return true;
    if (widget.category == "Fries" &&
        (restaurantName == "KFC" || restaurantName == "McDonald's")) return true;

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final restaurants = [
      {"name": "KFC", "image": "assets/images/kfc.png"},
      {"name": "Pizza Hut", "image": "assets/images/PizzaHut.png"},
      {"name": "McDonald's", "image": "assets/images/mcd.png"},
    ];

    final filtered = restaurants
        .where((r) => restaurantHasCategory(r["name"]!))
        .toList();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.red,
        title: Text(
          "${widget.category} Restaurants",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.red, Color(0xFFD32F2F)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: filtered.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              "No restaurants available 😢",
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      )
          : Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.restaurant_menu,
                        color: Colors.red,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.category,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          "${filtered.length} ${filtered.length == 1 ? 'restaurant' : 'restaurants'} available",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(1),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final rest = filtered[index];
                final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
                  CurvedAnimation(
                    parent: _controller,
                    curve: Interval(
                      index * 0.2,
                      1.0,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
                );

                return AnimatedBuilder(
                  animation: animation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, 30 * (1 - animation.value)),
                      child: Opacity(
                        opacity: animation.value,
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 15,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          if (rest["name"] == "KFC") {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const KFC()));
                          } else if (rest["name"] == "Pizza Hut") {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const PizzaHut()));
                          } else if (rest["name"] == "McDonald's") {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const McDonald()));
                          }
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 140,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.grey[300]!,
                                    width: 1.5,
                                  ),
                                ),
                                padding: const EdgeInsets.all(6),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.asset(
                                    rest["image"]!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      rest["name"]!,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.fastfood,
                                          size: 16,
                                          color: Colors.grey[600],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          "Serves ${widget.category}",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.star,
                                          size: 16,
                                          color: Colors.amber,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          "4.5",
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey[700],
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Icon(
                                          Icons.access_time,
                                          size: 16,
                                          color: Colors.grey[600],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          "25-30 min",
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
