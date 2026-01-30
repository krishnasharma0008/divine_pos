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

      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 500), resetAndFetch);
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
      final pjcode = authRepo.user?.pjcode;

      String? layingWith;
      //debugPrint("Top Button row: $filter.isInStore");
      if (filter.isInStore) {
        layingWith = pjcode;
      } else if (filter.productBranch != null) {
        layingWith = filter.productBranch;
      } else if (filter.allDesigns) {
        layingWith = null;
      } else {
        layingWith = pjcode;
      }

      debugPrint("layingWith : $layingWith");

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
        "item_number": null,
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
        // "gender": filter.selectedGender.isEmpty
        //     ? null
        //     : filter.selectedGender.join(","),
        "gender": gender,

        // "price_from": filter.selectedPriceRange.start > 0
        //     ? filter.selectedPriceRange.start.toInt()
        //     : null,

        // "price_to": filter.selectedPriceRange.end > 0
        //     ? filter.selectedPriceRange.end.toInt()
        //     : null,
        "price_from": filter.selectedPriceRange?.start.toInt(),

        "price_to": filter.selectedPriceRange?.end.toInt(),
        "order_for": null,

        // "cts_from": filter.caratStartLabel.isEmpty
        //     ? null
        //     : double.tryParse(filter.caratStartLabel),
        // "cts_to": filter.caratEndLabel.isEmpty
        //     ? null
        //     : double.tryParse(filter.caratEndLabel),
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
        "sort_by": filter.sortBy,
        if (layingWith != null)
          "laying_with": layingWith, //"laying_with": layingWith,
      };

      // debugPrint("🔄 Fetching jewellery - Page: $_page");
      //debugPrint("📦 Post Data: ${jsonEncode(postData)}");

      // debugPrint(
      //   '🌐 URL => ${dio.options.baseUrl}${ApiEndPoint.get_jewellery_listing}',
      // );

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
      //debugPrint("📦 Fetched Data: ${jsonEncode(response.data)}");
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
}
