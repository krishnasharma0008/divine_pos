import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/utils/api_endpointen.dart';
import '../../../shared/utils/http_client.dart';
import 'filter_provider.dart';
import 'jewellery_model.dart';
import '../../auth/data/auth_notifier.dart';

final jewelleryProvider =
    AsyncNotifierProvider<JewelleryNotifier, List<Jewellery>>(
      JewelleryNotifier.new,
    );

class JewelleryNotifier extends AsyncNotifier<List<Jewellery>> {
  Timer? _debounce;

  int _page = 1;
  final int _limit = 8;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;

  @override
  Future<List<Jewellery>> build() async {
    /// cleanup
    ref.onDispose(() {
      _debounce?.cancel();
    });

    /// filter change → debounce → reload
    ref.listen(filterProvider, (_, __) {
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 500), resetAndFetch);
    });

    /// initial load (page load)
    return _fetchJewellery();
  }

  /// reset + reload
  Future<void> resetAndFetch() async {
    _page = 1;
    _hasMore = true;

    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchJewellery);
  }

  /// pagination
  Future<void> loadMore() async {
    if (!_hasMore || _isLoadingMore) return;

    _isLoadingMore = true;
    _page++;

    try {
      final nextPage = await _fetchJewellery();
      state = state.whenData((current) => [...current, ...nextPage]);
    } finally {
      _isLoadingMore = false;
    }
  }

  Future<List<Jewellery>> _fetchJewellery() async {
    final dio = ref.read(httpClientProvider);
    final filter = ref.read(filterProvider);

    final authRepo = ref.read(authProvider);
    final pjcode = authRepo.user?.pjcode;

    String? layingWith;

    if (filter.isInStore) {
      layingWith = pjcode;
    } else if (filter.productBranch != null) {
      layingWith = filter.productBranch;
    } else if (filter.allDesigns) {
      layingWith = null;
    } else {
      layingWith = pjcode;
    }

    debugPrint("is_in_store: ${filter.isInStore}");
    debugPrint("branch_at_code: ${filter.productBranch}");
    debugPrint("all_designs: ${filter.allDesigns}");
    debugPrint("sort_by: ${filter.sortBy}");

    final postData = {
      "item_number": null,
      "product_category": filter.selectedCategory.isEmpty
          ? null
          : filter.selectedCategory.join(",").toLowerCase(),
      "product_sub_category": filter.selectedSubCategory.isEmpty
          ? null
          : filter.selectedSubCategory.join(","),
      "collection": null,
      "metal_purity": null,
      "portfolio_type": null,

      "pageno": _page,
      "is_new_launch": false,
      "discarded": false,

      "gender": filter.selectedGender.isEmpty
          ? null
          : filter.selectedGender.join(","),

      "price_from": null, //filter.selectedPriceRange.start,
      "price_to": null, //filter.selectedPriceRange.end,
      "order_for": null, //"Stock",
      "cts_from": null,
      "cts_to": null,
      "shapes": null,
      "occasions": null,
      "sort_by": filter.sortBy,

      "laying_with": layingWith,
    };

    debugPrint(" Post Data : ${postData}");

    final response = await dio.post(
      ApiEndPoint.get_jewellery_listing,
      data: postData,
    );

    if (response.statusCode != HttpStatus.ok ||
        response.data == null ||
        response.data["success"] != true) {
      throw Exception("Failed to load jewellery");
    }

    final rawData = response.data["data"];
    if (rawData == null || rawData is! List) {
      _hasMore = false;
      return [];
    }

    final data = rawData.map<Jewellery>((e) => Jewellery.fromJson(e)).toList();

    if (data.length < _limit) {
      _hasMore = false;
    }

    return data;
  }
}
