import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../shared/utils/scale_size.dart';
import '../shared/themes.dart';
import '../shared/widgets/text.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onMenuTap;
  final VoidCallback? onBackTap;
  final VoidCallback? onCartTap;
  final VoidCallback? onProfileTap;
  final VoidCallback? onNotificationTap;

  final bool showBackButton;
  final bool showLogo;
  final bool showSearch;

  const CustomAppBar({
    super.key,
    this.onMenuTap,
    this.onBackTap,
    this.onCartTap,
    this.onProfileTap,
    this.onNotificationTap,
    this.showBackButton = false,
    this.showLogo = true,
    this.showSearch = true,
  });

  @override
  Size get preferredSize => Size.fromHeight(ScaleSize.appBarHeight);

  IconData get _leadingIcon => showBackButton ? Icons.arrow_back : Icons.menu;

  @override
  Widget build(BuildContext context) {
    final fem = ScaleSize.aspectRatio;

    return Container(
      height: preferredSize.height * fem,
      color: MyThemes.appBarBackroundColor,
      child: Row(
        children: [
          /// Leading Icon
          Padding(
            padding: EdgeInsets.only(
              left: 30 * fem,
              top: 22 * fem,
              right: 28 * fem,
              bottom: 24 * fem,
            ),
            child: IconButton(
              icon: Icon(
                _leadingIcon,
                size: 32 * fem,
                color: MyThemes.fontColor,
              ),
              onPressed: showBackButton
                  ? (onBackTap ?? () => Navigator.of(context).maybePop())
                  : onMenuTap,
              padding: EdgeInsets.all(8 * fem),
              constraints: const BoxConstraints(),
            ),
          ),

          /// Optional Logo
          if (showLogo) ...[
            /// Logo
            Padding(
              padding: EdgeInsets.fromLTRB(28 * fem, 10 * fem, 0, 13 * fem),
              child: Image.asset(
                "assets/Login/logo.png",
                height: 72 * fem,
                width: 55 * fem,
                fit: BoxFit.contain,
              ),
            ),

            const Spacer(),
          ],

          /// Optional Search Bar
          if (showSearch) ...[
            SizedBox(
              width: 254 * fem,
              height: 56 * fem,
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
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        style: const TextStyle(fontFamily: "Montserrat"),
                        decoration: InputDecoration(
                          hintText: "Search",
                          hintStyle: const TextStyle(
                            fontFamily: "Montserrat",
                            fontSize: 16,
                            color: Color(0xFF959595),
                          ),
                          border: InputBorder.none,
                        ),
                        cursorColor: Colors.black,
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
            const SizedBox(width: 16),
          ],

          /// Notification
          if (onNotificationTap != null) ...[
            _roundedIcon(
              icon: SvgPicture.asset(
                'assets/icons/notification.svg',
                width: 24 * fem,
                height: 24 * fem,
                colorFilter: const ColorFilter.mode(
                  Color(0xFF90DCD0),
                  BlendMode.srcIn,
                ),
              ),
              onTap: onNotificationTap!,
              showDot: true,
            ),
            const SizedBox(width: 8),
          ],

          /// Profile
          if (onProfileTap != null) ...[
            _roundedIcon(
              icon: SvgPicture.asset(
                'assets/icons/profile.svg',
                width: 24 * fem,
                height: 24 * fem,
                colorFilter: const ColorFilter.mode(
                  Color(0xFF90DCD0),
                  BlendMode.srcIn,
                ),
              ),
              onTap: onProfileTap!,
            ),
            const SizedBox(width: 8),
          ],

          /// Cart
          if (onCartTap != null) ...[
            _roundedIcon(
              icon: SvgPicture.asset(
                'assets/icons/mdi_cart.svg',
                width: 24 * fem,
                height: 24 * fem,
                colorFilter: const ColorFilter.mode(
                  Color(0xFF90DCD0),
                  BlendMode.srcIn,
                ),
              ),
              onTap: onCartTap!,
              badgeCount: 2,
            ),
            const SizedBox(width: 27),
          ],
        ],
      ),
    );
  }

  Widget _roundedIcon({
    required Widget icon,
    required VoidCallback onTap,
    int? badgeCount,
    bool showDot = false,
  }) {
    final fem = ScaleSize.aspectRatio;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Container(
            width: 53 * fem, // ✅ fixed width
            height: 53 * fem, // ✅ fixed height
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: icon,
          ),
        ),
        if (showDot)
          Positioned(
            right: 3 * fem,
            top: 3 * fem,
            child: Container(
              width: 8 * fem,
              height: 8 * fem,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ),
        if (badgeCount != null)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              width: 22 * fem,
              height: 22 * fem,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFD9D9D9),
              ),
              child: MyText(
                "$badgeCount",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
