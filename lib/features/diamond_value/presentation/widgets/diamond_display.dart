import 'package:divine_pos/shared/utils/scale_size.dart';
import 'package:divine_pos/shared/widgets/text.dart';
import 'package:flutter/material.dart';
import '../../data/diamond_config.dart';

class DiamondDisplay extends StatelessWidget {
  final DiamondConfig config;
  const DiamondDisplay({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    final fem = ScaleSize.aspectRatio;
    return Column(
      children: [
        // Diamond circle with real image
        _DiamondCircle(config: config),
        const SizedBox(height: 14),

        // Diamond code
        Text(
          config.diamondCode,
          style: TextStyle(
            color: Colors.black,
            fontSize: 20 * fem,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w500,
            height: 1.35,
            letterSpacing: 0.40,
          ),
        ),
        SizedBox(height: 14 * fem),

        // Hearts & Arrows (only for Round white diamond)
        if (config.isRound) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _HeartsArrowsIcon(isHearts: true),
              const SizedBox(width: 28),
              _HeartsArrowsIcon(isHearts: false),
            ],
          ),
          SizedBox(height: 6 * fem),
          MyText(
            'Guaranteed on all Round Brilliant Diamond',
            style: TextStyle(
              color: Colors.black,
              fontSize: 12 * fem,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 14),
        ] else
          const SizedBox(height: 14),

        // Features grid
        _FeaturesGrid(),
      ],
    );
  }
}

class _DiamondCircle extends StatelessWidget {
  final DiamondConfig config;
  const _DiamondCircle({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    debugPrint('Shape: ${config.shapeAsset}');
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Container(
        key: ValueKey(config.shapeAsset),
        width: 200 * ScaleSize.aspectRatio,
        height: 200 * ScaleSize.aspectRatio,
        alignment: Alignment.center,
        decoration: const ShapeDecoration(
          color: Color(0xFFF6F6F6),
          shape: OvalBorder(
            side: BorderSide(width: 1, color: Color(0xFFCECECE)),
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            /// Ring (only if exists)
            // if (config.ringAsset != null)
            // Image.asset(
            //   'assets/diamond_value/grayring.png',
            //   width: 180 * ScaleSize.aspectRatio,
            //   fit: BoxFit.contain,
            //   filterQuality: FilterQuality.high,
            // ),

            /// Diamond always shows
            Image.asset(
              config.shapeAsset,
              width: 82 * ScaleSize.aspectRatio,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
          ],
        ),
      ),
    );
  }
}

class _HeartsArrowsIcon extends StatelessWidget {
  final bool isHearts;
  const _HeartsArrowsIcon({required this.isHearts});

  @override
  Widget build(BuildContext context) {
    final fem = ScaleSize.aspectRatio;

    return Column(
      children: [
        Container(
          width: 44 * fem,
          height: 44 * fem,
          padding: EdgeInsets.all(6 * fem),
          // decoration: BoxDecoration(
          //   shape: BoxShape.circle,
          //   border: Border.all(color: const Color(0xFFE88888), width: 1.5),
          // ),
          child: Image.asset(
            isHearts
                ? 'assets/vtdia/circle-heart.png'
                : 'assets/vtdia/circle.png',
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
          ),
        ),
        SizedBox(height: 4 * fem),
        MyText(
          isHearts ? '8 Hearts' : '8 Arrows',
          style: TextStyle(
            color: Colors.black,
            fontSize: 12 * fem,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _FeaturesGrid extends StatelessWidget {
  const _FeaturesGrid();

  final List<String> features = const [
    'Excellent cut',
    'None\nfluorescence',
    'Excellent polish',
    'No overtone',
    'Excellent symmetry',
    'faceted girdle',
    'Ultimate light\nperformance',
    'Pointed cullet\nMany more..',
  ];

  @override
  Widget build(BuildContext context) {
    final fem = ScaleSize.aspectRatio;

    return Container(
      width: double.infinity,
      height: 103 * fem,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment(0.01, 1.04),
          end: Alignment(0.97, 0.0),
          colors: [Color(0xFF6FA198), Color(0xFF8AC0B6)],
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white),
      ),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: features.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 2.8,
        ),
        itemBuilder: (context, index) {
          final row = index ~/ 4;
          final col = index % 4;

          return Container(
            padding: EdgeInsets.symmetric(horizontal: 10 * fem),
            decoration: BoxDecoration(
              border: Border(
                right: col == 3
                    ? BorderSide.none
                    : BorderSide(
                        color: Colors.white.withOpacity(0.35),
                        width: 1,
                      ),
                bottom: row == 1
                    ? BorderSide.none
                    : BorderSide(
                        color: Colors.white.withOpacity(0.35),
                        width: 1,
                      ),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                /// Tick badge
                Container(
                  width: 18 * fem,
                  height: 18 * fem,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset(
                        'assets/vtdia/Star 2.png',
                        width: 18 * fem,
                        height: 18 * fem,
                        fit: BoxFit.contain,
                      ),
                      Image.asset(
                        'assets/vtdia/green-rick.png',
                        width: 9 * fem,
                        height: 9 * fem,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                ),

                SizedBox(width: 8 * fem),

                /// Feature text
                Expanded(
                  child: Text(
                    features[index],
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11 * fem,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w400,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
