import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import '../../../shared/utils/api_endpointen.dart';
import 'jewellery_detail_model.dart';
import 'jewellery_price_model.dart';

class JewelleryApiService {
  Future<JewelleryDetail?> getJewelleryProductDetail({
    required String productCode,
    required Dio dio,
  }) async {
    debugPrint(
      'JewelleryApiService: Fetching product detail for productCode: $productCode',
    );

    final response = await dio
        .post(
          ApiEndPoint.get_jewellery_Prodct,
          data: {'productCode': productCode},
        )
        .timeout(
          const Duration(seconds: 15),
          onTimeout: () => throw DioException(
            requestOptions: RequestOptions(
              path: ApiEndPoint.get_jewellery_Prodct,
            ),
            error: 'Request timed out after 15s',
            type: DioExceptionType.receiveTimeout,
          ),
        );

    debugPrint(
      'JewelleryApiService: getJewelleryProductDetail response: ${response.data}',
    );

    if (response.statusCode != 200) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        error: 'Failed to fetch product detail',
      );
    }

    final body = response.data;

    if (body is Map<String, dynamic> &&
        body['success'] == true &&
        body['data'] != null) {
      return JewelleryDetail.fromJson(body['data']);
    }

    return null;
  }

  Future<JewelleryPrice> getJewelleryProductPrice({
    required String itemGroup,
    String? slab,
    String? shape,
    String? color,
    String? quality,
    required Dio dio,
  }) async {
    final response = await dio
        .post(
          ApiEndPoint.get_price,
          data: {
            'itemgroup': itemGroup,
            if (slab != null && slab.isNotEmpty)
              'weight': double.tryParse(slab),
            if (shape != null && shape.isNotEmpty) 'shape': shape,
            if (color != null && color.isNotEmpty) 'color': color,
            if (quality != null && quality.isNotEmpty) 'quality': quality,
          },
        )
        .timeout(
          const Duration(seconds: 15),
          onTimeout: () => throw DioException(
            requestOptions: RequestOptions(path: ApiEndPoint.get_price),
            error: 'Request timed out after 15s',
            type: DioExceptionType.receiveTimeout,
          ),
        );

    if (response.statusCode != 200) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        error: 'Failed to fetch price',
      );
    }

    return JewelleryPrice.fromJson(response.data);
  }
}
