import 'package:divine_pos/shared/utils/currency_formatter.dart';
import 'package:flutter/material.dart';
import '../../data/diamond_config.dart';

class PriceFooter extends StatelessWidget {
  final DiamondConfig config;
  //final double? price; // null = not yet loaded
  //final double? carats;
  final double? totalPrice;
  final bool isLoading;
  final VoidCallback onCompare;

  const PriceFooter({
    super.key,
    required this.config,
    required this.onCompare,
    //this.price,
    //this.carats,
    this.totalPrice,
    this.isLoading = false,
  });

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
              // Price — shimmer while loading
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: totalPrice == null
                    ? const _PriceShimmer(key: ValueKey('loading'))
                    : Text(
                        totalPrice!.inRupeesFormat(),
                        key: ValueKey(totalPrice),
                        style: const TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: 28,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF2A2A2A),
                          letterSpacing: 0.5,
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Today\'s Rate',
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

/// Simple shimmer placeholder while price is loading
class _PriceShimmer extends StatefulWidget {
  const _PriceShimmer({super.key});

  @override
  State<_PriceShimmer> createState() => _PriceShimmerState();
}

class _PriceShimmerState extends State<_PriceShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _anim = Tween(begin: 0.3, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: 140,
        height: 32,
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A).withOpacity(0.12),
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }
}
