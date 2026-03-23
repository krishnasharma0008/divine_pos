import 'package:divine_pos/features/diamond_value/presentation/widgets/carat_range_selector.dart';
import 'package:divine_pos/shared/utils/currency_formatter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/diamond_config.dart';
import '../../../../shared/utils/scale_size.dart';
import '../../../../shared/widgets/text.dart';

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

  String formatTodayDate() {
    final now = DateTime.now();
    final day = now.day;

    String suffix = 'th';
    if (day % 10 == 1 && day != 11) suffix = 'st';
    if (day % 10 == 2 && day != 12) suffix = 'nd';
    if (day % 10 == 3 && day != 13) suffix = 'rd';

    final month = DateFormat('MMMM').format(now);
    final year = now.year;

    return '$day$suffix $month $year';
  }

  @override
  Widget build(BuildContext context) {
    final fem = ScaleSize.aspectRatio;

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
                    : MyText(
                        totalPrice!.inRupeesFormat(),
                        key: ValueKey(totalPrice),
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 30 * fem,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w500,
                          height: 0.90,
                          letterSpacing: 0.60,
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Text(
                formatTodayDate(),
                style: TextStyle(
                  color: const Color(0xFF3A3A3A),
                  fontSize: 14 * fem,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w300,
                  height: 1.93,
                  letterSpacing: 0.28,
                ),
              ),
            ],
          ),
          comparePastPriceButton(fem, onCompare),
          // GestureDetector(
          //   onTap: onCompare,
          //   child: Container(
          //     padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          //     decoration: BoxDecoration(
          //       color: Colors.white.withOpacity(0.5),
          //       borderRadius: BorderRadius.circular(30),
          //       border: Border.all(color: const Color(0xFF2A2A2A), width: 1.5),
          //     ),
          //     child: const Text(
          //       'Compare Past Prices',
          //       style: TextStyle(
          //         fontFamily: 'Georgia',
          //         fontSize: 14,
          //         color: Color(0xFF2A2A2A),
          //         letterSpacing: 0.3,
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}

Widget comparePastPriceButton(
  double fem,
  VoidCallback onPressed, {
  String label = 'Compare Past Prices',
}) {
  return Material(
    color: Colors.transparent,
    child: InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onPressed,
      child: Container(
        height: 52 * fem,
        padding: EdgeInsets.symmetric(horizontal: 26 * fem),
        decoration: ShapeDecoration(
          gradient: const LinearGradient(
            begin: Alignment(0.0, 0.5),
            end: Alignment(0.96, 1.12),
            colors: [Color(0xFFBEE4DD), Color(0xA5D1B193)],
          ),
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 1, color: Color(0xFFACA584)),
            borderRadius: BorderRadius.circular(20),
          ),
          shadows: const [
            BoxShadow(
              color: Color(0x7C000000),
              blurRadius: 4,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            //const Icon(Icons.show_chart, size: 20, color: Color(0xFF6C5022)),
            //SizedBox(width: 8 * fem),
            MyText(
              label,
              style: TextStyle(
                color: const Color(0xFF6C5022),
                fontSize: 18 * fem,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    ),
  );
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
