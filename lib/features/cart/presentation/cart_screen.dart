import 'dart:async';
import 'dart:math';
import 'package:divine_pos/shared/routes/route_pages.dart';
import 'package:divine_pos/shared/widgets/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/app_bar.dart';
import '../../../shared/utils/enums.dart';
import '../../../shared/utils/scale_size.dart';
import '../data/cart_detail_model.dart';
import '../providers/cart_providers.dart';
import 'cart_item_card.dart';
import '../../auth/data/auth_notifier.dart';
import '../data/customer_detail_model.dart';
import '../presentation/cart_summary.dart';
import '../presentation/mobile_number_dialog.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  @override
  void initState() {
    super.initState();
    _initializeCart();
  }

  Future<void> _initializeCart() async {
    await Future.microtask(() async {
      final user = ref.read(authProvider).user?.userName;

      if (user?.isNotEmpty ?? false) {
        await ref.read(cartNotifierProvider.notifier).refresh(user!);

        final lastCustomer = ref.read(lastCustomerProvider);
        if (lastCustomer != null && lastCustomer.id != null) {
          final full = await ref
              .read(cartNotifierProvider.notifier)
              .getCustomerDetailValue(lastCustomer.id!.toString());

          final chosen = full ?? lastCustomer;

          ref.read(selectedCustomerProvider.notifier).setCustomer(chosen);
        }
      } else {
        ref.invalidate(cartNotifierProvider);
      }
    });
  }

  double _calculateSubtotal(List<CartDetail> items) {
    return items.fold(0.0, (total, item) {
      //final amount = item.productAmtMax ?? item.productAmtMin ?? 0;
      final max = item.productAmtMax;
      final min = item.productAmtMin;

      // if max is null or 0, use min; otherwise use max
      final amount = (max != null && max != 0) ? max : (min ?? 0);
      final quantity = item.productQty ?? 1;
      double lineTotal = amount * quantity;

      if (item.engraving?.trim().isNotEmpty ?? false) {
        lineTotal += 1000;
      }

      return total + lineTotal;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartAsync = ref.watch(cartNotifierProvider);
    final fem = ScaleSize.aspectRatio;

    return cartAsync.when(
      loading: () => const Scaffold(
        backgroundColor: Color(0xFFE7F7F4),
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: const Color(0xFFE7F7F4),
        body: Center(child: Text('Error loading cart')),
      ),
      data: (cart) {
        if (cart.isEmpty) {
          return const _EmptyCartView();
        }

        final items = ref.watch(filteredCartProvider);
        final activeCustomer =
            ref.watch(selectedCustomerProvider) ??
            ref.watch(lastCustomerProvider);

        //debugPrint('Last customer Details : name=${activeCustomer?.name}');

        final orderProducts = items
            .where((e) => e.productCode == e.designno)
            .toList();
        final readyProducts = items
            .where((e) => e.productCode != e.designno)
            .toList();
        final subtotal = _calculateSubtotal(items);

        return Scaffold(
          backgroundColor: const Color(0xFFE7F7F4),
          appBar: MyAppBar(appBarLeading: AppBarLeading.back, showLogo: false),
          body: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Fixed header — never scrolls
                CartHeader(customerName: activeCustomer?.name ?? ''),

                // Only cart items scroll
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.only(bottom: 24 * fem),
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          72 * fem,
                          8 * fem,
                          24 * fem,
                          0,
                        ),
                        child: MyText(
                          'Shopping Cart (${items.length})',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Montserrat',
                              ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 52 * fem),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1194),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _Section(
                                  title: 'Order Products',
                                  items: orderProducts,
                                  fem: fem,
                                ),
                                _Section(
                                  title: 'Ready Products',
                                  items: readyProducts,
                                  fem: fem,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: SafeArea(
            top: false,
            child: _BottomProceedBar(
              orderProducts: orderProducts,
              readyProducts: readyProducts,
              subtotal: subtotal,
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// CartHeader
// ---------------------------------------------------------------------------

class CartHeader extends StatelessWidget {
  final String customerName;

  const CartHeader({super.key, required this.customerName});

  @override
  Widget build(BuildContext context) {
    final fem = ScaleSize.aspectRatio;

    return Column(
      children: [
        SizedBox(height: 24 * fem),
        _buildStepper(fem),
        SizedBox(height: 24 * fem),
        SearchCurrentCartRow(fem: fem, cartCustomer: customerName),
        SizedBox(height: 24 * fem),
      ],
    );
  }

  Widget _buildStepper(double fem) {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 32 * fem, vertical: 12 * fem),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30 * fem),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _StepPill(label: 'Shopping Cart', index: 1, active: true, fem: fem),
            _StepDivider(fem: fem),
            _StepPill(
              label: 'Customer Feedback',
              index: 2,
              active: false,
              fem: fem,
            ),
            _StepDivider(fem: fem),
            _StepPill(
              label: 'Sales Executive Form',
              index: 3,
              active: false,
              fem: fem,
            ),
          ],
        ),
      ),
    );
  }
}

class _StepPill extends StatelessWidget {
  final String label;
  final int index;
  final bool active;
  final double fem;

  const _StepPill({
    required this.label,
    required this.index,
    required this.active,
    required this.fem,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 12 * fem,
          backgroundColor: active
              ? const Color(0xFF6CC6B4)
              : const Color(0xFFE5E7EB),
          child: MyText(
            '$index',
            style: TextStyle(
              fontSize: 12 * fem,
              color: active ? Colors.white : const Color(0xFF6B7280),
            ),
          ),
        ),
        SizedBox(width: 6 * fem),
        MyText(
          label,
          style: TextStyle(
            fontSize: 13 * fem,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF111827),
          ),
        ),
      ],
    );
  }
}

class _StepDivider extends StatelessWidget {
  final double fem;

  const _StepDivider({required this.fem});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60 * fem,
      height: 2 * fem,
      margin: EdgeInsets.symmetric(horizontal: 16 * fem),
      color: const Color(0xFFD1FAE5),
    );
  }
}

// ---------------------------------------------------------------------------
// SearchCurrentCartRow  ✅ overflow fix applied
// ---------------------------------------------------------------------------

class SearchCurrentCartRow extends ConsumerStatefulWidget {
  final double fem;
  final String cartCustomer;

  const SearchCurrentCartRow({
    super.key,
    required this.fem,
    required this.cartCustomer,
  });

  @override
  ConsumerState<SearchCurrentCartRow> createState() =>
      _SearchCurrentCartRowState();
}

class _SearchCurrentCartRowState extends ConsumerState<SearchCurrentCartRow> {
  final _controller = TextEditingController();
  Timer? _debounce;
  bool _showSuggestions = false;
  bool _loading = false;
  List<CustomerDetail> _results = [];

  static const _searchDebounceMs = 350;
  static const _maxSuggestionsHeight = 160.0;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onChanged(String value) async {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: _searchDebounceMs),
      () async {
        final query = value.trim();

        if (query.isEmpty) {
          setState(() {
            _results = [];
            _showSuggestions = false;
            _loading = false;
          });
          return;
        }

        setState(() => _loading = true);

        try {
          final results = await ref
              .read(cartNotifierProvider.notifier)
              .searchCustomer(query);

          if (mounted) {
            setState(() {
              _results = results;
              _showSuggestions = results.isNotEmpty;
            });
          }
        } catch (e) {
          if (mounted) {
            setState(() {
              _results = [];
              _showSuggestions = false;
            });
          }
        } finally {
          if (mounted) {
            setState(() => _loading = false);
          }
        }
      },
    );
  }

  void _onCustomerTap(CustomerDetail customer) {
    FocusScope.of(context).unfocus();
    ref.read(selectedCustomerProvider.notifier).setCustomer(customer);

    _controller.clear();
    setState(() {
      _results = [];
      _showSuggestions = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final fem = widget.fem;

    return Center(
      child: SizedBox(
        width: 560 * fem,
        // ✅ No fixed height — Column grows naturally to fit field + suggestions
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Stack only holds search field + badge — no suggestions inside
            SizedBox(
              height: 54 * fem,
              child: Stack(
                clipBehavior: Clip.none,
                children: [_buildSearchField(fem), _buildCurrentCartBadge(fem)],
              ),
            ),
            // ✅ Suggestions in normal flow below — zero overflow risk
            if (_showSuggestions && _results.isNotEmpty) _buildSuggestions(fem),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField(double fem) {
    return Positioned.fill(
      child: Align(
        alignment: Alignment.topLeft,
        child: Container(
          width: 560 * fem,
          height: 54 * fem,
          padding: EdgeInsets.symmetric(horizontal: 16 * fem),
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              side: const BorderSide(width: 1, color: Color(0xFFBEE4DD)),
              borderRadius: BorderRadius.circular(15 * fem),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.search,
                size: 18 * fem,
                color: const Color(0xFF6C6C6C),
              ),
              SizedBox(width: 8 * fem),
              Expanded(
                child: TextField(
                  controller: _controller,
                  onChanged: _onChanged,
                  decoration: const InputDecoration(
                    isCollapsed: true,
                    border: InputBorder.none,
                    hintText: 'Search customer here...',
                  ),
                  style: TextStyle(
                    fontSize: 16 * fem,
                    fontFamily: 'Rushter Glory',
                    color: const Color(0xFF6C6C6C),
                  ),
                ),
              ),
              if (_loading)
                SizedBox(
                  width: 18 * fem,
                  height: 18 * fem,
                  child: const CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentCartBadge(double fem) {
    return Positioned(
      right: 0,
      top: -2 * fem,
      child: Container(
        width: 222 * fem,
        height: 58 * fem,
        padding: EdgeInsets.symmetric(horizontal: 23 * fem, vertical: 8 * fem),
        decoration: ShapeDecoration(
          color: const Color(0xFFBEE4DD),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18 * fem),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.person,
                  size: 20 * fem,
                  color: const Color(0xFF5E5E5E),
                ),
                SizedBox(width: 10 * fem),
                Flexible(
                  child: MyText(
                    widget.cartCustomer,
                    style: TextStyle(
                      color: const Color(0xFF5E5E5E),
                      fontSize: 13 * fem,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 2 * fem),
            MyText(
              '(Current cart)',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFF5E5E5E),
                fontSize: 10 * fem,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w400,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestions(double fem) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      constraints: BoxConstraints(maxHeight: _maxSuggestionsHeight * fem),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8 * fem),
        border: Border.all(color: const Color(0xFFDDDDDD)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListView.separated(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        itemCount: _results.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final customer = _results[index];
          return InkWell(
            onTap: () => _onCustomerTap(customer),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 12 * fem,
                vertical: 10 * fem,
              ),
              child: Text(
                customer.name ?? 'Unknown',
                style: TextStyle(fontSize: 14 * fem, fontFamily: 'Montserrat'),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _Section
// ---------------------------------------------------------------------------

class _Section extends ConsumerWidget {
  final String title;
  final List<CartDetail> items;
  final double fem;

  const _Section({required this.title, required this.items, required this.fem});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (items.isEmpty) return const SizedBox.shrink();

    final notifier = ref.read(cartNotifierProvider.notifier);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16 * fem),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 22 * fem),
            child: MyText(
              title,
              style: TextStyle(
                color: const Color(0xFF0A0A0A),
                fontSize: 16 * fem,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w400,
                height: 2.25,
              ),
            ),
          ),
          SizedBox(height: 8 * fem),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, __) => Container(
              width: 1049 * fem,
              height: 1 * fem,
              margin: EdgeInsets.symmetric(horizontal: 24 * fem),
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    width: 0.50 * fem,
                    color: const Color(0xFFDADADC),
                  ),
                ),
              ),
            ),
            itemBuilder: (context, index) {
              final item = items[index];
              return CartItemCard(
                item: item,
                onDelete: () => notifier.deleteItem(item.id ?? 0),
                isTopRounded: index == 0,
                isBottomRounded: index == items.length - 1,
              );
            },
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _BottomProceedBar
// ---------------------------------------------------------------------------

class _BottomProceedBar extends ConsumerWidget {
  final List<CartDetail> orderProducts;
  final List<CartDetail> readyProducts;
  final double subtotal;

  const _BottomProceedBar({
    required this.orderProducts,
    required this.readyProducts,
    required this.subtotal,
  });

  Future<void> _handleProceed(
    BuildContext context,
    WidgetRef ref, {
    required double engravingCost,
    required double engravingGst,
    required double engravingtaxamt,
    required double gst,
    required double productTaxAmt,
    required double grandTotal,
    required List<CartDetail> items,
  }) async {
    final router = GoRouter.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final selected = ref.read(selectedCustomerProvider);

    final phone = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => MobileNumberDialog(
        initialMobile: selected?.contactNo ?? '',
        custname: selected?.name ?? '',
      ),
    );

    if (phone != null) {
      print('Submitted phone: $phone');
    } else {
      print('Dialog closed');
    }

    if (phone != null && phone.isNotEmpty) {
      if (selected != null && selected.id != null) {
        await ref
            .read(cartNotifierProvider.notifier)
            .updateCustomerMobile(customerId: selected.id!, mobile: phone);

        ref
            .read(selectedCustomerProvider.notifier)
            .setCustomer(selected.copyWith(contactNo: phone));

        final updated = ref.read(selectedCustomerProvider);
        debugPrint('After update: ${updated?.toJson()}');
      }
    }

    if (!context.mounted) return;

    final result = await ref
        .read(cartNotifierProvider.notifier)
        .proceedToCheckout(
          items,
          engravingCost,
          engravingGst,
          engravingtaxamt,
          gst,
          productTaxAmt,
          grandTotal,
        );

    debugPrint('checkout result: $result');

    final customer = selected;

    if (result['success'] == true) {
      final data = result['data'] as Map<String, dynamic>?;
      final infoList = data?['cart_to_order_info'] as List<dynamic>?;
      int? orderNo;
      if (infoList != null && infoList.isNotEmpty) {
        final first = infoList.first as Map<String, dynamic>;
        orderNo = first['orderno'] as int?;
      }

      router.pushNamed(
        RoutePages.feedbackform.routeName,
        extra: {'customer': customer, 'orderNo': orderNo},
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['msg'] ?? 'Checkout failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fem = ScaleSize.aspectRatio;

    return Container(
      height: 82 * fem,
      decoration: ShapeDecoration(
        color: const Color(0xFFBEE4DD),
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1 * fem, color: const Color(0xFF90DCD0)),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25 * fem),
            topRight: Radius.circular(25 * fem),
          ),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1194),
          child: Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: 258 * fem,
              height: 52 * fem,
              child: InkWell(
                borderRadius: BorderRadius.circular(20 * fem),
                onTap: () => showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (_) => CartSummaryPanel(
                    orderProducts: orderProducts,
                    readyProducts: readyProducts,
                    subtotal: subtotal,
                    onConfirm:
                        ({
                          required double engravingCost,
                          required double engravingGst,
                          required double engravingtaxamt,
                          required double gst,
                          required double productTaxAmt,
                          required double grandTotal,
                          required List<CartDetail> items,
                        }) {
                          _handleProceed(
                            context,
                            ref,
                            engravingCost: engravingCost,
                            engravingGst: engravingGst,
                            engravingtaxamt: engravingtaxamt,
                            gst: gst,
                            productTaxAmt: productTaxAmt,
                            grandTotal: grandTotal,
                            items: items,
                          );
                        },
                  ),
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 30 * fem,
                    vertical: 6 * fem,
                  ),
                  decoration: ShapeDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment(-0.00, 0.50),
                      end: Alignment(0.96, 1.12),
                      colors: [Color(0xFFBEE4DD), Color(0xA5D1B193)],
                    ),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 1 * fem,
                        color: const Color(0xFFACA584),
                      ),
                      borderRadius: BorderRadius.circular(20 * fem),
                    ),
                    shadows: [
                      BoxShadow(
                        color: const Color(0x7C000000),
                        blurRadius: 4 * fem,
                        offset: Offset(2 * fem, 2 * fem),
                      ),
                    ],
                  ),
                  child: Center(
                    child: MyText(
                      'Proceed',
                      style: TextStyle(
                        color: const Color(0xFF6C5022),
                        fontSize: 20 * fem,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _EmptyCartView
// ---------------------------------------------------------------------------

class _EmptyCartView extends StatelessWidget {
  const _EmptyCartView();

  @override
  Widget build(BuildContext context) {
    final fem = ScaleSize.aspectRatio;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: MyAppBar(appBarLeading: AppBarLeading.back, showLogo: false),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 180 * fem,
              height: 180 * fem,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Color(0xFFBEE4DD), Color(0xFFFFFFFF)],
                  stops: [0.0, 1.0],
                ),
              ),
              child: Icon(
                Icons.shopping_cart_outlined,
                size: 80 * fem,
                color: const Color(0xFF90DCD0),
              ),
            ),
            SizedBox(height: 28 * fem),
            Text(
              'Your cart is empty',
              style: TextStyle(
                fontSize: 22 * fem,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A2E),
              ),
            ),
            SizedBox(height: 10 * fem),
            Text(
              'Discover amazing products and start\nadding items to your cart today!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14 * fem,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w400,
                color: const Color(0xFF6B7280),
                height: 1.6,
              ),
            ),
            SizedBox(height: 32 * fem),
            TextButton(
              onPressed: () => context.pop(),
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF90DCD0),
                padding: EdgeInsets.symmetric(
                  horizontal: 40 * fem,
                  vertical: 14 * fem,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30 * fem),
                ),
              ),
              child: Text(
                'Start Shopping',
                style: TextStyle(
                  fontSize: 15 * fem,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
