import 'package:divine_pos/features/auth/data/auth_notifier.dart';
import 'package:divine_pos/features/feedback_form/data/feedback_model.dart';
import 'package:divine_pos/shared/utils/scale_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'product_uid_table.dart';
import '../../../shared/utils/api_endpointen.dart';
import '../../../shared/utils/http_client.dart';
import '../presentation/widget/shared_widgets.dart';
import '../theme.dart';

final fem = ScaleSize.aspectRatio;

// ─── UID Add Row (ConsumerStatefulWidget — needs ref for API lookup) ──────────

class _UpgradeAddUidRow extends ConsumerStatefulWidget {
  final void Function(ProductDetail product) onAdd;

  const _UpgradeAddUidRow({required this.onAdd});

  @override
  ConsumerState<_UpgradeAddUidRow> createState() => _UpgradeAddUidRowState();
}

class _UpgradeAddUidRowState extends ConsumerState<_UpgradeAddUidRow> {
  final _ctrl = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _handleAdd() async {
    final uid = _ctrl.text.trim();
    if (uid.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final dio = ref.read(httpClientProvider);
      final auth = ref.read(authProvider);
      final pjcode = auth.user?.pjcode;

      final res = await dio.post(
        ApiEndPoint.get_jewellery_listing,
        data: {
          'item_number': uid,
          'pageno': 1,
          if (pjcode != null) 'laying_with': pjcode,
        },
      );

      final raw = res.data;
      if (raw['success'] != true)
        throw Exception(raw['message'] ?? 'Not found');

      final list = raw['data'] as List?;
      if (list == null || list.isEmpty) throw Exception('UID "$uid" not found');

      final item = list.first as Map<String, dynamic>;
      final rawMrp = item['price'];
      if (rawMrp == null) throw Exception('Price not found for UID "$uid"');

      widget.onAdd(
        ProductDetail(
          uid: item['designno']?.toString() ?? uid,
          mrp: (rawMrp as num).toDouble(),
        ),
      );

      _ctrl.clear();
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _ctrl,
                enabled: !_isLoading,
                textCapitalization: TextCapitalization.characters,
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
                    borderSide: const BorderSide(
                      color: FeedbackTheme.borderColor,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: FeedbackTheme.borderColor,
                    ),
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
              onPressed: _isLoading ? null : _handleAdd,
              icon: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.add, size: 16),
              label: Text(_isLoading ? 'Fetching...' : 'Add'),
              style: ElevatedButton.styleFrom(
                backgroundColor: FeedbackTheme.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(
              _error!,
              style: const TextStyle(fontSize: 12, color: Colors.red),
            ),
          ),
      ],
    );
  }
}

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

// ─── Upgrade Section (StatefulWidget — GlobalKey works correctly) ─────────────

class UpgradeSection extends StatefulWidget {
  const UpgradeSection({super.key});

  @override
  UpgradeSectionState createState() => UpgradeSectionState();
}

class UpgradeSectionState extends State<UpgradeSection> {
  final _oldUidCtrl = TextEditingController();
  final _oldMrpCtrl = TextEditingController();
  final _orderAmountCtrl = TextEditingController();

  String _newPurchaseCategory = 'Ready Product';
  List<ProductDetail> _products = [];

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

        // Q11 New Purchase Category
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

        // Ready Product path — UID table
        if (!_isOrder) ...[
          _UpgradeAddUidRow(
            onAdd: (product) => setState(() => _products.add(product)),
          ),
          const SizedBox(height: 20),
          if (_products.isNotEmpty) ...[
            ProductUidTable(
              products: _products,
              onRemove: (i) => setState(() => _products.removeAt(i)),
            ),
            SizedBox(height: 28 * fem),
          ],
          UpgradeAmountField(
            questionNumber: 12,
            amount: _upgradeAmount,
            isValid: _upgradeAmountValid,
            hasInput: _products.isNotEmpty,
          ),
        ],

        // Order path
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
