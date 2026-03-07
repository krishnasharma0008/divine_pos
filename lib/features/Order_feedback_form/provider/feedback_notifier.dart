// lib/features/Order_feedback_form/provider/feedback_notifier.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import '../../../shared/utils/http_client.dart';
import '../../../shared/utils/api_endpointen.dart';
import '../data/order_feedback_model.dart';

class FeedbackNotifier extends AsyncNotifier<void> {
  Dio get dio => ref.read(httpClientProvider);

  @override
  Future<void> build() async {}

  Future<void> createOrderFeedback(DivineFeedbackModel feedback) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final res = await dio.post(
        ApiEndPoint.create_feedback,
        data: feedback.toJson(),
        options: Options(
          followRedirects: true, // let Dio follow 307 automatically
          maxRedirects: 3,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (res.statusCode == null || res.statusCode! >= 400) {
        throw Exception('Request failed with status ${res.statusCode}');
      }

      final body = res.data;
      if (body is Map<String, dynamic> && body['success'] != true) {
        throw Exception(body['msg'] ?? 'Feedback submission failed');
      }
    });
  }
}

final feedbackProvider = AsyncNotifierProvider<FeedbackNotifier, void>(
  FeedbackNotifier.new,
);
