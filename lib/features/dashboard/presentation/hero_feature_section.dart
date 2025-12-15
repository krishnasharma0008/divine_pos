import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/utils/scale_size.dart';
import '../../../shared/widgets/text.dart';

class HeroAndFeaturesSection extends ConsumerWidget {
  final VoidCallback? onArrowTap;

  const HeroAndFeaturesSection({super.key, required this.onArrowTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double ar = ScaleSize.aspectRatio.clamp(0.7, 1.3);

    return Column(
      children: [
        const SizedBox(height: 10),

        // ---------------- HERO BANNER ----------------
        SizedBox(
          width: double.infinity,
          height: 410 * ar,
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/dashboard/banner/hero_banner.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),

              Positioned(
                top: 0,
                right: 0,
                bottom: 0,
                child: Image.asset(
                  'assets/dashboard/banner/rectangle_5026.png',
                  width: 419 * ar,
                  height: 410 * ar,
                  fit: BoxFit.cover,
                ),
              ),

              /// LEFT ROTATED TEXT (EVERY PROMISE MATTERS)
              Positioned(
                left: 949 * ar,
                top: 100 * ar,
                child: SizedBox(
                  width: 199 * ar,
                  height: 200 * ar,
                  child: Center(
                    child: RotatedBox(
                      quarterTurns: 0,
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'EVERY',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 36 * ar,
                                fontFamily: 'Rushter Glory',
                                fontWeight: FontWeight.w400,
                                height: 1.39,
                                letterSpacing: 1.08,
                              ),
                            ),
                            const TextSpan(text: '\n\n'),
                            TextSpan(
                              text: 'P',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 128 * ar,
                                fontFamily: 'Ballpoint Rush',
                                fontWeight: FontWeight.w400,
                                height: 0.39,
                                letterSpacing: 3.84,
                              ),
                            ),
                            TextSpan(
                              text: 'romise',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 150 * ar,
                                fontFamily: 'Ballpoint Rush',
                                fontWeight: FontWeight.w400,
                                height: 0.33,
                                letterSpacing: 4.50,
                              ),
                            ),
                            const TextSpan(text: '\n'),
                            TextSpan(
                              text: 'MATTERS!',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 36 * ar,
                                fontFamily: 'Rushter Glory',
                                fontWeight: FontWeight.w400,
                                height: 1.39,
                                letterSpacing: 1.08,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 20 * ar),

        // ---------------- FEATURE CARDS ----------------
        SizedBox(
          width: double.infinity,
          height: 218,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 10 * ar), // ✅ x-7
            child: Row(
              children: [
                FeatureCard(
                  label: "Catalogue",
                  image: "assets/dashboard/action_section/catalouge.png",
                  onTap: () => context.push('/jewellery_listing'),
                ),
                FeatureCard(
                  label: "Feedback Form",
                  image: "assets/dashboard/action_section/feedback-form.png",
                  onTap: () => context.push('/feedback'),
                ),
                FeatureCard(
                  label: "Know Your Diamond Value",
                  image:
                      "assets/dashboard/action_section/know_your_diamond_value.png",
                  onTap: () => context.push('/diamond-value'),
                ),
                FeatureCard(
                  label: "Verify & Track",
                  image: "assets/dashboard/action_section/verify-track.png",
                  onTap: () => context.push('/verify-track'),
                ),
                FeatureCard(
                  label: "Scan Ready Product",
                  image:
                      "assets/dashboard/action_section/scan-ready-product.jpg",
                  onTap: () => context.push('/scan-product'),
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: 23 * ar),

        // ---------------- SCROLL DOWN ARROW ----------------
        GestureDetector(
          onTap: onArrowTap,
          child: Container(
            width: 49 * ar,
            height: 49 * ar,
            decoration: const BoxDecoration(
              color: Color(0xFFBEE4DD),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.keyboard_arrow_down,
              size: 22 * ar,
              color: Colors.black,
            ),
          ),
        ),

        SizedBox(height: 20 * ar),
      ],
    );
  }
}

// ---------------- FEATURE CARD ----------------
class FeatureCard extends StatelessWidget {
  final String label;
  final String image;
  final VoidCallback onTap;

  const FeatureCard({
    super.key,
    required this.label,
    required this.image,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double ar = ScaleSize.aspectRatio.clamp(0.7, 1.3);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(right: 10 * ar), // ✅ spacing here
        width: 232 * ar,
        height: 218 * ar,
        padding: EdgeInsets.all(12 * ar),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F2),
          borderRadius: BorderRadius.circular(20 * ar),
          border: Border.all(color: const Color(0xFFF2F2F2)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x3FEFEFEF),
              blurRadius: 4,
              offset: Offset(2, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /// IMAGE
            Container(
              width: double.infinity,
              height: 114 * ar,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20 * ar),
                border: Border.all(color: const Color(0xFFB5B5B5)),
                image: DecorationImage(
                  image: AssetImage(image),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            SizedBox(height: 12 * ar),

            /// LABEL + ICON
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    label,
                    maxLines: 2,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                Container(
                  width: 50 * ar,
                  height: 50 * ar,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFD2D2D2)),
                  ),
                  child: Center(
                    child: Image.asset(
                      "assets/dashboard/action_section/right-arrow-icon.png",
                      width: 50 * ar,
                      height: 50 * ar,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
