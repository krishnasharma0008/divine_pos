import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/utils/api_endpointen.dart';
import '../../../shared/utils/http_client.dart';
import 'filter_provider.dart';
import 'jewellery_model.dart';
import '../../auth/data/auth_notifier.dart';

final jewelleryProvider =
    AsyncNotifierProvider.autoDispose<JewelleryNotifier, List<Jewellery>>(
      JewelleryNotifier.new,
    );

class JewelleryNotifier extends AsyncNotifier<List<Jewellery>> {
  Timer? _debounce;

  int _page = 1;
  final int _limit = 8;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  //bool _firstBuild = true; // ✅ flag to prevent duplicate fetch

  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;

  @override
  Future<List<Jewellery>> build() async {
    ref.onDispose(() {
      _debounce?.cancel();
    });

    // Listen to filter changes ONLY
    ref.listen(filterProvider, (_, __) {
      if (_isLoadingMore) return;

      // ✅ Immediately show loading so stale data never flashes in the UI
      // (critical for solitaire: isSolitaire becomes true instantly but
      //  the old jewellery data would briefly render before debounce fires)
      state = const AsyncLoading();

      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 300), resetAndFetch);
    });

    //return _fetchJewellery();
    // ❌ DO NOT FETCH HERE
    return [];
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
    if (!ref.mounted) return; // ✅ add this guard
    _isLoadingMore = true;

    try {
      final nextPage = await _fetchJewellery(page: _page + 1);

      if (nextPage.isEmpty) {
        _hasMore = false;
        return;
      }

      _page++; // move to next page AFTER success
      state = state.whenData((current) => [...current, ...nextPage]);
    } finally {
      _isLoadingMore = false;
    }
  }

  Future<List<Jewellery>> _fetchJewellery({int? page}) async {
    final effectivePage = page ?? _page;
    try {
      final dio = ref.read(httpClientProvider);
      final filter = ref.read(filterProvider);

      final authRepo = ref.read(authProvider);
      // ✅
      final raw = authRepo.user?.pjcode ?? '';
      final pjcode = raw.split(',').first.trim(); //'OT025'; //

      String? layingWith;
      //debugPrint("Top Button row: $filter.isInStore");
      if (filter.isInStore) {
        //debugPrint("In Store selected");
        layingWith = pjcode;
      } else if (filter.productBranch != null) {
        //debugPrint("Other Branch selected: ${filter.productBranch}");
        layingWith = filter.productBranch;
      } else if (filter.allDesigns) {
        //debugPrint("All Designs selected");
        layingWith = null;
      } else {
        //debugPrint("Default selected");
        layingWith = pjcode;
      }

      String? sortby;

      if (filter.sortBy == 'Low to high') {
        sortby = 'low_to_high';
      } else if (filter.sortBy == 'High to low') {
        sortby = 'high_to_low';
      } else if (filter.sortBy == 'New Arrivals') {
        sortby = 'new_arrival';
      } else {
        sortby = null; // default sorting
      }

      // debugPrint("Button Type : ${filter.allDesigns}");
      // debugPrint("layingWith : $layingWith");
      //debugPrint("Sort by : ${filter.sortBy}");
      String? gender;

      if (filter.selectedGender.isNotEmpty) {
        final mapped = filter.selectedGender
            .map((g) {
              switch (g.toLowerCase()) {
                case 'men':
                case 'male':
                  return 'male';

                case 'women':
                case 'female':
                  return 'female';

                case 'unisex':
                  return 'Unisex';

                case 'children':
                case 'kids':
                  return 'Children';

                default:
                  return null;
              }
            })
            .whereType<String>()
            .toSet(); // remove nulls & duplicates

        gender = mapped.isEmpty ? null : mapped.join(',');
      }
      //debugPrint("Selected gender: $gender");
      //debugPrint(filter.selectedGender.join(","));
      final postData = {
        "item_number": filter.itemno,
        "product_category": filter.selectedCategory.isEmpty
            ? null
            : filter.selectedCategory.join(",").toLowerCase(),
        "product_sub_category": filter.selectedSubCategory.isEmpty
            ? null
            : filter.selectedSubCategory.join(","),
        "collection": null,
        "metal_purity": filter.selectedMetalPurity.isEmpty
            ? null
            : filter.selectedMetalPurity.join(","),
        "metal_color": filter.selectedMetalColor.isEmpty
            ? null
            : filter.selectedMetalColor.join(","),
        "portfolio_type": null,
        "pageno": effectivePage,
        "is_new_launch": false,
        "discarded": false,
        "gender": gender,
        "price_from": filter.selectedPriceRange?.start.toInt(),

        "price_to": filter.selectedPriceRange?.end.toInt(),
        "order_for": null,
        "cts_from": filter.caratStartLabel != null
            ? double.tryParse(filter.caratStartLabel!)
            : null,

        "cts_to": filter.caratEndLabel != null
            ? double.tryParse(filter.caratEndLabel!)
            : null,

        "shapes": filter.selectedShape.isEmpty
            ? null
            : filter.selectedShape.join(",").toLowerCase(),
        "occasions": filter.selectedOccasions.isEmpty
            ? null
            : filter.selectedOccasions.join(","),
        "sort_by": sortby, // ✅ include sortBy in post data
        if (layingWith != null)
          "laying_with": layingWith, //"laying_with": layingWith,

        "color_from": filter.colorStartLabel,
        "color_to": filter.colorEndLabel,
        "clarity_from": filter.clarityStartLabel,
        "clarity_to": filter.clarityEndLabel,
        'only_own': filter.allStore, // new field for "All Store" selection
        //'sortby': filter.sortBy, // include sortBy in post data
      };

      //debugPrint("🔄 Fetching jewellery - Page: $_page");
      debugPrint("📦 Post Data: ${jsonEncode(postData)}");

      debugPrint(
        '🌐cataloge URL => ${dio.options.baseUrl}${ApiEndPoint.get_jewellery_listing}',
      );

      final response = await dio
          .post(ApiEndPoint.get_jewellery_listing, data: postData)
          .timeout(
            const Duration(seconds: 15), // ✅ Network timeout
            onTimeout: () =>
                throw TimeoutException('Request timed out after 15s'),
          );

      // ✅ HTTP Status check
      if (response.statusCode != HttpStatus.ok) {
        throw HttpException(
          'HTTP ${response.statusCode}: ${response.statusMessage}',
        );
      }
      //longPrint("📦 Fetched Listing screen Data: ${jsonEncode(response.data)}");
      // ✅ Response data validation
      if (response.data == null) {
        throw Exception('Empty response from server');
      }

      final responseData = response.data;
      if (responseData['success'] != true) {
        final errorMsg = responseData['message'] ?? 'Unknown server error';
        throw Exception('Server error: $errorMsg');
      }

      final rawData = responseData['data'];
      //debugPrint("📦 Page $effectivePage → ${rawData.length} items");

      if (rawData == null || rawData is! List) {
        _hasMore = false;
        return [];
      }

      if (rawData.isEmpty) {
        _hasMore = false;
        return [];
      }

      // ✅ Safe JSON parsing
      final data = <Jewellery>[];
      for (final item in rawData) {
        try {
          if (item is Map<String, dynamic>) {
            data.add(Jewellery.fromJson(item));
          }
        } catch (e) {
          debugPrint('⚠️ Failed to parse item: $item, Error: $e');
          // Continue with next item
        }
      }

      //debugPrint('✅ Loaded ${data.length} jewellery items');

      if (data.length < _limit) {
        _hasMore = false;
      }

      return data;
    } on DioException catch (e) {
      // ✅ Network/Dio specific errors
      debugPrint('🌐 Dio Error: ${e.message}');
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Network timeout. Please check your connection.');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Session expired. Please login again.');
      } else if (e.response?.statusCode == 500) {
        throw Exception('Server error. Please try again later.');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } on TimeoutException catch (e) {
      debugPrint('⏰ Timeout Error: $e');
      throw Exception('Request timed out. Please try again.');
    } catch (e, stackTrace) {
      // ✅ Catch-all for unexpected errors
      debugPrint('❌ Unexpected error: $e');
      debugPrint('Stack trace: $stackTrace');
      throw Exception('Failed to load jewellery: $e');
    } finally {
      // ✅ Always update loading state
      // isLoadingNotifier.value = false; // if you have one
    }
  }

  void longPrint(Object? obj) {
    const chunkSize = 800;
    final str = obj.toString();
    for (var i = 0; i < str.length; i += chunkSize) {
      final end = (i + chunkSize < str.length) ? i + chunkSize : str.length;
      debugPrint(str.substring(i, end));
    }
  }
}
