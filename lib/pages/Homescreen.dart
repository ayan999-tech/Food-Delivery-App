import 'package:flutter/material.dart';

import 'KFC.dart';
import 'PizzaHut.dart';
import 'McDonald.dart';
import 'category_result.dart';

import 'History.dart';
import 'Profile.dart';
import 'app_drawer.dart';
import 'chatbot_page.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  int _selectedIndex = 0;

  final List<Map<String, dynamic>> restaurants = [
    {
      "name": "KFC",
      "image": "assets/images/kfc.png",
      "rating": "4.6",
      "time": "20-30 min",
      "desc": "Crispy Chicken, Burgers, Fries",
      "delivery_fee": "Free Delivery",
      "min_order": "Min \$10"
    },

    {
      "name": "Pizza Hut",
      "image": "assets/images/PizzaHut.png",
      "rating": "4.5",
      "time": "25-35 min",
      "desc": "Fresh Pizzas, Garlic Bread",
      "delivery_fee": "\$2.99 Delivery",
      "min_order": "Min \$15"
    },

    {
      "name": "McDonald's",
      "image": "assets/images/mcd.png",
      "rating": "4.7",
      "time": "15-25 min",
      "desc": "Burgers, Drinks, Ice-Cream",
      "delivery_fee": "\$1.50 Delivery",
      "min_order": "Min \$5"
    },
  ];


  @override
  Widget build(BuildContext context) {

    Widget currentBody;
    switch (_selectedIndex) {
      case 1:
        currentBody = const History();
        break;
      case 2:
        currentBody =  Profile();
        break;
      case 3:
        currentBody = ChatbotPage();
      default:

        currentBody = SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Promo Banners
                SizedBox(
                  height: 250,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      promoCard("assets/images/banner1.jpg"),
                      promoCard("assets/images/banner2.jpg"),
                      promoCard("assets/images/banner3.jpg"),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "Categories",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),

                SizedBox(
                  height: 100,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      categoryItem("Pizza", Icons.local_pizza),
                      categoryItem("Burgers", Icons.lunch_dining),
                      categoryItem("Drinks", Icons.local_drink),
                      categoryItem("Desserts", Icons.cake),
                      categoryItem("Fries", Icons.fastfood),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Popular Items
                const Text(
                  "Popular Items",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),

                SizedBox(
                  height: 160,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      popularItem("Pizza Slice", "assets/images/pizza.png"),
                      popularItem("Zinger Burger", "assets/images/zinger.png"),
                      popularItem("Shawarma", "assets/images/shawarma.png"),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Restaurants List
                const Text(
                  "Restaurants",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),

                ListView.builder(
                  itemCount: restaurants.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return restaurantCard(restaurants[index]);
                  },
                ),
              ],
            ),
          ),
        );
    }

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        title: const Text(
          "QuickBite",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.person, color: Colors.white),
          ),
        ],
      ),

      drawer: AppDrawer(),

      body: currentBody,

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.black54,
        type: BottomNavigationBarType.fixed,
        items: const[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.receipt), label: "Orders"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          BottomNavigationBarItem(icon: Icon(Icons.auto_awesome), label: "Yum Bot")
        ],
      ),
    );
  }


  Widget promoCard(String imgPath) {
    return Container(
      width: 300,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        imgPath,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget categoryItem(String title, IconData icon) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CategoryResult(category: title),
          ),
        );
      },
      child: Container(
        width: 90,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: Colors.red),
            const SizedBox(height: 5),
            Text(title, style: const TextStyle(color: Colors.black)),
          ],
        ),
      ),
    );
  }


  Widget popularItem(String name, String img) {
    return Container(
      width: 170,
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: AssetImage(img),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        alignment: Alignment.bottomCenter,
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0),
              Colors.black.withOpacity(0.2)
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Text(
          name,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget restaurantCard(Map<String, dynamic> rest) {
    return GestureDetector(
      onTap: () {
        if (rest["name"] == "KFC") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const KFC()),
          );
        } else if (rest["name"] == "Pizza Hut") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PizzaHut()),
          );
        } else if (rest["name"] == "McDonald's") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const McDonald()),
          );
        }
      },

      child: Card(
        margin: const EdgeInsets.only(bottom: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              child: Image.asset(
                rest["image"],
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            // Restaurant Details
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        rest["name"],
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star, color: Colors.white, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              rest["rating"],
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  Text(
                    rest["desc"],
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [

                      const Icon(Icons.access_time, size: 16, color: Colors.red),
                      const SizedBox(width: 4),
                      Text(
                        rest["time"],
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 15),

                      const Icon(Icons.delivery_dining, size: 16, color: Colors.black),
                      const SizedBox(width: 4),
                      Text(
                        rest["delivery_fee"] ?? "Delivery Fee",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 15),

                      const Icon(Icons.shopping_bag_outlined, size: 16, color: Colors.black),
                      const SizedBox(width: 4),
                      Text(
                        rest["min_order"] ?? "Min Order",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

