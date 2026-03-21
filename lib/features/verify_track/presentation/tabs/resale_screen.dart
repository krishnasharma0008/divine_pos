// lib/features/verify_track/presentation/tabs/resale_screen.dart

import 'package:divine_pos/shared/utils/currency_formatter.dart';
import 'package:flutter/material.dart';
import '../../data/verify_track_model.dart';
import '../verify_detail_shell.dart';

// =============================================================================
// MAIN SCREEN — 3 outer tabs: Upgrade | Buyback | Exchange
// =============================================================================

class ResaleScreen extends StatefulWidget {
  final VerifyTrackByUid product;
  const ResaleScreen({super.key, required this.product});

  @override
  State<ResaleScreen> createState() => _ResaleScreenState();
}

class _ResaleScreenState extends State<ResaleScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tc;

  @override
  void initState() {
    super.initState();
    _tc = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Outer segmented tab bar ───────────────────────────────────────────
        Container(
          color: AppColors.white,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.divider),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                _Segment(label: 'Upgrade', index: 0, controller: _tc),
                _Segment(label: 'Buyback', index: 1, controller: _tc),
                _Segment(
                  label: 'Exchange',
                  index: 2,
                  controller: _tc,
                  isLast: true,
                ),
              ],
            ),
          ),
        ),

        // ── Content ───────────────────────────────────────────────────────────
        Expanded(
          child: TabBarView(
            controller: _tc,
            children: [
              _UpgradeTab(product: widget.product),
              _BuybackTab(product: widget.product),
              _ExchangeTab(product: widget.product),
            ],
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// UPGRADE TAB — updated with validation message + disabled PROCEED
// =============================================================================

class _UpgradeTab extends StatefulWidget {
  final VerifyTrackByUid product;
  const _UpgradeTab({required this.product});

  @override
  State<_UpgradeTab> createState() => _UpgradeTabState();
}

class _UpgradeTabState extends State<_UpgradeTab> {
  bool _showForm = false;
  final _amountCtrl = TextEditingController();
  double _approxValue = 0;
  double _enteredAmt = 0;

  VerifyTrackByUid get p => widget.product;

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  bool get _isValidAmount =>
      _enteredAmt > 0 && _enteredAmt >= p.upgradeMinimumPrice;

  @override
  Widget build(BuildContext context) {
    if (_showForm) {
      return _ResaleForm(
        product: p,
        formTitle: 'Product Upgrade Summary',
        extraFields: [
          _FormFieldData(
            label: 'Upgrade Value',
            value: _amountCtrl.text.isNotEmpty
                ? _amountCtrl.text
                : p.upgradeMinimumPrice.toString(),
          ),
        ],
        onCancel: () => setState(() => _showForm = false),
        onSubmit: () => setState(() => _showForm = false),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product ID + Current Value
          _InfoRow(label: 'Product ID:', value: p.uid),
          const SizedBox(height: 8),
          _InfoRow(
            label: 'Current Value',
            value: p.currentPrice.inRupeesFormat(),
            valueColor: AppColors.gold,
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.divider),
          const SizedBox(height: 16),

          // Input row
          Row(
            children: [
              const Expanded(
                flex: 2,
                child: Text(
                  'Enter new product amount:',
                  style: TextStyle(fontSize: 14, color: AppColors.textDark),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _amountCtrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textDark,
                  ),
                  onChanged: (v) {
                    final entered = double.tryParse(v) ?? 0;
                    setState(() {
                      _enteredAmt = entered;
                      _approxValue = entered >= p.upgradeMinimumPrice
                          ? entered - p.currentPrice
                          : 0;
                    });
                  },
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: const BorderSide(color: AppColors.divider),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: const BorderSide(color: AppColors.divider),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: const BorderSide(
                        color: AppColors.mintDark,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ── Validation message ─────────────────────────────────────────
          // Shows in red when amount is entered but below minimum
          if (_amountCtrl.text.isNotEmpty && !_isValidAmount) ...[
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Minimum amount to upgrade is '
                '${p.upgradeMinimumPrice.inRupeesFormat()}',
                style: const TextStyle(fontSize: 12, color: AppColors.textDark),
              ),
            ),
          ],

          const SizedBox(height: 20),

          // Black approximate value box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: const BoxDecoration(color: AppColors.textDark),
            child: Column(
              children: [
                Text(
                  _approxValue > 0 ? _approxValue.inRupeesFormat() : '₹0',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Approximate Value Payable:',
                  style: TextStyle(fontSize: 13, color: AppColors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Buttons — PROCEED disabled until amount >= minimum
          Row(
            children: [
              Expanded(child: _CancelBtn(onPressed: () {})),
              const SizedBox(width: 12),
              Expanded(
                child: _ProceedBtn(
                  onPressed: _isValidAmount
                      ? () => setState(() => _showForm = true)
                      : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// BUYBACK TAB — unchanged
// =============================================================================

class _BuybackTab extends StatefulWidget {
  final VerifyTrackByUid product;
  const _BuybackTab({required this.product});

  @override
  State<_BuybackTab> createState() => _BuybackTabState();
}

class _BuybackTabState extends State<_BuybackTab>
    with SingleTickerProviderStateMixin {
  late final TabController _stc;
  bool _showForm = false;
  int _subIndex = 0;

  VerifyTrackByUid get p => widget.product;

  @override
  void initState() {
    super.initState();
    _stc = TabController(length: 2, vsync: this);
    _stc.addListener(() => setState(() => _subIndex = _stc.index));
  }

  @override
  void dispose() {
    _stc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_showForm) {
      return _ResaleForm(
        product: p,
        formTitle: 'Product Buyback Summary',
        extraFields: [
          _FormFieldData(
            label: 'Exchange Value',
            value: _subIndex == 0
                ? p.buybackSameStorePrice.toString()
                : p.buybackDifferentStorePrice.toString(),
          ),
          _FormFieldData(
            label: 'Purchase Store',
            value: p.purchaseFrom.isNotEmpty
                ? p.purchaseFrom.toUpperCase()
                : 'DIVINE SOLITAIRES',
          ),
        ],
        onCancel: () => setState(() => _showForm = false),
        onSubmit: () => setState(() => _showForm = false),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 30, 25, 20),
          child: _BrowserTabBar(
            controller: _stc,
            tabs: const [
              'Buyback At Purchased Store',
              'Buyback At Other Store',
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _stc,
            children: [
              _StoreView(
                product: p,
                storeName: p.purchaseFrom.isNotEmpty
                    ? p.purchaseFrom.toUpperCase()
                    : 'DIVINE SOLITAIRES',
                primaryAmount: p.buybackSameStorePrice,
                processingCharge: 0,
                showStoreDropdown: false,
                labelPrimary: 'Buyback Amount:',
                onProceed: () => setState(() => _showForm = true),
              ),
              _StoreView(
                product: p,
                storeName: '',
                primaryAmount: p.buybackPrice,
                processingCharge: p.buybackProcessingCharges,
                finalAmount: p.buybackDifferentStorePrice,
                showStoreDropdown: true,
                labelPrimary: 'Buyback Amount:',
                labelFinal: 'Buyback Amount at Other Store:',
                onProceed: () => setState(() => _showForm = true),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// EXCHANGE TAB — unchanged
// =============================================================================

class _ExchangeTab extends StatefulWidget {
  final VerifyTrackByUid product;
  const _ExchangeTab({required this.product});

  @override
  State<_ExchangeTab> createState() => _ExchangeTabState();
}

class _ExchangeTabState extends State<_ExchangeTab>
    with SingleTickerProviderStateMixin {
  late final TabController _stc;
  bool _showForm = false;
  int _subIndex = 0;

  VerifyTrackByUid get p => widget.product;

  @override
  void initState() {
    super.initState();
    _stc = TabController(length: 2, vsync: this);
    _stc.addListener(() => setState(() => _subIndex = _stc.index));
  }

  @override
  void dispose() {
    _stc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_showForm) {
      return _ResaleForm(
        product: p,
        formTitle: 'Product Exchange Summary',
        extraFields: [
          _FormFieldData(
            label: 'Exchange Value',
            value: _subIndex == 0
                ? p.exchangeSameStorePrice.toString()
                : p.exchangeDifferentStorePrice.toString(),
          ),
          _FormFieldData(
            label: 'Purchase Store',
            value: p.purchaseFrom.isNotEmpty
                ? p.purchaseFrom.toUpperCase()
                : 'DIVINE SOLITAIRES',
          ),
        ],
        onCancel: () => setState(() => _showForm = false),
        onSubmit: () => setState(() => _showForm = false),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 30, 25, 20),
          child: _BrowserTabBar(
            controller: _stc,
            tabs: const [
              'Exchange At Purchased Store',
              'Exchange At Other Store',
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _stc,
            children: [
              _StoreView(
                product: p,
                storeName: p.purchaseFrom.isNotEmpty
                    ? p.purchaseFrom.toUpperCase()
                    : 'DIVINE SOLITAIRES',
                primaryAmount: p.exchangeSameStorePrice,
                processingCharge: 0,
                showStoreDropdown: false,
                labelPrimary: 'Exchange Amount:',
                onProceed: () => setState(() => _showForm = true),
              ),
              _StoreView(
                product: p,
                storeName: '',
                primaryAmount: p.exchangePrice,
                processingCharge: p.exchangeProcessingCharges,
                finalAmount: p.exchangeDifferentStorePrice,
                showStoreDropdown: true,
                labelPrimary: 'Exchange Amount:',
                labelFinal: 'Exchange Amount at Other Store:',
                onProceed: () => setState(() => _showForm = true),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// SHARED: Store view — unchanged
// =============================================================================

class _StoreView extends StatefulWidget {
  final VerifyTrackByUid product;
  final String storeName;
  final double primaryAmount;
  final double processingCharge;
  final double? finalAmount;
  final bool showStoreDropdown;
  final String labelPrimary;
  final String? labelFinal;
  final VoidCallback onProceed;

  const _StoreView({
    required this.product,
    required this.storeName,
    required this.primaryAmount,
    required this.processingCharge,
    required this.showStoreDropdown,
    required this.labelPrimary,
    required this.onProceed,
    this.finalAmount,
    this.labelFinal,
  });

  @override
  State<_StoreView> createState() => _StoreViewState();
}

class _StoreViewState extends State<_StoreView> {
  String? _selectedStore;

  VerifyTrackByUid get p => widget.product;

  String get _sltSummary {
    if (p.sltDetails.isEmpty) return '';
    final s = p.sltDetails.first;
    return '${p.sltTotalPcs} pcs | ${s.shape} ${s.carat}cts. '
        '${s.colour}, ${s.clarity}';
  }

  String get _mountSummary => '${p.netWt} gms | ${p.mountDetails1}';

  String get _sdSummary =>
      '${p.sdPcs} pcs ${p.sdCts} cts | ${p.sdColourClarity}';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!widget.showStoreDropdown) ...[
            const Text(
              'Store Name',
              style: TextStyle(fontSize: 13, color: AppColors.textDark),
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.divider),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                widget.storeName,
                style: const TextStyle(fontSize: 14, color: AppColors.textDark),
              ),
            ),
            const SizedBox(height: 16),
          ] else ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.divider),
                borderRadius: BorderRadius.circular(4),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  hint: const Text(
                    'Select a store',
                    style: TextStyle(fontSize: 14, color: AppColors.textLight),
                  ),
                  value: _selectedStore,
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: AppColors.textMid,
                  ),
                  items: const [],
                  onChanged: (v) => setState(() => _selectedStore = v),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          const Text(
            'Product Details',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),

          if (p.sltDetails.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.divider),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Divine Solitaires:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _sltSummary,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textMid,
                          ),
                        ),
                      ),
                      Text(
                        p.buybackSolitairePrice.inRupeesFormat(),
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],

          if (p.mountDetails1.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.divider),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Divine Mount',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _mountSummary,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textMid,
                          ),
                        ),
                      ),
                      Text(
                        p.buybackMountPrice.inRupeesFormat(),
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                  if (p.sdPcs > 0) ...[
                    const SizedBox(height: 4),
                    Text(
                      _sdSummary,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textMid,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 1,
            child: CustomPaint(painter: _DashedDividerPainter()),
          ),
          const SizedBox(height: 12),

          _InfoRow(
            label: widget.labelPrimary,
            value: widget.primaryAmount.inRupeesFormat(),
            valueColor: AppColors.gold,
          ),

          if (widget.processingCharge > 0) ...[
            const SizedBox(height: 8),
            _InfoRow(
              label: 'Admin & Processing Charge:',
              value: '-${widget.processingCharge.inRupeesFormat()}',
              valueColor: AppColors.textMid,
            ),
            const SizedBox(height: 8),
            _InfoRow(
              label: widget.labelFinal ?? 'Final Amount:',
              value: (widget.finalAmount ?? 0).inRupeesFormat(),
              valueColor: AppColors.gold,
            ),
          ],

          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _CancelBtn(onPressed: () {})),
              const SizedBox(width: 12),
              Expanded(child: _ProceedBtn(onPressed: widget.onProceed)),
            ],
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// RESALE FORM — unchanged
// =============================================================================

class _FormFieldData {
  final String label;
  final String value;
  const _FormFieldData({required this.label, required this.value});
}

class _ResaleForm extends StatefulWidget {
  final VerifyTrackByUid product;
  final String formTitle;
  final List<_FormFieldData> extraFields;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;

  const _ResaleForm({
    required this.product,
    required this.formTitle,
    required this.extraFields,
    required this.onCancel,
    required this.onSubmit,
  });

  @override
  State<_ResaleForm> createState() => _ResaleFormState();
}

class _ResaleFormState extends State<_ResaleForm> {
  bool _showSuccess = false;
  final _nameCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _mobileCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Customer Information',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gold,
                ),
              ),
              const SizedBox(height: 16),

              _FormLabel('Customer Name'),
              _FormInput(controller: _nameCtrl),
              const SizedBox(height: 12),

              _FormLabel('Mobile Number'),
              _FormInput(
                controller: _mobileCtrl,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 24),

              Text(
                widget.formTitle,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gold,
                ),
              ),
              const SizedBox(height: 16),

              _FormLabel('Uid *'),
              _FormInput(initialValue: p.uid, readOnly: true),
              const SizedBox(height: 12),

              _FormLabel('Product Category'),
              _FormInput(initialValue: p.category, readOnly: true),
              const SizedBox(height: 12),

              ...widget.extraFields.map(
                (f) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FormLabel(f.label),
                    _FormInput(initialValue: f.value, readOnly: true),
                    const SizedBox(height: 12),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: _CancelBtn(onPressed: widget.onCancel)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SubmitBtn(
                      onPressed: () => setState(() => _showSuccess = true),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
        if (_showSuccess)
          _SuccessDialog(
            onOkay: () {
              setState(() => _showSuccess = false);
              widget.onSubmit();
            },
          ),
      ],
    );
  }
}

// =============================================================================
// SUCCESS DIALOG — unchanged
// =============================================================================

class _SuccessDialog extends StatelessWidget {
  final VoidCallback onOkay;
  const _SuccessDialog({required this.onOkay});

  @override
  Widget build(BuildContext context) => Positioned.fill(
    child: Container(
      color: AppColors.textDark.withOpacity(0.45),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: AppColors.cardShadow,
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: AppColors.mintDark,
                    size: 24,
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Successfully Submitted',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: onOkay,
                    child: const Icon(
                      Icons.close,
                      size: 20,
                      color: AppColors.textMid,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: AppColors.divider),
              const SizedBox(height: 16),
              const Text(
                'Our CRM team will reach out to you during working days. '
                'Thank you for your patience.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textMid,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 120,
                height: 44,
                child: ElevatedButton(
                  onPressed: onOkay,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.textDark,
                    foregroundColor: AppColors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: const Text(
                    'OKAY',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

// =============================================================================
// SEGMENT CONTROL — unchanged
// =============================================================================

class _Segment extends StatefulWidget {
  final String label;
  final int index;
  final TabController controller;
  final bool isLast;

  const _Segment({
    required this.label,
    required this.index,
    required this.controller,
    this.isLast = false,
  });

  @override
  State<_Segment> createState() => _SegmentState();
}

class _SegmentState extends State<_Segment> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTabChange);
  }

  void _onTabChange() => setState(() {});

  @override
  void dispose() {
    widget.controller.removeListener(_onTabChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final active = widget.controller.index == widget.index;
    return Expanded(
      child: GestureDetector(
        onTap: () => widget.controller.animateTo(widget.index),
        child: Container(
          height: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? AppColors.mintLight : AppColors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(widget.index == 0 ? 5 : 0),
              bottomLeft: Radius.circular(widget.index == 0 ? 5 : 0),
              topRight: Radius.circular(widget.isLast ? 5 : 0),
              bottomRight: Radius.circular(widget.isLast ? 5 : 0),
            ),
          ),
          child: Text(
            widget.label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: active ? FontWeight.w700 : FontWeight.w400,
              color: active ? AppColors.textDark : AppColors.textLight,
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// BROWSER-STYLE TAB BAR — unchanged
// =============================================================================

class _BrowserTabBar extends StatefulWidget {
  final TabController controller;
  final List<String> tabs;
  const _BrowserTabBar({required this.controller, required this.tabs});

  @override
  State<_BrowserTabBar> createState() => _BrowserTabBarState();
}

class _BrowserTabBarState extends State<_BrowserTabBar> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChange);
  }

  void _onChange() => setState(() {});

  @override
  void dispose() {
    widget.controller.removeListener(_onChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final active = widget.controller.index;

    return Container(
      color: AppColors.white,
      height: 48,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: List.generate(widget.tabs.length, (i) {
          final isActive = i == active;
          return isActive
              ? Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => widget.controller.animateTo(i),
                    child: CustomPaint(
                      painter: _TabPainter(
                        isActive: true,
                        lineColor: AppColors.textDark,
                        isLeftTab: i == 0,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Text(
                            widget.tabs[i],
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              : GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => widget.controller.animateTo(i),
                  child: CustomPaint(
                    painter: _TabPainter(
                      isActive: false,
                      lineColor: AppColors.textDark,
                      isLeftTab: i == 0,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Text(
                          widget.tabs[i],
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textMid,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
        }),
      ),
    );
  }
}

class _TabPainter extends CustomPainter {
  final bool isActive;
  final bool isLeftTab;
  final Color lineColor;
  static const double r = 8.0;
  static const double lw = 1.5;

  const _TabPainter({
    required this.isActive,
    required this.lineColor,
    required this.isLeftTab,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = lw
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    if (isActive) {
      // White fill to erase bottom line behind active tab
      canvas.drawRect(
        Rect.fromLTWH(0, 0, w, h + 1),
        Paint()
          ..color = AppColors.white
          ..style = PaintingStyle.fill,
      );

      final path = isLeftTab
          // Left active: right border + top-right curve + top to left
          ? (Path()
              ..moveTo(w, h)
              ..lineTo(w, r)
              ..arcToPoint(
                Offset(w - r, 0),
                radius: Radius.circular(r),
                clockwise: false,
              )
              ..lineTo(0, 0))
          // Right active: left border + top-left curve + top to right
          : (Path()
              ..moveTo(0, h)
              ..lineTo(0, r)
              ..arcToPoint(Offset(r, 0), radius: Radius.circular(r))
              ..lineTo(w, 0));

      canvas.drawPath(path, linePaint);
    } else {
      canvas.drawLine(Offset(0, h - lw / 2), Offset(w, h - lw / 2), linePaint);
    }
  }

  @override
  bool shouldRepaint(_TabPainter old) =>
      old.isActive != isActive || old.isLeftTab != isLeftTab;
}

// =============================================================================
// DASHED DIVIDER — unchanged
// =============================================================================

class _DashedDividerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.divider
      ..strokeWidth = 1;
    const dash = 6.0;
    const gap = 4.0;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + dash, 0), paint);
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// =============================================================================
// SHARED WIDGETS — unchanged
// =============================================================================

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _InfoRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: AppColors.textDark),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.textDark,
          ),
        ),
      ],
    ),
  );
}

class _FormLabel extends StatelessWidget {
  final String text;
  const _FormLabel(this.text);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: const TextStyle(fontSize: 13, color: AppColors.textMid),
    ),
  );
}

class _FormInput extends StatelessWidget {
  final TextEditingController? controller;
  final String? initialValue;
  final bool readOnly;
  final TextInputType keyboardType;

  const _FormInput({
    this.controller,
    this.initialValue,
    this.readOnly = false,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) => TextFormField(
    controller:
        controller ??
        (initialValue != null
            ? TextEditingController(text: initialValue)
            : null),
    readOnly: readOnly,
    keyboardType: keyboardType,
    style: const TextStyle(fontSize: 14, color: AppColors.textDark),
    decoration: InputDecoration(
      filled: true,
      fillColor: readOnly ? AppColors.bgGrey : AppColors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: AppColors.divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: AppColors.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: AppColors.mintDark, width: 1.5),
      ),
    ),
  );
}

class _CancelBtn extends StatelessWidget {
  final VoidCallback onPressed;
  const _CancelBtn({required this.onPressed});

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 48,
    child: OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textDark,
        side: const BorderSide(color: AppColors.divider),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      child: const Text(
        'CANCEL',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    ),
  );
}

class _ProceedBtn extends StatelessWidget {
  final VoidCallback? onPressed;
  const _ProceedBtn({required this.onPressed});

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 48,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: onPressed != null
            ? AppColors.textDark
            : AppColors.textLight,
        foregroundColor: AppColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      child: const Text(
        'PROCEED',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    ),
  );
}

class _SubmitBtn extends StatelessWidget {
  final VoidCallback onPressed;
  const _SubmitBtn({required this.onPressed});

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 48,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.textDark,
        foregroundColor: AppColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      child: const Text(
        'SUBMIT',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    ),
  );
}
