import 'package:flutter/material.dart';
import '../../data/diamond_config.dart';

class PriceFooter extends StatelessWidget {
  final DiamondConfig config;
  final VoidCallback onCompare;

  const PriceFooter({super.key, required this.config, required this.onCompare});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFB8D8D0),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                config.priceFormatted,
                style: const TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 28,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF2A2A2A),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                '22nd September 2025',
                style: TextStyle(fontSize: 11, color: Color(0xFF6B6B6B)),
              ),
            ],
          ),
          GestureDetector(
            onTap: onCompare,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: const Color(0xFF2A2A2A), width: 1.5),
              ),
              child: const Text(
                'Compare Past Prices',
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 14,
                  color: Color(0xFF2A2A2A),
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
