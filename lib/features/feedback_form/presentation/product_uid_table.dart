import 'package:divine_pos/features/feedback_form/data/feedback_model.dart';
import 'package:divine_pos/shared/utils/scale_size.dart';
import 'package:flutter/material.dart';

import '../theme.dart';

final fem = ScaleSize.aspectRatio;

// ─── Add UID Row (input + Add button) ────────────────────────────────────────

class AddUidRow extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onAdd;

  const AddUidRow({super.key, required this.controller, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Enter UID',
              hintStyle: const TextStyle(
                color: FeedbackTheme.textGrey,
                fontSize: 14,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: FeedbackTheme.borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: FeedbackTheme.borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: FeedbackTheme.teal,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add, size: 16),
          label: const Text('Add'),
          style: ElevatedButton.styleFrom(
            backgroundColor: FeedbackTheme.teal,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
          ),
        ),
      ],
    );
  }
}

// ─── Product UID Table ────────────────────────────────────────────────────────

class ProductUidTable extends StatelessWidget {
  final List<ProductUIDEntry> products;
  final void Function(int index) onRemove;

  const ProductUidTable({
    super.key,
    required this.products,
    required this.onRemove,
  });

  double get _totalMrp => products.fold(0, (s, p) => s + p.mrp);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          _TableHeader(columns: const ['PRODUCT UID', 'MRP']),
          const Divider(height: 1, color: FeedbackTheme.borderColor),

          // Rows
          ...List.generate(products.length, (i) {
            final p = products[i];
            return Column(
              children: [
                _UidRow(
                  uid: p.uid,
                  mrp: p.mrp.toStringAsFixed(0),
                  onRemove: () => onRemove(i),
                ),
                if (i < products.length - 1)
                  const Divider(height: 1, color: FeedbackTheme.borderColor),
              ],
            );
          }),

          // Footer
          const Divider(height: 1, color: FeedbackTheme.borderColor),
          _UidTableFooter(totalUids: products.length, totalMrp: _totalMrp),
        ],
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  final List<String> columns;
  const _TableHeader({required this.columns});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF7FAFD),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              columns.first,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: FeedbackTheme.textGrey,
                letterSpacing: 0.5,
              ),
            ),
          ),
          if (columns.length > 1)
            Text(
              columns.last,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: FeedbackTheme.textGrey,
                letterSpacing: 0.5,
              ),
            ),
          const SizedBox(width: 32),
        ],
      ),
    );
  }
}

class _UidRow extends StatelessWidget {
  final String uid;
  final String mrp;
  final VoidCallback onRemove;

  const _UidRow({required this.uid, required this.mrp, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              uid,
              style: const TextStyle(
                fontSize: 14,
                color: FeedbackTheme.textDark,
              ),
            ),
          ),
          Text(
            mrp,
            style: const TextStyle(fontSize: 14, color: FeedbackTheme.textDark),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(
              Icons.close,
              size: 18,
              color: FeedbackTheme.textGrey,
            ),
          ),
        ],
      ),
    );
  }
}

class _UidTableFooter extends StatelessWidget {
  final int totalUids;
  final double totalMrp;

  const _UidTableFooter({required this.totalUids, required this.totalMrp});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: FeedbackTheme.tealBg,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _FooterStat(label: 'Total UIDs', value: '$totalUids'),
          const Spacer(),
          _FooterStat(
            label: 'Total MRP',
            value: '₹${totalMrp.toStringAsFixed(0)}',
            align: CrossAxisAlignment.end,
          ),
        ],
      ),
    );
  }
}

class _FooterStat extends StatelessWidget {
  final String label;
  final String value;
  final CrossAxisAlignment align;

  const _FooterStat({
    required this.label,
    required this.value,
    this.align = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: align,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: FeedbackTheme.textGrey),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: FeedbackTheme.textDark,
          ),
        ),
      ],
    );
  }
}
