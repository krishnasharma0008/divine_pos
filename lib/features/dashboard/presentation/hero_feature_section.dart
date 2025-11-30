import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/utils/scale_size.dart';

class HeroAndFeaturesSection extends ConsumerWidget {
  const HeroAndFeaturesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double ar = ScaleSize.aspectRatio.clamp(0.7, 1.3);

    return Column(
      children: [
        // HERO BANNER
        Container(
          width: double.infinity,
          height: 410,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/dashboard/banner/hero_banner.png'),
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),
        ),

        SizedBox(height: 20 * ar),

        // FEATURE CARDS SCROLLER (CENTERED)
        SizedBox(
          height: 218,
          child: Center(
            child: SizedBox(
              height: 218,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 8 * ar),
                shrinkWrap: true,
                children: [
                  FeatureCard(
                    label: "Catalogue",
                    image: "assets/dashboard/action_section/catalouge.png",
                    onTap: () => context.push('/catalogue'),
                  ),
                  SizedBox(width: 8 * ar),
                  FeatureCard(
                    label: "Feedback Form",
                    image: "assets/dashboard/action_section/feedback-form.png",
                    onTap: () => context.push('/feedback'),
                  ),
                  SizedBox(width: 8 * ar),
                  FeatureCard(
                    label: "Know Your Diamond Value",
                    image:
                        "assets/dashboard/action_section/know_your_diamond_value.png",
                    onTap: () => context.push('/diamond-value'),
                  ),
                  SizedBox(width: 8 * ar),
                  FeatureCard(
                    label: "Verify & Track",
                    image: "assets/dashboard/action_section/verify-track.png",
                    onTap: () => context.push('/verify-track'),
                  ),
                  SizedBox(width: 8 * ar),
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
        ),

        SizedBox(height: 20 * ar),
      ],
    );
  }
}

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

    return Container(
      width: 230 * ar,
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2), // ← #F2F2F2 background
        borderRadius: BorderRadius.circular(22 * ar),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.10 * 255).round()),
            blurRadius: 16 * ar,
            offset: Offset(0, 4 * ar),
          ),
        ],
      ),
      child: Padding(
        // outer padding smaller
        padding: EdgeInsets.all(6 * ar),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGE
            Padding(
              padding: EdgeInsets.all(6), // .only(top: 9 * ar, left: 10 * ar),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16 * ar),
                child: Image.asset(
                  image,
                  height: 100 * ar,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            SizedBox(height: 10 * ar),

            // TEXT + ARROW aligned to same left/right (14)
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 14 * ar),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 14 * ar,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    GestureDetector(
                      onTap: onTap,
                      child: Image.asset(
                        "assets/dashboard/action_section/right-arrow-icon.png",
                        height: 32 * ar,
                        width: 32 * ar,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
