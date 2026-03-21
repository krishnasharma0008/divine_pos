// lib/features/verify_track/presentation/tabs/certificate_screen.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../shared/widgets/text.dart';
import '../../data/verify_track_model.dart';
import '../verify_detail_shell.dart';

// Text styles tuned to match the web layout
const _titleStyle = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w700,
  letterSpacing: 0.4,
  color: AppColors.textDark,
);

const _qualityStyle = TextStyle(
  fontSize: 12,
  fontWeight: FontWeight.w500,
  letterSpacing: 0.8,
  color: AppColors.textDark,
);

const _bodyLabelStyle = TextStyle(fontSize: 12, color: AppColors.textMid);

const _bodyValueStyle = TextStyle(
  fontSize: 12,
  fontWeight: FontWeight.w600,
  color: AppColors.gold,
);

class CertificateScreen extends StatelessWidget {
  final VerifyTrackByUid product;
  const CertificateScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final p = product;
    final slt = p.sltDetails.isNotEmpty ? p.sltDetails.first : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        // match a fixed paper width like the web view
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
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
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 12, 16, 0),
                    child: GestureDetector(
                      onTap: () {},
                      child: const Icon(
                        Icons.download_outlined,
                        size: 20,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                ),

                // ── DIVINE SOLITAIRES logo ───────────────────────────────
                const SizedBox(height: 8),
                Center(
                  child: Image.asset(
                    'assets/vtdia/certificate-head-logo.png', // top logo asset
                    width: 280,
                    height: 80,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) =>
                        const SizedBox(width: 140, height: 40),
                  ),
                ),

                const SizedBox(height: 24),

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
                const Center(
                  child: Text('Divine Solitaire Summary', style: _titleStyle),
                ),
                const SizedBox(height: 20),

                _CertRow(label: 'UID:', value: p.uid),
                _CertRow(
                  label: 'Description:',
                  value: p.isDiamond ? 'Natural Diamond' : p.category,
                ),
                if (slt != null) _CertRow(label: 'Shape:', value: slt.shape),
                if (!p.isDiamond && p.designNo.isNotEmpty)
                  _CertRow(label: 'Design No:', value: p.designNo),

                const SizedBox(height: 24),
                // const Divider(color: AppColors.divider),
                //const SizedBox(height: 16),

                // ── 4Cs / Specs ─────────────────────────────────────────
                if (p.isDiamond && slt != null) ...[
                  const Center(child: Text('The 4Cs', style: _titleStyle)),
                  const SizedBox(height: 20),
                  _CertRow(
                    label: 'Carat Weight:',
                    value: slt.carat.toStringAsFixed(2),
                  ),
                  _CertRow(label: 'Colour Guide:', value: slt.colour),
                  _CertRow(label: 'Clarity Grade:', value: slt.clarity),
                  const _CertRow(
                    label: 'Cut Grade:',
                    value: '(Ex.Ex.Ex.) Plus',
                  ),
                ] else ...[
                  const Center(
                    child: Text('Product Specifications', style: _titleStyle),
                  ),
                  const SizedBox(height: 20),
                  _CertRow(label: 'Gross Weight:', value: '${p.grossWt}g'),
                  _CertRow(label: 'Net Weight:', value: '${p.netWt}g'),
                  if (p.jewellerySize.isNotEmpty)
                    _CertRow(label: 'Size:', value: p.jewellerySize),
                  if (p.sdCts > 0)
                    _CertRow(label: 'Diamond Weight:', value: '${p.sdCts} Cts'),
                  if (p.sdColourClarity.isNotEmpty)
                    _CertRow(
                      label: 'Diamond Clarity:',
                      value: p.sdColourClarity,
                    ),
                ],

                const SizedBox(height: 28),
                // const Divider(color: AppColors.divider),
                //const SizedBox(height: 20),

                // ── Footer text ─────────────────────────────────────────
                const Padding(
                  padding: EdgeInsets.fromLTRB(32, 32, 32, 0),
                  child: Text(
                    "Divine Solitaires Stringently analyses as well as "
                    "Guarantees every diamond to score 'The Best' on all "
                    "the 123 parameters.",
                    style: TextStyle(
                      fontSize: 13,
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
                          const SizedBox(width: 80, height: 80),
                    ),
                    const SizedBox(width: 32),
                  ],
                ),

                const SizedBox(height: 24),
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
  const _CertRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // fixed-width label column so all values align
          SizedBox(
            width: 110, // tweak until it visually matches your design
            child: Text(label, style: _bodyLabelStyle),
          ),
          const SizedBox(width: 8),
          // value takes the rest and is right‑aligned
          Expanded(
            child: Text(
              value,
              style: _bodyValueStyle,
              textAlign: TextAlign.right,
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}
