import 'package:flutter/material.dart';
import '../shared/utils/scale_size.dart';
import '../shared/themes.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  //final VoidCallback onMenuTap;
  final VoidCallback? onMenuTap; // Nullable - optional drawer button
  final VoidCallback? onBackTap; // Nullable - optional back button
  final VoidCallback onCartTap;
  final VoidCallback onProfileTap;
  final VoidCallback onNotificationTap;
  final bool showBackButton; // Control back vs menu
  final bool automaticallyImplyBack; // Auto-handle back behavior

  const CustomAppBar({
    super.key,
    //required this.onMenuTap,
    this.onMenuTap,
    this.onBackTap,
    required this.onCartTap,
    required this.onProfileTap,
    required this.onNotificationTap,
    this.showBackButton = false,
    this.automaticallyImplyBack = false,
  });

  @override
  Size get preferredSize => Size.fromHeight(ScaleSize.appBarHeight);

  // FIXED: Proper leading behavior using Builder widget
  VoidCallback? get _leadingOnTap {
    if (showBackButton) {
      if (automaticallyImplyBack) {
        return null; // Will use Builder context below
      }
      return onBackTap;
    }
    return onMenuTap;
  }

  IconData get _leadingIcon => showBackButton ? Icons.arrow_back : Icons.menu;

  @override
  Widget build(BuildContext context) {
    return Container(
      //height: preferredSize.height,
      height: ScaleSize.appBarHeight, // Direct use of ScaleSize,
      //padding: const EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.symmetric(horizontal: 16.0 * ScaleSize.aspectRatio),
      decoration: const BoxDecoration(
        color: MyThemes.appBarBackroundColor, // Mint background from theme
      ),
      child: Row(
        children: [
          // // MENU ICON
          // IconButton(
          //   icon: const Icon(Icons.menu, size: 30, color: Colors.black87),
          //   onPressed: onMenuTap,
          // ),
          // FIXED: SMART LEADING BUTTON with proper context
          Builder(
            builder: (leadingContext) {
              VoidCallback? leadingTap;
              if (showBackButton && automaticallyImplyBack) {
                leadingTap = () => Navigator.of(leadingContext).pop();
              } else {
                leadingTap = _leadingOnTap;
              }

              return leadingTap != null
                  ? IconButton(
                      icon: Icon(
                        _leadingIcon,
                        size: 30.0 * ScaleSize.aspectRatio,
                        color: MyThemes.fontColor,
                      ),
                      onPressed: leadingTap,
                    )
                  : const SizedBox.shrink();
            },
          ),

          // LOGO (conditional padding)
          Padding(
            padding: EdgeInsets.only(
              left:
                  (_leadingOnTap != null ? 12.0 : 0.0) * ScaleSize.aspectRatio,
            ),
            child: Image.asset(
              "assets/Login/logo.png",
              height:
                  42.0 *
                  ScaleSize.aspectRatio, // FIXED: aspectRatio not appRatio
              fit: BoxFit.contain,
            ),
          ),

          // // LOGO
          // Padding(
          //   padding: const EdgeInsets.only(left: 12),
          //   child: Image.asset("assets/Login/logo.png", height: 42),
          // ),
          const Spacer(),

          // SEARCH BAR
          Expanded(
            flex: 3,
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  const Icon(Icons.search, size: 22, color: Colors.black54),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Search",
                        hintStyle: TextStyle(fontSize: 14),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const Icon(Icons.fullscreen, size: 20, color: Colors.brown),
                ],
              ),
            ),
          ),

          const Spacer(),

          // NOTIFICATION BUTTON
          _roundedIcon(
            icon: Icons.notifications_none,
            onTap: onNotificationTap,
            showDot: true,
          ),

          const SizedBox(width: 10),

          // PROFILE BUTTON
          _roundedIcon(icon: Icons.person_outline, onTap: onProfileTap),

          const SizedBox(width: 10),

          // CART BUTTON
          _roundedIcon(
            icon: Icons.shopping_cart_outlined,
            onTap: onCartTap,
            badgeCount: 2,
          ),
        ],
      ),
    );
  }

  Widget _roundedIcon({
    required IconData icon,
    required VoidCallback onTap,
    int? badgeCount,
    bool showDot = false,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFDBF0EC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 24, color: Colors.black87),
          ),
        ),

        if (showDot)
          Positioned(
            right: 6,
            top: 4,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ),

        if (badgeCount != null)
          Positioned(
            right: 4,
            top: -2,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black,
              ),
              child: Text(
                "$badgeCount",
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
          ),
      ],
    );
  }
}
