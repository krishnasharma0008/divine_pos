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
        _DiamondCircle(config: config),
        const SizedBox(height: 14),

        MyText(
          config.diamondCode,
          style: TextStyle(
            color: Colors.black,
            fontSize: 20 * fem,
            //fontFamily: 'Montserrat',
            fontWeight: FontWeight.w500,
            height: 1.35,
            letterSpacing: 0.40,
          ),
        ),
        SizedBox(height: 14 * fem),

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
              //fontFamily: 'Montserrat',
              fontWeight: FontWeight.w300,
            ),
          ),
          SizedBox(height: 14 * fem),
        ] else
          SizedBox(height: 14 * fem),

        const _FeaturesGrid(),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Diamond circle
// ─────────────────────────────────────────────────────────────────────────────

class _DiamondCircle extends StatelessWidget {
  final DiamondConfig config;
  const _DiamondCircle({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
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
        child: Image.asset(
          config.shapeAsset,
          width: 82 * ScaleSize.aspectRatio,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hearts & Arrows
// ─────────────────────────────────────────────────────────────────────────────

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
            //fontFamily: 'Montserrat',
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Features Grid — Option C: Clean white card, mint header, bordered cells
// ─────────────────────────────────────────────────────────────────────────────

class _FeaturesGrid extends StatelessWidget {
  const _FeaturesGrid();

  static const _features = [
    (icon: Icons.cut_outlined, label: 'Excellent Cut'),
    (icon: Icons.flare_outlined, label: 'No Fluorescence'),
    (icon: Icons.lens_blur, label: 'Excellent Polish'),
    (icon: Icons.palette_outlined, label: 'No Overtone'),
    (icon: Icons.hub_outlined, label: 'Excellent Symmetry'),
    (icon: Icons.hexagon_outlined, label: 'Faceted Girdle'),
    (icon: Icons.wb_sunny_outlined, label: 'Ultimate Light Perf.'),
    (icon: Icons.more_horiz_rounded, label: 'Pointed Cullet & More'),
  ];

  // Mint palette
  static const _mintBg = Color(0xFFF0F9F7);
  static const _mintBorder = Color(0xFFC5E8E1);
  static const _mintText = Color(0xFF0F6E56);
  static const _cellBorder = Color(0xFFEAF3F1);

  @override
  Widget build(BuildContext context) {
    final fem = ScaleSize.aspectRatio;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _mintBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: _mintText.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // ── Mint header ──────────────────────────────────────────────────
          Container(
            width: double.infinity,
            color: _mintBg,
            padding: EdgeInsets.symmetric(
              horizontal: 14 * fem,
              vertical: 10 * fem,
            ),
            child: Row(
              children: [
                Icon(Icons.diamond_outlined, color: _mintText, size: 18 * fem),
                SizedBox(width: 6 * fem),
                MyText(
                  'Divine Quality Assurance',
                  style: TextStyle(
                    //fontFamily: 'Montserrat',
                    fontSize: 14 * fem,
                    fontWeight: FontWeight.w700,
                    color: _mintText,
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
          ),

          // ── Accent line below header ──────────────────────────────────────
          Container(height: 1, color: _mintBorder),

          // ── Rows: 2 cells per row ─────────────────────────────────────────
          ...List.generate((_features.length / 2).ceil(), (row) {
            final leftIndex = row * 2;
            final rightIndex = leftIndex + 1;
            final isLastRow = rightIndex >= _features.length;

            return Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: isLastRow
                      ? BorderSide.none
                      : BorderSide(color: _cellBorder, width: 1),
                ),
              ),
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    Expanded(
                      child: _FeatureCell(
                        icon: _features[leftIndex].icon,
                        label: _features[leftIndex].label,
                        rightBorder: true,
                        fem: fem,
                      ),
                    ),
                    if (rightIndex < _features.length)
                      Expanded(
                        child: _FeatureCell(
                          icon: _features[rightIndex].icon,
                          label: _features[rightIndex].label,
                          rightBorder: false,
                          fem: fem,
                        ),
                      )
                    else
                      const Expanded(child: SizedBox()),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Single feature cell
// ─────────────────────────────────────────────────────────────────────────────

class _FeatureCell extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool rightBorder;
  final double fem;

  const _FeatureCell({
    required this.icon,
    required this.label,
    required this.rightBorder,
    required this.fem,
  });

  static const _tickBg = Color(0xFFE1F5EE);
  static const _tickIcon = Color(0xFF1D9E75);
  static const _labelColor = Color(0xFF2A2A2A);
  static const _cellBorder = Color(0xFFEAF3F1);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10 * fem, vertical: 9 * fem),
      decoration: rightBorder
          ? BoxDecoration(
              border: Border(right: BorderSide(color: _cellBorder, width: 1)),
            )
          : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Rounded tick badge
          // Container(
          //   width: 22 * fem,
          //   height: 22 * fem,
          //   decoration: BoxDecoration(
          //     color: _tickBg,
          //     borderRadius: BorderRadius.circular(6),
          //   ),
          //   child: Icon(Icons.check_rounded, color: _tickIcon, size: 13 * fem),
          // ),
          SizedBox(width: 8 * fem),
          // Feature label
          Expanded(
            child: MyText(
              label,
              style: TextStyle(
                //fontFamily: 'Montserrat',
                fontSize: 14 * fem,
                fontWeight: FontWeight.w500,
                color: _labelColor,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
