import 'package:divine_pos/features/feedback_form/data/feedback_model.dart';
import 'package:divine_pos/shared/utils/scale_size.dart';
import 'package:flutter/material.dart';

import 'product_uid_table.dart';
import 'pyds_section.dart';
import '../presentation/widget/shared_widgets.dart';
import '../theme.dart';
import 'upgrade_section.dart';

final fem = ScaleSize.aspectRatio;

class SalesExecutiveForm extends StatefulWidget {
  final ValueChanged<SalesExecutiveData> onSubmit;
  const SalesExecutiveForm({super.key, required this.onSubmit});

  @override
  State<SalesExecutiveForm> createState() => _SalesExecutiveFormState();
}

class _SalesExecutiveFormState extends State<SalesExecutiveForm> {
  // ── Q8 Sales Staff ────────────────────────────────────────────────────────
  final _staffCtrl = TextEditingController();
  bool _showSuggestions = false;

  // ── Q9 Purchase Category ──────────────────────────────────────────────────
  PurchaseCategory _category = PurchaseCategory.readyProduct;

  // ── Ready Product / Exchange – UID table state ────────────────────────────
  final _uidCtrl = TextEditingController();
  List<ProductUIDEntry> _products = [];

  // ── Section keys to call buildData() on child sections ───────────────────
  final _upgradeKey = GlobalKey<UpgradeSectionState>();
  final _pydsKey = GlobalKey<PydsSectionState>();

  // ── Staff autocomplete ────────────────────────────────────────────────────
  final _staffList = const [
    'Sukanya Anant Naiknaware',
    'Suhani Nitesh Patil',
    'Suresh Kumar',
    'Sunita Sharma',
  ];

  List<String> get _filteredStaff {
    final q = _staffCtrl.text.toLowerCase();
    if (q.isEmpty) return [];
    return _staffList.where((s) => s.toLowerCase().contains(q)).toList();
  }

  // ── Product UID table (Ready / Exchange) ─────────────────────────────────
  void _addProduct() {
    final uid = _uidCtrl.text.trim();
    if (uid.isEmpty) return;
    setState(() {
      _products.add(ProductUIDEntry(uid: uid, mrp: 67999));
      _uidCtrl.clear();
    });
  }

  // ── Submit ────────────────────────────────────────────────────────────────
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
            salesStaff: _staffCtrl.text.trim(),
            purchaseCategory: _category,
            products: List.from(_products),
          ),
        );

      case PurchaseCategory.upgrade:
        final upgradeData = _upgradeKey.currentState?.buildData(context);
        if (upgradeData == null) return; // validation failed inside section
        widget.onSubmit(
          SalesExecutiveData(
            salesStaff: _staffCtrl.text.trim(),
            purchaseCategory: _category,
            upgradeData: upgradeData,
          ),
        );

      case PurchaseCategory.pyds:
        final pydsData = _pydsKey.currentState?.buildData(context);
        if (pydsData == null) return; // validation failed inside section
        widget.onSubmit(
          SalesExecutiveData(
            salesStaff: _staffCtrl.text.trim(),
            purchaseCategory: _category,
            pydsData: pydsData,
          ),
        );
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
            // Header
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
              child: Column(
                children: [
                  FeedbackInput(
                    controller: _staffCtrl,
                    hint: 'Enter your full name',
                    onChanged: (v) =>
                        setState(() => _showSuggestions = v.isNotEmpty),
                  ),
                  if (_showSuggestions && _filteredStaff.isNotEmpty)
                    StaffDropdown(
                      items: _filteredStaff,
                      onSelect: (s) {
                        _staffCtrl.text = s;
                        setState(() => _showSuggestions = false);
                      },
                    ),
                ],
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

            // Ready Product & Exchange — UID table
            if (_category == PurchaseCategory.readyProduct ||
                _category == PurchaseCategory.exchange) ...[
              AddUidRow(controller: _uidCtrl, onAdd: _addProduct),
              const SizedBox(height: 20),
              if (_products.isNotEmpty) ...[
                ProductUidTable(
                  products: _products,
                  onRemove: (i) => setState(() => _products.removeAt(i)),
                ),
              ],
            ],

            // Upgrade
            if (_category == PurchaseCategory.upgrade)
              UpgradeSection(key: _upgradeKey),

            // PYDS
            if (_category == PurchaseCategory.pyds) PydsSection(key: _pydsKey),

            SizedBox(height: 36 * fem),

            // ── Submit ───────────────────────────────────────────────────
            SubmitButton(label: 'Submit', onTap: _handleSubmit),
            SizedBox(height: 8 * fem),
          ],
        ),
      ),
    );
  }
}
