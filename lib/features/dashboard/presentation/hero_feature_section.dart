import 'package:divine_pos/shared/routes/route_pages.dart';
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
    //final double fem = ScaleSize.aspectRatio;
    //print("ar:$ar");
    //print("fem:$fem");
    return Column(
      //mainAxisSize: MainAxisSize.max,
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
                right: 46 * ar,
                top: 92 * ar,
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

        SizedBox(height: 23 * ar),

        // ---------------- FEATURE CARDS ----------------
        SizedBox(
          width: double.infinity,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,

            padding: EdgeInsets.symmetric(horizontal: 7 * ar), // ✅ x-7
            child: Row(
              //mainAxisAlignment: MainAxisAlignment.spaceAround,
              //mainAxisSize: MainAxisSize.min,
              spacing: ar * 5,
              children: [
                featureCard(
                  context: context,
                  fem: ar,
                  label: "Catalogue",
                  image: "catalouge.png",
                  routePage: RoutePages.jewellerylisting,
                ),
                SizedBox(width: 12 * ar),
                featureCard(
                  context: context,
                  fem: ar,
                  label: "Feedback Form",
                  image: "feedback-form.png",
                  routePage: RoutePages.feedbackform,
                ),
                SizedBox(width: 12 * ar),
                featureCard(
                  context: context,
                  fem: ar,
                  label: "Know Your Diamond Value",
                  image: "know_your_diamond_value.png",
                  routePage: RoutePages.knowDiamond,
                ),
                SizedBox(width: 12 * ar),
                featureCard(
                  context: context,
                  fem: ar,
                  label: "Verify & Track",
                  image: "verify-track.png",
                  routePage: RoutePages.verifyTrack,
                ),
                SizedBox(width: 12 * ar),
                featureCard(
                  context: context,
                  fem: ar,
                  label: "Scan Ready Product",
                  image: "scan-ready-product.jpg",
                  routePage: RoutePages.verifyTrack,
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

  // ---------------- FEATURE CARD ----------------
  GestureDetector featureCard({
    required BuildContext context,
    required double fem,
    required String label,
    required String image,
    required RoutePages routePage,
  }) {
    return GestureDetector(
      onTap: () {
        //GoRouter.of(context).push(routePage.routePath);
        GoRouter.of(context).pushReplacement(routePage.routePath);
      },
      child: Container(
        width: 232 * fem,
        //height: 218 * fem,
        padding: EdgeInsets.symmetric(horizontal: fem * 14, vertical: 9 * fem),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F2),
          borderRadius: BorderRadius.circular(20 * fem),
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
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20 * fem),
                border: Border.all(color: const Color(0xFFB5B5B5)),
                image: DecorationImage(
                  image: AssetImage("assets/dashboard/action_section/$image"),
                  fit: BoxFit.cover,
                ),
              ),
              height: 114 * fem,
            ),

            SizedBox(height: 22 * fem),

            /// LABEL + ICON
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: MyText(
                    label,
                    maxLines: 2,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: fem * 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                Container(
                  width: 50 * fem,
                  height: 50 * fem,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFD2D2D2)),
                  ),
                  child: Center(
                    child: Image.asset(
                      "assets/dashboard/action_section/right-arrow-icon.png",
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: fem * 13),
          ],
        ),
      ),
    );
  }
}
