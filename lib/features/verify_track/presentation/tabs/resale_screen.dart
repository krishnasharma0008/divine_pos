// lib/features/verify_track/presentation/tabs/resale_screen.dart

import 'package:divine_pos/features/feedback_form/presentation/customer_feedback_form.dart';
import 'package:divine_pos/shared/utils/currency_formatter.dart';
import 'package:divine_pos/shared/utils/scale_size.dart';
import 'package:divine_pos/shared/widgets/text.dart';
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
    final fem = ScaleSize.aspectRatio;
    return Column(
      children: [
        // ── Outer segmented tab bar ───────────────────────────────────────────
        Container(
          color: AppColors.white,
          padding: EdgeInsets.fromLTRB(16 * fem, 12 * fem, 16 * fem, 0 * fem),
          child: Container(
            height: 44 * fem,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.divider),
              borderRadius: BorderRadius.circular(6 * fem),
            ),
            child: Row(
              children: [
                _Segment(label: 'Upgrade', index: 0, controller: _tc, fem: fem),
                _Segment(label: 'Buyback', index: 1, controller: _tc, fem: fem),
                _Segment(
                  label: 'Exchange',
                  index: 2,
                  controller: _tc,
                  isLast: true,
                  fem: fem,
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
              _UpgradeTab(product: widget.product, fem: fem),
              _BuybackTab(product: widget.product, fem: fem),
              _ExchangeTab(product: widget.product, fem: fem),
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
  final double fem;
  const _UpgradeTab({required this.product, required this.fem});

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
            fem: fem,
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
          _InfoRow(label: 'Product ID:', value: p.uid, fem: fem),
          SizedBox(height: 8 * fem),
          _InfoRow(
            label: 'Current Value',
            value: p.currentPrice.inRupeesFormat(),
            valueColor: AppColors.gold,
            fem: fem,
          ),
          SizedBox(height: 16 * fem),
          const Divider(color: AppColors.divider),
          SizedBox(height: 16 * fem),

          // Input row
          Row(
            children: [
              Expanded(
                flex: 2,
                child: MyText(
                  'Enter new product amount:',
                  style: TextStyle(
                    fontSize: 14 * fem,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              SizedBox(width: 12 * fem),
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _amountCtrl,
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    fontSize: 14 * fem,
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
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12 * fem,
                      vertical: 12 * fem,
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
            SizedBox(height: 6 * fem),
            Align(
              alignment: Alignment.centerRight,
              child: MyText(
                'Minimum amount to upgrade is '
                '${p.upgradeMinimumPrice.inRupeesFormat()}',
                style: TextStyle(fontSize: 12 * fem, color: AppColors.textDark),
              ),
            ),
          ],

          SizedBox(height: 20 * fem),

          // Black approximate value box
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 16 * fem),
            decoration: const BoxDecoration(color: AppColors.textDark),
            child: Column(
              children: [
                MyText(
                  _approxValue > 0 ? _approxValue.inRupeesFormat() : '₹0',
                  style: TextStyle(
                    fontSize: 20 * fem,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
                SizedBox(height: 6 * fem),
                MyText(
                  'Approximate Value Payable:',
                  style: TextStyle(fontSize: 13 * fem, color: AppColors.white),
                ),
              ],
            ),
          ),
          SizedBox(height: 24 * fem),

          // Buttons — PROCEED disabled until amount >= minimum
          // Row(
          //   children: [
          //     Expanded(child: _CancelBtn(onPressed: () {})),
          //     const SizedBox(width: 12),
          //     Expanded(
          //       child: _ProceedBtn(
          //         onPressed: _isValidAmount
          //             ? () => setState(() => _showForm = true)
          //             : null,
          //       ),
          //     ),
          //   ],
          // ),
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
  final double fem;
  const _BuybackTab({required this.product, required this.fem});

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
            fem: fem,
          ),
          _FormFieldData(
            label: 'Purchase Store',
            value: p.purchaseFrom.isNotEmpty
                ? p.purchaseFrom.toUpperCase()
                : 'DIVINE SOLITAIRES',
            fem: fem,
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
            fem: fem,
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
  final double fem;
  const _ExchangeTab({required this.product, required this.fem});

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
            fem: fem,
          ),
          _FormFieldData(
            label: 'Purchase Store',
            value: p.purchaseFrom.isNotEmpty
                ? p.purchaseFrom.toUpperCase()
                : 'DIVINE SOLITAIRES',
            fem: fem,
          ),
        ],
        onCancel: () => setState(() => _showForm = false),
        onSubmit: () => setState(() => _showForm = false),
      );
    }

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(0, 30 * fem, 25 * fem, 20 * fem),
          child: _BrowserTabBar(
            controller: _stc,
            tabs: const [
              'Exchange At Purchased Store',
              'Exchange At Other Store',
            ],
            fem: fem,
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
      padding: EdgeInsets.all(16 * fem),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!widget.showStoreDropdown) ...[
            MyText(
              'Store Name',
              style: TextStyle(fontSize: 13 * fem, color: AppColors.textDark),
            ),
            SizedBox(height: 6 * fem),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: 12 * fem,
                vertical: 14 * fem,
              ),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.divider),
                borderRadius: BorderRadius.circular(4),
              ),
              child: MyText(
                widget.storeName,
                style: TextStyle(fontSize: 14 * fem, color: AppColors.textDark),
              ),
            ),
            SizedBox(height: 16 * fem),
          ] else ...[
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 12 * fem,
                vertical: 4 * fem,
              ),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.divider),
                borderRadius: BorderRadius.circular(4),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  hint: MyText(
                    'Select a store',
                    style: TextStyle(
                      fontSize: 14 * fem,
                      color: AppColors.textLight,
                    ),
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
            SizedBox(height: 16 * fem),
          ],

          MyText(
            'Product Details',
            style: TextStyle(
              fontSize: 14 * fem,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          SizedBox(height: 1 * fem),

          if (p.sltDetails.isNotEmpty) ...[
            Container(
              padding: EdgeInsets.all(12 * fem),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.divider),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyText(
                    'Divine Solitaires:',
                    style: TextStyle(
                      fontSize: 14 * fem,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  SizedBox(height: 8 * fem),
                  Row(
                    children: [
                      Expanded(
                        child: MyText(
                          _sltSummary,
                          style: TextStyle(
                            fontSize: 13 * fem,
                            color: AppColors.textMid,
                          ),
                        ),
                      ),
                      MyText(
                        p.buybackSolitairePrice.inRupeesFormat(),
                        style: TextStyle(
                          fontSize: 13 * fem,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 8 * fem),
          ],

          if (p.mountDetails1.isNotEmpty) ...[
            Container(
              padding: EdgeInsets.all(12 * fem),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.divider),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyText(
                    'Divine Mount',
                    style: TextStyle(
                      fontSize: 14 * fem,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  SizedBox(height: 8 * fem),
                  Row(
                    children: [
                      Expanded(
                        child: MyText(
                          _mountSummary,
                          style: TextStyle(
                            fontSize: 13 * fem,
                            color: AppColors.textMid,
                          ),
                        ),
                      ),
                      MyText(
                        p.buybackMountPrice.inRupeesFormat(),
                        style: TextStyle(
                          fontSize: 13 * fem,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                  if (p.sdPcs > 0) ...[
                    SizedBox(height: 4 * fem),
                    MyText(
                      _sdSummary,
                      style: TextStyle(
                        fontSize: 13 * fem,
                        color: AppColors.textMid,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],

          SizedBox(height: 12 * fem),
          SizedBox(
            width: double.infinity,
            height: 1,
            child: CustomPaint(painter: _DashedDividerPainter()),
          ),
          SizedBox(height: 12 * fem),

          _InfoRow(
            label: widget.labelPrimary,
            value: widget.primaryAmount.inRupeesFormat(),
            valueColor: AppColors.gold,
            fem: fem,
          ),

          if (widget.processingCharge > 0) ...[
            SizedBox(height: 8 * fem),
            _InfoRow(
              label: 'Admin & Processing Charge:',
              value: '-${widget.processingCharge.inRupeesFormat()}',
              valueColor: AppColors.textMid,
              fem: fem,
            ),
            SizedBox(height: 8 * fem),
            _InfoRow(
              label: widget.labelFinal ?? 'Final Amount:',
              value: (widget.finalAmount ?? 0).inRupeesFormat(),
              valueColor: AppColors.gold,
              fem: fem,
            ),
          ],

          // const SizedBox(height: 24),
          // Row(
          //   children: [
          //     Expanded(child: _CancelBtn(onPressed: () {})),
          //     const SizedBox(width: 12),
          //     Expanded(child: _ProceedBtn(onPressed: widget.onProceed)),
          //   ],
          // ),
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
  final double fem;
  const _FormFieldData({
    required this.label,
    required this.value,
    required this.fem,
  });
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
          padding: EdgeInsets.all(16 * fem),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyText(
                'Customer Information',
                style: TextStyle(
                  fontSize: 16 * fem,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gold,
                ),
              ),
              SizedBox(height: 16 * fem),

              _FormLabel('Customer Name', fem),
              _FormInput(controller: _nameCtrl),
              SizedBox(height: 12 * fem),

              _FormLabel('Mobile Number', fem),
              _FormInput(
                controller: _mobileCtrl,
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 24 * fem),

              MyText(
                widget.formTitle,
                style: TextStyle(
                  fontSize: 16 * fem,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gold,
                ),
              ),
              SizedBox(height: 16 * fem),

              _FormLabel('Uid *', fem),
              _FormInput(initialValue: p.uid, readOnly: true),
              SizedBox(height: 12 * fem),

              _FormLabel('Product Category', fem),
              _FormInput(initialValue: p.category, readOnly: true),
              SizedBox(height: 12 * fem),

              ...widget.extraFields.map(
                (f) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FormLabel(f.label, fem),
                    _FormInput(initialValue: f.value, readOnly: true),
                    const SizedBox(height: 12),
                  ],
                ),
              ),

              SizedBox(height: 24 * fem),
              // Row(
              //   children: [
              //     Expanded(child: _CancelBtn(onPressed: widget.onCancel)),
              //     const SizedBox(width: 12),
              //     Expanded(
              //       child: _SubmitBtn(
              //         onPressed: () => setState(() => _showSuccess = true),
              //       ),
              //     ),
              //   ],
              // ),
              // const SizedBox(height: 24),
            ],
          ),
        ),
        if (_showSuccess)
          _SuccessDialog(
            onOkay: () {
              setState(() => _showSuccess = false);
              widget.onSubmit();
            },
            fem: fem,
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
  final double fem;
  const _SuccessDialog({required this.onOkay, required this.fem});

  @override
  Widget build(BuildContext context) => Positioned.fill(
    child: Container(
      color: AppColors.textDark.withOpacity(0.45),
      child: Center(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 24 * fem),
          padding: EdgeInsets.all(24 * fem),
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
                  Icon(
                    Icons.check_circle,
                    color: AppColors.mintDark,
                    size: 24 * fem,
                  ),
                  SizedBox(width: 10 * fem),
                  Expanded(
                    child: MyText(
                      'Successfully Submitted',
                      style: TextStyle(
                        fontSize: 16 * fem,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: onOkay,
                    child: Icon(
                      Icons.close,
                      size: 20 * fem,
                      color: AppColors.textMid,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16 * fem),
              const Divider(color: AppColors.divider),
              SizedBox(height: 16 * fem),
              MyText(
                'Our CRM team will reach out to you during working days. '
                'Thank you for your patience.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14 * fem,
                  color: AppColors.textMid,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 20 * fem),
              SizedBox(
                width: 120 * fem,
                height: 44 * fem,
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
                  child: MyText(
                    'OKAY',
                    style: TextStyle(
                      fontSize: 13 * fem,
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
  final double fem;

  const _Segment({
    required this.label,
    required this.index,
    required this.controller,
    this.isLast = false,
    required this.fem,
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
          child: MyText(
            widget.label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12 * fem,
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
  final double fem;
  const _BrowserTabBar({
    required this.controller,
    required this.tabs,
    required this.fem,
  });

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
                        padding: EdgeInsets.fromLTRB(
                          20 * fem,
                          0 * fem,
                          20 * fem,
                          8 * fem,
                        ),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: MyText(
                            widget.tabs[i],
                            style: TextStyle(
                              fontSize: 12 * fem,
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
                      padding: EdgeInsets.fromLTRB(
                        20 * fem,
                        0 * fem,
                        20 * fem,
                        8 * fem,
                      ),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: MyText(
                          widget.tabs[i],
                          style: TextStyle(
                            fontSize: 12 * fem,
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
  final double fem;
  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
    required this.fem,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        MyText(
          label,
          style: TextStyle(fontSize: 14 * fem, color: AppColors.textDark),
        ),
        const Spacer(),
        MyText(
          value,
          style: TextStyle(
            fontSize: 14 * fem,
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
  final double fem;
  const _FormLabel(this.text, this.fem);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: MyText(
      text,
      style: TextStyle(fontSize: 13 * fem, color: AppColors.textMid),
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
    style: TextStyle(fontSize: 14 * fem, color: AppColors.textDark),
    decoration: InputDecoration(
      filled: true,
      fillColor: readOnly ? AppColors.bgGrey : AppColors.white,
      contentPadding: EdgeInsets.symmetric(
        horizontal: 12 * fem,
        vertical: 14 * fem,
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
        borderSide: const BorderSide(color: AppColors.mintDark, width: 1.5),
      ),
    ),
  );
}

// class _CancelBtn extends StatelessWidget {
//   final VoidCallback onPressed;
//   const _CancelBtn({required this.onPressed});

//   @override
//   Widget build(BuildContext context) => SizedBox(
//     height: 48,
//     child: OutlinedButton(
//       onPressed: onPressed,
//       style: OutlinedButton.styleFrom(
//         foregroundColor: AppColors.textDark,
//         side: const BorderSide(color: AppColors.divider),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
//       ),
//       child: const Text(
//         'CANCEL',
//         style: TextStyle(
//           fontSize: 13,
//           fontWeight: FontWeight.w700,
//           letterSpacing: 1.2,
//         ),
//       ),
//     ),
//   );
// }

// class _ProceedBtn extends StatelessWidget {
//   final VoidCallback? onPressed;
//   const _ProceedBtn({required this.onPressed});

//   @override
//   Widget build(BuildContext context) => SizedBox(
//     height: 48,
//     child: ElevatedButton(
//       onPressed: onPressed,
//       style: ElevatedButton.styleFrom(
//         backgroundColor: onPressed != null
//             ? AppColors.textDark
//             : AppColors.textLight,
//         foregroundColor: AppColors.white,
//         elevation: 0,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
//       ),
//       child: const Text(
//         'PROCEED',
//         style: TextStyle(
//           fontSize: 13,
//           fontWeight: FontWeight.w700,
//           letterSpacing: 1.2,
//         ),
//       ),
//     ),
//   );
// }

class _SubmitBtn extends StatelessWidget {
  final VoidCallback onPressed;
  final double fem;
  const _SubmitBtn({required this.onPressed, required this.fem});

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 48 * fem,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.textDark,
        foregroundColor: AppColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      child: MyText(
        'SUBMIT',
        style: TextStyle(
          fontSize: 13 * fem,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    ),
  );
}
