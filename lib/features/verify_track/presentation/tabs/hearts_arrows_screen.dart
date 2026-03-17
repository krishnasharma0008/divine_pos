// lib/features/verify_track/screens/tabs/hearts_arrows_screen.dart

import 'package:flutter/material.dart';
import '../../data/verify_track_model.dart';
import '../verify_detail_shell.dart';

class HeartsArrowsScreen extends StatelessWidget {
  final VerifyTrackByUid product;
  const HeartsArrowsScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: VtCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                _HaImage(label: '8 HEARTS'),
                _HaImage(label: '8 ARROWS'),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Hearts & Arrows',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 12),
            const Divider(color: AppColors.divider),
            const SizedBox(height: 12),
            const Text(
              'The brilliance of a diamond is determined by its cut. With exquisite and precise '
              'cuts, diamonds at Divine Solitaires are crafted with grace and utmost care. The '
              'most exclusive and perfect diamond cut in the world shows a hearts and arrows '
              'pattern within. The magnificent craftsmanship at Divine Solitaires guarantees '
              'all the diamonds to be (Ex. Ex. Ex.) Plus® quality which stands for excellent cut, '
              'excellent polish and excellent symmetry.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textMid,
                height: 1.7,
              ),
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );
  }
}

class _HaImage extends StatelessWidget {
  final String label;
  const _HaImage({required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.mintLight,
            border: Border.all(color: AppColors.mintDark, width: 1.5),
          ),
          child: const Center(
            child: Icon(Icons.favorite_border, size: 40, color: Colors.red),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }
}
