import 'package:flutter/material.dart';

class CustomizationPanel extends StatelessWidget {
  final double r;
  final int activeTab;

  const CustomizationPanel(this.r, {super.key, required this.activeTab});

  @override
  Widget build(BuildContext context) {
    switch (activeTab) {
      case 0:
        return _mountAndSideDia();
      case 1:
        return _productDetails();
      case 2:
        return _priceBreakup();
      default:
        return const SizedBox();
    }
  }

  Widget _mountAndSideDia() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Metal Type: 18 KT Yellow Gold",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),

          Wrap(
            spacing: 10,
            children: [
              _chip("Yellow Gold", true),
              _chip("Rose Gold", false),
              _chip("White Gold", false),
            ],
          ),

          const SizedBox(height: 20),

          const Text(
            "Side Diamonds:",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          const Text("EF-VVS, Cts 0.232 | Qty 48"),
        ],
      ),
    );
  }

  Widget _productDetails() {
    return _card(
      child: Column(
        children: [
          _row("Metal Type", "18KT Yellow Gold"),
          _row("Net Weight", "3.74 Gms"),
          _row("Side Diamonds", "Qty 48 / 0.234ct"),
          _row("Ring Size", "14"),
        ],
      ),
    );
  }

  Widget _priceBreakup() {
    return _card(
      child: Column(
        children: [
          _row("Solitaire", "₹57,900"),
          _row("Mount", "₹41,275"),
          const Divider(),
          _row("Grand Total", "₹1,02,150", bold: true),
        ],
      ),
    );
  }

  Widget _chip(String title, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: active ? const Color(0xFFB79D4B) : Colors.grey.shade300,
        ),
      ),
      child: Text(title),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBFE6E0)),
        color: Colors.white,
      ),
      child: child,
    );
  }

  static Widget _row(String title, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(title),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
