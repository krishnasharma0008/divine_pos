import 'package:divine_pos/shared/utils/enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../features/auth/data/auth_notifier.dart';
import '../utils/scale_size.dart';
import '../themes.dart';
import '../widgets/text.dart';
import 'drawer_provider.dart';
import 'route_pages.dart';
import '../../shared/data/category_data.dart';

class SideDrawer extends ConsumerWidget {
  const SideDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final drawerState = ref.watch(drawerProvider);
    final drawerNotifier = ref.read(drawerProvider.notifier);

    final fem = ScaleSize.aspectRatio;

    return Drawer(
      backgroundColor: Colors.transparent,
      elevation: 0,
      width: fem * 400,
      child: SafeArea(
        child: Material(
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF5F9F8),
              //color: Colors.red,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(18),
                bottomRight: Radius.circular(18),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 22,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                header(context: context, fem: fem),
                const Divider(height: 1, color: Color(0xFFE2E6E5)),

                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(
                      left: fem * 12,
                      right: fem * 26,
                      top: fem * 16,
                      bottom: fem * 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _nav(
                          ref,
                          context: context,
                          fem: fem,
                          label: "Home",
                          //icon: Icons.home_outlined,
                          iconPath: 'assets/icons/menu_home.svg',
                          routePage: RoutePages.dashboard,
                          drawerState: drawerState,
                          drawerNotifier: drawerNotifier,
                        ),

                        _nav(
                          ref,
                          context: context,
                          fem: fem,
                          label: "Demo Checking page",
                          //icon: Icons.home_outlined,
                          iconPath: 'assets/icons/menu_home.svg',
                          routePage: RoutePages.jewelleryjourney,
                          drawerState: drawerState,
                          drawerNotifier: drawerNotifier,
                        ),
                        _nav(
                          ref,
                          context: context,
                          fem: fem,
                          label: "Catalogue",
                          iconPath: 'assets/icons/menu_catalouge.svg',
                          routePage: RoutePages.jewellerylisting,
                          drawerState: drawerState,
                          drawerNotifier: drawerNotifier,
                        ),

                        _nav(
                          ref,
                          context: context,
                          fem: fem,
                          label: "Feedback Form",
                          iconPath: 'assets/icons/menu_feedback.svg',
                          routePage: RoutePages.feedback,
                          drawerState: drawerState,
                          drawerNotifier: drawerNotifier,
                        ),

                        _nav(
                          ref,
                          context: context,
                          fem: fem,
                          label: "Know Your Diamond Value",
                          iconPath: 'assets/icons/menu_kydv.svg',
                          routePage: RoutePages.knowDiamond,
                          drawerState: drawerState,
                          drawerNotifier: drawerNotifier,
                        ),

                        _nav(
                          ref,
                          context: context,
                          fem: fem,
                          label: "Verify & Track",
                          iconPath: 'assets/icons/menu_vt.svg',
                          routePage: RoutePages.verifyTrack,
                          drawerState: drawerState,
                          drawerNotifier: drawerNotifier,
                        ),

                        //SizedBox(height: fem * 12),
                        sectionCard(
                          fem: fem,
                          context: context,
                          routePage: RoutePages.jewellerylisting,
                          iconPath: 'assets/icons/menu_vt.svg',
                          title: "Categories",
                          items: categories,
                        ),

                        sectionCard(
                          fem: fem,
                          context: context,
                          routePage: RoutePages.jewellerylisting,
                          iconPath: 'assets/icons/menu_vt.svg',
                          title: 'Collection',
                          items: Collection,
                          isSubcategory: true,
                        ),

                        _nav(
                          ref,
                          context: context,
                          fem: fem,
                          label: "Cart",
                          iconPath: 'assets/icons/menu_cart.svg',
                          routePage: RoutePages.cart,
                          drawerState: drawerState,
                          drawerNotifier: drawerNotifier,
                        ),

                        _nav(
                          ref,
                          context: context,
                          fem: fem,
                          label: "Account",
                          iconPath: 'assets/icons/menu_account.svg',
                          routePage: RoutePages.account,
                          drawerState: drawerState,
                          drawerNotifier: drawerNotifier,
                        ),
                      ],
                    ),
                  ),
                ),

                //_LogoutRow(onLogout: onLogout),
                logoutRow(ref: ref, fem: fem),
              ],
            ),
          ),
        ),
      ),
    );
  }

  dynamic sectionCard({
    required double fem,
    required BuildContext context,
    required RoutePages routePage,
    required String iconPath,
    required String title,
    required Map<String, String> items,
    bool isSubcategory = false,
  }) {
    Widget categoryItem(MapEntry<String, String> item) {
      return InkWell(
        onTap: () {
          Navigator.of(context).pop();
          final paramKey = isSubcategory
              ? JewelleryProductKey.collection.value
              : JewelleryProductKey.category.value; //'collection' : 'category';
          //debugPrint(paramKey);

          GoRouter.of(context).pushReplacement(
            '${routePage.routePath}?$paramKey=${Uri.encodeComponent(item.value)}',
          );

          //GoRouter.of(context).push(routePage.routePath);RoutePages.jewellerylisting.routePath
        },
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.only(
            left: fem * 35,
            top: fem * 12,
            bottom: fem * 12,
          ),
          margin: EdgeInsets.only(bottom: fem * 4),
          child: MyText(item.value, style: TextStyle(fontSize: fem * 16)),
        ),
      );
    }

    return ListTileTheme(
      minVerticalPadding: 0,
      child: ExpansionTile(
        tilePadding: EdgeInsets.only(
          top: fem * 25,
          bottom: fem * 25,
          left: fem * 24,
          right: fem * 10,
        ),
        minTileHeight: 0,
        dense: true,
        shape: const Border(),
        collapsedShape: const Border(),
        title: Row(
          children: [
            Container(
              width: fem * 36,
              height: fem * 36,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: SvgPicture.asset(
                  iconPath,
                  fit: BoxFit.scaleDown,
                  // keep color optional; remove if SVG already has correct color
                  colorFilter: const ColorFilter.mode(
                    Colors.black87,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            SizedBox(width: fem * 16),
            MyText(
              title,
              style: TextStyle(
                fontSize: fem * 16,
                color: Colors.black87,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            padding: EdgeInsets.symmetric(
              vertical: fem * 8,
              horizontal: fem * 12,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [for (var item in items.entries) categoryItem(item)],
            ),
          ),
        ],
      ),
    );
  }

  /// Central navigation builder (keeps code DRY)
  Widget _nav(
    WidgetRef ref, {
    required BuildContext context,
    required double fem,
    required String label,
    required String iconPath, // pass the path
    required RoutePages routePage,
    required DrawerState drawerState,
    required DrawerNotifier drawerNotifier,
  }) {
    final isActive = drawerState.routePage == routePage;
    final activeColor = isActive ? Colors.blue : const Color(0xFF232323);
    final activeFontweight = isActive ? FontWeight.w600 : FontWeight.w400;

    return InkWell(
      onTap: () {
        Navigator.of(context).pop();
        drawerNotifier.routePage = routePage;
        GoRouter.of(context).pushReplacement(routePage.routePath);
      },
      child: Container(
        padding: EdgeInsets.only(
          top: fem * 25,
          bottom: fem * 25,
          left: fem * 24,
        ),
        child: Row(
          children: [
            Container(
              width: fem * 36,
              height: fem * 36,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: SvgPicture.asset(iconPath, fit: BoxFit.scaleDown),
            ),
            SizedBox(width: fem * 16),
            MyText(
              label,
              style: TextStyle(
                fontSize: fem * 16,
                color: activeColor,
                fontWeight: activeFontweight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  dynamic header({required BuildContext context, required double fem}) {
    return Padding(
      padding: EdgeInsets.all(fem * 24),
      child: Container(
        width: fem * 40,
        height: fem * 40,
        decoration: ShapeDecoration(
          color: Colors.white.withValues(alpha: 0.90),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          shadows: [
            BoxShadow(
              color: Color(0x19000000),
              blurRadius: 15,
              offset: Offset(0, 10),
              spreadRadius: -3,
            ),
          ],
        ),
        child: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
            padding: EdgeInsets.all(fem * 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          icon: Icon(Icons.close, size: fem * 18, color: Colors.black87),
        ),
      ),
    );
  }

  InkWell logoutRow({required WidgetRef ref, required double fem}) {
    return InkWell(
      onTap: () {
        ref.read(authProvider.notifier).logout();
      },
      child: Container(
        height: fem * 56,
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFFE2E6E5))),
        ),
        padding: EdgeInsets.symmetric(horizontal: fem * 20.0),
        child: Row(
          children: [
            Icon(Icons.logout, size: fem * 18, color: Colors.red),
            SizedBox(width: fem * 12),
            MyText(
              'Logout',
              style: TextStyle(
                fontSize: fem * 14,
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
