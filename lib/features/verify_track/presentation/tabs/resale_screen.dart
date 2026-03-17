// lib/features/verify_track/screens/tabs/resale_screen.dart

import 'package:flutter/material.dart';
import '../../data/verify_track_model.dart';
import '../verify_detail_shell.dart';

enum _Step { info, form, done }

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
    _tc = TabController(length: 2, vsync: this);
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
        Container(
          color: AppColors.white,
          child: TabBar(
            controller: _tc,
            labelColor: AppColors.textDark,
            unselectedLabelColor: AppColors.textLight,
            indicatorColor: AppColors.mintDark,
            indicatorWeight: 3,
            labelStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            tabs: const [
              Tab(text: 'UPGRADE'),
              Tab(text: 'BUYBACK'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tc,
            children: [
              _UpgradeTab(product: widget.product),
              _BuybackTab(product: widget.product),
            ],
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// UPGRADE TAB
// =============================================================================

class _UpgradeTab extends StatefulWidget {
  final VerifyTrackByUid product;
  const _UpgradeTab({required this.product});

  @override
  State<_UpgradeTab> createState() => _UpgradeTabState();
}

class _UpgradeTabState extends State<_UpgradeTab> {
  _Step _step = _Step.info;
  bool _accept = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.product;

    if (_step == _Step.done)
      return _ThankYouView(
        message: 'Your request for Upgrade\nis under process.',
        onHome: () => Navigator.of(context).pop(),
      );

    if (_step == _Step.form)
      return _ResaleForm(
        product: p,
        onCancel: () => setState(() => _step = _Step.info),
        onSubmit: () => setState(() => _step = _Step.done),
      );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: VtCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current value
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.bgGrey,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  const Text(
                    'Current Value',
                    style: TextStyle(fontSize: 12, color: AppColors.textMid),
                  ),
                  const Spacer(),
                  Text(
                    formatInr(p.currentPrice),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Divider(color: AppColors.divider),
            const SizedBox(height: 12),

            if (p.upgradeMinimumPrice <= 0)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Colors.orange.shade600,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'No upgrade available. Upgrades must be at least 30% above the current value.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textMid,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else ...[
              const Text(
                'Enter new product amount',
                style: TextStyle(fontSize: 12, color: AppColors.textMid),
              ),
              const SizedBox(height: 8),
              TextField(
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 13, color: AppColors.textDark),
                decoration: InputDecoration(
                  hintText: 'Minimum ${formatInr(p.upgradeMinimumPrice)}',
                  hintStyle: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textLight,
                  ),
                  filled: true,
                  fillColor: AppColors.bgGrey,
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
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Minimum upgrade value: ${formatInr(p.upgradeMinimumPrice)}',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textLight,
                ),
              ),
            ],

            const SizedBox(height: 16),
            _TermsRow(
              accepted: _accept,
              onChanged: (v) => setState(() => _accept = v!),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: VtOutlineButton(label: 'CANCEL', onPressed: () {}),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: VtFilledButton(
                    label: 'PROCEED',
                    onPressed: (_accept && p.upgradeMinimumPrice > 0)
                        ? () => setState(() => _step = _Step.form)
                        : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// BUYBACK TAB
// =============================================================================

class _BuybackTab extends StatefulWidget {
  final VerifyTrackByUid product;
  const _BuybackTab({required this.product});

  @override
  State<_BuybackTab> createState() => _BuybackTabState();
}

class _BuybackTabState extends State<_BuybackTab> {
  _Step _step = _Step.info;
  int _selection = 0; // 0=same store, 1=different store
  bool _showBreakup = false;
  bool _accept = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.product;

    if (_step == _Step.done)
      return _ThankYouView(
        message: 'Your request for Buyback\nis under process.',
        onHome: () => Navigator.of(context).pop(),
      );

    if (_step == _Step.form)
      return _ResaleForm(
        product: p,
        onCancel: () => setState(() => _step = _Step.info),
        onSubmit: () => setState(() => _step = _Step.done),
      );

    // Blocked
    if (p.buybackIsBlock) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: VtCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.lock_outlined, size: 24, color: Colors.red),
                  const SizedBox(width: 8),
                  const Text(
                    'Buyback Blocked',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (p.buybackBlockDate.isNotEmpty)
                VtInfoRow(label: 'Blocked Until', value: p.buybackBlockDate),
              const SizedBox(height: 8),
              Text(
                p.buybackBlockMessage.isNotEmpty
                    ? p.buybackBlockMessage
                    : 'Buyback is currently unavailable for this product.',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textMid,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: VtCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current value
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.bgGrey,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  const Text(
                    'Current Value',
                    style: TextStyle(fontSize: 12, color: AppColors.textMid),
                  ),
                  const Spacer(),
                  Text(
                    formatInr(p.currentPrice),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Divider(color: AppColors.divider),
            const SizedBox(height: 8),

            // Same store option
            _BuybackOption(
              label: 'Buyback through same store',
              amount: formatInr(p.buybackSameStorePrice),
              selected: _selection == 0,
              onTap: () => setState(() => _selection = 0),
            ),
            const SizedBox(height: 8),

            // Different store option
            _BuybackOption(
              label: 'Buyback through different store',
              amount: formatInr(p.buybackDifferentStorePrice),
              selected: _selection == 1,
              onTap: () => setState(() => _selection = 1),
            ),
            const SizedBox(height: 12),

            // Price breakup toggle
            GestureDetector(
              onTap: () => setState(() => _showBreakup = !_showBreakup),
              child: Row(
                children: [
                  const Text(
                    'Check price breakup',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.mintDark,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    _showBreakup
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 16,
                    color: AppColors.mintDark,
                  ),
                ],
              ),
            ),
            if (_showBreakup) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.bgGrey,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  children: [
                    VtInfoRow(
                      label: 'Solitaire Price',
                      value: formatInr(p.buybackSolitairePrice),
                    ),
                    VtInfoRow(
                      label: 'Mount Price',
                      value: formatInr(p.buybackMountPrice),
                    ),
                    VtInfoRow(
                      label: 'Buyback Price',
                      value: formatInr(p.buybackPrice),
                    ),
                    const Divider(color: AppColors.divider, height: 16),
                    VtInfoRow(
                      label: 'Processing Charges',
                      value: '- ${formatInr(p.buybackProcessingCharges)}',
                    ),
                    VtInfoRow(
                      label: 'Net Amount',
                      value: _selection == 0
                          ? formatInr(p.buybackSameStorePrice)
                          : formatInr(p.buybackDifferentStorePrice),
                      valueColor: AppColors.gold,
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),
            _TermsRow(
              accepted: _accept,
              onChanged: (v) => setState(() => _accept = v!),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: VtOutlineButton(label: 'CANCEL', onPressed: () {}),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: VtFilledButton(
                    label: 'PROCEED',
                    onPressed: _accept
                        ? () => setState(() => _step = _Step.form)
                        : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// SHARED WIDGETS (Resale-specific)
// =============================================================================

class _BuybackOption extends StatelessWidget {
  final String label;
  final String amount;
  final bool selected;
  final VoidCallback onTap;
  const _BuybackOption({
    required this.label,
    required this.amount,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: selected ? AppColors.mintLight : AppColors.bgGrey,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: selected ? AppColors.mintDark : AppColors.divider,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            selected ? Icons.radio_button_checked : Icons.radio_button_off,
            size: 18,
            color: selected ? AppColors.mintDark : AppColors.textLight,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: selected ? AppColors.textDark : AppColors.textMid,
              ),
            ),
          ),
          Text(
            amount,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.gold,
            ),
          ),
        ],
      ),
    ),
  );
}

class _TermsRow extends StatelessWidget {
  final bool accepted;
  final ValueChanged<bool?> onChanged;
  const _TermsRow({required this.accepted, required this.onChanged});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Checkbox(
        value: accepted,
        onChanged: onChanged,
        activeColor: AppColors.mintDark,
      ),
      const Expanded(
        child: Text(
          'Accept Terms and Conditions',
          style: TextStyle(fontSize: 12, color: AppColors.textMid),
        ),
      ),
    ],
  );
}

// =============================================================================
// SHARED: Form view
// =============================================================================

class _ResaleForm extends StatelessWidget {
  final VerifyTrackByUid product;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;
  const _ResaleForm({
    required this.product,
    required this.onCancel,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final p = product;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: VtCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const VtSectionTitle('Personal Information'),
            const VtFormField(label: 'Name'),
            const VtFormField(label: 'Email Id'),
            const VtFormField(label: 'Mobile No'),
            const VtFormField(label: 'Address'),
            const VtFormField(label: 'Pin Code'),
            const VtFormField(label: 'Date of Birth', isDate: true),
            const SizedBox(height: 16),
            const VtSectionTitle('Product Information'),
            // Pre-filled
            VtFormField(label: 'UID', initialValue: p.uid, readOnly: true),
            VtFormField(label: 'Invoice Number*'),
            VtFormField(label: 'Invoice Date*', isDate: true),
            VtFormField(
              label: 'Invoice Amount*',
              initialValue: formatInr(p.purchasePrice),
              readOnly: true,
            ),
            const SizedBox(height: 12),
            const VtUploadBox(label: 'Upload Documents'),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: VtOutlineButton(label: 'CANCEL', onPressed: onCancel),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: VtFilledButton(label: 'SUBMIT', onPressed: onSubmit),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// SHARED: Thank You view
// =============================================================================

class _ThankYouView extends StatelessWidget {
  final String message;
  final VoidCallback onHome;
  const _ThankYouView({required this.message, required this.onHome});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: VtCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.diamond_outlined,
              size: 56,
              color: AppColors.mintDark,
            ),
            const SizedBox(height: 12),
            const Text(
              'Thank You!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textMid,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            VtFilledButton(label: 'HOME', onPressed: onHome),
          ],
        ),
      ),
    ),
  );
}
