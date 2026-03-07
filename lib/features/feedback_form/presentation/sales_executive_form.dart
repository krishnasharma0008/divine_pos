import 'package:divine_pos/features/feedback_form/data/feedback_model.dart';
import 'package:divine_pos/features/feedback_form/provider/sales_staff_provider.dart';
import 'package:divine_pos/shared/utils/scale_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'product_uid_table.dart';
import 'pyds_section.dart';
import '../presentation/widget/shared_widgets.dart';
import '../theme.dart';
import 'upgrade_section.dart';

final fem = ScaleSize.aspectRatio;

class SalesExecutiveForm extends ConsumerStatefulWidget {
  final ValueChanged<SalesExecutiveData> onSubmit;
  const SalesExecutiveForm({super.key, required this.onSubmit});

  @override
  ConsumerState<SalesExecutiveForm> createState() => _SalesExecutiveFormState();
}

class _SalesExecutiveFormState extends ConsumerState<SalesExecutiveForm> {
  final _staffCtrl = TextEditingController();
  bool _showSuggestions = false;

  PurchaseCategory _category = PurchaseCategory.readyProduct;

  final _uidCtrl = TextEditingController();
  List<ProductDetail> _products = [];

  final _upgradeKey = GlobalKey<UpgradeSectionState>();
  final _pydsKey = GlobalKey<PydsSectionState>();

  List<String> _filteredStaff(List<String> allStaff) {
    final q = _staffCtrl.text.toLowerCase();
    if (q.isEmpty) return [];
    return allStaff.where((s) => s.toLowerCase().contains(q)).toList();
  }

  void _handleSubmit() {
    if (_staffCtrl.text.trim().isEmpty) {
      _snack('Please enter sales staff name.');
      return;
    }

    switch (_category) {
      case PurchaseCategory.readyProduct:
      case PurchaseCategory.exchange:
        if (_products.isEmpty) {
          _snack('Please add at least one product UID.');
          return;
        }
        widget.onSubmit(
          SalesExecutiveData(
            sales_by: _staffCtrl.text.trim(),
            purchase_category: _category,
            products: List.from(_products),
          ),
        );
        break;

      case PurchaseCategory.upgrade:
        final upgradeData = _upgradeKey.currentState?.buildData(context);
        if (upgradeData == null) return;
        widget.onSubmit(
          SalesExecutiveData(
            sales_by: _staffCtrl.text.trim(),
            purchase_category: _category,
            upgradeData: upgradeData,
          ),
        );
        break;

      case PurchaseCategory.pyds:
        final pydsData = _pydsKey.currentState?.buildData(context);
        if (pydsData == null) return;
        widget.onSubmit(
          SalesExecutiveData(
            sales_by: _staffCtrl.text.trim(),
            purchase_category: _category,
            pydsData: pydsData,
          ),
        );
        break;
    }
  }

  void _snack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  void _onCategoryChanged(PurchaseCategory cat) {
    setState(() {
      _category = cat;
      _products.clear();
      _uidCtrl.clear();
    });
  }

  @override
  void dispose() {
    _staffCtrl.dispose();
    _uidCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final staffAsync = ref.watch(salesStaffProvider);

    return SingleChildScrollView(
      padding: EdgeInsets.all(16 * fem),
      child: Container(
        decoration: BoxDecoration(
          color: FeedbackTheme.cardBg,
          borderRadius: BorderRadius.circular(16 * fem),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12 * fem,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: EdgeInsets.all(24 * fem),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Form to be filled by Sales Executive',
              style: TextStyle(
                fontSize: 15 * fem,
                fontWeight: FontWeight.w500,
                color: FeedbackTheme.textDark,
              ),
            ),
            SizedBox(height: 24 * fem),

            // ── Q8 Sales Staff ───────────────────────────────────────────
            FeedbackFormField(
              number: 8,
              label: 'Sales Staff',
              required: true,
              child: staffAsync.when(
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FeedbackInput(
                      controller: _staffCtrl,
                      hint: 'Enter staff name',
                      onChanged: (_) => setState(() {}),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        'Could not load staff list — type manually',
                        style: TextStyle(
                          fontSize: 12 * fem,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
                data: (staffList) => Column(
                  children: [
                    FeedbackInput(
                      controller: _staffCtrl,
                      hint: 'Search staff name',
                      onChanged: (v) =>
                          setState(() => _showSuggestions = v.isNotEmpty),
                    ),
                    if (_showSuggestions &&
                        _filteredStaff(staffList).isNotEmpty)
                      StaffDropdown(
                        items: _filteredStaff(staffList),
                        onSelect: (s) {
                          _staffCtrl.text = s;
                          setState(() => _showSuggestions = false);
                        },
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 28 * fem),

            // ── Q9 Purchase Category ─────────────────────────────────────
            FeedbackFormField(
              number: 9,
              label: 'Purchase Category',
              required: true,
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: PurchaseCategory.values
                    .map(
                      (c) => CategoryButton(
                        label: c.label,
                        selected: c == _category,
                        onTap: () => _onCategoryChanged(c),
                      ),
                    )
                    .toList(),
              ),
            ),
            SizedBox(height: 28 * fem),

            // ── Category-specific sections ───────────────────────────────
            if (_category == PurchaseCategory.readyProduct ||
                _category == PurchaseCategory.exchange) ...[
              AddUidRow(
                controller: _uidCtrl,
                onAdd: (product) => setState(() => _products.add(product)),
              ),
              const SizedBox(height: 20),
              if (_products.isNotEmpty)
                ProductUidTable(
                  products: _products,
                  onRemove: (i) => setState(() => _products.removeAt(i)),
                ),
            ],

            if (_category == PurchaseCategory.upgrade)
              UpgradeSection(key: _upgradeKey),

            if (_category == PurchaseCategory.pyds) PydsSection(key: _pydsKey),

            SizedBox(height: 36 * fem),

            SubmitButton(label: 'Submit', onTap: _handleSubmit),
            SizedBox(height: 8 * fem),
          ],
        ),
      ),
    );
  }
}
