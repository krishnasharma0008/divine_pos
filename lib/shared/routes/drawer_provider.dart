import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'route_pages.dart';

final drawerProvider = NotifierProvider<DrawerNotifier, DrawerState>(
  DrawerNotifier.new,
);

class DrawerNotifier extends Notifier<DrawerState> {
  @override
  DrawerState build() {
    return DrawerState();
  }

  /// Update selected drawer page safely
  set routePage(RoutePages? routePage) {
    state = state.copyWith(routePage: routePage);
  }
}

class DrawerState {
  final RoutePages? routePage;

  DrawerState({this.routePage});

  bool get isOpenFromDrawer => routePage != null;

  DrawerState copyWith({RoutePages? routePage}) {
    return DrawerState(routePage: routePage ?? this.routePage);
  }
}
