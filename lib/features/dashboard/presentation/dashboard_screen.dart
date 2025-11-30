import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'hero_feature_section.dart';
//import '../../app/layout/app_drawer.dart';
//import '../../utils/scale_size.dart';
import '../../../shared/utils/scale_size.dart';
//import '../../shared/layout/app_drawer.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.of(context).size.width;
    final bool isTablet = width >= 800;

    final fem = ScaleSize.aspectRatio;

    return Scaffold(
      // Mobile - AppBar with menu button
      appBar: !isTablet
          ? AppBar(
              title: Text("Dashboard", style: TextStyle(fontSize: 20 * fem)),
              leading: Builder(
                builder: (context) {
                  return IconButton(
                    icon: Icon(Icons.menu, size: 26 * fem),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  );
                },
              ),
            )
          : null,

      // Drawer only for mobile
      // drawer: !isTablet
      //     ? AppDrawer(
      //         onClose: () {
      //           Navigator.pop(context);
      //         },
      //       )
      //     : null,

      // Main Body
      body: Row(
        children: [
          // LEFT MENU for large screens only
          if (isTablet)
            SizedBox(
              width: ScaleSize.aspectRatio,
              //child: AppDrawer(onClose: () {}),
            ),

          // MAIN CONTENT
          Expanded(child: const DashboardBody()),
        ],
      ),
    );
  }
}

class DashboardBody extends ConsumerWidget {
  const DashboardBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        //horizontal: 20 * ScaleSize.aspectRatio,
        vertical: 2 * ScaleSize.aspectRatio,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HeroAndFeaturesSection(),
          SizedBox(height: 24 * ScaleSize.aspectRatio),
        ],
      ),
    );
  }
}
