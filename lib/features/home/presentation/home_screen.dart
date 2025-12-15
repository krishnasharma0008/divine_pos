import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/data/auth_notifier.dart';
import '../../../shared/utils/scale_size.dart';
import '../../../shared/app_bar.dart';
import '../../../shared/routes/app_drawer.dart';

class HomeScreen extends ConsumerWidget {
  HomeScreen({super.key});

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void openDrawer() => _scaffoldKey.currentState?.openDrawer();

  void closeDrawer(BuildContext context) {
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,

      // ------------------ CUSTOM APP BAR ------------------
      appBar: CustomAppBar(
        onMenuTap: openDrawer,
        onCartTap: () => print('Cart tapped'),
        onProfileTap: () => print('Profile tapped'),
        onNotificationTap: () => print('Notification tapped'),
        showBackButton: false, // show menu for home
      ),

      // ------------------ DRAWER ------------------
      drawer: Drawer(
        backgroundColor: Colors.transparent,
        elevation: 0,
        width: 400 * ScaleSize.aspectRatio,
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome ${auth.user?.userName ?? ''}'),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () => context.go('/profile'),
              child: const Text('Go to Profile Screen'),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                ref.read(authProvider.notifier).logout();

                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Logged out')));

                context.go('/login');
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}


/*
Updated HomeScreen snippet without drawer and extra buttons:
Scaffold(
  appBar: CustomAppBar(
    showBackButton: true,
    automaticallyImplyBack: true,
  ),
  body: Center(
    child: Text('This is a screen with only back button'),
  ),
);
*/