// lib/features/verify_track/screens/tabs/certificate_screen.dart

import 'package:flutter/material.dart';
import '../../data/verify_track_model.dart';
import '../verify_detail_shell.dart';

class CertificateScreen extends StatelessWidget {
  final VerifyTrackByUid product;
  const CertificateScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final p = product;
    final slt = p.sltDetails.isNotEmpty ? p.sltDetails.first : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: VtCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Download button
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () {
                    /* TODO: download / share */
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.bgGrey,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: const Icon(
                      Icons.download_outlined,
                      size: 18,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Certificate header
            Center(
              child: Column(
                children: [
                  const Text(
                    'DIVINE',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 4,
                      color: AppColors.textDark,
                    ),
                  ),
                  const Text(
                    'SOLITAIRES',
                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 4,
                      color: AppColors.textMid,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.textDark),
                    ),
                    child: const Text(
                      'QUALITY GUARANTEE CERTIFICATE®',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Divider(color: AppColors.divider),

            // ── Summary ────────────────────────────────────────────────────
            const VtSectionTitle('Divine Solitaires Summary'),
            _CertRow(label: 'UID :', value: p.uid, valueColor: AppColors.gold),
            _CertRow(
              label: 'Description :',
              value: p.isDiamond ? 'Natural Diamond' : p.category,
              valueColor: AppColors.gold,
            ),
            if (p.isDiamond && slt != null)
              _CertRow(
                label: 'Shape :',
                value: slt.shape,
                valueColor: AppColors.gold,
              ),
            if (!p.isDiamond && p.designNo.isNotEmpty)
              _CertRow(
                label: 'Design No :',
                value: p.designNo,
                valueColor: AppColors.gold,
              ),
            if (p.collection.isNotEmpty)
              _CertRow(
                label: 'Collection :',
                value: p.collection,
                valueColor: AppColors.gold,
              ),

            const SizedBox(height: 16),
            const Divider(color: AppColors.divider),

            // ── 4Cs (Diamond) / Specs (Jewellery) ─────────────────────────
            if (p.isDiamond && slt != null) ...[
              const VtSectionTitle('The 4Cs'),
              _CertRow(
                label: 'Carat Weight :',
                value: '${slt.carat}',
                valueColor: AppColors.gold,
              ),
              _CertRow(
                label: 'Colour Guide :',
                value: slt.colour,
                valueColor: AppColors.gold,
              ),
              _CertRow(
                label: 'Clarity Grade :',
                value: slt.clarity,
                valueColor: AppColors.gold,
              ),
              const _CertRow(
                label: 'Cut Grade :',
                value: '(Ex.Ex.Ex.) Plus®',
                valueColor: AppColors.gold,
              ),
              if (p.sltTotalPcs > 1) ...[
                const SizedBox(height: 8),
                const Divider(color: AppColors.divider),
                const VtSectionTitle('All Solitaires'),
                ...p.sltDetails.asMap().entries.map((e) {
                  final i = e.key + 1;
                  final s = e.value;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      children: [
                        Text(
                          '#$i  ${s.shape}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textMid,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${s.carat}ct  ${s.colour}  ${s.clarity}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ] else ...[
              const VtSectionTitle('Product Specifications'),
              _CertRow(
                label: 'Gross Weight :',
                value: '${p.grossWt}g',
                valueColor: AppColors.gold,
              ),
              _CertRow(
                label: 'Net Weight :',
                value: '${p.netWt}g',
                valueColor: AppColors.gold,
              ),
              if (p.jewellerySize.isNotEmpty)
                _CertRow(
                  label: 'Size :',
                  value: p.jewellerySize,
                  valueColor: AppColors.gold,
                ),
              if (p.sdCts > 0) ...[
                _CertRow(
                  label: 'Diamond Weight :',
                  value: '${p.sdCts} Cts',
                  valueColor: AppColors.gold,
                ),
                _CertRow(
                  label: 'Diamond Clarity :',
                  value: p.sdColourClarity,
                  valueColor: AppColors.gold,
                ),
              ],
            ],

            const SizedBox(height: 20),
            const Divider(color: AppColors.divider),

            // Footer
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Divine Solitaires Stringently analyses as well as Guarantees '
                "every diamond to score 'The Best' on all the 123 parameters.",
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textMid,
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                ),
              ),
            ),

            // 123 badge
            Center(
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.textDark, width: 2),
                    ),
                    child: const Center(
                      child: Text(
                        '123',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'PARAMETERS',
                    style: TextStyle(
                      fontSize: 9,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMid,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CertRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _CertRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      children: [
        SizedBox(
          width: 130,
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.textMid),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: valueColor ?? AppColors.textDark,
            ),
          ),
        ),
      ],
    ),
  );
}
