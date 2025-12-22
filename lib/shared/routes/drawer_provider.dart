import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'route_pages.dart';

final drawerProvider = StateNotifierProvider<DrawerNotifier, DrawerState>((
  ref,
) {
  return DrawerNotifier(ref: ref);
});

class DrawerNotifier extends StateNotifier<DrawerState> {
  DrawerNotifier({required this.ref}) : super(DrawerState());

  final Ref ref;

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
