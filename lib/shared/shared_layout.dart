import 'package:flutter/material.dart';
import 'app_bar.dart';
import 'routes/app_drawer.dart';
import '../shared/utils/scale_size.dart';
//import '../../auth/data/auth_notifier.dart';
import '../features/auth/data/auth_notifier.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/utils/enums.dart';

class SharedLayout extends ConsumerStatefulWidget {
  final Widget child;
  const SharedLayout({super.key, required this.child});

  @override
  ConsumerState<SharedLayout> createState() => _SharedLayoutState();
}

class _SharedLayoutState extends ConsumerState<SharedLayout> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void openDrawer() => _scaffoldKey.currentState?.openDrawer();

  void closeDrawer() {
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      // appBar: CustomAppBar(
      //   onMenuTap: openDrawer, // Correct usage here
      //   onCartTap: () => print('Cart tapped'),
      //   onProfileTap: () => print('Profile tapped'),
      //   onNotificationTap: () => print('Notification tapped'),
      // ),
      appBar: MyAppBar(showLogo: false, appBarLeading: AppBarLeading.drawer),
      drawer: Drawer(
        backgroundColor: Colors.transparent,
        elevation: 0,
        width: _getDrawerWidth(context),
        child: SideMenu(
          onClose: closeDrawer,
          onLogout: () {
            ref.read(authProvider.notifier).logout();
            if (mounted) {
              // Prevent setState after dispose
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Logged out')));
            }
            context.go('/login');
          },
        ),
      ),
      body: SafeArea(child: widget.child),
    );
  }

  double _getDrawerWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 600) return screenWidth * 0.90;
    if (screenWidth < 900) return screenWidth * 0.75;
    return 360.0 * ScaleSize.aspectRatio; // Simpler scaling
  }
}
