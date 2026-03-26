import 'dart:convert';

import 'package:divine_pos/constants/tax_constants.dart';
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

final selectedCustomerProvider =
    NotifierProvider<SelectedCustomerNotifier, CustomerDetail?>(
      SelectedCustomerNotifier.new,
    );

class SelectedCustomerNotifier extends Notifier<CustomerDetail?> {
  @override
  CustomerDetail? build() => null;

  void setCustomer(CustomerDetail? customer) => state = customer;
  void clear() => state = null;
}

final lastCustomerProvider = Provider<CustomerDetail?>((ref) {
  return ref
      .watch(cartNotifierProvider)
      .maybeWhen(
        data: (cart) {
          if (cart.isEmpty) return null;
          final last = cart.last;
          //debugPrint();
          // debugPrint(
          //   'Customer Name : ${last.end_customer_name} Customer Id : ${last.end_customer_id}',
          // );
          //return CustomerDetail(id: last.customerId, name: last.customerName); // old
          return CustomerDetail(
            id: last.end_customer_id,
            name: last.end_customer_name,
          );
        },
        orElse: () => null,
      );
});

final filteredCartProvider = Provider<List<CartDetail>>((ref) {
  final cartAsync = ref.watch(cartNotifierProvider);
  final selected = ref.watch(selectedCustomerProvider);
  final last = ref.watch(lastCustomerProvider);

  return cartAsync.maybeWhen(
    data: (cart) {
      final customerId = selected?.id ?? last?.id;
      if (customerId == null) return [];
      return cart.where((e) => e.end_customer_id == customerId).toList();
    },
    orElse: () => [],
  );
});

class CartNotifier extends AsyncNotifier<List<CartDetail>> {
  List<CartDetail> _cartData = [];
  List<int> _selectedItems = [];
  String _orderSummaryRemark = '';
  String _errorMsg = '';
  String? _currentUser;

  static const int maxEngravingWords = 10;

  Dio get dio => ref.read(httpClientProvider);

  @override
  Future<List<CartDetail>> build() async {
    final auth = ref.read(authProvider);
    _currentUser = auth.user?.userName;

    if (_currentUser?.isEmpty ?? true) {
      _cartData = [];
      _orderSummaryRemark = '';
      return _cartData;
    }

    return _fetchCart(_currentUser!);
  }

  // ==================== API CALLS ====================

  Future<List<CartDetail>> _fetchCart(String user) async {
    //debugPrint('Current User : $user');
    try {
      final response = await dio.post(
        ApiEndPoint.cart_list,
        data: {'username': user},
      );

      //longPrint("📦 Fetched Data: ${jsonEncode(response.data)}");

      if (response.statusCode == 200) {
        final res = response.data;
        _cartData = (res['data'] as List<dynamic>? ?? [])
            .map((e) => CartDetail.fromJson(e as Map<String, dynamic>))
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

  Future<void> _editCart(CartDetail item) async {
    try {
      await dio.put(ApiEndPoint.update_cart, data: item.toJson());
    } on DioException {
      rethrow;
    }
  }

  // ==================== PUBLIC GETTERS ====================

  List<int> get selectedItems => _selectedItems;
  String get orderSummaryRemark => _orderSummaryRemark;
  String get errorMsg => _errorMsg;

  List<CustomerDetail> get cartCustomers {
    final map = <int, CustomerDetail>{};
    for (final item in _cartData) {
      final id = item.customerId;
      final name = item.customerName;
      if (id != null && name?.isNotEmpty == true) {
        map[id] = CustomerDetail(
          id: id,
          name: name!,
          address: '',
          contactNo: '',
          pan: '',
          gender: '',
          dob: '',
          pincode: '',
          email: '',
        );
      }
    }
    return map.values.toList();
  }

  // ==================== CART OPERATIONS ====================

  Future<void> createCart(CartDetail item) async {
    final current = state.value ?? _cartData;
    _cartData = [...current, item];
    state = AsyncData(_cartData);

    try {
      final res = await dio.post(
        ApiEndPoint.create_cart,
        data: [item.toJson()],
      );
      if (res.data['success'] != true) throw Exception(res.data['msg']);
    } catch (e, st) {
      _cartData = current;
      state = AsyncError(e, st);
      rethrow;
    }
  }

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

  Future<void> refresh(String user) async {
    _currentUser = user;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchCart(user));
  }

  // ==================== SELECTION ====================

  void toggleSelectAll() {
    final allSelected = _selectedItems.length == _cartData.length;
    _selectedItems = allSelected
        ? []
        : _cartData.map((e) => e.id ?? 0).where((id) => id > 0).toList();
    state = AsyncData(_cartData);
  }

  void toggleItem(int id) {
    _selectedItems.contains(id)
        ? _selectedItems.remove(id)
        : _selectedItems.add(id);
    state = AsyncData(_cartData);
  }

  // ==================== QUANTITY ====================

  Future<void> updateQuantity(int id, bool increase) async {
    final list = state.value ?? const <CartDetail>[];
    final index = list.indexWhere((e) => e.id == id);
    if (index == -1) return;

    final item = list[index];
    final oldQty = item.productQty ?? 1;
    final newQty = increase ? oldQty + 1 : (oldQty > 1 ? oldQty - 1 : 1);
    final unitMin = (item.productAmtMin ?? 0) / (oldQty == 0 ? 1 : oldQty);
    final unitMax = (item.productAmtMax ?? 0) / (oldQty == 0 ? 1 : oldQty);

    final updated = item.copyWith(
      productQty: newQty,
      productAmtMin: unitMin * newQty,
      productAmtMax: unitMax * newQty,
    );

    final updatedList = [...list]..[index] = updated;
    state = AsyncData(updatedList);

    try {
      await _editCart(updated);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  // ==================== ENGRAVING ====================

  Future<void> toggleEngraving(int id, bool enabled) async {
    final list = state.value ?? const <CartDetail>[];
    final index = list.indexWhere((e) => e.id == id);
    if (index == -1) return;

    final item = list[index];

    // ✅ Empty string when enabled with no prior text (not 'Engraving')
    final newEngraving = enabled
        ? ((item.engraving?.trim().isNotEmpty ?? false) ? item.engraving! : '')
        : '';

    final updated = item.copyWith(engraving: newEngraving);
    final updatedList = [...list]..[index] = updated;
    state = AsyncData(updatedList);

    try {
      await _editCart(updated);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> updateEngravingText(int id, String text) async {
    final list = state.value ?? _cartData;
    final index = list.indexWhere((e) => e.id == id);
    if (index == -1) return;

    final words = text.trim().split(RegExp(r'\s+'));
    if (words.length > maxEngravingWords) return;

    final updated = list[index].copyWith(engraving: text);
    final updatedList = [...list]..[index] = updated;
    _cartData = updatedList;
    state = AsyncData(updatedList);

    try {
      await _editCart(updated);
    } catch (e) {
      debugPrint('Engraving text error: $e');
    }
  }

  // ==================== CHECKOUT ====================

  Future<Map<String, dynamic>> proceedToCheckout(
    List<CartDetail> items,
    double engravingCostTotal,
    double engravingGstPer,
    double engravingGstAmtTotal,
    double gstPer,
    double productTaxAmtTotal,
    double grandTotal,
  ) async {
    if (items.isEmpty) {
      _errorMsg = 'Please select at least one item';
      return {'success': false, 'msg': _errorMsg};
    }

    final latestCart = state.value ?? _cartData;
    final selected = latestCart
        .where((e) => items.map((i) => i.id).contains(e.id))
        .toList();

    final List<Map<String, dynamic>> engravingAndTax = [];

    for (final item in selected) {
      final baseAmt = item.productAmtMax ?? item.productAmtMin ?? 0;
      final lineBase = baseAmt * (item.productQty ?? 1);

      final hasEngraving = item.engraving?.trim().isNotEmpty ?? false;
      final lineEngravingCost = hasEngraving
          ? TaxConstants.engravingCostPerItem
          : 0.0;
      final lineEngravingTaxAmt = TaxConstants.calculateEngravingGst(
        lineEngravingCost,
      );
      final lineProductTaxAmt = TaxConstants.calculateGst(lineBase);
      final lineNetAmt =
          lineBase +
          lineEngravingCost +
          lineEngravingTaxAmt +
          lineProductTaxAmt;

      final updated = item.copyWith(
        engraving: item.engraving,
        engraving_cost: lineEngravingCost,
        engraving_taxper: TaxConstants.engravingGstPercent,
        engraving_taxamt: lineEngravingTaxAmt,
        product_taxper: TaxConstants.gstPercent,
        product_taxamt: lineProductTaxAmt,
        product_netamt: lineNetAmt,
      );

      final idx = _cartData.indexWhere((e) => e.id == item.id);
      if (idx != -1) _cartData[idx] = updated;

      engravingAndTax.add({
        'id': item.id,
        'engraving': updated.engraving,
        'engraving_cost': updated.engraving_cost,
        'engraving_taxper': updated.engraving_taxper,
        'engraving_taxamt': updated.engraving_taxamt,
        'product_taxper': updated.product_taxper,
        'product_taxamt': updated.product_taxamt,
        'product_netamt': updated.product_netamt,
      });
    }

    final ids = selected.map((e) => e.id).whereType<int>().toList();
    state = const AsyncLoading();

    debugPrint('data : ${engravingAndTax}');

    try {
      final response = await dio.post(
        ApiEndPoint.create_order,
        data: {'ids': ids, 'engraving_and_tax': engravingAndTax},
      );

      if ((response.data['msg'] ?? '').toString().toLowerCase() == 'sucess') {
        _cartData.removeWhere((item) => ids.contains(item.id));
        _selectedItems.removeWhere(ids.contains);
        state = AsyncData(_cartData);
        return {'success': true, 'data': response.data};
      }

      return {'success': false, 'msg': response.data['msg'] ?? 'Failed'};
    } catch (e) {
      _errorMsg = e.toString();
      state = AsyncError(e, StackTrace.current);
      return {'success': false, 'msg': _errorMsg};
    }
  }

  // ==================== CUSTOMER ====================

  Future<List<CustomerDetail>> searchCustomer(String value) async {
    final query = value.trim();
    if (query.isEmpty) return [];

    try {
      final res = await dio.get(
        '${ApiEndPoint.customerSearch}find',
        queryParameters: {'value': query},
      );
      return (res.data['data'] as List<dynamic>? ?? [])
          .map((e) => CustomerDetail.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Customer search error: $e');
      return [];
    }
  }

  Future<CustomerDetail?> getCustomerDetailValue(String value) async {
    final query = value.trim();
    if (query.isEmpty) return null;

    try {
      final res = await dio.get('${ApiEndPoint.customerSearch}$query');
      final data = res.data['data'];
      if (data == null) return null;
      return CustomerDetail.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      debugPrint('Customer search error: $e');
      return null;
    }
  }

  Future<CustomerDetail> createCustomer({
    required String name,
    required String mobile,
  }) async {
    final res = await dio.post(
      ApiEndPoint.create_customer,
      data: {'name': name, 'contactno': mobile},
    );

    final body = res.data as Map<String, dynamic>;
    if (body['success'] != true) {
      throw Exception(body['msg'] ?? 'Customer create failed');
    }

    final id = body['id'] as int?;
    if (id == null) throw Exception('No id returned from API');

    return CustomerDetail(
      id: id,
      name: name,
      address: '',
      contactNo: mobile,
      pan: '',
      gender: '',
      dob: '',
      pincode: '',
      email: '',
    );
  }

  Future<void> updateCustomerMobile({
    required int customerId,
    required String mobile,
  }) async {
    final selected = ref.read(selectedCustomerProvider);
    if (selected == null || selected.id != customerId) return;

    ref
        .read(selectedCustomerProvider.notifier)
        .setCustomer(selected.copyWith(contactNo: mobile));

    try {
      await dio.post(
        ApiEndPoint.update_customer,
        data: {'id': customerId, 'contactno': mobile},
      );
    } catch (e) {
      debugPrint('Update customer error: $e');
      rethrow;
    }
  }

  List<CartDetail> getItemsForCustomer(int customerId) =>
      _cartData.where((e) => e.customerId == customerId).toList();

  void longPrint(Object? obj) {
    const chunkSize = 800;
    final str = obj.toString();
    for (var i = 0; i < str.length; i += chunkSize) {
      final end = (i + chunkSize < str.length) ? i + chunkSize : str.length;
      debugPrint(str.substring(i, end));
    }
  }
}
