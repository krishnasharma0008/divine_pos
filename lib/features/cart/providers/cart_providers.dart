import 'dart:async';
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
  final cartAsync = ref.watch(cartNotifierProvider);

  return cartAsync.maybeWhen(
    data: (cart) {
      if (cart.isEmpty) return null;
      final last = cart.last;
      return CustomerDetail(id: last.customerId, name: last.customerName);
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
      return cart.where((e) => e.customerId == customerId).toList();
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
    try {
      final response = await dio.post(
        ApiEndPoint.cart_list,
        data: {'username': user},
      );

      if (response.statusCode == 200) {
        final res = response.data;
        final rawList = res['data'] as List<dynamic>? ?? [];

        _cartData = rawList
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
    //debugPrint('Editing cart item: ${item.toJson()}');
    //print('Editing cart item: ${item.toJson()}');
    // debugPrint('engraving in payload: "${item.engraving}"'); // ← just this
    // debugPrint('toJson engraving: ${item.toJson()['engraving']}'); // ← and this
    final json = item.toJson().toString();
    for (int i = 0; i < json.length; i += 800) {
      debugPrint(
        json.substring(i, i + 800 > json.length ? json.length : i + 800),
      );
    }
    try {
      await dio.put(ApiEndPoint.update_cart, data: item.toJson());
    } on DioException {
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

  // ==================== PUBLIC GETTERS ====================

  List<int> get selectedItems => _selectedItems;
  String get orderSummaryRemark => _orderSummaryRemark;
  String get errorMsg => _errorMsg;
  Map<String, dynamic> get totals => _calculateTotals();

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

    // ✅ optimistic update
    final updated = [...current, item];
    _cartData = updated;
    state = AsyncData(updated);

    debugPrint('Creating cart item: ${item.toJson()}');

    try {
      final res = await dio.post(
        ApiEndPoint.create_cart,
        data: [item.toJson()],
      );

      if (res.data['success'] != true) {
        throw Exception(res.data['msg']);
      }

      // ✅ DONE
      // don't modify state again
    } catch (e, st) {
      // rollback only if API fails
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
    if (_selectedItems.contains(id)) {
      _selectedItems.remove(id);
    } else {
      _selectedItems.add(id);
    }
    state = AsyncData(_cartData);
  }

  // ==================== QUANTITY UPDATE ====================

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

    // Optimistic update
    final updatedList = [...list];
    updatedList[index] = updated;
    state = AsyncData(updatedList);

    try {
      await _editCart(updated);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  // ==================== ENGRAVING ====================

  bool isEngravingEnabled(int id) {
    final item = _cartData.firstWhere(
      (e) => e.id == id,
      orElse: () => throw Exception('Item not found'),
    );
    return (item.engraving?.trim().isNotEmpty ?? false);
  }

  String getEngravingText(int id) {
    final item = _cartData.firstWhere(
      (e) => e.id == id,
      orElse: () => throw Exception('Item not found'),
    );
    return item.engraving ?? '';
  }

  Future<void> toggleEngraving(int id, bool enabled) async {
    final list = state.value ?? const <CartDetail>[];
    final index = list.indexWhere((e) => e.id == id);
    if (index == -1) return;

    final item = list[index];

    debugPrint('BEFORE copyWith: engraving="${item.engraving}"');

    final newEngraving = enabled
        ? ((item.engraving?.trim().isNotEmpty ?? false)
              ? item.engraving!
              : 'Engraving')
        : '';

    final updated = item.copyWith(engraving: newEngraving);

    debugPrint('AFTER copyWith: engraving="${updated.engraving}"');

    final updatedList = [...list];
    updatedList[index] = updated;

    state = AsyncData(updatedList);

    debugPrint(
      'Toggling engraving for item $id to ${enabled ? 'enabled' : 'disabled'}',
    );
    debugPrint('Updated List: "$updated"');

    try {
      await _editCart(updated);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> updateEngravingText(int id, String text) async {
    final list =
        state.value ?? _cartData; // ← use state.value like updateQuantity
    final index = list.indexWhere((e) => e.id == id);
    if (index == -1) return;

    final words = text.trim().split(RegExp(r'\s+'));
    if (words.length > maxEngravingWords) return;

    final updated = list[index].copyWith(engraving: text);
    final updatedList = [...list];
    updatedList[index] = updated;

    _cartData = updatedList; // keep in sync
    state = AsyncData(updatedList);

    try {
      await _editCart(updated);
    } catch (e) {
      debugPrint('Engraving text error: $e');
    }
  }

  void debugEngraving(int id) {
    final item = _cartData.firstWhere(
      (e) => e.id == id,
      orElse: () => throw Exception('Item not found'),
    );
    debugPrint('engraving for $id: "${item.engraving}"');
  }

  // ==================== CHECKOUT ====================

  // Future<Map<String, dynamic>> proceedToCheckout(List<CartDetail> items) async {
  //   // debugPrint(
  //   //   "Starting checkout with selected items: ${items.map((e) => e.id)}",
  //   // );

  //   if (items.isEmpty) {
  //     _errorMsg = 'Please select at least one item';
  //     return {'success': false, 'msg': _errorMsg};
  //   }

  //   // items is already List<CartDetail> for this customer; just use that
  //   final selected = items;

  //   //debugPrint("Selected items for checkout: ${selected.map((e) => e.id)}");

  //   if (selected.map((e) => e.customerName).toSet().length != 1) {
  //     _errorMsg = 'Only one partner jeweller allowed';
  //     return {'success': false, 'msg': _errorMsg};
  //   }

  //   // 1) per‑item tax calculation + local update + API update
  //   for (final item in selected) {
  //     final baseAmt = (item.productAmtMax ?? item.productAmtMin ?? 0);
  //     final qty = item.productQty ?? 1;
  //     final lineBase = baseAmt * qty;

  //     // engraving per item based on engraving text
  //     final hasEngraving = item.engraving?.trim().isNotEmpty ?? false;
  //     final lineEngravingCost = hasEngraving
  //         ? TaxConstants.engravingCostPerItem
  //         : 0.0;
  //     final lineEngravingTaxPer = TaxConstants.engravingGstPercent;
  //     final lineEngravingTaxAmt = TaxConstants.calculateEngravingGst(
  //       lineEngravingCost,
  //     );

  //     // product tax per line
  //     final lineProductTaxPer = TaxConstants.gstPercent;
  //     final lineProductTaxAmt = TaxConstants.calculateGst(lineBase);

  //     // net amount = base + engraving + both taxes
  //     final lineNetAmt =
  //         lineBase +
  //         lineEngravingCost +
  //         lineEngravingTaxAmt +
  //         lineProductTaxAmt;

  //     final updated = item.copyWith(
  //       // id stays same, no need to pass
  //       engraving_cost: lineEngravingCost,
  //       engraving_taxper: lineEngravingTaxPer,
  //       engraving_taxamt: lineEngravingTaxAmt,
  //       product_taxper: lineProductTaxPer,
  //       product_taxamt: lineProductTaxAmt,
  //       product_netamt: lineNetAmt,
  //     );

  //     //debugPrint("working ");
  //     final idx = _cartData.indexWhere((e) => e.id == item.id);
  //     if (idx != -1) {
  //       _cartData[idx] = updated;
  //     }

  //     //debugPrint("data to be updated : ${updated.toJson()}");

  //     try {
  //       await _editCart(updated);
  //     } catch (e) {
  //       debugPrint('Cart tax update error for item ${item.id}: $e');
  //     }
  //   }

  //   // 2) अब order create करो – still use ids from selected items
  //   final ids = selected.map((e) => e.id).whereType<int>().toList();
  //   state = const AsyncLoading();
  //   try {
  //     final response = await _createOrder(ids);

  //     if ((response['msg'] ?? '').toLowerCase() == 'sucess') {
  //       _cartData.removeWhere((item) => ids.contains(item.id));
  //       _selectedItems.removeWhere(ids.contains);
  //       state = AsyncData(_cartData);
  //       return {'success': true, 'data': response};
  //     }

  //     return {'success': false, 'msg': response['msg'] ?? 'Failed'};
  //   } catch (e) {
  //     _errorMsg = e.toString();
  //     state = AsyncError(e, StackTrace.current);
  //     return {'success': false, 'msg': _errorMsg};
  //   }
  // }

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

    // per-item calculations + local update
    final List<Map<String, dynamic>> engravingAndTax = [];

    for (final item in selected) {
      //debugPrint('checkout item ${item.id} engraving="${item.engraving}"');
      final baseAmt = (item.productAmtMax ?? item.productAmtMin ?? 0);
      final qty = item.productQty ?? 1;
      final lineBase = baseAmt * qty;

      final hasEngraving = item.engraving?.trim().isNotEmpty ?? false;
      final lineEngravingCost = hasEngraving
          ? TaxConstants.engravingCostPerItem
          : 0.0;
      final lineEngravingTaxPer = TaxConstants.engravingGstPercent;
      final lineEngravingTaxAmt = TaxConstants.calculateEngravingGst(
        lineEngravingCost,
      );

      final lineProductTaxPer = TaxConstants.gstPercent;
      final lineProductTaxAmt = TaxConstants.calculateGst(lineBase);

      final lineNetAmt =
          lineBase +
          lineEngravingCost +
          lineEngravingTaxAmt +
          lineProductTaxAmt;

      final updated = item.copyWith(
        engraving: item.engraving,
        engraving_cost: lineEngravingCost,
        engraving_taxper: lineEngravingTaxPer,
        engraving_taxamt: lineEngravingTaxAmt,
        product_taxper: lineProductTaxPer,
        product_taxamt: lineProductTaxAmt,
        product_netamt: lineNetAmt,
      );

      final idx = _cartData.indexWhere((e) => e.id == item.id);
      if (idx != -1) {
        _cartData[idx] = updated;
      }

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
    //debugPrint("Ids: $ids");
    //debugPrint('engravingAndTax: $engravingAndTax');
    state = const AsyncLoading();
    try {
      final response = await dio.post(
        ApiEndPoint.create_order, // or your new endpoint
        data: {'ids': ids, 'engraving_and_tax': engravingAndTax},
      );

      //debugPrint("Response ${response.data}");
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

  // ==================== CUSTOMER OPERATIONS ====================

  Future<List<CustomerDetail>> searchCustomer(String value) async {
    final query = value.trim();
    if (query.isEmpty) return [];

    try {
      final res = await dio.get(
        '${ApiEndPoint.customerSearch}find',
        queryParameters: {'value': query, 'useronly': 1},
      );

      final data = res.data['data'] as List<dynamic>? ?? [];
      return data
          .map((e) => CustomerDetail.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Customer search error: $e');
      return [];
    }
  }

  Future<CustomerDetail> createCustomer({
    required String name,
    required String mobile,
  }) async {
    final res = await dio.post(
      ApiEndPoint.create_customer,
      data: {'name': name, 'mobile': mobile},
    );

    final body = res.data as Map<String, dynamic>;

    if (body['success'] != true) {
      throw Exception(body['msg'] ?? 'Customer create failed');
    }

    final id = body['id'] as int?;
    if (id == null) {
      throw Exception('No id returned from API');
    }

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
    try {
      await dio.put(
        ApiEndPoint.update_customer, // अपना endpoint
        data: {'id': customerId, 'mobile': mobile},
      );
    } catch (e) {
      debugPrint('Update customer error: $e');
      rethrow;
    }
  }

  List<CartDetail> getItemsForCustomer(int customerId) {
    return _cartData.where((e) => e.customerId == customerId).toList();
  }

  // ==================== CALCULATIONS ====================

  Map<String, dynamic> _calculateTotals() {
    final selected = _cartData
        .where((item) => _selectedItems.contains(item.id))
        .toList();

    return {
      'totalQty': selected.fold<int>(
        0,
        (sum, item) => sum + (item.productQty ?? 0),
      ),
      'totalAmtMin': selected.fold<double>(
        0,
        (sum, item) => sum + (item.productAmtMin ?? 0),
      ),
      'totalAmtMax': selected.fold<double>(
        0,
        (sum, item) => sum + (item.productAmtMax ?? 0),
      ),
    };
  }
}
