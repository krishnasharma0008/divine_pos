import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/feedback_model.dart';
import '../../../shared/utils/http_client.dart';
import '../../../shared/utils/api_endpointen.dart';

enum FeedbackSubmitStatus { idle, loading, success, error }

class FeedbackFormState {
  final FeedbackSubmitStatus status;
  final String? errorMsg;

  const FeedbackFormState({
    this.status = FeedbackSubmitStatus.idle,
    this.errorMsg,
  });

  bool get isLoading => status == FeedbackSubmitStatus.loading;
  bool get isSuccess => status == FeedbackSubmitStatus.success;
  bool get isError => status == FeedbackSubmitStatus.error;

  FeedbackFormState copyWith({FeedbackSubmitStatus? status, String? errorMsg}) {
    return FeedbackFormState(
      status: status ?? this.status,
      // explicitly allow clearing errorMsg when transitioning away from error
      errorMsg: status != null && status != FeedbackSubmitStatus.error
          ? null
          : errorMsg ?? this.errorMsg,
    );
  }
}

final feedbackFormProvider =
    NotifierProvider<FeedbackFormNotifier, FeedbackFormState>(
      FeedbackFormNotifier.new,
    );

class FeedbackFormNotifier extends Notifier<FeedbackFormState> {
  @override
  FeedbackFormState build() => const FeedbackFormState();

  Dio get _dio => ref.read(httpClientProvider);

  Future<bool> submit(FeedbackFormData data) async {
    if (state.isLoading) return false;

    state = state.copyWith(status: FeedbackSubmitStatus.loading);

    try {
      final res = await _dio.post(
        ApiEndPoint.create_dfeedback,
        data: data.toJson(),
        options: Options(
          followRedirects: true,
          maxRedirects: 3,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      print('✅ Status: ${res.statusCode}');
      print('✅ Type: ${res.data.runtimeType}');
      print('✅ Body: ${res.data}');

      if (res.statusCode == null || res.statusCode! >= 400) {
        throw Exception('Request failed with status ${res.statusCode}');
      }

      final body = res.data;
      if (body is! Map<String, dynamic>) {
        throw Exception('Unexpected response format');
      }

      if (body['success'] != true) {
        throw Exception(body['msg']?.toString() ?? 'Submission failed');
      }

      state = state.copyWith(status: FeedbackSubmitStatus.success); // ✅ missing
      return true; // ✅ missing
    } on DioException catch (e) {
      // ✅ missing
      final serverMsg = e.response?.data is Map
          ? e.response!.data['msg']?.toString()
          : null;
      state = state.copyWith(
        status: FeedbackSubmitStatus.error,
        errorMsg: serverMsg ?? e.message ?? 'Network error',
      );
      return false;
    } catch (e) {
      // ✅ missing
      state = state.copyWith(
        status: FeedbackSubmitStatus.error,
        errorMsg: e.toString(),
      );
      return false;
    }
  }

  void reset() => state = const FeedbackFormState();
}
