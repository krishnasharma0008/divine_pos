import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dio/dio.dart';

import '../../../shared/utils/http_client.dart';
import '../../../shared/utils/api_endpointen.dart';
import '../data/cart_detail_model.dart';
import '../data/customer_detail_model.dart';
import '../../auth/data/auth_notifier.dart';

final cartNotifierProvider =
    AsyncNotifierProvider<CartNotifier, List<CartDetail>>(CartNotifier.new);

class CartNotifier extends AsyncNotifier<List<CartDetail>> {
  List<CartDetail> _cartData = [];
  List<int> _selectedItems = [];
  String _orderSummaryRemark = '';
  String _errorMsg = '';
  String? _currentUser;

  Dio get dio => ref.read(httpClientProvider);

  @override
  Future<List<CartDetail>> build() async {
    final auth = ref.read(authProvider);
    _currentUser = auth.user?.userName;
    debugPrint('current user $_currentUser');

    if (_currentUser == null || _currentUser!.isEmpty) {
      _cartData = [];
      _orderSummaryRemark = '';
      return _cartData;
    }

    return _fetchCart(_currentUser!);
  }

  Future<List<CartDetail>> _fetchCart(String user) async {
    try {
      debugPrint('🌐 URL => ${dio.options.baseUrl}${ApiEndPoint.cart_list}');

      final response = await dio.post(
        ApiEndPoint.cart_list,
        data: {'username': user},
      );

      debugPrint("📦 Fetched Data: ${jsonEncode(response.data)}");

      if (response.statusCode == 200) {
        final res = response.data;
        _cartData = (res['data'] as List)
            .map((e) => CartDetail.fromJson(e))
            .toList();
        _orderSummaryRemark = res['order_remarks'] ?? '';
        state = AsyncData(_cartData);
        return _cartData;
      }
      throw Exception('Failed to load cart: ${response.statusCode}');
    } catch (e) {
      _errorMsg = e.toString();
      state = AsyncError(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> _deleteCart(int id) async {
    await dio.delete('${ApiEndPoint.delete_cart}$id');
  }

  /// EDIT CART (used for qty + engraving)
  Future<void> _editCart(CartDetail item) async {
    //final url = '${ApiEndPoint.update_cart}';
    final body = item.toJson();

    // debugPrint('EditCart URL  => ${dio.options.baseUrl}$url');
    // debugPrint('EditCart body => $body');

    try {
      final res = await dio.put(ApiEndPoint.update_cart, data: body);
      debugPrint('EditCart OK   => ${res.statusCode}, ${res.data}');
    } on DioException catch (e) {
      debugPrint('EditCart ERROR => ${e.response?.statusCode}');
      debugPrint('EditCart RESP  => ${e.response?.data}');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> _createOrder(List<int> ids) async {
    final response = await dio.post(
      ApiEndPoint.create_cart,
      data: {'ids': ids},
    );
    return response.data as Map<String, dynamic>;
  }

  // PUBLIC GETTERS

  List<int> get selectedItems => _selectedItems;
  String get orderSummaryRemark => _orderSummaryRemark;
  String get errorMsg => _errorMsg;
  Map<String, dynamic> get totals => _calculateTotals();

  // SELECTION

  void toggleSelectAll() {
    _selectedItems = _selectedItems.length == _cartData.length
        ? []
        : _cartData.map((e) => e.id ?? 0).where((id) => id > 0).toList();
    state = AsyncData(_cartData);
  }

  void toggleItem(int id) {
    if (_selectedItems.contains(id)) {
      _selectedItems.remove(id);
    } else {
      _selectedItems.add(id);
    }
    state = AsyncData(_cartData);
  }

  // DELETE

  Future<void> deleteItem(int id) async {
    state = const AsyncLoading();
    try {
      await _deleteCart(id);
      _cartData.removeWhere((item) => item.id == id);
      _selectedItems.remove(id);
      state = AsyncData(_cartData);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  // QTY UPDATE

  Future<void> updateQuantity(int id, bool increase) async {
    final list = state.value ?? const <CartDetail>[];
    final index = list.indexWhere((e) => e.id == id);
    if (index == -1) return;

    final item = list[index];
    final oldQty = item.productQty ?? 1;
    final newQty = increase ? oldQty + 1 : (oldQty > 1 ? oldQty - 1 : 1);

    final updated = item.copyWith(productQty: newQty);

    // optimistic local update so UI changes instantly
    final updatedList = [...list];
    updatedList[index] = updated;
    state = AsyncData(updatedList);

    try {
      // call your existing edit-cart API here
      await _editCart(updated); // ensure this sends productQty to backend
    } catch (e, st) {
      // optionally revert UI or show error
      state = AsyncError(e, st);
    }
  }

  // PROCEED TO CHECKOUT

  Future<Map<String, dynamic>> proceedToCheckout() async {
    if (_selectedItems.isEmpty) {
      _errorMsg = 'Please select at least one item';
      return {'success': false, 'msg': _errorMsg};
    }

    final selected = _cartData
        .where((i) => _selectedItems.contains(i.id))
        .toList();
    if (selected.map((e) => e.customerName).toSet().length != 1) {
      _errorMsg = 'Only one partner jeweller allowed';
      return {'success': false, 'msg': _errorMsg};
    }

    state = const AsyncLoading();
    try {
      final response = await _createOrder(_selectedItems);
      if ((response['msg'] ?? '').toLowerCase() == 'sucess') {
        _cartData.removeWhere((item) => _selectedItems.contains(item.id));
        _selectedItems.clear();
        state = AsyncData(_cartData);
        return {'success': true, 'data': response};
      }
      return {'success': false, 'msg': response['msg'] ?? 'Failed'};
    } catch (e) {
      _errorMsg = e.toString();
      state = AsyncError(e, StackTrace.current);
      return {'success': false, 'msg': _errorMsg};
    }
  }

  // REFRESH

  Future<void> refresh(String user) async {
    _currentUser = user;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchCart(user));
  }

  // TOTALS

  Map<String, dynamic> _calculateTotals() {
    final selected = _cartData
        .where((item) => _selectedItems.contains(item.id))
        .toList();
    return {
      'totalQty': selected.fold<int>(0, (s, i) => s + (i.productQty ?? 0)),
      'totalAmtMin': selected.fold<double>(
        0,
        (s, i) => s + (i.productAmtMin ?? 0),
      ),
      'totalAmtMax': selected.fold<double>(
        0,
        (s, i) => s + (i.productAmtMax ?? 0),
      ),
    };
  }

  // ENGRAVING STATE HELPERS
  bool isEngravingEnabled(int id) {
    final item = _cartData.firstWhere((e) => e.id == id);
    return (item.cartRemarks ?? '').trim().isNotEmpty;
  }

  String getEngravingText(int id) {
    final item = _cartData.firstWhere(
      (e) => e.id == id,
      orElse: () => throw Exception('Item not found'),
    );
    return item.cartRemarks ?? '';
  }

  Future<void> toggleEngraving(int id, bool enabled) async {
    final list = state.value ?? const <CartDetail>[];
    final index = list.indexWhere((e) => e.id == id);
    if (index == -1) return;

    final item = list[index];

    final newRemarks = enabled
        ? ((item.cartRemarks ?? '').trim().isNotEmpty
              ? item.cartRemarks!
              : 'Engraving')
        : '';

    final updated = CartDetail(
      id: item.id,
      cartRemarks: newRemarks,
      productQty: item.productQty,
      productAmtMin: item.productAmtMin,
      productAmtMax: item.productAmtMax,
      orderFor: item.orderFor,
      customerId: item.customerId,
      customerCode: item.customerCode,
      customerBranch: item.customerBranch,
      orderType: item.orderType,
      productType: item.productType,
      productCategory: item.productCategory,
      productSubCategory: item.productSubCategory,
      collection: item.collection,
      expDlvDate: item.expDlvDate,
      oldVarient: item.oldVarient,
      solitairePcs: item.solitairePcs,
      solitaireShape: item.solitaireShape,
      solitaireSlab: item.solitaireSlab,
      solitaireColor: item.solitaireColor,
      solitaireQuality: item.solitaireQuality,
      solitairePremSize: item.solitairePremSize,
      solitairePremPct: item.solitairePremPct,
      solitaireAmtMin: item.solitaireAmtMin,
      solitaireAmtMax: item.solitaireAmtMax,
      metalType: item.metalType,
      metalPurity: item.metalPurity,
      metalColor: item.metalColor,
      metalWeight: item.metalWeight,
      metalPrice: item.metalPrice,
      mountAmtMin: item.mountAmtMin,
      mountAmtMax: item.mountAmtMax,
      sizeFrom: item.sizeFrom,
      sizeTo: item.sizeTo,
      sideStonePcs: item.sideStonePcs,
      sideStoneCts: item.sideStoneCts,
      sideStoneColor: item.sideStoneColor,
      sideStoneQuality: item.sideStoneQuality,
      orderRemarks: item.orderRemarks,
      style: item.style,
      wearStyle: item.wearStyle,
      look: item.look,
      portfolioType: item.portfolioType,
      gender: item.gender,
      customerName: item.customerName,
      productCode: item.productCode,
      imageUrl: item.imageUrl,
    );

    final updatedList = [...list];
    updatedList[index] = updated;

    state = AsyncData(updatedList);

    try {
      await _editCart(updated);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  // UPDATE ENGRAVING TEXT

  Future<void> updateEngravingText(int id, String text) async {
    final index = _cartData.indexWhere((e) => e.id == id);
    if (index == -1) return;

    final words = text.trim().split(RegExp(r'\s+'));
    if (words.length > 10) return;

    final item = _cartData[index];

    final updated = CartDetail(
      id: item.id,
      cartRemarks: text,
      productQty: item.productQty,
      productAmtMin: item.productAmtMin,
      productAmtMax: item.productAmtMax,
      orderFor: item.orderFor,
      customerId: item.customerId,
      customerCode: item.customerCode,
      customerBranch: item.customerBranch,
      orderType: item.orderType,
      productType: item.productType,
      productCategory: item.productCategory,
      productSubCategory: item.productSubCategory,
      collection: item.collection,
      expDlvDate: item.expDlvDate,
      oldVarient: item.oldVarient,
      solitairePcs: item.solitairePcs,
      solitaireShape: item.solitaireShape,
      solitaireSlab: item.solitaireSlab,
      solitaireColor: item.solitaireColor,
      solitaireQuality: item.solitaireQuality,
      solitairePremSize: item.solitairePremSize,
      solitairePremPct: item.solitairePremPct,
      solitaireAmtMin: item.solitaireAmtMin,
      solitaireAmtMax: item.solitaireAmtMax,
      metalType: item.metalType,
      metalPurity: item.metalPurity,
      metalColor: item.metalColor,
      metalWeight: item.metalWeight,
      metalPrice: item.metalPrice,
      mountAmtMin: item.mountAmtMin,
      mountAmtMax: item.mountAmtMax,
      sizeFrom: item.sizeFrom,
      sizeTo: item.sizeTo,
      sideStonePcs: item.sideStonePcs,
      sideStoneCts: item.sideStoneCts,
      sideStoneColor: item.sideStoneColor,
      sideStoneQuality: item.sideStoneQuality,
      orderRemarks: item.orderRemarks,
      style: item.style,
      wearStyle: item.wearStyle,
      look: item.look,
      portfolioType: item.portfolioType,
      gender: item.gender,
      customerName: item.customerName,
      productCode: item.productCode,
      imageUrl: item.imageUrl,
    );

    // local update
    _cartData[index] = updated;
    state = AsyncData(_cartData);

    try {
      await _editCart(updated);
    } catch (e) {
      debugPrint('Engraving text error: $e');
    }
  }

  // CUSTOMER SEARCH

  Future<List<CustomerDetail>> searchCustomer(String value) async {
    final query = value.trim();
    if (query.isEmpty) return [];

    final res = await dio.get(
      '${ApiEndPoint.customerSearch}find', // base path + "find"
      queryParameters: {
        'value': query, // => ?value=<query>
      },
    );

    final data = res.data['data'] as List<dynamic>? ?? [];

    final list = data
        .map((e) => CustomerDetail.fromJson(e as Map<String, dynamic>))
        .toList();

    return list;
  }
}
