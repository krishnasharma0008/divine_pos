import 'package:flutter/material.dart';
import '../../data/diamond_config.dart';

class DiamondDisplay extends StatelessWidget {
  final DiamondConfig config;
  const DiamondDisplay({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Diamond circle with real image
        _DiamondCircle(config: config),
        const SizedBox(height: 14),

        // Diamond code
        Text(
          config.diamondCode,
          style: const TextStyle(
            fontFamily: 'Georgia',
            fontSize: 17,
            fontWeight: FontWeight.w500,
            color: Color(0xFF2A2A2A),
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 14),

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
          const SizedBox(height: 6),
          Text(
            'Guaranteed on all Round Brilliant Diamond',
            style: TextStyle(fontSize: 10, color: Colors.grey[500]),
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
  const _DiamondCircle({required this.config});

  @override
  Widget build(BuildContext context) {
    debugPrint('Check selected Data : ${config}');

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, anim) => FadeTransition(
        opacity: anim,
        child: ScaleTransition(scale: anim, child: child),
      ),
      child: Container(
        key: ValueKey(config.shapeAsset),
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const RadialGradient(
            center: Alignment(-0.2, -0.2),
            colors: [Color(0xFFEFECEC), Color(0xFFD5D5D5)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(28),
        child: Image.asset(config.shapeAsset, fit: BoxFit.contain),
      ),
    );
  }
}

class _HeartsArrowsIcon extends StatelessWidget {
  final bool isHearts;
  const _HeartsArrowsIcon({required this.isHearts});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFE88888), width: 1.5),
          ),
          child: CustomPaint(painter: _RadialDotsPainter(isHearts: isHearts)),
        ),
        const SizedBox(height: 4),
        Text(
          isHearts ? '8 Hearts' : '8 Arrows',
          style: const TextStyle(fontSize: 10, color: Color(0xFF6B6B6B)),
        ),
      ],
    );
  }
}

class _RadialDotsPainter extends CustomPainter {
  final bool isHearts;
  _RadialDotsPainter({required this.isHearts});

  static double _sin(double x) {
    double result = x, term = x;
    for (int i = 1; i <= 8; i++) {
      term *= -x * x / ((2 * i) * (2 * i + 1));
      result += term;
    }
    return result;
  }

  static double _cos(double x) {
    double result = 1, term = 1;
    for (int i = 1; i <= 8; i++) {
      term *= -x * x / ((2 * i - 1) * (2 * i));
      result += term;
    }
    return result;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE88888).withOpacity(0.85)
      ..style = PaintingStyle.fill;
    final cx = size.width / 2, cy = size.height / 2;
    const r = 10.0, dotR = 2.2;
    const pi = 3.14159265358979;

    for (int i = 0; i < 8; i++) {
      final angle = (i * 45 - 90) * pi / 180;
      final x = cx + r * _cos(angle);
      final y = cy + r * _sin(angle);
      if (isHearts) {
        canvas.drawCircle(Offset(x, y), dotR, paint);
      } else {
        final path = Path()
          ..moveTo(x, y - dotR * 1.5)
          ..lineTo(x + dotR, y + dotR)
          ..lineTo(x - dotR, y + dotR)
          ..close();
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_RadialDotsPainter old) => old.isHearts != isHearts;
}

class _FeaturesGrid extends StatelessWidget {
  final features = const [
    'Excellent cut',
    'None fluorescence',
    'Excellent polish',
    'No overtone',
    'Excellent symmetry',
    'Faceted girdle',
    'Ultimate light performance',
    'Pointed cullet. Many more...',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFB8D8D0),
        borderRadius: BorderRadius.circular(8),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 3.5,
        ),
        itemCount: features.length,
        itemBuilder: (_, i) {
          final isLastRow = i >= features.length - 2;
          final isRightCol = i.isOdd;
          return Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: isLastRow
                    ? BorderSide.none
                    : BorderSide(
                        color: Colors.white.withOpacity(0.35),
                        width: 1,
                      ),
                right: isRightCol
                    ? BorderSide.none
                    : BorderSide(
                        color: Colors.white.withOpacity(0.35),
                        width: 1,
                      ),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              children: [
                const Icon(Icons.check, size: 12, color: Color(0xFF3AA09A)),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    features[i],
                    style: const TextStyle(
                      fontSize: 9.5,
                      color: Color(0xFF2A2A2A),
                    ),
                    overflow: TextOverflow.ellipsis,
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
