import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../shared/routes/route_pages.dart';

import '../shared/themes.dart';
import '../shared/utils/enums.dart';
import '../shared/utils/scale_size.dart';

//////////////////////////////////////////////////
/// ACTION CONFIG
//////////////////////////////////////////////////

class AppBarActionConfig {
  final AppBarAction type;
  final VoidCallback? onTap;
  final int badgeCount;
  final bool visible;

  const AppBarActionConfig({
    required this.type,
    this.onTap,
    this.badgeCount = 0,
    this.visible = true,
  });
}

//////////////////////////////////////////////////
/// MY APP BAR (NO TITLE)
//////////////////////////////////////////////////

class MyAppBar extends ConsumerWidget implements PreferredSizeWidget {
  MyAppBar({
    super.key,
    required this.appBarLeading,
    this.actions = const [],
    this.showLogo = false,
  }) : preferredSize = Size.fromHeight(ScaleSize.appBarHeight);

  @override
  final Size preferredSize;

  final AppBarLeading appBarLeading;
  final List<AppBarActionConfig> actions;
  final bool showLogo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fem = ScaleSize.aspectRatio;

    return SafeArea(
      bottom: false,
      child: AppBar(
        elevation: 0,
        toolbarHeight: ScaleSize.appBarHeight,
        backgroundColor: MyThemes.appBarBackroundColor,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.dark,
        ),
        automaticallyImplyLeading: false,

        leadingWidth: ScaleSize.appBarHeight,
        leading: _buildLeading(context, fem),

        /// LOGO ONLY (NO TITLE)
        title: Row(
          children: [
            if (showLogo) ...[
              Padding(
                padding: EdgeInsets.only(
                  left: fem * 28,
                  top: fem * 50,
                  bottom: fem * 50,
                ),
                child: Image.asset(
                  "assets/Login/logo.png",
                  //height: fem * 55,
                  width: fem * 72,
                  fit: BoxFit.scaleDown,
                ),
              ),
            ],
          ],
        ),

        actions: _buildActions(context, fem),
      ),
    );
  }

  //////////////////////////////////////////////////
  /// LEADING
  //////////////////////////////////////////////////

  Widget? _buildLeading(BuildContext context, double fem) {
    switch (appBarLeading) {
      case AppBarLeading.drawer:
        return IconButton(
          icon: Icon(Icons.menu, size: fem * 30),
          onPressed: () {
            if (Scaffold.of(context).hasDrawer) {
              Scaffold.of(context).openDrawer();
            }
          },
        );

      case AppBarLeading.back:
        return IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: fem * 22),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/dashboard');
            }
          },
        );

      case AppBarLeading.none:
        return null;
    }
  }

  //////////////////////////////////////////////////
  /// ACTIONS
  //////////////////////////////////////////////////

  List<Widget> _buildActions(BuildContext context, double fem) {
    final List<Widget> widgets = [];

    for (final action in actions) {
      if (!action.visible) continue;

      switch (action.type) {
        case AppBarAction.search:
          widgets.add(_searchAction(fem, action.onTap));

          /// ✅ EXACT 59 PX SPACE AFTER SEARCH
          widgets.add(SizedBox(width: 59 * fem));
          break;

        case AppBarAction.notification:
          widgets.add(
            _notificationAction(
              fem: fem,
              badgeCount: action.badgeCount,
              onTap: action.onTap,
            ),
          );
          break;

        case AppBarAction.profile:
          //widgets.add(_profileAction(fem: fem, onTap: action.onTap));
          widgets.add(
            _profileAction(context: context, fem: fem, onTap: action.onTap),
          );

          break;

        case AppBarAction.cart:
          widgets.add(
            _cartAction(
              fem: fem,
              badgeCount: action.badgeCount,
              onTap: action.onTap,
            ),
          );
          break;

          /// ✅ 27 PX SPACE AFTER CART
          widgets.add(SizedBox(width: 27 * fem));
          break;
      }
    }

    return widgets;
  }

  // notification action
  Widget _notificationAction({
    required double fem,
    required VoidCallback? onTap,
    int badgeCount = 0,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4 * fem),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 53 * fem,
          height: 53 * fem,
          padding: EdgeInsets.all(4 * fem),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20 * fem),
            border: Border.all(width: 1, color: const Color(0xFF90DCD0)),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              /// 🔔 Notification Icon
              Center(
                child: Icon(
                  Icons.notifications_none_outlined,
                  size: 24 * fem,
                  color: Colors.black87,
                ),
              ),

              /// 🔴 Red Dot Badge
              if (badgeCount > 0)
                Positioned(
                  right: 4 * fem,
                  top: 4 * fem,
                  child: Container(
                    width: 8 * fem,
                    height: 8 * fem,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFB2C36),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // profile action
  Widget _profileAction({
    required BuildContext context,
    required double fem,
    required VoidCallback? onTap,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4 * fem),
      child: GestureDetector(
        onTap: () {
          context.push(RoutePages.account.routePath);
        },
        child: Container(
          width: 54 * fem,
          height: 54 * fem,
          padding: EdgeInsets.all(4 * fem),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20 * fem),
            border: Border.all(width: 1, color: const Color(0xFF90DCD0)),
          ),
          child: Center(
            child: Icon(
              Icons.person_outline,
              size: 20 * fem,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  // cart action
  Widget _cartAction({
    required double fem,
    required VoidCallback? onTap,
    int badgeCount = 0,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4 * fem),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 53 * fem,
          height: 54 * fem,
          padding: EdgeInsets.all(4 * fem),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20 * fem),
            border: Border.all(width: 1, color: const Color(0xFF90DCD0)),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              /// 🛒 Cart Icon
              Center(
                child: Icon(
                  Icons.shopping_cart_outlined,
                  size: 28 * fem,
                  color: Colors.black87,
                ),
              ),

              /// 🔢 Badge (optional)
              if (badgeCount > 0)
                Positioned(
                  right: 2 * fem,
                  top: 2 * fem,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 5 * fem,
                      vertical: 1 * fem,
                    ),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFB2C36),
                      shape: BoxShape.circle,
                    ),
                    constraints: BoxConstraints(
                      minWidth: 16 * fem,
                      minHeight: 16 * fem,
                    ),
                    child: Center(
                      child: Text(
                        '$badgeCount',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10 * fem,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  //////////////////////////////////////////////////
  /// SEARCH ACTION (FIGMA STYLE)
  //////////////////////////////////////////////////

  Widget _searchAction(double fem, VoidCallback? onTap) {
    return Padding(
      //padding: EdgeInsets.symmetric(horizontal: 6 * fem, vertical: 8 * fem),
      padding: EdgeInsets.symmetric(horizontal: 4 * fem), // ✅ 8px gap
      child: SizedBox(
        width: 254 * fem,
        height: 56 * fem,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10 * fem),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15 * fem),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                SvgPicture.asset(
                  'assets/icons/magnifying-glass.svg',
                  width: 18 * fem,
                  height: 18 * fem,
                  colorFilter: const ColorFilter.mode(
                    Colors.black54,
                    BlendMode.srcIn,
                  ),
                ),
                SizedBox(width: 10 * fem),
                const Expanded(
                  child: Text(
                    'Search',
                    style: TextStyle(
                      fontFamily: "Montserrat",
                      fontSize: 16,
                      color: Color(0xFF959595),
                    ),
                  ),
                ),
                SvgPicture.asset(
                  'assets/icons/si_barcode-scan-line.svg',
                  width: 33 * fem,
                  height: 33 * fem,
                  colorFilter: const ColorFilter.mode(
                    Colors.brown,
                    BlendMode.srcIn,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
