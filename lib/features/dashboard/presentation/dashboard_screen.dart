import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'hero_feature_section.dart';
import 'categories_section.dart';

import '../../../shared/utils/scale_size.dart';
import '../../../shared/app_bar.dart';
import '../../../shared/routes/app_drawer.dart';
import '../../auth/data/auth_notifier.dart';
import '../../../shared/utils/enums.dart';

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

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final fem = ScaleSize.aspectRatio;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,

      // ------------------ APP BAR ------------------
      appBar: MyAppBar(
        //titleText: 'Dashboard',
        appBarLeading: AppBarLeading.drawer,
        showLogo: true,
        actions: [
          AppBarActionConfig(
            type: AppBarAction.search,
            onTap: () {
              print('Search tapped');
            },
          ),
          AppBarActionConfig(
            type: AppBarAction.notification,
            badgeCount: 0,
            onTap: () {
              context.push('/notifications');
            },
          ),
          AppBarActionConfig(
            type: AppBarAction.profile,
            onTap: () {
              context.push('/profile');
            },
          ),
          AppBarActionConfig(
            type: AppBarAction.cart,
            badgeCount: 0,
            onTap: () {
              context.push('/cart');
            },
          ),
        ],
      ),

      // ------------------ DRAWER ------------------
      drawer: SideDrawer(),

      // ------------------ BODY ------------------
      body: SingleChildScrollView(
        controller: _scrollController, // ✅ attached here
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// HERO + FEATURES
            HeroAndFeaturesSection(onArrowTap: scrollToCategories),
            SizedBox(height: 24 * fem),

            /// TARGET SECTION
            Container(key: _categoriesKey, child: const CategoriesSection()),

            SizedBox(height: 80 * fem),
          ],
        ),
      ),
    );
  }
}
