// lib/features/verify_track/presentation/verify_detail_shell.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/verify_track_model.dart';
import '../provider/verify_track_providers.dart';
import 'tabs/summary_screen.dart';
import 'tabs/certificate_screen.dart';
import 'tabs/insurance_screen.dart';
import 'tabs/hearts_arrows_screen.dart';
import 'tabs/resale_screen.dart';
import 'tabs/journey_screen.dart';

// =============================================================================
// COLORS
// =============================================================================

class AppColors {
  static const mintGreen = Color(0xFFB2CFCA);
  static const mintLight = Color(0xFFD4E8E4);
  static const mintDark = Color(0xFF7AADA6);
  static const white = Color(0xFFFFFFFF);
  static const bgGrey = Color(0xFFF8F8F8);
  static const textDark = Color(0xFF1A1A1A);
  static const textMid = Color(0xFF555555);
  static const textLight = Color(0xFF999999);
  static const divider = Color(0xFFDDDDDD);
  static const cardShadow = Color(0x14000000);
  static const gold = Color(0xFF826344);
}

// =============================================================================
// CURRENCY HELPER
// Used by tab screens that import verify_detail_shell.dart
// Falls back gracefully if inRupeesFormat() extension is unavailable
// =============================================================================

String formatInr(num? value) {
  if (value == null || value == 0) return '₹0';
  // Format as Indian rupees with comma separators: 1,22,681
  final str = value.abs().toStringAsFixed(0);
  final buffer = StringBuffer();
  final isNegative = value < 0;

  if (str.length <= 3) {
    buffer.write(str);
  } else {
    // Last 3 digits
    final last3 = str.substring(str.length - 3);
    final rest = str.substring(0, str.length - 3);
    // Remaining digits in groups of 2
    final groups = <String>[];
    for (int i = rest.length; i > 0; i -= 2) {
      groups.add(rest.substring(i - 2 < 0 ? 0 : i - 2, i));
    }
    buffer.write(groups.reversed.join(','));
    buffer.write(',');
    buffer.write(last3);
  }

  return '${isNegative ? '-' : ''}₹${buffer.toString()}';
}

// =============================================================================
// SHARED WIDGETS
// =============================================================================

class VtCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  const VtCard({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: padding ?? const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(8),
      boxShadow: const [
        BoxShadow(
          color: AppColors.cardShadow,
          blurRadius: 8,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: child,
  );
}

class VtSectionTitle extends StatelessWidget {
  final String text;
  const VtSectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColors.textDark,
        letterSpacing: 0.3,
      ),
    ),
  );
}

class VtInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const VtInfoRow({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.textMid),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.textDark,
          ),
        ),
      ],
    ),
  );
}

class VtFilledButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  const VtFilledButton({super.key, required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 44,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.textDark,
        disabledBackgroundColor: AppColors.textLight,
        foregroundColor: AppColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
      ),
    ),
  );
}

class VtOutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  const VtOutlineButton({super.key, required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 44,
    child: OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textDark,
        side: const BorderSide(color: AppColors.mintDark, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
      ),
    ),
  );
}

class VtFormField extends StatelessWidget {
  final String label;
  final bool isDate;
  final String? initialValue;
  final bool readOnly;
  const VtFormField({
    super.key,
    required this.label,
    this.isDate = false,
    this.initialValue,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(
      readOnly: readOnly,
      controller: initialValue != null
          ? TextEditingController(text: initialValue)
          : null,
      style: const TextStyle(fontSize: 13, color: AppColors.textDark),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 12, color: AppColors.textLight),
        suffixIcon: isDate
            ? const Icon(
                Icons.calendar_today_outlined,
                size: 16,
                color: AppColors.textLight,
              )
            : null,
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
          borderSide: const BorderSide(color: AppColors.mintDark, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
    ),
  );
}

class VtUploadBox extends StatelessWidget {
  final String label;
  const VtUploadBox({super.key, required this.label});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () {},
    child: Container(
      height: 70,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.bgGrey,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.mintDark),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.upload_outlined,
            size: 20,
            color: AppColors.mintDark,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.textMid),
          ),
        ],
      ),
    ),
  );
}

// =============================================================================
// TABS ENUM
// =============================================================================

enum VtTab { summary, certificate, insurance, ha, resale, journey }

const _tabLabels = {
  VtTab.summary: 'Summary',
  VtTab.certificate: 'Certificate',
  VtTab.insurance: 'Insurance',
  VtTab.ha: 'H&A',
  VtTab.resale: 'Resale',
  VtTab.journey: 'Journey',
};

// =============================================================================
// SHELL
// =============================================================================

class VerifyDetailShell extends ConsumerStatefulWidget {
  final String uid;
  const VerifyDetailShell({super.key, this.uid = ''});

  @override
  ConsumerState<VerifyDetailShell> createState() => _VerifyDetailShellState();
}

class _VerifyDetailShellState extends ConsumerState<VerifyDetailShell> {
  VtTab _active = VtTab.summary;

  @override
  Widget build(BuildContext context) {
    final product = ref.watch(verifyTrackProvider).lastResult;

    if (product == null) {
      return const Scaffold(
        backgroundColor: AppColors.white,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.mintDark),
        ),
      );
    }

    // H&A only for Diamond
    final tabs = VtTab.values.where((t) {
      if (t == VtTab.ha && !product.isDiamond) return false;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(uid: product.uid, isSold: product.isSold),
            // Mint gradient underline
            Container(
              height: 3,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.mintLight,
                    AppColors.mintDark,
                    AppColors.mintLight,
                  ],
                ),
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  _TopTabs(
                    tabs: tabs,
                    active: _active,
                    onTap: (t) => setState(() => _active = t),
                  ),
                  Expanded(child: _buildScreen(product)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScreen(VerifyTrackByUid p) {
    switch (_active) {
      case VtTab.summary:
        return SummaryScreen(product: p);
      case VtTab.certificate:
        return CertificateScreen(product: p);
      case VtTab.insurance:
        return InsuranceScreen(product: p);
      case VtTab.ha:
        return HeartsArrowsScreen(product: p);
      case VtTab.resale:
        return ResaleScreen(product: p);
      case VtTab.journey:
        return JourneyScreen(product: p);
    }
  }
}

// =============================================================================
// TOP BAR
// =============================================================================

class _TopBar extends StatelessWidget {
  final String uid;
  final bool isSold;
  const _TopBar({required this.uid, required this.isSold});

  @override
  Widget build(BuildContext context) => Container(
    color: AppColors.mintLight,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: const Icon(
            Icons.arrow_back_ios,
            size: 18,
            color: AppColors.textDark,
          ),
        ),
        // const SizedBox(width: 12),
        // const Text(
        //   'DIVINE SOLITAIRES',
        //   style: TextStyle(
        //     fontSize: 13,
        //     fontWeight: FontWeight.w800,
        //     letterSpacing: 1.5,
        //     color: AppColors.textDark,
        //   ),
        // ),
        const Spacer(),
        if (isSold)
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Text(
              'SOLD',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Colors.red.shade600,
                letterSpacing: 1,
              ),
            ),
          ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.bgGrey,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: AppColors.divider),
          ),
          child: Text(
            'UID: $uid',
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textMid,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}

// =============================================================================
// TOP TAB BAR — horizontal scrollable tabs
// =============================================================================

class _TopTabs extends StatelessWidget {
  final List<VtTab> tabs;
  final VtTab active;
  final ValueChanged<VtTab> onTap;
  const _TopTabs({
    required this.tabs,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Container(
    color: AppColors.white,
    width: double.infinity,
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width - 16,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: tabs
              .map(
                (tab) => _TopTabItem(
                  label: _tabLabels[tab]!,
                  isActive: active == tab,
                  onTap: () => onTap(tab),
                ),
              )
              .toList(),
        ),
      ),
    ),
  );
}

class _TopTabItem extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  const _TopTabItem({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isActive ? AppColors.textDark : AppColors.bgGrey,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
          color: isActive ? AppColors.white : AppColors.textDark,
        ),
      ),
    ),
  );
}
