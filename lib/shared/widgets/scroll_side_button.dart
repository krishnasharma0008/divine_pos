import 'package:flutter/material.dart';

class ScrollSideButton extends StatelessWidget {
  final bool isRight;
  final VoidCallback onTap;
  final double fem;

  const ScrollSideButton({
    super.key,
    required this.isRight,
    required this.onTap,
    required this.fem,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: isRight ? 0 : null,
      left: isRight ? null : 0,
      top: 8 * fem,
      bottom: 8 * fem,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 24 * fem,
          decoration: BoxDecoration(
            color: const Color(0xFFAED8CF),
            borderRadius: BorderRadius.horizontal(
              left: isRight ? Radius.circular(12 * fem) : Radius.zero,
              right: isRight ? Radius.zero : Radius.circular(12 * fem),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0x14000000),
                blurRadius: 6 * fem,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(
            isRight ? Icons.chevron_right : Icons.chevron_left,
            size: 28 * fem,
            color: const Color(0xFF3F3F3F),
          ),
        ),
      ),
    );
  }
}
