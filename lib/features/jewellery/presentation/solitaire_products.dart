import 'package:flutter/material.dart';

class DiamondsRow extends StatelessWidget {
  final int srNo;
  final String shape;
  final String color;
  final String clarity;
  final int amount;
  final int qty;
  final VoidCallback onInc;
  final VoidCallback onDec;

  const DiamondsRow({
    super.key,
    required this.srNo,
    required this.shape,
    required this.color,
    required this.clarity,
    required this.amount,
    required this.qty,
    required this.onInc,
    required this.onDec,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: const Color(0xFF888888),
          fontSize: 16,
          fontFamily: 'Arial',
          height: 1.5,
        );

    return Container(
      height: 61,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _Cell(text: '${srNo.toString().padLeft(2, '0')}.', style: textStyle),
          _Cell(text: shape, style: textStyle),
          _Cell(text: color, style: textStyle),
          _Cell(text: clarity, style: textStyle),
          _Cell(text: '₹$amount', style: textStyle),
          _QtyCell(qty: qty, onInc: onInc, onDec: onDec),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                '₹${amount * qty}',
                style: textStyle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const _Cell({required this.text, this.style});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(text, style: style),
      ),
    );
  }
}

class _QtyCell extends StatelessWidget {
  final int qty;
  final VoidCallback onInc;
  final VoidCallback onDec;

  const _QtyCell({
    required this.qty,
    required this.onInc,
    required this.onDec,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFBEE4DD),
          borderRadius: BorderRadius.circular(18),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _StepButton(icon: Icons.remove, onTap: onDec),
            SizedBox(
              width: 32,
              child: Center(
                child: Text(
                  '$qty',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
            _StepButton(icon: Icons.add, onTap: onInc),
          ],
        ),
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _StepButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: const Color(0xFF7BD0BB),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Icon(icon, size: 16, color: Colors.white),
      ),
    );
  }
}