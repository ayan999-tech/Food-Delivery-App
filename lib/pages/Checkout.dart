import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'database_helper.dart';
import 'map_location_screen.dart';

class CheckoutItem {
  final String name;
  final double price;
  final int quantity;

  CheckoutItem({
    required this.name,
    required this.price,
    required this.quantity,
  });
}

enum PaymentMethod { none, cashOnDelivery, card }

class Checkout extends StatefulWidget {
  final String restaurantName;
  final List<CheckoutItem> items;

  const Checkout({
    super.key,
    required this.restaurantName,
    required this.items,
  });

  @override
  State<Checkout> createState() => _CheckoutState();
}

class _CheckoutState extends State<Checkout> {
  PaymentMethod _selectedPayment = PaymentMethod.none;
  final _cardNumberController = TextEditingController();
  bool _showCardForm = false;

  String selectedAddress = '';
  double selectedLatitude = 0.0;
  double selectedLongitude = 0.0;

  double get subTotal {
    double sum = 0;
    for (var item in widget.items) {
      sum += item.price * item.quantity;
    }
    return sum;
  }

  double get tax => subTotal * 0.13;

  double get deliveryFee => subTotal == 0 ? 0 : 99;

  double get total => subTotal + tax + deliveryFee;

  @override
  void dispose() {
    _cardNumberController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (selectedAddress.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select delivery location"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }


    if (_selectedPayment == PaymentMethod.none) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a payment method"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }


    if (_selectedPayment == PaymentMethod.card) {
      if (_cardNumberController.text.isEmpty ||
          _cardNumberController.text.replaceAll(' ', '').length < 16) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please enter a valid card number"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    final orderItems = widget.items.map((item) {
      return {
        'name': item.name,
        'price': item.price,
        'quantity': item.quantity,
      };
    }).toList();

    await DatabaseHelper.instance.insertOrder(
      restaurantName: widget.restaurantName,
      total: total,
      items: orderItems,
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 80),
              const SizedBox(height: 12),
              const Text(
                "Order Placed!",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                "Your order from ${widget.restaurantName} has been placed successfully.",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text("Done"),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPaymentMethodTile({
    required PaymentMethod method,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final isSelected = _selectedPayment == method;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPayment = method;
          _showCardForm = method == PaymentMethod.card;
          if (method == PaymentMethod.cashOnDelivery) {
            _cardNumberController.clear();
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.red.shade50 : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.red : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? Colors.red : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey.shade600,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.red : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Colors.red, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildCardForm() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _showCardForm ? null : 0,
      child: _showCardForm
          ? Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Card Details",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _cardNumberController,
              keyboardType: TextInputType.number,
              maxLength: 19,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                _CardNumberFormatter(),
              ],
              decoration: InputDecoration(
                labelText: "Card Number",
                hintText: "1234 5678 9012 3456",
                prefixIcon: const Icon(
                  Icons.credit_card,
                  color: Colors.red,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: Colors.red,
                    width: 2,
                  ),
                ),
                counterText: "",
              ),
            ),
          ],
        ),
      )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildLocationSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.location_on, color: Colors.red),
              SizedBox(width: 8),
              Text(
                "Delivery Location",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MapLocationScreen(),
                ),
              );

              if (result != null) {
                setState(() {
                  selectedAddress = result['address'];
                  selectedLatitude = result['latitude'];
                  selectedLongitude = result['longitude'];
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: selectedAddress.isEmpty
                    ? Colors.grey.shade50
                    : Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selectedAddress.isEmpty
                      ? Colors.grey.shade300
                      : Colors.red,
                  width: selectedAddress.isEmpty ? 1 : 2,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: selectedAddress.isEmpty
                          ? Colors.grey.shade300
                          : Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.location_on,
                      color: selectedAddress.isEmpty
                          ? Colors.grey.shade600
                          : Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      selectedAddress.isEmpty
                          ? 'Tap to select delivery location'
                          : selectedAddress,
                      style: TextStyle(
                        fontSize: 14,
                        color: selectedAddress.isEmpty
                            ? Colors.grey.shade600
                            : Colors.black87,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Checkout"),
        backgroundColor: Colors.red,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.store, color: Colors.red),
                const SizedBox(width: 8),
                Text(
                  widget.restaurantName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  widget.items.isEmpty
                      ? const Padding(
                    padding: EdgeInsets.all(32),
                    child: Text("No items in cart"),
                  )
                      : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.items.length,
                    itemBuilder: (context, index) {
                      final item = widget.items[index];
                      return ListTile(
                        title: Text(item.name),
                        subtitle: Text("Qty: ${item.quantity}"),
                        trailing: Text(
                          "${(item.price * item.quantity).toStringAsFixed(0)} PKR",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
                  const Divider(),

                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.payment, color: Colors.red),
                            SizedBox(width: 8),
                            Text(
                              "Select Payment Method",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildPaymentMethodTile(
                          method: PaymentMethod.cashOnDelivery,
                          icon: Icons.money,
                          title: "Cash on Delivery",
                          subtitle: "Pay when you receive your order",
                        ),
                        _buildPaymentMethodTile(
                          method: PaymentMethod.card,
                          icon: Icons.credit_card,
                          title: "Card Payment",
                          subtitle: "Pay online with your card",
                        ),
                        _buildCardForm(),
                      ],
                    ),
                  ),

                  const Divider(),

                  _buildLocationSection(),

                  const Divider(),

                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _billRow("Subtotal", subTotal),
                        _billRow("Tax (13%)", tax),
                        _billRow("Delivery", deliveryFee),
                        const Divider(height: 20),
                        _billRow("Total", total, isBold: true),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: widget.items.isEmpty ? null : _placeOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Place Order",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _billRow(String title, double value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            "${value.toStringAsFixed(0)} PKR",
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    final text = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if ((i + 1) % 4 == 0 && i + 1 != text.length) {
        buffer.write(' ');
      }
    }

    final string = buffer.toString();
    return TextEditingValue(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}

