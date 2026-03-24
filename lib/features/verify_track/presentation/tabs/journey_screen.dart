import 'package:divine_pos/shared/utils/scale_size.dart';
import 'package:divine_pos/shared/widgets/text.dart';
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
    final fem = ScaleSize.aspectRatio;
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
            labelStyle: TextStyle(
              fontSize: 12 * fem,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
            unselectedLabelStyle: TextStyle(
              fontSize: 12 * fem,
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
              _DiamondFormed(product: widget.product, fem: fem),
              _MinedFrom(product: widget.product, fem: fem),
              _AboutDiamond(product: widget.product, fem: fem),
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
  final double fem;
  const _DiamondFormed({required this.product, required this.fem});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: VtCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _JourneyBanner(image: 'assets/vtdia/Rectangle 40.png'),
            SizedBox(height: 16 * fem),

            MyText(
              'How was your diamond formed?',
              style: TextStyle(
                fontSize: 14 * fem,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            SizedBox(height: 16 * fem),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _Stat(
                  image: 'assets/vtdia/image 20.png',
                  label: 'Up to 3 billion\nyears ago',
                  fem: fem,
                ),
                _Stat(
                  image: 'assets/vtdia/image 14.png',
                  label: 'Up to 200 km\nin depth',
                  fem: fem,
                ),
                _Stat(
                  image: 'assets/vtdia/image 15.png',
                  label: 'At 900-1300\nDegree Celsius',
                  fem: fem,
                ),
              ],
            ),
            const SizedBox(height: 20),

            MyText(
              'Your diamond was formed hundreds of kilometers below the earth\'s '
              'surface forging through extreme heat and pressure crystallizing '
              'fragments of carbon to form a rough diamond.',
              style: TextStyle(
                fontSize: 13 * fem,
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
  final double fem;
  const _MinedFrom({required this.product, required this.fem});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16 * fem),
      child: VtCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _JourneyBanner(image: 'assets/vtdia/Rectangle40.png'),
            SizedBox(height: 24 * fem),

            MyText(
              'Mined From',
              style: TextStyle(
                fontSize: 14 * fem,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            SizedBox(height: 16 * fem),

            MyText(
              'Every Divine Solitaires diamond is ethically sourced from one of '
              'three mines - Canada, Botswana, Russia, South Africa, Australia '
              '& Angola. Diamonds sourced from these, follow internationally '
              'recognised labour & environment standards.',
              style: TextStyle(
                fontSize: 13 * fem,
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
  final double fem;
  const _AboutDiamond({required this.product, required this.fem});

  @override
  Widget build(BuildContext context) {
    final p = product;
    final slt = p.sltDetails.isNotEmpty ? p.sltDetails.first : null;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16 * fem),
      child: VtCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8 * fem),

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
                  fem: fem,
                ),
                Icon(
                  Icons.arrow_forward,
                  size: 16 * fem,
                  color: AppColors.textLight,
                ),
                _JourneyStage(
                  image: 'assets/vtdia/image 18.png',
                  label: 'Planned Model',
                  value: slt != null
                      ? '${(slt.carat * 1.5).toStringAsFixed(2)} Carat'
                      : '',
                  fem: fem,
                ),
                Icon(
                  Icons.arrow_forward,
                  size: 16 * fem,
                  color: AppColors.textLight,
                ),
                _JourneyStage(
                  image: 'assets/vtdia/image 19.png',
                  label: 'Polished',
                  value: slt != null ? '${slt.carat} Carat' : '',
                  fem: fem,
                ),
              ],
            ),
            SizedBox(height: 20 * fem),

            MyText(
              'The rough stone of carat is planned and after numerous stages of '
              'precise cutting and thorough polishing, the final round brilliant '
              'cut diamond of carat is formed.',
              style: TextStyle(
                fontSize: 13 * fem,
                color: AppColors.textMid,
                height: 1.7,
              ),
              textAlign: TextAlign.justify,
            ),
            SizedBox(height: 12 * fem),
            MyText(
              'The diamonds mined from these are Responsibly Sourced, passed '
              'through Kimberley process & guarantees Natural Diamond with no '
              'artificial treatments or enhancements.',
              style: TextStyle(
                fontSize: 13 * fem,
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
  final double fem;
  const _Stat({required this.image, required this.label, required this.fem});

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Image.asset(
        image,
        width: 66 * fem,
        height: 50 * fem,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => Icon(
          Icons.circle_outlined,
          size: 44 * fem,
          color: AppColors.mintDark,
        ),
      ),
      SizedBox(height: 6 * fem),
      MyText(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 11 * fem,
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
  final double fem;
  const _JourneyStage({
    required this.image,
    required this.label,
    required this.value,
    required this.fem,
  });

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 64 * fem,
        height: 64 * fem,
        decoration: BoxDecoration(
          color: AppColors.mintLight,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.mintDark),
        ),
        child: ClipOval(
          child: Image.asset(
            image,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                SizedBox(width: 64 * fem, height: 64 * fem),
          ),
        ),
      ),
      SizedBox(height: 4 * fem),
      MyText(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 10 * fem,
          color: AppColors.textMid,
          height: 1.3,
        ),
      ),
      if (value.isNotEmpty)
        MyText(
          value,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10 * fem,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
    ],
  );
}
