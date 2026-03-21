import 'package:flutter/material.dart';
import '../../data/verify_track_model.dart';
import '../verify_detail_shell.dart';

class JourneyScreen extends StatefulWidget {
  final VerifyTrackByUid product;
  const JourneyScreen({super.key, required this.product});

  @override
  State<JourneyScreen> createState() => _JourneyScreenState();
}

class _JourneyScreenState extends State<JourneyScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tc;

  @override
  void initState() {
    super.initState();
    _tc = TabController(length: 3, vsync: this);
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
        // ── TabBar — same style as ResaleScreen ───────────────────────────────
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
              Tab(text: 'DIAMOND FORMED'),
              Tab(text: 'MINED FROM'),
              Tab(text: 'ABOUT DIAMOND'),
            ],
          ),
        ),

        // ── Content ───────────────────────────────────────────────────────────
        Expanded(
          child: TabBarView(
            controller: _tc,
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
// TAB 1: Diamond Formed
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
            _JourneyBanner(image: 'assets/vtdia/Rectangle 40.png'),
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

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                _Stat(
                  image: 'assets/vtdia/image 20.png',
                  label: 'Up to 3 billion\nyears ago',
                ),
                _Stat(
                  image: 'assets/vtdia/image 14.png',
                  label: 'Up to 200 km\nin depth',
                ),
                _Stat(
                  image: 'assets/vtdia/image 15.png',
                  label: 'At 900-1300\nDegree Celsius',
                ),
              ],
            ),
            const SizedBox(height: 20),

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
// TAB 2: Mined From
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
            _JourneyBanner(image: 'assets/vtdia/Rectangle40.png'),
            const SizedBox(height: 24),

            const Text(
              'Mined From',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 16),

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
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// TAB 3: About Diamond
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
            const SizedBox(height: 8),

            // Journey stages
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _JourneyStage(
                  image: 'assets/vtdia/image 17.png',
                  label: 'Rough Diamond',
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
                  image: 'assets/vtdia/image 18.png',
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
                  image: 'assets/vtdia/image 19.png',
                  label: 'Polished',
                  value: slt != null ? '${slt.carat} Carat' : '',
                ),
              ],
            ),
            const SizedBox(height: 20),

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
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// SHARED WIDGETS
// =============================================================================

/// Full-width banner — fills width, fixed height, gradient fallback
class _JourneyBanner extends StatelessWidget {
  final String image;
  const _JourneyBanner({required this.image});

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(6),
    child: Image.asset(
      image,
      height: 160,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        height: 160,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.mintDark, Color(0xFF4A8A83)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    ),
  );
}

/// Stat icon + label — no circle clipping, natural image display
class _Stat extends StatelessWidget {
  final String image;
  final String label;
  const _Stat({required this.image, required this.label});

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Image.asset(
        image,
        width: 66,
        height: 50,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const Icon(
          Icons.circle_outlined,
          size: 44,
          color: AppColors.mintDark,
        ),
      ),
      const SizedBox(height: 6),
      Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 11,
          color: AppColors.textMid,
          height: 1.4,
        ),
      ),
    ],
  );
}

/// Journey stage — circular container with ClipOval image
class _JourneyStage extends StatelessWidget {
  final String image;
  final String label;
  final String value;
  const _JourneyStage({
    required this.image,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: AppColors.mintLight,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.mintDark),
        ),
        child: ClipOval(
          child: Image.asset(
            image,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const SizedBox(width: 64, height: 64),
          ),
        ),
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
