// lib/features/verify_track/screens/tabs/journey_screen.dart

import 'package:flutter/material.dart';
import '../../data/verify_track_model.dart';
import '../verify_detail_shell.dart';

class JourneyScreen extends StatefulWidget {
  final VerifyTrackByUid product;
  const JourneyScreen({super.key, required this.product});

  @override
  State<JourneyScreen> createState() => _JourneyScreenState();
}

class _JourneyScreenState extends State<JourneyScreen> {
  int _subTab = 0;

  static const _tabs = ['Diamond Formed', 'Mined From', 'About Diamond'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Sub-tab bar
        Container(
          color: AppColors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(_tabs.length, (i) {
                final active = i == _subTab;
                return GestureDetector(
                  onTap: () => setState(() => _subTab = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: active ? AppColors.textDark : AppColors.bgGrey,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: active ? AppColors.textDark : AppColors.divider,
                      ),
                    ),
                    child: Text(
                      _tabs[i],
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: active ? AppColors.white : AppColors.textMid,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),

        // Content
        Expanded(
          child: IndexedStack(
            index: _subTab,
            children: [
              _DiamondFormed(product: widget.product),
              _MinedFrom(product: widget.product),
              _AboutDiamond(product: widget.product),
            ],
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// SUB-TAB 1: Diamond Formed
// =============================================================================

class _DiamondFormed extends StatelessWidget {
  final VerifyTrackByUid product;
  const _DiamondFormed({required this.product});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: VtCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner
            _JourneyBanner(icon: Icons.local_fire_department_outlined),
            const SizedBox(height: 16),

            const Text(
              'How was your diamond formed?',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 16),

            // Stats row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                _Stat(icon: Icons.history, label: 'Up to 3 billion\nyears ago'),
                _Stat(icon: Icons.south, label: 'Up to 200 km\nin depth'),
                _Stat(
                  icon: Icons.thermostat,
                  label: 'At 900-1300\nDegree Celsius',
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: AppColors.divider),
            const SizedBox(height: 12),

            const Text(
              'Your diamond was formed hundreds of kilometers below the earth\'s '
              'surface forging through extreme heat and pressure crystallizing '
              'fragments of carbon to form a rough diamond.',
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

// =============================================================================
// SUB-TAB 2: Mined From
// =============================================================================

class _MinedFrom extends StatelessWidget {
  final VerifyTrackByUid product;
  const _MinedFrom({required this.product});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: VtCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _JourneyBanner(icon: Icons.terrain_outlined),
            const SizedBox(height: 16),

            const Text(
              'Mined From',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 16),

            // Mining locations
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: const [
                _CountryChip('Canada'),
                _CountryChip('Botswana'),
                _CountryChip('Russia'),
                _CountryChip('South Africa'),
                _CountryChip('Australia'),
                _CountryChip('Angola'),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: AppColors.divider),
            const SizedBox(height: 12),

            const Text(
              'Every Divine Solitaires diamond is ethically sourced from one of '
              'three mines - Canada, Botswana, Russia, South Africa, Australia '
              '& Angola. Diamonds sourced from these, follow internationally '
              'recognised labour & environment standards.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textMid,
                height: 1.7,
              ),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 16),

            // Kimberley process badge
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.mintLight,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.verified_outlined,
                    size: 20,
                    color: AppColors.mintDark,
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Kimberley Process Certified\nConflict-Free Diamond',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.mintDark,
                        height: 1.4,
                      ),
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

// =============================================================================
// SUB-TAB 3: About Diamond
// =============================================================================

class _AboutDiamond extends StatelessWidget {
  final VerifyTrackByUid product;
  const _AboutDiamond({required this.product});

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
            _JourneyBanner(icon: Icons.diamond_outlined),
            const SizedBox(height: 16),

            const Text(
              'About Diamond',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 16),

            // Journey stages with real carat data
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _JourneyStage(
                  icon: Icons.lens_outlined,
                  label: 'Rough Diamond',
                  // rough is ~2x the final carat
                  value: slt != null
                      ? '${(slt.carat * 2).toStringAsFixed(2)} Carat'
                      : '',
                ),
                const Icon(
                  Icons.arrow_forward,
                  size: 16,
                  color: AppColors.textLight,
                ),
                _JourneyStage(
                  icon: Icons.blur_circular_outlined,
                  label: 'Planned Model',
                  value: slt != null
                      ? '${(slt.carat * 1.5).toStringAsFixed(2)} Carat'
                      : '',
                ),
                const Icon(
                  Icons.arrow_forward,
                  size: 16,
                  color: AppColors.textLight,
                ),
                _JourneyStage(
                  icon: Icons.diamond_outlined,
                  label: 'Polished',
                  // actual final carat from API
                  value: slt != null ? '${slt.carat} Carat' : '',
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: AppColors.divider),
            const SizedBox(height: 12),

            const Text(
              'The rough stone of carat is planned and after numerous stages of '
              'precise cutting and thorough polishing, the final round brilliant '
              'cut diamond of carat is formed.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textMid,
                height: 1.7,
              ),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 12),
            const Text(
              'The diamonds mined from these are Responsibly Sourced, passed '
              'through Kimberley process & guarantees Natural Diamond with no '
              'artificial treatments or enhancements.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textMid,
                height: 1.7,
              ),
              textAlign: TextAlign.justify,
            ),

            // Diamond specs if available
            if (slt != null) ...[
              const SizedBox(height: 16),
              const Divider(color: AppColors.divider),
              const SizedBox(height: 12),
              const VtSectionTitle('Your Diamond'),
              VtInfoRow(label: 'Shape', value: slt.shape),
              VtInfoRow(label: 'Carat', value: '${slt.carat}'),
              VtInfoRow(label: 'Colour', value: slt.colour),
              VtInfoRow(label: 'Clarity', value: slt.clarity),
            ],
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// SHARED JOURNEY WIDGETS
// =============================================================================

class _JourneyBanner extends StatelessWidget {
  final IconData icon;
  const _JourneyBanner({required this.icon});

  @override
  Widget build(BuildContext context) => Container(
    height: 140,
    width: double.infinity,
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [AppColors.mintDark, Color(0xFF4A8A83)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Center(child: Icon(icon, size: 60, color: AppColors.white)),
  );
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Stat({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.mintLight,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 22, color: AppColors.mintDark),
      ),
      const SizedBox(height: 6),
      Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 10,
          color: AppColors.textMid,
          height: 1.4,
        ),
      ),
    ],
  );
}

class _JourneyStage extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _JourneyStage({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.mintLight,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.mintDark),
        ),
        child: Icon(icon, size: 24, color: AppColors.mintDark),
      ),
      const SizedBox(height: 4),
      Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 10,
          color: AppColors.textMid,
          height: 1.3,
        ),
      ),
      if (value.isNotEmpty)
        Text(
          value,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
    ],
  );
}

class _CountryChip extends StatelessWidget {
  final String country;
  const _CountryChip(this.country);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: AppColors.mintLight,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColors.mintDark),
    ),
    child: Text(
      country,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.mintDark,
      ),
    ),
  );
}
