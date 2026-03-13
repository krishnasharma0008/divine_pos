import 'dart:io';

import 'package:divine_pos/shared/utils/api_endpointen.dart';
import 'package:divine_pos/shared/utils/http_client.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ---------------------------------------------------------------------------
// Result model — mirrors JS IPastPrice { past_price, difference }
// ---------------------------------------------------------------------------
class ComparePriceResult {
  final DateTime checkDate;
  final double currentPrice;
  final double pastPrice;
  final double difference;
  final String currencyCode;
  final String currencyLocale;
  final bool flag;
  final String message;

  const ComparePriceResult({
    required this.checkDate,
    required this.currentPrice,
    required this.pastPrice,
    required this.difference,
    required this.currencyCode,
    required this.currencyLocale,
    required this.flag,
    required this.message,
  });
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------
final diamondPriceRepositoryProvider = Provider<DiamondPriceRepository>(
  (ref) => DiamondPriceRepository(ref),
);

// ---------------------------------------------------------------------------
// Repository
// ---------------------------------------------------------------------------
class DiamondPriceRepository {
  final Ref _ref;
  DiamondPriceRepository(this._ref);

  static const _countryCode = 'IN';
  static const _pricingBase = 'https://query.rsdpl.com/api';
  // -------------------------------------------------------------------------
  // getStonePrice
  // mirrors JS: callWebService(`${url}?countrycode=${countryCode}&islocal=0`, {
  //               method, params: { shape, clarity, colour, cts } })
  // -------------------------------------------------------------------------
  Future<double> fetchPrice({
    required String itemGroup,
    String? slab,
    String? shape,
    String? color,
    String? quality,
  }) async {
    final dio = _ref.read(httpClientProvider);

    final String? colour = switch (color) {
      'Yellow Vivid' => 'VDY',
      'Yellow Intense' => 'INY',
      null => null,
      _ => color,
    };

    final response = await dio.post(
      ApiEndPoint.get_price,
      data: {
        'itemgroup': itemGroup,
        'weight': slab?.isNotEmpty == true ? double.parse(slab!) : null,
        'shape': shape?.isNotEmpty == true ? shape : null,
        'color': colour,
        'quality': quality,
      },
    );

    _assertOk(response.statusCode, 'stone price');

    if (response.statusCode != HttpStatus.ok) {
      throw HttpException('Failed to fetch solitaire price');
    }

    final body = response.data;
    if (body == null || body['success'] != true) {
      throw Exception('Invalid price response');
    }

    final price = body['price'];

    if (price is num) {
      return price.toDouble();
    }

    throw Exception('Invalid price response: $body');
  }

  // -------------------------------------------------------------------------
  // comparePastPrices
  // mirrors JS: callWebService(`${url}?countrycode=${countryCode}&islocal=0`, {
  //               method, params: state })
  // state = { shape, colour, clarity, cts, month, year, day }
  // returns: res.data.data = IPastPrice { past_price, difference }
  // -------------------------------------------------------------------------
  Future<ComparePriceResult> comparePastPrices({
    required String shape,
    required String colour,
    required String clarity,
    required double cts,
    required int month,
    required int year,
    int day = 1,
  }) async {
    final dio = _ref.read(httpClientProvider);

    final query = {
      'shape': shape,
      'colour': colour,
      'clarity': clarity,
      'cts': cts,
      'month': month,
      'year': year,
      'day': day,
    };

    const endpoint =
        '$_pricingBase/check_price_difference?countrycode=$_countryCode&islocal=0';
    debugPrint('🌐 comparePastPrices URL => $endpoint');
    debugPrint('🟦 comparePastPrices query => $query');

    final response = await dio.get(endpoint, queryParameters: query);

    _assertOk(response.statusCode, 'past price');

    // Response: { data: { check_date, current_price, past_price, difference,
    //                     currency_code, currency_locale }, flag, message }
    final body = response.data;
    debugPrint("📦 comparePastPrices raw body => $body");

    final data = body['data'] as Map;

    return ComparePriceResult(
      checkDate:
          DateTime.tryParse('${data['check_date'] ?? ''}') ?? DateTime.now(),
      currentPrice: (data['current_price'] as num).toDouble(),
      pastPrice: (data['past_price'] as num).toDouble(),
      difference: (data['difference'] as num).toDouble(),
      currencyCode: '${data['currency_code'] ?? ''}',
      currencyLocale: '${data['currency_locale'] ?? ''}',
      flag: body['flag'] == true || body['flag'] == 'true',
      message: '${body['message'] ?? ''}',
    );
  }

  void _assertOk(int? statusCode, String label) {
    if (statusCode != HttpStatus.ok) {
      throw HttpException('Failed to fetch $label (HTTP $statusCode)');
    }
  }
}
