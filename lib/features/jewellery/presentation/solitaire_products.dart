import 'package:divine_pos/shared/utils/currency_formatter.dart';
import 'package:divine_pos/shared/utils/scale_size.dart';
import 'package:divine_pos/shared/widgets/text.dart';
import 'package:flutter/material.dart';

// ── Data model passed to the customisation screen ────────────────────────────
class DiamondRowData {
  final int srNo;
  final String shape;
  final String color;
  final String clarity;
  final double carat;
  final double price;
  final int qty;

  const DiamondRowData({
    required this.srNo,
    required this.shape,
    required this.color,
    required this.clarity,
    required this.carat,
    required this.price,
    required this.qty,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// DiamondsRow
// ─────────────────────────────────────────────────────────────────────────────

class DiamondsRow extends StatelessWidget {
  final int srNo;
  final String shape;
  final String color;
  final String clarity;
  final double carat;
  final double price;
  final int qty;
  final VoidCallback onInc;
  final VoidCallback onDec;
  final VoidCallback onCart;
  final VoidCallback onCustomise;

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
    required this.onCart,
    required this.onCustomise,
  });

  DiamondRowData get _rowData => DiamondRowData(
    srNo: srNo,
    shape: shape,
    color: color,
    clarity: clarity,
    carat: carat,
    price: price,
    qty: qty,
  );

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
          _Cell(text: carat.toStringAsFixed(2), fem: fem),
          _Cell(text: color, fem: fem),
          _Cell(text: clarity, fem: fem),
          _Cell(text: price.inRupeesFormat(), fem: fem),
          // ── Cart button ──────────────────────────────────────────────────
          _ActionCell(
            fem: fem,
            icon: Icons.shopping_cart_outlined,
            onTap: onCart,
          ),
          SizedBox(width: 28 * fem),
          // ── Customise button ─────────────────────────────────────────────
          _ActionCell(fem: fem, icon: Icons.tune_rounded, onTap: onCustomise),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ActionCell — fixed-width icon button, icon is configurable
// ─────────────────────────────────────────────────────────────────────────────

class _ActionCell extends StatelessWidget {
  final double fem;
  final IconData icon;
  final VoidCallback onTap;

  static const double _iconSize = 32;

  const _ActionCell({
    required this.fem,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: _iconSize * fem,
        height: _iconSize * fem,
        decoration: BoxDecoration(
          color: const Color(0xFFBEE4DD),
          borderRadius: BorderRadius.circular(8 * fem),
        ),
        child: Icon(icon, size: 18 * fem, color: Colors.white),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared _Cell
// ─────────────────────────────────────────────────────────────────────────────

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
            color: const Color(0xFF888888),
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

// ─────────────────────────────────────────────────────────────────────────────
// _QtyCell
// ─────────────────────────────────────────────────────────────────────────────

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
    return Expanded(
      child: Align(
        alignment: Alignment.center,
        child: Container(
          width: 94 * fem,
          height: 31 * fem,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(29),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
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
// SolitaireHeader
// ─────────────────────────────────────────────────────────────────────────────

class SolitaireHeader extends StatelessWidget {
  const SolitaireHeader({super.key});

  static const double _actionCellWidth = 32;

  @override
  Widget build(BuildContext context) {
    final fem = ScaleSize.aspectRatio;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: ShapeDecoration(
        color: const Color(0xFFBEE4DD),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const _HeaderCell(label: 'Sr No'),
          const _HeaderCell(label: 'Shape'),
          const _HeaderCell(label: 'Carat'),
          const _HeaderCell(label: 'Color'),
          const _HeaderCell(label: 'Clarity'),
          const _HeaderCell(label: 'Amount'),
          // Matches the two _ActionCell widths + gap between them in the row
          SizedBox(width: _actionCellWidth * fem),
          SizedBox(width: 28 * fem),
          SizedBox(width: _actionCellWidth * fem),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String label;
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
      child: Align(
        alignment: align,
        child: MyText(
          label,
          style: TextStyle(
            color: const Color(0xFF888888),
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
