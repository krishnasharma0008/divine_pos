// lib/features/verify_track/presentation/tabs/insurance_screen.dart

import 'package:flutter/material.dart';
import '../../data/verify_track_model.dart';
import '../verify_detail_shell.dart';

enum _InsuranceStep { landing, form, done }

class InsuranceScreen extends StatefulWidget {
  final VerifyTrackByUid product;
  const InsuranceScreen({super.key, required this.product});

  @override
  State<InsuranceScreen> createState() => _InsuranceScreenState();
}

class _InsuranceScreenState extends State<InsuranceScreen> {
  _InsuranceStep _step = _InsuranceStep.landing;
  bool _showHeadsUp = false;

  // Form controllers
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _pinCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();

  VerifyTrackByUid get p => widget.product;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _mobileCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _pinCtrl.dispose();
    _dobCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ── Step content ────────────────────────────────────────────────────
        switch (_step) {
          _InsuranceStep.landing => _buildLanding(),
          _InsuranceStep.form => _buildForm(),
          _InsuranceStep.done => _buildSuccess(),
        },

        // ── Heads Up dialog (shown after APPLY tap) ──────────────────────────
        if (_showHeadsUp) _buildHeadsUpDialog(),
      ],
    );
  }

  // ── LANDING PAGE ───────────────────────────────────────────────────────────
  Widget _buildLanding() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dark banner
          _buildBanner(),

          const SizedBox(height: 32),

          // Feature rows
          _FeatureRow(
            icon: _InsuranceIcons.shield,
            label: 'FREE INSURANCE FOR 1 YEAR',
          ),
          _divider(),
          _FeatureRow(icon: _InsuranceIcons.claim, label: 'EASY CLAIM PROCESS'),
          _divider(),
          _FeatureRow(icon: _InsuranceIcons.terms, label: 'TERMS & CONDITIONS'),

          const SizedBox(height: 40),

          // APPLY button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => setState(() => _showHeadsUp = true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.textDark,
                  foregroundColor: AppColors.white,
                  elevation: 0,
                  shape: const RoundedRectangleBorder(),
                ),
                child: const Text(
                  'APPLY',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _divider() => const Divider(
    color: AppColors.divider,
    height: 1,
    indent: 16,
    endIndent: 16,
  );

  // ── FORM ───────────────────────────────────────────────────────────────────
  Widget _buildForm() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBanner(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Personal Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 20),

                _FieldLabel('Name *'),
                _InsuranceField(controller: _nameCtrl),
                const SizedBox(height: 14),

                _FieldLabel('Email *'),
                _InsuranceField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 14),

                _FieldLabel('Mobile *'),
                _InsuranceField(
                  controller: _mobileCtrl,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 14),

                _FieldLabel('Address *'),
                _InsuranceField(controller: _addressCtrl, maxLines: 2),
                const SizedBox(height: 14),

                _FieldLabel('City'),
                _InsuranceField(controller: _cityCtrl),
                const SizedBox(height: 14),

                _FieldLabel('Pin Code *'),
                _InsuranceField(
                  controller: _pinCtrl,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 14),

                _FieldLabel('Date of Birth'),
                _InsuranceDateField(controller: _dobCtrl),
                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () =>
                        setState(() => _step = _InsuranceStep.done),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.textDark,
                      foregroundColor: AppColors.white,
                      elevation: 0,
                      shape: const RoundedRectangleBorder(),
                    ),
                    child: const Text(
                      'SUBMIT',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── SUCCESS ─────────────────────────────────────────────────────────────────
  Widget _buildSuccess() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: Color(0xFFE8F5E9),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.green, size: 36),
            ),
            const SizedBox(height: 20),
            const Text(
              'Insurance Request Submitted',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Our team will get back to you within 24 hours.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textMid,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: 140,
              height: 48,
              child: ElevatedButton(
                onPressed: () => setState(() => _step = _InsuranceStep.landing),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.textDark,
                  foregroundColor: AppColors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: const Text(
                  'DONE',
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
    );
  }

  // ── SHARED: dark banner with UID + shield ──────────────────────────────────
  Widget _buildBanner() {
    return Container(
      width: double.infinity,
      height: 180,
      color: AppColors.textDark,
      child: Stack(
        children: [
          Positioned(
            top: 16,
            left: 16,
            child: Text(
              'UID : ${p.uid}',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Center(child: _ShieldDiamondIcon(size: 80)),
        ],
      ),
    );
  }

  // ── HEADS UP DIALOG ────────────────────────────────────────────────────────
  Widget _buildHeadsUpDialog() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.45),
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x22000000),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Heads Up!',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _showHeadsUp = false),
                      child: const Icon(
                        Icons.close,
                        size: 20,
                        color: AppColors.textMid,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Message
                RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textMid,
                      height: 1.6,
                    ),
                    children: [
                      TextSpan(text: 'Apply Insurance within '),
                      TextSpan(
                        text: '7 days',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      TextSpan(text: ' from the invoice date to stay covered'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // OKAY
                SizedBox(
                  width: 120,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () => setState(() {
                      _showHeadsUp = false;
                      _step = _InsuranceStep.form;
                    }),
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
}

// =============================================================================
// SHIELD + DIAMOND ICON
// Matches Image 1: clean white shield outline + diamond inside
// =============================================================================

class _ShieldDiamondIcon extends StatelessWidget {
  final double size;
  const _ShieldDiamondIcon({required this.size});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: size,
    height: size,
    child: CustomPaint(painter: _ShieldDiamondPainter()),
  );
}

class _ShieldDiamondPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final strokePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;

    // ── Shield outline ──────────────────────────────────────────────────────
    final shield = Path()
      ..moveTo(w * 0.50, h * 0.04) // top center
      ..lineTo(w * 0.93, h * 0.22) // top right
      ..lineTo(w * 0.93, h * 0.54) // right side
      // curve down to bottom point
      ..quadraticBezierTo(w * 0.93, h * 0.80, w * 0.50, h * 0.96)
      ..quadraticBezierTo(w * 0.07, h * 0.80, w * 0.07, h * 0.54)
      ..lineTo(w * 0.07, h * 0.22) // left side
      ..close();
    canvas.drawPath(shield, strokePaint);

    // ── Diamond inside ──────────────────────────────────────────────────────
    final cx = w * 0.50;
    final cy = h * 0.55;
    final dw = w * 0.30;
    final dh = h * 0.32;

    final diamond = Path()
      // Top crown points
      ..moveTo(cx - dw * 0.50, cy - dh * 0.08) // far left
      ..lineTo(cx - dw * 0.22, cy - dh * 0.52) // upper left
      ..lineTo(cx, cy - dh * 0.62) // top center
      ..lineTo(cx + dw * 0.22, cy - dh * 0.52) // upper right
      ..lineTo(cx + dw * 0.50, cy - dh * 0.08) // far right
      // Bottom point
      ..lineTo(cx, cy + dh * 0.52) // bottom
      ..close()
      // Horizontal facet line
      ..moveTo(cx - dw * 0.50, cy - dh * 0.08)
      ..lineTo(cx + dw * 0.50, cy - dh * 0.08)
      // Left facet lines
      ..moveTo(cx - dw * 0.22, cy - dh * 0.52)
      ..lineTo(cx, cy + dh * 0.52)
      // Right facet line
      ..moveTo(cx + dw * 0.22, cy - dh * 0.52)
      ..lineTo(cx, cy + dh * 0.52)
      // Center vertical line (crown to girdle)
      ..moveTo(cx, cy - dh * 0.62)
      ..lineTo(cx, cy - dh * 0.08);

    canvas.drawPath(diamond, strokePaint);
  }

  @override
  bool shouldRepaint(_) => false;
}

// =============================================================================
// FEATURE ROW ICONS (drawn with CustomPainter)
// =============================================================================

class _InsuranceIcons {
  static const shield = 0;
  static const claim = 1;
  static const terms = 2;
}

class _FeatureRow extends StatelessWidget {
  final int icon;
  final String label;
  const _FeatureRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: Image.asset(
              _assetForIcon(icon),
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => _FallbackIcon(icon: icon),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: AppColors.gold,
            ),
          ),
        ],
      ),
    );
  }

  String _assetForIcon(int icon) {
    return switch (icon) {
      _InsuranceIcons.shield => 'assets/insurance/free_insurance.png',
      _InsuranceIcons.claim => 'assets/insurance/easy_claim.png',
      _InsuranceIcons.terms => 'assets/insurance/terms.png',
      _ => '',
    };
  }
}

// Fallback if asset not found
class _FallbackIcon extends StatelessWidget {
  final int icon;
  const _FallbackIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    final iconData = switch (icon) {
      _InsuranceIcons.shield => Icons.verified_outlined,
      _InsuranceIcons.claim => Icons.groups_outlined,
      _InsuranceIcons.terms => Icons.description_outlined,
      _ => Icons.info_outline,
    };
    return Icon(iconData, size: 36, color: AppColors.gold);
  }
}

// =============================================================================
// FORM FIELD WIDGETS
// =============================================================================

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: const TextStyle(fontSize: 13, color: AppColors.textDark),
    ),
  );
}

class _InsuranceField extends StatelessWidget {
  final TextEditingController controller;
  final TextInputType keyboardType;
  final int maxLines;

  const _InsuranceField({
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    keyboardType: keyboardType,
    maxLines: maxLines,
    style: const TextStyle(fontSize: 14, color: AppColors.textDark),
    decoration: InputDecoration(
      filled: true,
      fillColor: AppColors.white,
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

class _InsuranceDateField extends StatelessWidget {
  final TextEditingController controller;
  const _InsuranceDateField({required this.controller});

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    readOnly: true,
    style: const TextStyle(fontSize: 14, color: AppColors.textDark),
    decoration: InputDecoration(
      hintText: 'dd-mm-yyyy',
      hintStyle: const TextStyle(fontSize: 13, color: AppColors.textLight),
      filled: true,
      fillColor: AppColors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      suffixIcon: const Icon(
        Icons.calendar_today_outlined,
        size: 18,
        color: AppColors.textMid,
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
    onTap: () async {
      final picked = await showDatePicker(
        context: context,
        initialDate: DateTime(1990),
        firstDate: DateTime(1900),
        lastDate: DateTime.now(),
        builder: (context, child) => Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.textDark,
              onPrimary: AppColors.white,
            ),
          ),
          child: child!,
        ),
      );
      if (picked != null) {
        controller.text =
            '${picked.day.toString().padLeft(2, '0')}-'
            '${picked.month.toString().padLeft(2, '0')}-'
            '${picked.year}';
      }
    },
  );
}
