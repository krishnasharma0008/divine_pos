import 'dart:io';

import 'package:divine_pos/shared/utils/api_endpointen.dart';
import 'package:divine_pos/shared/utils/http_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'route_pages.dart';

final drawerProvider = NotifierProvider<DrawerNotifier, DrawerState>(
  DrawerNotifier.new,
);

class DrawerNotifier extends Notifier<DrawerState> {
  @override
  DrawerState build() {
    /// Fetch filters when drawer provider initializes
    Future.microtask(() => getFilters());
    return DrawerState();
  }

  /// Update selected drawer page safely
  set routePage(RoutePages? routePage) {
    state = state.copyWith(routePage: routePage);
  }

  /// ─────────────────────────────────────────────
  /// FETCH FILTERS (Categories / SubCategories / Collections)
  /// ─────────────────────────────────────────────
  Future<bool> getFilters() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final dio = ref.read(httpClientProvider);
      final response = await dio.get(ApiEndPoint.get_jewellery_filters);

      if (response.statusCode == HttpStatus.ok) {
        final data = response.data;

        if (data["success"] == true) {
          final categories = List<String>.from(data["category"] ?? []);
          final subCategories = List<String>.from(data["sub_category"] ?? []);
          final collections = List<String>.from(data["collection"] ?? []);

          debugPrint("Drawer categories: $categories");

          state = state.copyWith(
            isLoading: false,
            categories: categories,
            subCategories: subCategories,
            collections: collections,
          );

          return true;
        }
      }

      state = state.copyWith(
        isLoading: false,
        errorMessage: "Filters not found",
      );

      return false;
    } catch (e) {
      debugPrint("Drawer getFilters error: $e");

      state = state.copyWith(
        isLoading: false,
        errorMessage: "Failed to load filters",
      );

      return false;
    }
  }
}

class DrawerState {
  final RoutePages? routePage;

  final bool isLoading;
  final List<String> categories;
  final List<String> subCategories;
  final List<String> collections;

  final String? errorMessage;

  DrawerState({
    this.routePage,
    this.isLoading = false,
    this.categories = const [],
    this.subCategories = const [],
    this.collections = const [],
    this.errorMessage,
  });

  bool get isOpenFromDrawer => routePage != null;

  DrawerState copyWith({
    RoutePages? routePage,
    bool? isLoading,
    List<String>? categories,
    List<String>? subCategories,
    List<String>? collections,
    String? errorMessage,
  }) {
    return DrawerState(
      routePage: routePage ?? this.routePage,
      isLoading: isLoading ?? this.isLoading,
      categories: categories ?? this.categories,
      subCategories: subCategories ?? this.subCategories,
      collections: collections ?? this.collections,
      errorMessage: errorMessage,
    );
  }
}
