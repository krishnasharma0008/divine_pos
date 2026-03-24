// lib/features/verify_track/presentation/tabs/insurance_screen.dart

import 'package:divine_pos/shared/utils/scale_size.dart';
import 'package:divine_pos/shared/widgets/text.dart';
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

  final fem = ScaleSize.aspectRatio;

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
          _InsuranceStep.form => _buildForm(fem: fem),
          _InsuranceStep.done => _buildSuccess(),
        },

        // ── Heads Up dialog (shown after APPLY tap) ──────────────────────────
        if (_showHeadsUp) _buildHeadsUpDialog(fem: fem),
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
          _buildBanner(fem: fem),

          SizedBox(height: 32 * fem),

          // Feature rows
          _FeatureRow(
            icon: _InsuranceIcons.shield,
            label: 'FREE INSURANCE FOR 1 YEAR',
            fem: fem,
          ),
          _divider(),
          _FeatureRow(
            icon: _InsuranceIcons.claim,
            label: 'EASY CLAIM PROCESS',
            fem: fem,
          ),
          _divider(),
          _FeatureRow(
            icon: _InsuranceIcons.terms,
            label: 'TERMS & CONDITIONS',
            fem: fem,
          ),

          SizedBox(height: 40 * fem),

          // APPLY button
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 16),
          //   child: SizedBox(
          //     width: double.infinity,
          //     height: 50,
          //     child: ElevatedButton(
          //       onPressed: () => setState(() => _showHeadsUp = true),
          //       style: ElevatedButton.styleFrom(
          //         backgroundColor: AppColors.textDark,
          //         foregroundColor: AppColors.white,
          //         elevation: 0,
          //         shape: const RoundedRectangleBorder(),
          //       ),
          //       child: const Text(
          //         'APPLY',
          //         style: TextStyle(
          //           fontSize: 13,
          //           fontWeight: FontWeight.w700,
          //           letterSpacing: 1.5,
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
          SizedBox(height: 32),
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
  Widget _buildForm({required double fem}) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBanner(fem: fem),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText(
                  'Personal Information',
                  style: TextStyle(
                    fontSize: 16 * fem,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                SizedBox(height: 20 * fem),

                _FieldLabel('Name *', fem),
                _InsuranceField(controller: _nameCtrl, fem: fem),
                SizedBox(height: 14 * fem),

                _FieldLabel('Email *', fem),
                _InsuranceField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  fem: fem,
                ),
                SizedBox(height: 14 * fem),

                _FieldLabel('Mobile *', fem),
                _InsuranceField(
                  controller: _mobileCtrl,
                  keyboardType: TextInputType.phone,
                  fem: fem,
                ),
                SizedBox(height: 14 * fem),

                _FieldLabel('Address *', fem),
                _InsuranceField(
                  controller: _addressCtrl,
                  maxLines: 2,
                  fem: fem,
                ),
                SizedBox(height: 14 * fem),

                _FieldLabel('City', fem),
                _InsuranceField(controller: _cityCtrl, fem: fem),
                SizedBox(height: 14 * fem),

                _FieldLabel('Pin Code *', fem),
                _InsuranceField(
                  controller: _pinCtrl,
                  keyboardType: TextInputType.number,
                  fem: fem,
                ),
                SizedBox(height: 14 * fem),

                _FieldLabel('Date of Birth', fem),
                _InsuranceDateField(controller: _dobCtrl, fem: fem),
                SizedBox(height: 32 * fem),

                SizedBox(
                  width: double.infinity,
                  height: 50 * fem,
                  child: ElevatedButton(
                    onPressed: () =>
                        setState(() => _step = _InsuranceStep.done),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.textDark,
                      foregroundColor: AppColors.white,
                      elevation: 0,
                      shape: const RoundedRectangleBorder(),
                    ),
                    child: MyText(
                      'SUBMIT',
                      style: TextStyle(
                        fontSize: 13 * fem,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24 * fem),
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
  Widget _buildBanner({required double fem}) {
    return Container(
      width: double.infinity,
      height: 180 * fem,
      color: AppColors.textDark,
      child: Stack(
        children: [
          Positioned(
            top: 16 * fem,
            left: 16 * fem,
            child: MyText(
              'UID : ${p.uid}',
              style: TextStyle(
                fontSize: 13 * fem,
                color: AppColors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Center(
            child: _ShieldDiamondIcon(size: 80 * fem, fem: fem),
          ),
        ],
      ),
    );
  }

  // ── HEADS UP DIALOG ────────────────────────────────────────────────────────
  Widget _buildHeadsUpDialog({required double fem}) {
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
                    Expanded(
                      child: MyText(
                        'Heads Up!',
                        style: TextStyle(
                          fontSize: 16 * fem,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _showHeadsUp = false),
                      child: Icon(
                        Icons.close,
                        size: 20 * fem,
                        color: AppColors.textMid,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Message
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 14 * fem,
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
                SizedBox(height: 24 * fem),

                // OKAY
                SizedBox(
                  width: 120 * fem,
                  height: 44 * fem,
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
}

// =============================================================================
// SHIELD + DIAMOND ICON
// Matches Image 1: clean white shield outline + diamond inside
// =============================================================================

class _ShieldDiamondIcon extends StatelessWidget {
  final double size;
  final double fem;
  const _ShieldDiamondIcon({required this.size, required this.fem});

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
  final double fem;
  const _FeatureRow({
    required this.icon,
    required this.label,
    required this.fem,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16 * fem, vertical: 16 * fem),
      child: Row(
        children: [
          SizedBox(
            width: 48 * fem,
            height: 48 * fem,
            child: Image.asset(
              _assetForIcon(icon),
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => _FallbackIcon(icon: icon),
            ),
          ),
          SizedBox(width: 16 * fem),
          MyText(
            label,
            style: TextStyle(
              fontSize: 13 * fem,
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
  final double fem;
  const _FieldLabel(this.text, this.fem);

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: 6 * fem),
    child: MyText(
      text,
      style: TextStyle(fontSize: 13 * fem, color: AppColors.textDark),
    ),
  );
}

class _InsuranceField extends StatelessWidget {
  final TextEditingController controller;
  final TextInputType keyboardType;
  final int maxLines;
  final double fem;

  const _InsuranceField({
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    required this.fem,
  });

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    keyboardType: keyboardType,
    maxLines: maxLines,
    style: TextStyle(fontSize: 14 * fem, color: AppColors.textDark),
    decoration: InputDecoration(
      filled: true,
      fillColor: AppColors.white,
      contentPadding: EdgeInsets.symmetric(
        horizontal: 12 * fem,
        vertical: 14 * fem,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4 * fem),
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
  final double fem;
  const _InsuranceDateField({required this.controller, required this.fem});

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    readOnly: true,
    style: TextStyle(fontSize: 14 * fem, color: AppColors.textDark),
    decoration: InputDecoration(
      hintText: 'dd-mm-yyyy',
      hintStyle: TextStyle(fontSize: 13 * fem, color: AppColors.textLight),
      filled: true,
      fillColor: AppColors.white,
      contentPadding: EdgeInsets.symmetric(
        horizontal: 12 * fem,
        vertical: 14 * fem,
      ),
      suffixIcon: Icon(
        Icons.calendar_today_outlined,
        size: 18 * fem,
        color: AppColors.textMid,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4 * fem),
        borderSide: const BorderSide(color: AppColors.divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: AppColors.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4 * fem),
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
