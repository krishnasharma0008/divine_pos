import 'package:divine_pos/shared/utils/currency_formatter.dart';
import 'package:divine_pos/shared/utils/scale_size.dart';
import 'package:divine_pos/shared/widgets/text.dart';
import 'package:flutter/material.dart';

// ── Shared text style across row and header ──────────────────────────────────
//const _kCellStyle =

class DiamondsRow extends StatelessWidget {
  final int srNo;
  final String shape;
  final String color;
  final String clarity;
  final double carat;
  final double price; // per stone
  final int qty;
  final VoidCallback onInc;
  final VoidCallback onDec;

  const DiamondsRow({
    super.key,
    required this.srNo,
    required this.shape,
    required this.color,
    required this.clarity,
    required this.carat,
    required this.price,
    required this.qty,
    required this.onInc,
    required this.onDec,
  });

  @override
  Widget build(BuildContext context) {
    final fem = ScaleSize.aspectRatio;

    return Container(
      height: 61 * fem,
      margin: EdgeInsets.only(top: 8 * fem),
      padding: EdgeInsets.symmetric(horizontal: 10 * fem),
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0xFFE5E5E5)),
          borderRadius: BorderRadius.circular(10 * fem),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _Cell(text: '${srNo.toString().padLeft(2, '0')}.', fem: fem),
          _Cell(text: shape, fem: fem),
          _Cell(text: color, fem: fem),
          _Cell(text: clarity, fem: fem),
          _Cell(text: carat.toStringAsFixed(2), fem: fem),
          _Cell(text: price!.inRupeesFormat(), fem: fem), // per stone price
          _QtyCell(qty: qty, onInc: onInc, onDec: onDec, fem: fem),
          _Cell(
            text: (carat * price * qty).toDouble().round().inRupeesFormat(),
            align: Alignment.centerRight,
            fem: fem,
          ),
        ],
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  final String text;
  final Alignment align;
  final double fem;

  const _Cell({
    required this.text,
    this.align = Alignment.centerLeft,
    required this.fem,
  });

  @override
  Widget build(BuildContext context) {
    // derive TextAlign from Alignment so text inside also aligns correctly
    final textAlign = align == Alignment.centerRight
        ? TextAlign.right
        : align == Alignment.center
        ? TextAlign.center
        : TextAlign.left;

    return Expanded(
      child: Align(
        alignment: align,
        child: Text(
          text,
          style: TextStyle(
            color: Color(0xFF888888),
            fontSize: 20 * fem,
            fontFamily: 'Arial',
            fontWeight: FontWeight.w400,
            height: 1.50,
          ),
          textAlign: textAlign,
        ),
      ),
    );
  }
}

class _QtyCell extends StatelessWidget {
  final int qty;
  final VoidCallback onInc;
  final VoidCallback onDec;
  final double fem;

  const _QtyCell({
    required this.qty,
    required this.onInc,
    required this.onDec,
    required this.fem,
  });

  @override
  Widget build(BuildContext context) {
    // ── Figma: white pill, mint square tap buttons, number centered ──────────
    return Expanded(
      child: Align(
        alignment: Alignment.center, // center the stepper inside the cell
        child: Container(
          width: 94 * fem, // fixed Figma width
          height: 31 * fem,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(29),
          ),
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween, // fills full width
            children: [
              // ── Minus button — disabled at 0 ─────────────────────────────
              Material(
                color: qty == 0
                    ? const Color(0xFFBEE4DD).withValues(alpha: 0.4)
                    : const Color(0xFFBEE4DD),
                child: InkWell(
                  onTap: qty == 0 ? null : onDec,
                  child: SizedBox(
                    width: 32 * fem,
                    height: 32 * fem,
                    child: Icon(
                      Icons.remove,
                      size: 16 * fem,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              // ── Qty number — centered ─────────────────────────────────────
              MyText(
                '$qty',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20 * fem,
                  fontFamily: 'Arial',
                  fontWeight: FontWeight.w400,
                  height: 1.50,
                ),
              ),
              // ── Plus button ───────────────────────────────────────────────
              Material(
                color: const Color(0xFFBEE4DD),
                child: InkWell(
                  onTap: onInc,
                  child: SizedBox(
                    width: 32 * fem,
                    height: 32 * fem,
                    child: Icon(Icons.add, size: 16 * fem, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Header row — matches Figma design
// ─────────────────────────────────────────────────────────────────────────────

class SolitaireHeader extends StatelessWidget {
  const SolitaireHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      //height: 61,
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: ShapeDecoration(
        color: const Color(0xFFBEE4DD),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _HeaderCell(label: 'Sr No'),
          _HeaderCell(label: 'Shape'),
          _HeaderCell(label: 'Color'),
          _HeaderCell(label: 'Clarity'),
          _HeaderCell(label: 'Carat'),
          _HeaderCell(label: 'Price'),
          _HeaderCell(label: 'Qty', align: Alignment.center),
          _HeaderCell(label: 'Amount', align: Alignment.centerRight),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String label;
  //final int flex;
  final Alignment align;

  const _HeaderCell({required this.label, this.align = Alignment.centerLeft});

  @override
  Widget build(BuildContext context) {
    final textAlign = align == Alignment.centerRight
        ? TextAlign.right
        : align == Alignment.center
        ? TextAlign.center
        : TextAlign.left;

    return Expanded(
      // flex: flex,
      child: Align(
        alignment: align,
        child: MyText(
          label,
          style: TextStyle(
            color: Color(0xFF888888),
            fontSize: 20 * ScaleSize.aspectRatio,
            fontFamily: 'Arial',
            fontWeight: FontWeight.w400,
            height: 1.50,
          ),
          textAlign: textAlign,
        ),
      ),
    );
  }
}
