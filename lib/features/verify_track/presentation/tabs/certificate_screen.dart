// lib/features/verify_track/presentation/tabs/certificate_screen.dart

import 'dart:math' as math;
import 'package:divine_pos/shared/utils/scale_size.dart';
import 'package:flutter/material.dart';
import '../../../../shared/widgets/text.dart';
import '../../data/verify_track_model.dart';
import '../verify_detail_shell.dart';
import 'package:flutter_svg/flutter_svg.dart';

// Text styles tuned to match the web layout
TextStyle titleStyle(double fem) {
  return TextStyle(
    fontSize: 16 * fem,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.4,
    color: AppColors.textDark,
  );
}

TextStyle qualityStyle(double fem) {
  return TextStyle(
    fontSize: 12 * fem,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.8,
    color: AppColors.textDark,
  );
}

TextStyle bodyLabelStyle(double fem) {
  return TextStyle(fontSize: 12 * fem, color: AppColors.textMid);
}

TextStyle bodyValueStyle(double fem) {
  return TextStyle(
    fontSize: 12 * fem,
    fontWeight: FontWeight.w600,
    color: AppColors.gold,
  );
}

class CertificateScreen extends StatelessWidget {
  final VerifyTrackByUid product;
  const CertificateScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final p = product;
    final slt = p.sltDetails.isNotEmpty ? p.sltDetails.first : null;

    final fem = ScaleSize.aspectRatio;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        // match a fixed paper width like the web view
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 420 * fem),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              border: Border.all(color: AppColors.divider),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Download ─────────────────────────────────────────────
                // Align(
                //   alignment: Alignment.topRight,
                //   child: Padding(
                //     padding: const EdgeInsets.fromLTRB(0, 12, 16, 0),
                //     child: GestureDetector(
                //       onTap: () {},
                //       child: const Icon(
                //         Icons.download_outlined,
                //         size: 20,
                //         color: AppColors.textDark,
                //       ),
                //     ),
                //   ),
                // ),

                // ── DIVINE SOLITAIRES logo ───────────────────────────────
                SizedBox(height: 8 * fem),
                Center(
                  // child: Image.asset(
                  //   'assets/vtdia/certificate-head-logo.png', // top logo asset
                  //   width: 280,
                  //   height: 80,
                  //   fit: BoxFit.contain,
                  //   errorBuilder: (_, __, ___) =>
                  //       const SizedBox(width: 140, height: 40),
                  // ),
                  child: SvgPicture.asset(
                    "assets/Login/logo.svg",
                    height: fem * 80,
                    fit: BoxFit.contain,
                  ),
                ),

                SizedBox(height: 24 * fem),

                // ── QUALITY GUARANTEE CERTIFICATE ────────────────────────
                // const Center(
                //   child: Text(
                //     'QUALITY GUARANTEE CERTIFICATE\u00AE',
                //     style: _qualityStyle,
                //   ),
                // ),
                // const SizedBox(height: 28),
                // const Divider(color: AppColors.divider),
                //const SizedBox(height: 16),

                // ── Divine Solitaire Summary ─────────────────────────────
                Center(
                  child: MyText(
                    'Divine Solitaire Summary',
                    style: titleStyle(fem),
                  ),
                ),
                SizedBox(height: 20 * fem),

                _CertRow(label: 'UID:', value: p.uid, fem: fem),
                _CertRow(
                  label: 'Description:',
                  value: p.isDiamond ? 'Natural Diamond' : p.category,
                  fem: fem,
                ),
                if (slt != null)
                  _CertRow(label: 'Shape:', value: slt.shape, fem: fem),
                if (!p.isDiamond && p.designNo.isNotEmpty)
                  _CertRow(label: 'Design No:', value: p.designNo, fem: fem),

                SizedBox(height: 24 * fem),
                // const Divider(color: AppColors.divider),
                //const SizedBox(height: 16),

                // ── 4Cs / Specs ─────────────────────────────────────────
                if (p.isDiamond && slt != null) ...[
                  Center(child: Text('The 4Cs', style: titleStyle(fem))),
                  SizedBox(height: 20 * fem),
                  _CertRow(
                    label: 'Carat Weight:',
                    value: slt.carat.toStringAsFixed(2),
                    fem: fem,
                  ),
                  _CertRow(label: 'Colour Guide:', value: slt.colour, fem: fem),
                  _CertRow(
                    label: 'Clarity Grade:',
                    value: slt.clarity,
                    fem: fem,
                  ),
                  _CertRow(
                    label: 'Cut Grade:',
                    value: '(Ex.Ex.Ex.) Plus',
                    fem: fem,
                  ),
                ] else ...[
                  Center(
                    child: Text(
                      'Product Specifications',
                      style: titleStyle(fem),
                    ),
                  ),
                  SizedBox(height: 20 * fem),
                  _CertRow(
                    label: 'Gross Weight:',
                    value: '${p.grossWt}g',
                    fem: fem,
                  ),
                  _CertRow(
                    label: 'Net Weight:',
                    value: '${p.netWt}g',
                    fem: fem,
                  ),
                  if (p.jewellerySize.isNotEmpty)
                    _CertRow(label: 'Size:', value: p.jewellerySize, fem: fem),
                  if (p.sdCts > 0)
                    _CertRow(
                      label: 'Diamond Weight:',
                      value: '${p.sdCts} Cts',
                      fem: fem,
                    ),
                  if (p.sdColourClarity.isNotEmpty)
                    _CertRow(
                      label: 'Diamond Clarity:',
                      value: p.sdColourClarity,
                      fem: fem,
                    ),
                ],

                SizedBox(height: 28 * fem),
                // const Divider(color: AppColors.divider),
                //const SizedBox(height: 20),

                // ── Footer text ─────────────────────────────────────────
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    32 * fem,
                    32 * fem,
                    32 * fem,
                    0 * fem,
                  ),
                  child: MyText(
                    "Divine Solitaires Stringently analyses as well as "
                    "Guarantees every diamond to score 'The Best' on all "
                    "the 123 parameters.",
                    style: TextStyle(
                      fontSize: 13 * fem,
                      color: AppColors.textMid,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),

                //const SizedBox(height: 18),

                // ── 123 PARAMETERS badge ────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Image.asset(
                      'assets/vtdia/guarantee-certificate.png',
                      width: 120,
                      height: 160,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) =>
                          SizedBox(width: 80 * fem, height: 80 * fem),
                    ),
                    SizedBox(width: 32 * fem),
                  ],
                ),

                SizedBox(height: 24 * fem),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Certificate row ─────────────────────────────────────────────────────

class _CertRow extends StatelessWidget {
  final String label;
  final String value;
  final double fem;
  const _CertRow({required this.label, required this.value, required this.fem});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32 * fem, vertical: 6 * fem),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // fixed-width label column so all values align
          SizedBox(
            width: 110 * fem, // tweak until it visually matches your design
            child: MyText(label, style: bodyLabelStyle(fem)),
          ),
          SizedBox(width: 8 * fem),
          // value takes the rest and is right‑aligned
          Expanded(
            child: MyText(
              value,
              style: bodyValueStyle(fem),
              textAlign: TextAlign.right,
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}
