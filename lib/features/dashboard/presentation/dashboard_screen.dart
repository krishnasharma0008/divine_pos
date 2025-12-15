import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'hero_feature_section.dart';
import 'categories_section.dart';

import '../../../shared/utils/scale_size.dart';
import '../../../shared/app_bar.dart';
import '../../../shared/routes/app_drawer.dart';
import '../../auth/data/auth_notifier.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  /// ✅ Scroll controller
  final ScrollController _scrollController = ScrollController();

  /// ✅ Target section key
  final GlobalKey _categoriesKey = GlobalKey();

  void openDrawer() => _scaffoldKey.currentState?.openDrawer();

  void scrollToCategories() {
    final context = _categoriesKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    }
  }

  void closeDrawer(BuildContext context) {
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final fem = ScaleSize.aspectRatio;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,

      // ------------------ APP BAR ------------------
      appBar: CustomAppBar(
        onMenuTap: openDrawer,
        onCartTap: () => print('Cart tapped'),
        onProfileTap: () => print('Profile tapped'),
        onNotificationTap: () => print('Notification tapped'),
        showBackButton: false,
      ),

      // ------------------ DRAWER ------------------
      drawer: Drawer(
        backgroundColor: Colors.transparent,
        elevation: 0,
        width: 400 * fem,
        child: SideMenu(
          onClose: () => closeDrawer(context),
          onLogout: () {
            ref.read(authProvider.notifier).logout();

            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Logged out')));

            context.go('/login');
          },
        ),
      ),

      // ------------------ BODY ------------------
      body: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController, // ✅ attached here
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// HERO + FEATURES
                  HeroAndFeaturesSection(onArrowTap: scrollToCategories),
                  SizedBox(height: 24 * fem),

                  /// TARGET SECTION
                  Container(
                    key: _categoriesKey,
                    child: const CategoriesSection(),
                  ),

                  SizedBox(height: 40 * fem),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
