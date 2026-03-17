// lib/features/verify_track/screens/tabs/summary_screen.dart

import 'package:flutter/material.dart';
import '../../data/verify_track_model.dart';
import '../verify_detail_shell.dart';

class SummaryScreen extends StatefulWidget {
  final VerifyTrackByUid product;
  const SummaryScreen({super.key, required this.product});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  int _imgIndex = 0;
  bool _showPurchaseInfo = false;
  bool _signedUp = false;

  VerifyTrackByUid get p => widget.product;

  // All images — prefer images list, fall back to single image
  List<String> get _images {
    if (p.images.isNotEmpty) return p.images;
    if (p.image.isNotEmpty) return [p.image];
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageCard(),
          _buildProductDetails(),
          _buildPurchaseInfo(),
          _buildActions(),
        ],
      ),
    );
  }

  // ── Image Carousel ──────────────────────────────────────────────────────────
  Widget _buildImageCard() {
    return VtCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 220,
            child: Stack(
              alignment: Alignment.center,
              children: [
                _images.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.network(
                          _images[_imgIndex],
                          fit: BoxFit.contain,
                          width: double.infinity,
                          errorBuilder: (_, __, ___) => const _Placeholder(),
                        ),
                      )
                    : const _Placeholder(),
                if (_images.length > 1) ...[
                  Positioned(
                    left: 0,
                    child: _Arrow(
                      icon: Icons.chevron_left,
                      onTap: () => setState(
                        () => _imgIndex =
                            (_imgIndex - 1 + _images.length) % _images.length,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    child: _Arrow(
                      icon: Icons.chevron_right,
                      onTap: () => setState(
                        () => _imgIndex = (_imgIndex + 1) % _images.length,
                      ),
                    ),
                  ),
                ],
                // Image counter dots
                if (_images.length > 1)
                  Positioned(
                    bottom: 0,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(
                        _images.length,
                        (i) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: i == _imgIndex ? 8 : 5,
                          height: i == _imgIndex ? 8 : 5,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: i == _imgIndex
                                ? AppColors.mintDark
                                : AppColors.divider,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // UID + Design No
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'UID : ${p.uid}',
                style: const TextStyle(fontSize: 12, color: AppColors.textMid),
              ),
              Text(
                'Design No. : ${p.designNo}',
                style: const TextStyle(fontSize: 12, color: AppColors.textMid),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Price
          Row(
            children: [
              Text(
                formatInr(p.currentPrice),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gold,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Excl. GST',
                style: TextStyle(fontSize: 11, color: AppColors.textLight),
              ),
              const Spacer(),
              const Icon(
                Icons.info_outline,
                size: 16,
                color: AppColors.textLight,
              ),
            ],
          ),

          // Category badge
          if (p.category.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.mintLight,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                p.category,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.mintDark,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Product details ─────────────────────────────────────────────────────────
  Widget _buildProductDetails() {
    return VtCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          VtSectionTitle(
            p.isDiamond ? 'Divine Solitaires :' : 'Product Details :',
          ),

          if (p.isDiamond && p.sltDetails.isNotEmpty) ...[
            const Divider(color: AppColors.divider),
            // Header row
            const Row(
              children: [
                Expanded(
                  child: Text(
                    'Shape',
                    style: TextStyle(fontSize: 11, color: AppColors.textLight),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Carat',
                    style: TextStyle(fontSize: 11, color: AppColors.textLight),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Colour',
                    style: TextStyle(fontSize: 11, color: AppColors.textLight),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Clarity',
                    style: TextStyle(fontSize: 11, color: AppColors.textLight),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // Each solitaire
            ...p.sltDetails.map(
              (s) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        s.shape,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '${s.carat}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        s.colour,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        s.clarity,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Totals
            if (p.sltTotalPcs > 1) ...[
              const Divider(color: AppColors.divider, height: 16),
              VtInfoRow(label: 'Total Pcs', value: '${p.sltTotalPcs}'),
              VtInfoRow(label: 'Total Carat', value: '${p.sltTotalCts}'),
            ],
          ] else ...[
            // Jewellery details
            VtInfoRow(label: 'Category', value: p.category),
            VtInfoRow(label: 'Collection', value: p.collection),
            if (p.jewellerySize.isNotEmpty)
              VtInfoRow(label: 'Size', value: p.jewellerySize),
            VtInfoRow(label: 'Gross Weight', value: '${p.grossWt}g'),
            VtInfoRow(label: 'Net Weight', value: '${p.netWt}g'),
            if (p.sdCts > 0) ...[
              const Divider(color: AppColors.divider, height: 16),
              const VtSectionTitle('Small Diamonds :'),
              VtInfoRow(label: 'Colour / Clarity', value: p.sdColourClarity),
              VtInfoRow(label: 'Weight', value: '${p.sdCts} Cts'),
              VtInfoRow(label: 'Pieces', value: '${p.sdPcs}'),
            ],
          ],

          // Mount details (both types)
          if (p.mountDetails1.isNotEmpty) ...[
            const Divider(color: AppColors.divider, height: 16),
            const VtSectionTitle('Mount Details :'),
            Text(
              p.mountDetails1,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textMid,
                height: 1.5,
              ),
            ),
            if (p.mountDetails2.isNotEmpty)
              Text(
                p.mountDetails2,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMid,
                  height: 1.5,
                ),
              ),
          ],

          // Solitaire details line
          if (p.isDiamond && p.solitaireDetails1.isNotEmpty) ...[
            const Divider(color: AppColors.divider, height: 16),
            Text(
              p.solitaireDetails1,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textMid,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Purchase Information ────────────────────────────────────────────────────
  Widget _buildPurchaseInfo() {
    return VtCard(
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() => _showPurchaseInfo = !_showPurchaseInfo),
            child: Row(
              children: [
                const Text(
                  'Purchase Information -',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                const Spacer(),
                Icon(
                  _showPurchaseInfo
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 18,
                  color: AppColors.textMid,
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.info_outline,
                  size: 15,
                  color: AppColors.textLight,
                ),
              ],
            ),
          ),
          if (_showPurchaseInfo) ...[
            const Divider(color: AppColors.divider, height: 20),
            if (p.purchaseFrom.isNotEmpty)
              VtInfoRow(label: 'Purchase From', value: p.purchaseFrom),
            if (p.purchaseDate.isNotEmpty)
              VtInfoRow(label: 'Purchase Date', value: p.purchaseDate),
            VtInfoRow(
              label: 'Purchase Amount',
              value: formatInr(p.purchasePrice),
            ),
            const VtInfoRow(label: 'Excl. GST', value: ''),
            if (p.purchaseDiscount > 0)
              VtInfoRow(
                label: 'Discount',
                value: '- ${formatInr(p.purchaseDiscount)}',
              ),
            const Divider(color: AppColors.divider, height: 16),
            VtInfoRow(
              label: 'Total Purchase Amount',
              value: formatInr(p.purchasePriceFinal),
              valueColor: AppColors.textDark,
            ),
          ],
        ],
      ),
    );
  }

  // ── Actions ─────────────────────────────────────────────────────────────────
  Widget _buildActions() {
    return VtCard(
      child: Column(
        children: [
          Row(
            children: [
              Checkbox(
                value: _signedUp,
                onChanged: (v) => setState(() => _signedUp = v ?? false),
                activeColor: AppColors.mintDark,
              ),
              const Text(
                'Click here to sign up',
                style: TextStyle(fontSize: 12, color: AppColors.textMid),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: VtOutlineButton(label: 'INSURE NOW', onPressed: () {}),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: VtFilledButton(
                  label: 'ADD TO PORTFOLIO',
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Small helpers ─────────────────────────────────────────────────────────────

class _Placeholder extends StatelessWidget {
  const _Placeholder();
  @override
  Widget build(BuildContext context) => const Center(
    child: Icon(Icons.diamond_outlined, size: 80, color: AppColors.textLight),
  );
}

class _Arrow extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _Arrow({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: AppColors.white,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.divider),
      ),
      child: Icon(icon, size: 18, color: AppColors.textDark),
    ),
  );
}
