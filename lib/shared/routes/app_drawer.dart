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
                          routePage: RoutePages.home,
                          drawerState: drawerState,
                          drawerNotifier: drawerNotifier,
                        ),

                        _nav(
                          ref,
                          context: context,
                          fem: fem,
                          label: "Catalogue",
                          //icon: Icons.menu_book_outlined,
                          iconPath: 'assets/icons/menu_catalouge.svg',
                          routePage: RoutePages.catalogue,
                          drawerState: drawerState,
                          drawerNotifier: drawerNotifier,
                        ),

                        _nav(
                          ref,
                          context: context,
                          fem: fem,
                          label: "Feedback Form",
                          //icon: Icons.star_border,
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
                          //icon: Icons.diamond_outlined,
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
                          //icon: Icons.track_changes_outlined,
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
                          //icon: Icons.layers_outlined,
                          iconPath: 'assets/icons/menu_vt.svg',
                          title: "Categories",
                          items: [
                            'Necklaces',
                            'Bangles',
                            'Mangalsutra',
                            'Rings',
                            'Solitaire',
                            'Bracelets',
                            'Earrings',
                          ],
                        ),

                        sectionCard(
                          fem: fem,
                          context: context,
                          routePage: RoutePages.jewellerylisting,
                          //icon: Icons.collections_outlined,
                          iconPath: 'assets/icons/menu_vt.svg',
                          title: 'Collection',
                          items: ['Ballerina', 'Souls', 'Setu'],
                        ),

                        _nav(
                          ref,
                          context: context,
                          fem: fem,
                          label: "Cart",
                          //icon: Icons.shopping_cart_outlined,
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
                          //icon: Icons.person_outline,
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
    required List<String> items,
  }) {
    Widget categoryItem(String title) {
      return InkWell(
        onTap: () {
          Navigator.of(context).pop();
          GoRouter.of(context).push(routePage.routePath);
        },
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.only(
            left: fem * 35,
            top: fem * 12,
            bottom: fem * 12,
          ),
          margin: EdgeInsets.only(bottom: fem * 4),
          child: MyText(title, style: TextStyle(fontSize: fem * 16)),
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
                  width: fem * 18,
                  height: fem * 18,
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
              children: [for (var item in items) categoryItem(item)],
            ),
          ),
        ],
      ),
    );
  }

  // dynamic sectionCard({
  //   required double fem,
  //   required BuildContext context,
  //   required RoutePages routePage,
  //   //required IconData icon,
  //   required String iconPath,
  //   required String title,
  //   required List<String> items,
  // }) {
  //   //final isActive = false;
  //   Widget categoryItem(String title) {
  //     return InkWell(
  //       onTap: () {
  //         Navigator.of(context).pop();
  //         GoRouter.of(context).push(routePage.routePath);
  //       },
  //       child: Container(
  //         width: double.infinity,
  //         padding: EdgeInsets.only(
  //           left: fem * 35,
  //           top: fem * 12,
  //           bottom: fem * 12,
  //         ),
  //         margin: EdgeInsets.only(bottom: fem * 4),
  //         // decoration: isActive
  //         //     ? BoxDecoration(
  //         //         borderRadius: BorderRadius.circular(6),
  //         //         border: Border.all(color: const Color(0xFFCED4D1), width: 1),
  //         //       )
  //         //     : null,
  //         child: MyText(title, style: TextStyle(fontSize: fem * 16)),
  //       ),
  //     );
  //   }

  //   return ListTileTheme(
  //     minVerticalPadding: 0,
  //     child: ExpansionTile(
  //       tilePadding: EdgeInsets.only(
  //         top: fem * 25,
  //         bottom: fem * 25,
  //         left: fem * 24,
  //         right: fem * 10,
  //       ),
  //       minTileHeight: 0,
  //       dense: true,
  //       shape: const Border(), // Removes the border when expanded
  //       collapsedShape: const Border(), // Removes the border when collapsed
  //       //collapsedBackgroundColor: Colors.red,
  //       title: Row(
  //         children: [
  //           Container(
  //             width: fem * 36,
  //             height: fem * 36,
  //             decoration: BoxDecoration(
  //               color: Colors.white,
  //               borderRadius: BorderRadius.circular(999),
  //             ),
  //             child: Icon(icon, size: fem * 18, color: Colors.black87),
  //           ),
  //           SizedBox(width: fem * 16),
  //           MyText(
  //             title,
  //             style: TextStyle(
  //               fontSize: fem * 16,
  //               color: Colors.black87,
  //               fontWeight: FontWeight.w400,
  //             ),
  //           ),
  //         ],
  //       ),
  //       children: [
  //         Container(
  //           width: double.infinity,
  //           decoration: BoxDecoration(
  //             color: Colors.white,
  //             borderRadius: BorderRadius.circular(10),
  //           ),
  //           padding: EdgeInsets.symmetric(
  //             vertical: fem * 8,
  //             horizontal: fem * 12,
  //           ),
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [for (var item in items) categoryItem(item)],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

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
        GoRouter.of(context).push(routePage.routePath);
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
              child: SvgPicture.asset(
                iconPath,
                width: fem * 18,
                height: fem * 18,
                //colorFilter: ColorFilter.mode(activeColor, BlendMode.srcIn),
              ),
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

  // Widget _nav(
  //   WidgetRef ref, {
  //   required BuildContext context,
  //   required double fem,
  //   required String label,
  //   required IconData icon,
  //   required RoutePages routePage,
  //   required DrawerState drawerState,
  //   required DrawerNotifier drawerNotifier,
  // }) {
  //   //final drawerState = ref.watch(drawerProvider);
  //   //final drawerNotifier = ref.read(drawerProvider.notifier);

  //   final isActive = drawerState.routePage == routePage;

  //   final activeColor = isActive ? Colors.blue : Color(0xFF232323);
  //   final activeFontweight = isActive ? FontWeight.w600 : FontWeight.w400;

  //   return InkWell(
  //     onTap: () {
  //       Navigator.of(context).pop();
  //       drawerNotifier.routePage = routePage;
  //       GoRouter.of(context).push(routePage.routePath);
  //     },
  //     //borderRadius: BorderRadius.circular(8),
  //     child: Container(
  //       //color: label == "Verify & Track" ? Colors.pink : null,
  //       padding: EdgeInsets.only(
  //         top: fem * 25,
  //         bottom: fem * 25,
  //         left: fem * 24,
  //       ),
  //       child: Row(
  //         children: [
  //           Container(
  //             width: fem * 36,
  //             height: fem * 36,
  //             decoration: BoxDecoration(
  //               color: Colors.white,
  //               borderRadius: BorderRadius.circular(999),
  //             ),
  //             child: Icon(icon, size: fem * 18, color: activeColor),
  //           ),
  //           SizedBox(width: fem * 16),
  //           MyText(
  //             label,
  //             style: TextStyle(
  //               fontSize: fem * 16,
  //               color: activeColor,
  //               fontWeight: activeFontweight,
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

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

// class _SectionCard extends StatelessWidget {
//   final IconData icon;
//   final String title;
//   final List<String> items;

//   const _SectionCard({
//     required this.icon,
//     required this.title,
//     required this.items,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final fem = ScaleSize.aspectRatio;

//     return Container(
//       // decoration: BoxDecoration(
//       //   color: const Color(0xFFEFF4F3),
//       //   borderRadius: BorderRadius.circular(12),
//       // ),
//       //padding: EdgeInsets.symmetric(vertical: fem * 12, horizontal: fem * 10),
//       padding: EdgeInsets.only(top: fem * 25, bottom: fem * 25, left: fem * 24),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(icon, size: fem * 18, color: Colors.black87),
//               SizedBox(width: fem * 8),
//               MyText(
//                 title,
//                 style: TextStyle(
//                   fontSize: fem * 13,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               const Spacer(),
//               Icon(Icons.expand_less, size: fem * 18, color: Colors.black87),
//             ],
//           ),

//           SizedBox(height: fem * 25),

//           Container(
//             width: double.infinity,
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(8),
//             ),
//             padding: EdgeInsets.symmetric(vertical: fem * 6),
//             child: Column(
//               children: items.map((text) {
//                 final isFirst = text == items.first;

//                 return Container(
//                   margin: EdgeInsets.symmetric(
//                     vertical: fem * 3,
//                     horizontal: fem * 8,
//                   ),
//                   padding: EdgeInsets.symmetric(
//                     horizontal: fem * 10,
//                     vertical: fem * 8,
//                   ),
//                   decoration: isFirst
//                       ? BoxDecoration(
//                           borderRadius: BorderRadius.circular(6),
//                           border: Border.all(
//                             color: const Color(0xFFCED4D1),
//                             width: 1,
//                           ),
//                         )
//                       : null,
//                   child: Align(
//                     alignment: Alignment.centerLeft,
//                     child: MyText(
//                       text,
//                       style: TextStyle(
//                         fontSize: fem * 13,
//                         color: Colors.black87,
//                       ),
//                     ),
//                   ),
//                 );
//               }).toList(),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
