import 'package:flutter/material.dart';
import 'dart:async';
import 'Checkout.dart';

class MenuItemModel {
  final String id;
  final String name;
  final String desc;
  final double price;
  final String image;
  final String badge;
  final String category;

  MenuItemModel({
    required this.id,
    required this.name,
    required this.desc,
    required this.price,
    required this.image,
    required this.category,
    this.badge = '',
  });
}

class PizzaHut extends StatefulWidget {
  const PizzaHut({super.key});

  @override
  State<PizzaHut> createState() => _PizzaHutState();
}

class _PizzaHutState extends State<PizzaHut> with SingleTickerProviderStateMixin {

  final ScrollController _promoScrollController = ScrollController();

  final List<MenuItemModel> menu = [
    MenuItemModel(
      id: 'fajita',
      name: 'Fajita Sicilian Pizza (Large)',
      desc: 'Spicy chicken, onions, green peppers, and a blend of mozzarella cheese.',
      price: 1899.0,
      image: 'assets/images/PizzaHutMenu/Fajita.png',
      category: 'Pizzas',
      badge: 'Bestseller',
    ),
    MenuItemModel(
      id: 'super_supreme',
      name: 'Super Supreme Pizza (Medium)',
      desc: 'Pepperoni, ham, mushrooms, green peppers, onions, black olives, and mozzarella.',
      price: 1499.0,
      image: 'assets/images/PizzaHutMenu/Supreme.png',
      category: 'Pizzas',
    ),
    MenuItemModel(
      id: 'pasta',
      name: 'Creamy Pasta',
      desc: 'Penne pasta baked in a creamy white sauce with chicken chunks and mushrooms.',
      price: 799.0,
      image: 'assets/images/PizzaHutMenu/PhPasta.png',
      category: 'Pasta',
    ),
    MenuItemModel(
      id: 'wings',
      name: 'Spicy Chicken Wings (6 pcs)',
      desc: 'Oven-baked chicken wings tossed in a fiery hot sauce.',
      price: 649.0,
      image: 'assets/images/PizzaHutMenu/Wings.png',
      category: 'Sides',
    ),
    MenuItemModel(
      id: 'pepsi_ph',
      name: 'Pepsi (1.5L)',
      desc: 'The perfect fizzy drink to complement your meal.',
      price: 299.0,
      image: 'assets/images/PizzaHutMenu/PhPepsi.png',
      category: 'Drinks',
    ),
    MenuItemModel(
      id: 'lava_cake',
      name: 'Chocolate Lava Cake',
      desc: 'Warm chocolate cake with a molten chocolate center.',
      price: 450.0,
      image: 'assets/images/PizzaHutMenu/PhCake.png',
      category: 'Desserts',
    ),
  ];

  final Map<String, int> _cart = {};

  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startPromoAutoScroll();
    });
  }

  List<CheckoutItem> _buildCheckoutItems() {
    final List<CheckoutItem> items = [];

    for (var entry in _cart.entries) {
      final menuItem = menu.firstWhere((m) => m.id == entry.key);

      items.add(
        CheckoutItem(
          name: menuItem.name,
          price: menuItem.price,
          quantity: entry.value,
        ),
      );
    }

    return items;
  }

  void _startPromoAutoScroll() {

    const duration = Duration(milliseconds: 20);
    const offsetIncrement = 2.0;

    Timer.periodic(duration, (timer) {
      if (_promoScrollController.hasClients) {
        final maxScroll = _promoScrollController.position.maxScrollExtent;
        double next = _promoScrollController.offset + offsetIncrement;

        if (next >= maxScroll) {
          _promoScrollController.jumpTo(0);
        } else {
          _promoScrollController.jumpTo(next);
        }
      }
    });
  }

  @override
  void dispose() {
    _promoScrollController.dispose();
    super.dispose();
  }
  void addItem(String id) {
    setState(() {
      _cart[id] = (_cart[id] ?? 0) + 1;
    });
  }

  void removeItem(String id) {
    if (!_cart.containsKey(id)) return;
    setState(() {
      final newQty = (_cart[id] ?? 0) - 1;
      if (newQty <= 0) {
        _cart.remove(id);
      } else {
        _cart[id] = newQty;
      }
    });
  }
  void setItemQty(String id, int qty) {
    if (qty <= 0) {
      setState(() => _cart.remove(id));
    } else {
      setState(() => _cart[id] = qty);
    }
  }

  int get totalItems => _cart.values.fold<int>(0, (p, e) => p + e);

  double get subTotal {
    double sum = 0.0;
    for (var entry in _cart.entries) {
      final item =
      menu.firstWhere((m) => m.id == entry.key, orElse: () => menu[0]);
      sum += item.price * entry.value;
    }
    return sum;
  }

  double get tax => subTotal * 0.13;
  double get deliveryFee => (subTotal >= 1000 || subTotal == 0) ? 0.0 : 99.0;
  double get total => subTotal - _computeDiscount() + tax + deliveryFee;

  double _computeDiscount() {
    double discount = 0.0;

    if (_cart.containsKey('fajita')) {
      final qty = _cart['fajita'] ?? 0;
      final item = menu.firstWhere((m) => m.id == 'fajita', orElse: () => menu[0]);
      discount += item.price * qty * 0.15;
    }
    if (_cart.containsKey('super_supreme')) {
      final qty = _cart['super_supreme'] ?? 0;
      final item = menu.firstWhere((m) => m.id == 'super_supreme', orElse: () => menu[0]);
      final free = (qty / 2).floor();
      discount += free * item.price;
    }
    return discount;
  }

  List<MenuItemModel> get filteredMenu {
    if (_selectedCategory == 'All') return menu;
    return menu.where((m) => m.category == _selectedCategory).toList();
  }

  void _showCartSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(builder: (context, setModalState) {
          Widget buildCartItem(String id, int qty) {
            final item = menu.firstWhere((m) => m.id == id);
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(item.image, width: 60, height: 60, fit: BoxFit.cover),
              ),
              title: Text(item.name, style: const TextStyle(color: Colors.black)),
              subtitle: Text("${item.price.toStringAsFixed(0)} PKR", style: const TextStyle(color: Colors.black54)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () {
                      setModalState(() {
                        final newQty = qty - 1;
                        if (newQty <= 0) {
                          _cart.remove(id);
                        } else {
                          _cart[id] = newQty;
                        }
                      });
                      setState(() {});
                    },
                    icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                  ),
                  Text(qty.toString(), style: const TextStyle(fontSize: 16, color: Colors.black)),
                  IconButton(
                    onPressed: () {
                      setModalState(() {
                        _cart[id] = qty + 1;
                      });
                      setState(() {});
                    },
                    icon: const Icon(Icons.add_circle_outline, color: Colors.red),
                  ),
                ],
              ),
            );
          }

          final entries = _cart.entries.toList();
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.65,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  Center(
                    child: Container(
                      width: 60,
                      height: 6,
                      decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(6)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text("Your Cart",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        )),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: entries.isEmpty
                        ? const Center(child: Text("Your cart is empty.", style: TextStyle(color: Colors.black87)))
                        : ListView.separated(
                      itemBuilder: (context, index) {
                        final id = entries[index].key;
                        final qty = entries[index].value;
                        return buildCartItem(id, qty);
                      },
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemCount: entries.length,
                    ),
                  ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Subtotal", style: TextStyle(color: Colors.black)),
                            Text("${subTotal.toStringAsFixed(0)} PKR", style: const TextStyle(color: Colors.black)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Discount", style: TextStyle(color: Colors.black)),
                            Text("- ${_computeDiscount().toStringAsFixed(0)} PKR", style: const TextStyle(color: Colors.black)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Tax (13%)", style: TextStyle(color: Colors.black)),
                            Text("${tax.toStringAsFixed(0)} PKR", style: const TextStyle(color: Colors.black)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Delivery", style: TextStyle(color: Colors.black)),
                            Text("${deliveryFee.toStringAsFixed(0)} PKR", style: const TextStyle(color: Colors.black)),
                          ],
                        ),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Total", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black)),
                            Text("${total.toStringAsFixed(0)} PKR", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _cart.isEmpty
                                ? null
                                : () {
                              Navigator.pop(context);

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Checkout(
                                    restaurantName: "Pizza Hut",
                                    items: _buildCheckoutItems(),
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text("Checkout", style: TextStyle(color: Colors.white)),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  // Widget for Add / Qty control
  Widget _buildAddOrQty(MenuItemModel item) {
    final qty = _cart[item.id] ?? 0;
    if (qty == 0) {
      return ElevatedButton(
        onPressed: () {
          addItem(item.id);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text('Add', style: TextStyle(color: Colors.white)),
      );
    } else {
      return Container(
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.06),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () => removeItem(item.id),
              icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
              splashRadius: 20,
              constraints: const BoxConstraints(),
            ),
            Text(qty.toString(), style: const TextStyle(fontSize: 16, color: Colors.black)),
            IconButton(
              onPressed: () => addItem(item.id),
              icon: const Icon(Icons.add_circle_outline, color: Colors.red),
              splashRadius: 20,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      );
    }
  }

  // Category chip widget
  Widget _categoryChip(String cat) {
    final active = _selectedCategory == cat;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = cat;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? Colors.red : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          cat,
          style: TextStyle(color: active ? Colors.white : Colors.black87),
        ),
      ),
    );
  }

  // Menu item card widget
  Widget _menuCard(MenuItemModel item) {
    final qty = _cart[item.id] ?? 0;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                item.image,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 100,
                  height: 80,
                  color: Colors.grey[200],
                  child: const Icon(Icons.image_not_supported),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Title & desc
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [

                      Expanded(
                        child: Text(
                          item.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (item.badge.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(item.badge, style: const TextStyle(color: Colors.white, fontSize: 12)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(item.desc, style: TextStyle(color: Colors.grey[700], fontSize: 12)),
                  const SizedBox(height: 8),
                  Text("${item.price.toStringAsFixed(0)} PKR", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                ],
              ),
            ),


            // Add / Qty
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _buildAddOrQty(item),
              transitionBuilder: (child, anim) {
                return ScaleTransition(scale: anim, child: child);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Stack(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
              child: Image.asset(
                'assets/images/PizzaHutMenu/PhBanner.png',
                width: double.infinity,
                height: 220,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: double.infinity,
                  height: 220,
                  color: Colors.red,
                  child: const Center(child: Text("Pizza Hut Banner", style: TextStyle(color: Colors.white))),
                ),
              ),
            ),

            // Back & Favorite buttons
            Positioned(
              left: 8,
              top: 30,
              child: SafeArea(
                child: CircleAvatar(
                  backgroundColor: Colors.white70,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ),
            Positioned(
              right: 12,
              top: 30,
              child: SafeArea(
                child: CircleAvatar(
                  backgroundColor: Colors.white70,
                  child: IconButton(
                    icon: const Icon(Icons.favorite_border, color: Colors.red),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Added to favorites")));
                    },
                  ),
                ),
              ),
            ),
          ],
        ),

        // Restaurant info row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              ClipOval(
                child: Image.asset(
                  'assets/images/PizzaHutMenu/PhLogo.png',
                  width: 72,
                  height: 72,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 72,
                    height: 72,
                    color: Colors.white,
                    child: const Icon(Icons.fastfood, color: Colors.red),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Pizza Hut", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
                    const SizedBox(height: 4),
                    Row(
                      children: const [
                        Icon(Icons.star, size: 16, color: Colors.orange),
                        SizedBox(width: 4),
                        Text("4.6", style: TextStyle(color: Colors.black)),
                        SizedBox(width: 10),
                        Icon(Icons.access_time, size: 16, color: Colors.grey),
                        SizedBox(width: 4),
                        Text("20-30 min", style: TextStyle(color: Colors.black)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text("Pizzas, Pasta, Wings, Desserts", style: TextStyle(color: Colors.grey[700])),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: const [
                  Chip(label: Text("Open", style: TextStyle(color: Colors.white)), backgroundColor: Colors.green),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }


  Widget _promoCarousel() {
    final promos = [
      {"title": "Large Pizza Deal 15% OFF", "img": "assets/images/PizzaHutMenu/phDeal1.png"},
      {"title": "Buy 1 Get 1 Free on Medium Pizza", "img": "assets/images/PizzaHutMenu/PhDeal2.png"},
      {"title": "Free Lava Cake with any Large Pizza", "img": "assets/images/PizzaHutMenu/PhDeal3.png"},
    ];

    return SizedBox(
      height: 160,
      child: ListView.separated(
        controller: _promoScrollController,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final p = promos[index % promos.length];
          return Container(
            width: 280,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: AssetImage(p['img']!),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.0), Colors.black.withOpacity(0.2)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  p['title']!,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: promos.length * 100,
      ),
    );
  }




  @override
  Widget build(BuildContext context) {

    final categories = ['All', 'Pizzas', 'Pasta', 'Sides', 'Drinks', 'Desserts'];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    _promoCarousel(),
                    const SizedBox(height: 12),

                    // Categories
                    SizedBox(
                      height: 44,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: categories.map((c) => _categoryChip(c)).toList(),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Menu list (scrollable)
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.only(bottom: 80, top: 6),
                        itemCount: filteredMenu.length,
                        itemBuilder: (context, index) {
                          final item = filteredMenu[index];
                          return _menuCard(item);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
      floatingActionButton: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: totalItems == 0
            ? null
            : FloatingActionButton.extended(
          onPressed: _showCartSheet,
          backgroundColor: Colors.red,
          label: Row(
            children: [
              const Icon(Icons.shopping_cart, color: Colors.white),
              const SizedBox(width: 8),
              Text("$totalItems items", style: const TextStyle(color: Colors.white)),
              const SizedBox(width: 12),
              Text("${total.toStringAsFixed(0)} PKR", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}