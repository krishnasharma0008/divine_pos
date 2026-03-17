import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/verify_track_model.dart';

// =============================================================================
// REPOSITORY
// =============================================================================

class VerifyTrackRepository {
  static const _countryCode = 'IN';
  static const _base = 'https://query.rsdpl.com/api';

  final Dio _dio;
  const VerifyTrackRepository({required Dio dio}) : _dio = dio;

  Future<VerifyTrackByUidResponse> getVerifyTrackByUid({
    required String uid,
  }) async {
    final endpoint = '$_base/getproductinfo/${uid.toUpperCase()}';

    debugPrint('>>> VerifyTrack URL: $endpoint');

    final response = await _dio.get<Map<String, dynamic>>(
      endpoint,
      queryParameters: {'countrycode': _countryCode, 'islocal': 0},
      options: Options(
        sendTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
      ),
    );

    return VerifyTrackByUidResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
  }
}

final verifyTrackRepositoryProvider = Provider<VerifyTrackRepository>((ref) {
  return VerifyTrackRepository(dio: Dio());
});

// =============================================================================
// STATE
// =============================================================================

enum VerifyTrackStatus { idle, loading, error }

class VerifyTrackState {
  final VerifyTrackStatus status;
  final String? errorMessage;
  final VerifyTrackByUid? lastResult;

  const VerifyTrackState({
    this.status = VerifyTrackStatus.idle,
    this.errorMessage,
    this.lastResult,
  });

  bool get isLoading => status == VerifyTrackStatus.loading;
  bool get hasError => status == VerifyTrackStatus.error;

  VerifyTrackState copyWith({
    VerifyTrackStatus? status,
    String? errorMessage,
    VerifyTrackByUid? lastResult,
  }) => VerifyTrackState(
    status: status ?? this.status,
    errorMessage: errorMessage ?? this.errorMessage,
    lastResult: lastResult ?? this.lastResult,
  );
}

// =============================================================================
// NOTIFIER
// =============================================================================

class UidControllerNotifier extends Notifier<TextEditingController> {
  @override
  TextEditingController build() {
    final controller = TextEditingController();
    ref.onDispose(controller.dispose);
    return controller;
  }
}

final uidControllerProvider =
    NotifierProvider.autoDispose<UidControllerNotifier, TextEditingController>(
      UidControllerNotifier.new,
    );

class VerifyTrackNotifier extends Notifier<VerifyTrackState> {
  @override
  VerifyTrackState build() => const VerifyTrackState();

  Future<void> searchData({
    required String uid,
    required void Function(String path, {bool isPortfolio}) onNavigate,
    required void Function(String message) onError,
    bool isPortfolio = false,
  }) async {
    if (uid.trim().isEmpty) {
      onError('Please enter a Unique Identification Number.');
      return;
    }

    state = state.copyWith(status: VerifyTrackStatus.loading);

    try {
      final response = await ref
          .read(verifyTrackRepositoryProvider)
          .getVerifyTrackByUid(uid: uid.trim());

      if (!response.isSuccess || response.data == null) {
        throw Exception('Something Went Wrong');
      }

      final product = response.data!;
      final trackSegment = product.uidStatus == 'SOLD' ? 'track' : 'verify';
      final typeSegment = product.productType == 'Diamond'
          ? 'solitaire'
          : 'jewellery';
      final path = '/$trackSegment/$typeSegment/${uid.trim().toUpperCase()}';

      state = state.copyWith(
        status: VerifyTrackStatus.idle,
        lastResult: product,
      );
      onNavigate(path, isPortfolio: isPortfolio);
    } catch (e) {
      state = state.copyWith(
        status: VerifyTrackStatus.error,
        errorMessage: 'Something went wrong. Please try again.',
      );
      onError('Something went wrong. Please try again.');
      debugPrint('VerifyTrack searchData error: $e');
    }
  }
}

final verifyTrackProvider =
    NotifierProvider.autoDispose<VerifyTrackNotifier, VerifyTrackState>(
      VerifyTrackNotifier.new,
    );
