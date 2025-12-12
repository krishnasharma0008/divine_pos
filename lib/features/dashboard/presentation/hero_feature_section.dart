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
        SizedBox(height: 10),
        // HERO BANNER
        // Container(
        //   width: double.infinity,
        //   height: 410,
        //   decoration: const BoxDecoration(
        //     image: DecorationImage(
        //       image: AssetImage('assets/dashboard/banner/hero_banner.png'),
        //       fit: BoxFit.cover,
        //       alignment: Alignment.topCenter,
        //     ),
        //   ),
        // ),

        // HERO BANNER WITH RIGHT IMAGE + TEXT
        SizedBox(
          width: double.infinity,
          height: 410,
          child: Stack(
            children: [
              // background banner
              Positioned.fill(
                child: Image.asset(
                  'assets/dashboard/banner/hero_banner.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),

              // right-side image + text
              Align(
                //alignment: Alignment.centerRight,
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 0), // adjust as needed
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Rectangle 5026 image
                      Image.asset(
                        'assets/dashboard/banner/rectangle_5026.png',
                        height: 410,
                        width: 419,
                        fit: BoxFit.cover,
                      ),

                      const SizedBox(width: 12),

                      // Text on top of it (or next to it)
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Your title text',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w600,
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Your subtitle or description',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
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
                    onTap: () => context.push('/jewellery_listing'),
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
        color: const Color(0xFFF2F2F2),
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
        padding: EdgeInsets.all(6 * ar),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(6 * ar),
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
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 14 * ar),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        label,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          height: 1.0,
                          letterSpacing: 0.0,
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
