import 'dart:async';

import 'package:divine_pos/features/dashboard/presentation/dashboard_screen.dart';
import 'package:divine_pos/features/jewellery_journey/presentation/jewellery_journey_screen.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/data/auth_notifier.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/home/presentation/loading_screen.dart';
//import '../../features/profile/presentation/profile_screen.dart';
import '../../features/auth/presentation/otp_screen.dart'; // import your OTP screen
import '../../features/jewellery/presentation/jewellery_listing_screen.dart';

import '../../shared/shared_layout.dart';
import 'route_pages.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    //initialLocation: RoutePages.home.routePath,
    initialLocation: RoutePages.dashboard.routePath,
    refreshListenable: GoRouterRefreshStream(
      ref.read(authProvider.notifier).authChanges,
    ),

    redirect: (context, state) {
      if (authState.status == AuthStatus.loading) {
        return '/loading';
      }
      // if (authState.status == AuthStatus.unauthenticated) {
      //   return RoutePages.login.routePath;
      // }
      // Allow OTP route even when unauthenticated!
      // Only redirect to login for all other pages
      if (authState.status == AuthStatus.unauthenticated &&
          state.uri.toString() != RoutePages.login.routePath &&
          state.uri.toString() != RoutePages.otp.routePath &&
          state.uri.toString() != '/loading') {
        return RoutePages.login.routePath;
      }
      if (authState.status == AuthStatus.authenticated &&
          state.matchedLocation == RoutePages.login.routePath) {
        //return RoutePages.home.routePath;
        return RoutePages.dashboard.routePath;
      }
      return null;
    },

    routes: [
      GoRoute(
        path: '/loading',
        name: 'loading',
        builder: (context, state) => LoadingScreen(),
      ),
      GoRoute(
        path: RoutePages.login.routePath,
        name: RoutePages.login.routeName,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RoutePages.otp.routePath,
        name: RoutePages.otp.routeName,
        builder: (context, state) {
          final phoneNumber = state.extra as String?;
          return OtpScreen(phoneNumber: phoneNumber ?? '');
        },
      ),

      // ⭐ MAIN APP LAYOUT (Bottom Navigation)
      ShellRoute(
        builder: (context, state, child) {
          return SharedLayout(child: child);
        },
        routes: [
          GoRoute(
            path: RoutePages.home.routePath,
            name: RoutePages.home.routeName,
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: RoutePages.dashboard.routePath,
            name: RoutePages.dashboard.routeName,
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: RoutePages.jewellerylisting.routePath,
            name: RoutePages.jewellerylisting.routeName,
            builder: (context, state) => JewelleryListingScreen(),
          ),
          GoRoute(
            path: RoutePages.jewelleryjourney.routePath,
            name: RoutePages.jewelleryjourney.routeName,
            builder: (context, state) => JewelleryJourneyScreen(),
          ),
          // GoRoute(
          //   path: RoutePages.profile.routePath,
          //   name: RoutePages.profile.routeName,
          //   builder: (context, state) => const ProfileScreen(),
          // ),

          // GoRoute(
        ],
      ),
    ],
  );
});

// Helper that converts a Stream into a Listenable for GoRouter refresh
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notify();
    _sub = stream.asBroadcastStream().listen((_) => notify());
  }

  late final StreamSubscription _sub;
  void notify() => notifyListeners();
  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
