import 'dart:async'; // for Timer
import 'package:divine_pos/shared/widgets/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/app_bar.dart';
import '../../../shared/utils/enums.dart';
import '../../../shared/utils/scale_size.dart';
import '../data/cart_detail_model.dart';
import '../providers/cart_providers.dart';
import 'cart_item_card.dart';
import '../../auth/data/auth_notifier.dart';
import '../data/customer_detail_model.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final auth = ref.read(authProvider);
      final user = auth.user?.userName;
      if (user != null && user.isNotEmpty) {
        await ref.read(cartNotifierProvider.notifier).refresh(user);
      } else {
        ref.invalidate(cartNotifierProvider); // clear if no user
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartAsync = ref.watch(cartNotifierProvider);
    final auth = ref.read(authProvider);
    final currentUser = auth.user?.userName;

    final fem = ScaleSize.aspectRatio;

    return Scaffold(
      backgroundColor: const Color(0xFFE7F7F4),
      appBar: MyAppBar(appBarLeading: AppBarLeading.back, showLogo: false),
      body: cartAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (items) {
          final orderProducts = items
              .where((e) => e.orderType != 'READY')
              .toList();
          final readyProducts = items
              .where((e) => e.orderType == 'READY')
              .toList();

          return ListView(
            padding: EdgeInsets.only(bottom: 120 * fem),
            children: [
              CartHeader(User: currentUser ?? ''),

              // Shopping Cart title
              Padding(
                padding: EdgeInsets.fromLTRB(72 * fem, 8 * fem, 24 * fem, 0),
                child: MyText(
                  'Shopping Cart (${items.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ),

              // Sections
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
          );
        },
      ),
      bottomNavigationBar: const _BottomProceedBar(),
    );
  }
}

class CartHeader extends StatelessWidget {
  final String User;
  const CartHeader({super.key, required this.User});

  @override
  Widget build(BuildContext context) {
    final fem = ScaleSize.aspectRatio;

    return Column(
      children: [
        SizedBox(height: 24 * fem),

        // Stepper
        Center(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 32 * fem,
              vertical: 12 * fem,
            ),
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
                _StepPill(
                  label: 'Shopping Cart',
                  index: 1,
                  active: true,
                  fem: fem,
                ),
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
        ),

        SizedBox(height: 24 * fem),

        // Search + current cart
        SearchCurrentCartRow(fem: fem, user: User),

        SizedBox(height: 24 * fem),
      ],
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
              fontFamily: 'Montserrat',
            ),
          ),
        ),
        SizedBox(width: 6 * fem),
        MyText(
          label,
          style: TextStyle(
            fontSize: 13 * fem,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w500,
            color: Color(0xFF111827),
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

// search and current user
class SearchCurrentCartRow extends ConsumerStatefulWidget {
  final double fem;
  final String user;

  const SearchCurrentCartRow({
    super.key,
    required this.fem,
    required this.user,
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

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () async {
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
        setState(() {
          _results = results;
          _showSuggestions = results.isNotEmpty;
        });
      } catch (_) {
        setState(() {
          _results = [];
          _showSuggestions = false;
        });
      } finally {
        setState(() => _loading = false);
      }
    });
  }

  void _onCustomerTap(CustomerDetail c) {
    // you can set current user / customer here if needed
    _controller.text = c.name;
    setState(() => _showSuggestions = false);
    debugPrint("Suggestation Clicked");
    // TODO: hook this to your cart refresh / context if required
  }

  @override
  Widget build(BuildContext context) {
    final fem = widget.fem;
    final results = _results;

    return Center(
      child: SizedBox(
        width: 560 * fem,
        height: 70 * fem + (results.isNotEmpty && _showSuggestions ? 160 : 0),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // SEARCH pill with TextField
            // SEARCH pill with TextField (FIXED)
            Positioned.fill(
              child: Align(
                alignment: Alignment.topLeft,
                child: Container(
                  width: 560 * fem,
                  height: 54 * fem, // 🔥 FIXED HEIGHT
                  padding: EdgeInsets.symmetric(horizontal: 16 * fem),
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(
                        width: 1,
                        color: Color(0xFFBEE4DD),
                      ),
                      borderRadius: BorderRadius.circular(15 * fem),
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
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
                            ],
                          ),
                        ),
                      ),

                      if (_loading)
                        Positioned(
                          right: 4 * fem,
                          top: 0,
                          bottom: 0,
                          child: SizedBox(
                            width: 18 * fem,
                            height: 18 * fem,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // CURRENT CART pill (unchanged)
            Positioned(
              right: 0,
              top: -2 * fem,
              child: Container(
                width: 222 * fem,
                height: 58 * fem,
                padding: EdgeInsets.symmetric(
                  horizontal: 23 * fem,
                  vertical: 8 * fem,
                ),
                decoration: ShapeDecoration(
                  color: const Color(0xFFBEE4DD),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18 * fem),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person,
                            size: 20 * fem,
                            color: const Color(0xFF5E5E5E),
                          ),
                          SizedBox(width: 10 * fem),
                          MyText(
                            widget.user,
                            style: TextStyle(
                              color: const Color(0xFF5E5E5E),
                              fontSize: 13 * fem,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w600,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 2 * fem),
                    SizedBox(
                      width: double.infinity,
                      child: MyText(
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
                    ),
                  ],
                ),
              ),
            ),

            // Suggestions dropdown
            if (_showSuggestions && results.isNotEmpty)
              Positioned(
                left: 0,
                top: 54 * fem + 4,
                child: Container(
                  width: 560 * fem,
                  constraints: BoxConstraints(maxHeight: 160 * fem),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8 * fem),
                    border: Border.all(color: const Color(0xFFDDDDDD)),
                  ),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final c = results[index];
                      return InkWell(
                        onTap: () => _onCustomerTap(c),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12 * fem,
                            vertical: 8 * fem,
                          ),
                          child: Text(
                            c.name,
                            style: TextStyle(
                              fontSize: 14 * fem,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Section extends ConsumerWidget {
  final String title;
  final List<CartDetail> items;
  final double fem;

  const _Section({required this.title, required this.items, required this.fem});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (items.isEmpty) return const SizedBox();

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
              // style: Theme.of(context).textTheme.titleMedium?.copyWith(
              //       fontWeight: FontWeight.w600,
              //       fontFamily: 'Montserrat',
              //     ),
            ),
          ),
          SizedBox(height: 8 * fem),
          ...items.map(
            (item) => CartItemCard(
              item: item,
              onDelete: () {
                notifier.deleteItem(item.id ?? 0);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Bottom bar styled like Figma
class _BottomProceedBar extends ConsumerWidget {
  const _BottomProceedBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(cartNotifierProvider.notifier);
    final fem = ScaleSize.aspectRatio;

    return Container(
      height: 82 * fem,
      width: double.infinity,
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
                onTap: () => notifier.proceedToCheckout(),
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
                        spreadRadius: 0,
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
