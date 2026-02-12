import 'dart:async';
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

    // Optimistic update
    final tempList = [...current, item];
    _cartData = tempList;
    state = AsyncData(tempList);

    try {
      final res = await dio.post(ApiEndPoint.create_cart, data: item.toJson());
      final data = res.data['data'] as Map<String, dynamic>;
      final created = CartDetail.fromJson(data);

      // Replace with server version
      final updated = [...current, created];
      _cartData = updated;
      state = AsyncData(updated);
    } catch (e, st) {
      // Rollback on failure
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
    return (item.cartRemarks?.trim().isNotEmpty ?? false);
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
        ? ((item.cartRemarks?.trim().isNotEmpty ?? false)
              ? item.cartRemarks!
              : 'Engraving')
        : '';

    final updated = item.copyWith(cartRemarks: newRemarks);
    final updatedList = [...list];
    updatedList[index] = updated;

    state = AsyncData(updatedList);

    try {
      await _editCart(updated);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> updateEngravingText(int id, String text) async {
    final index = _cartData.indexWhere((e) => e.id == id);
    if (index == -1) return;

    final words = text.trim().split(RegExp(r'\s+'));
    if (words.length > maxEngravingWords) return;

    final item = _cartData[index];
    final updated = item.copyWith(cartRemarks: text);

    // Local update
    _cartData[index] = updated;
    state = AsyncData(_cartData);

    try {
      await _editCart(updated);
    } catch (e) {
      debugPrint('Engraving text error: $e');
    }
  }

  // ==================== CHECKOUT ====================

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
