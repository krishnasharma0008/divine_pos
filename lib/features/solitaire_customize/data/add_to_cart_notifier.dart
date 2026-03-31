import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/utils/api_endpointen.dart';
import '../../../shared/utils/http_client.dart';
import '../../cart/data/cart_detail_model.dart';

// =============================================================================
// State
// =============================================================================

enum AddToCartStatus { idle, loading, success, error }

class AddToCartState {
  const AddToCartState({this.status = AddToCartStatus.idle, this.errorMessage});

  final AddToCartStatus status;
  final String? errorMessage;

  bool get isLoading => status == AddToCartStatus.loading;
  bool get isSuccess => status == AddToCartStatus.success;
  bool get isError => status == AddToCartStatus.error;

  AddToCartState copyWith({AddToCartStatus? status, String? errorMessage}) {
    return AddToCartState(
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }
}

// =============================================================================
// Provider
// =============================================================================

final addToCartProvider = NotifierProvider<AddToCartNotifier, AddToCartState>(
  AddToCartNotifier.new,
);

// =============================================================================
// Notifier
// =============================================================================

class AddToCartNotifier extends Notifier<AddToCartState> {
  late final Dio _dio;

  @override
  AddToCartState build() {
    _dio = ref.read(httpClientProvider);
    return const AddToCartState();
  }

  // ---------------------------------------------------------------------------
  // Add to cart
  // ---------------------------------------------------------------------------

  Future<void> addToCart({required CartDetail detail}) async {
    state = state.copyWith(status: AddToCartStatus.loading, errorMessage: null);

    try {
      await _createCart(detail);

      state = state.copyWith(status: AddToCartStatus.success);
    } on TimeoutException {
      state = state.copyWith(
        status: AddToCartStatus.error,
        errorMessage: 'Request timed out. Please try again.',
      );
    } on HttpException catch (e) {
      state = state.copyWith(
        status: AddToCartStatus.error,
        errorMessage: 'Network error: ${e.message}',
      );
    } on DioException catch (e, st) {
      debugPrint('AddToCart Dio error: $e\n$st');

      final message =
          e.response?.data?['msg'] ??
          e.response?.data?['message'] ??
          e.message ??
          'Something went wrong';

      state = state.copyWith(
        status: AddToCartStatus.error,
        errorMessage: message,
      );
    } catch (e, st) {
      debugPrint('AddToCart error: $e\n$st');

      state = state.copyWith(
        status: AddToCartStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  void reset() {
    state = const AddToCartState();
  }

  // ---------------------------------------------------------------------------
  // POST create cart
  // ---------------------------------------------------------------------------

  Future<void> _createCart(CartDetail item) async {
    final response = await _dio
        .post(ApiEndPoint.create_cart, data: [item.toJson()])
        .timeout(
          const Duration(seconds: 15),
          onTimeout: () => throw TimeoutException('Create cart timed out'),
        );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw HttpException('HTTP ${response.statusCode}');
    }

    if (response.data is! Map<String, dynamic>) {
      throw Exception('Invalid server response');
    }

    final body = response.data as Map<String, dynamic>;

    if (body['success'] != true) {
      throw Exception(body['msg'] ?? 'Failed to create cart');
    }
  }
}
