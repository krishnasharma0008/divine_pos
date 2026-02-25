import 'package:divine_pos/features/feedback_form/data/feedback_model.dart';
import 'package:divine_pos/shared/utils/scale_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'product_uid_table.dart';
import '../presentation/widget/shared_widgets.dart';
import '../theme.dart';

final fem = ScaleSize.aspectRatio;

// ─── Upgrade Amount display field ─────────────────────────────────────────────

class UpgradeAmountField extends StatelessWidget {
  final int questionNumber;
  final double amount;
  final bool isValid;
  final bool hasInput;

  const UpgradeAmountField({
    super.key,
    required this.questionNumber,
    required this.amount,
    required this.isValid,
    required this.hasInput,
  });

  String _format(double v) => v
      .toStringAsFixed(0)
      .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');

  @override
  Widget build(BuildContext context) {
    return FeedbackFormField(
      number: questionNumber,
      label: 'Upgrade Amount',
      required: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: 14 * fem,
              vertical: 13 * fem,
            ),
            decoration: BoxDecoration(
              color: FeedbackTheme.tealBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: FeedbackTheme.borderColor),
            ),
            child: Text(
              amount > 0 ? _format(amount) : '0',
              style: TextStyle(
                fontSize: 14 * fem,
                color: FeedbackTheme.textDark,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (hasInput && !isValid)
            Padding(
              padding: EdgeInsets.only(top: 8 * fem),
              child: Text(
                'Please select product above ₹ 49,999',
                style: TextStyle(
                  fontSize: 13 * fem,
                  color: const Color(0xFFE57373),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Upgrade Section ──────────────────────────────────────────────────────────

class UpgradeSection extends StatefulWidget {
  const UpgradeSection({super.key});

  /// Call [UpgradeSectionState.buildData()] to collect the UpgradeData
  /// before submitting the parent form.
  @override
  UpgradeSectionState createState() => UpgradeSectionState();
}

class UpgradeSectionState extends State<UpgradeSection> {
  final _oldUidCtrl = TextEditingController();
  final _oldMrpCtrl = TextEditingController();
  final _orderAmountCtrl = TextEditingController();
  final _uidCtrl = TextEditingController();

  String _newPurchaseCategory = 'Ready Product'; // 'Ready Product' | 'Order'
  List<ProductUIDEntry> _products = [];

  // ── Derived ───────────────────────────────────────────────────────────────
  bool get _isOrder => _newPurchaseCategory == 'Order';

  double get _oldMrp =>
      double.tryParse(_oldMrpCtrl.text.replaceAll(',', '').trim()) ?? 0.0;

  double get _totalNewMrp => _products.fold(0.0, (s, p) => s + p.mrp);

  double get _orderAmount =>
      double.tryParse(_orderAmountCtrl.text.replaceAll(',', '').trim()) ?? 0.0;

  double get _upgradeAmount {
    final base = _isOrder ? _orderAmount : _totalNewMrp;
    return (base - _oldMrp).clamp(0, double.infinity);
  }

  double get _newValueForValidation => _isOrder ? _orderAmount : _totalNewMrp;
  bool get _upgradeAmountValid => _newValueForValidation >= 49999;

  // ── Product table ─────────────────────────────────────────────────────────
  void _addProduct() {
    final uid = _uidCtrl.text.trim();
    if (uid.isEmpty) return;
    setState(() {
      _products.add(ProductUIDEntry(uid: uid, mrp: 67999));
      _uidCtrl.clear();
    });
  }

  // ── Public: collect data for parent submit ────────────────────────────────
  /// Returns null + shows a SnackBar if validation fails.
  UpgradeData? buildData(BuildContext context) {
    if (_oldUidCtrl.text.trim().isEmpty || _oldMrpCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill Old Product UID and MRP.')),
      );
      return null;
    }
    if (_isOrder && _orderAmountCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the Order Amount.')),
      );
      return null;
    }
    if (!_isOrder && _products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one product UID.')),
      );
      return null;
    }
    if (!_upgradeAmountValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a product above ₹ 49,999.'),
        ),
      );
      return null;
    }

    return UpgradeData(
      oldProduct: OldProductEntry(uid: _oldUidCtrl.text.trim(), mrp: _oldMrp),
      subCategory: _isOrder
          ? UpgradeSubCategory.order
          : UpgradeSubCategory.readyProduct,
      orderAmount: _isOrder ? _orderAmount : null,
      newProducts: _isOrder ? [] : List.from(_products),
    );
  }

  @override
  void dispose() {
    _oldUidCtrl.dispose();
    _oldMrpCtrl.dispose();
    _orderAmountCtrl.dispose();
    _uidCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Q10 Old Product UID/s
        FeedbackFormField(
          number: 10,
          label: 'Old Product UID/s',
          required: true,
          child: Column(
            children: [
              FeedbackInput(controller: _oldUidCtrl, hint: 'Product UID'),
              SizedBox(height: 10 * fem),
              FeedbackInput(
                controller: _oldMrpCtrl,
                hint: 'MRP',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (_) => setState(() {}),
              ),
            ],
          ),
        ),
        SizedBox(height: 28 * fem),

        // Q11 New Purchase Category (Ready Product | Order)
        FeedbackFormField(
          number: 11,
          label: 'Purchase Category',
          required: true,
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: ['Ready Product', 'Order']
                .map(
                  (c) => CategoryButton(
                    label: c,
                    selected: c == _newPurchaseCategory,
                    onTap: () => setState(() {
                      _newPurchaseCategory = c;
                      if (c != 'Order') _orderAmountCtrl.clear();
                      if (c == 'Order') _products.clear();
                    }),
                  ),
                )
                .toList(),
          ),
        ),
        SizedBox(height: 28 * fem),

        // Add Product UID (hidden when Order sub-category)
        if (!_isOrder) ...[
          AddUidRow(controller: _uidCtrl, onAdd: _addProduct),
          const SizedBox(height: 20),
          if (_products.isNotEmpty) ...[
            ProductUidTable(
              products: _products,
              onRemove: (i) => setState(() => _products.removeAt(i)),
            ),
            SizedBox(height: 28 * fem),
          ],
          // Q12 Upgrade Amount (Ready Product path)
          UpgradeAmountField(
            questionNumber: 12,
            amount: _upgradeAmount,
            isValid: _upgradeAmountValid,
            hasInput: _products.isNotEmpty,
          ),
        ],

        // Q12 Order Amount + Q13 Upgrade Amount (Order path)
        if (_isOrder) ...[
          FeedbackFormField(
            number: 12,
            label: 'Order Amount',
            required: true,
            child: FeedbackInput(
              controller: _orderAmountCtrl,
              hint: '0',
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (_) => setState(() {}),
            ),
          ),
          SizedBox(height: 28 * fem),
          UpgradeAmountField(
            questionNumber: 13,
            amount: _upgradeAmount,
            isValid: _upgradeAmountValid,
            hasInput: _orderAmountCtrl.text.isNotEmpty,
          ),
        ],
      ],
    );
  }
}
