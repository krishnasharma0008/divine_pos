import 'dart:async';
import 'package:flutter/material.dart';
import 'package:divine_pos/shared/widgets/text.dart';
import 'package:divine_pos/shared/utils/scale_size.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../cart/providers/cart_providers.dart';
import '../../../cart/data/customer_detail_model.dart';

class ContinueCartPopup extends ConsumerStatefulWidget {
  const ContinueCartPopup({super.key});

  @override
  ConsumerState<ContinueCartPopup> createState() => _ContinueCartPopupState();
}

class _ContinueCartPopupState extends ConsumerState<ContinueCartPopup> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  bool _loading = false;
  bool _showSuggestions = false;
  List<CustomerDetail> _results = [];

  void _onSearchChanged(String value) {
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
        final list = await ref
            .read(cartNotifierProvider.notifier)
            .searchCustomer(query);
        setState(() {
          _results = list;
          _showSuggestions = list.isNotEmpty;
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
    // Fill the field and close suggestions (you can also pop with selected)
    _searchController.text = c.name;
    setState(() => _showSuggestions = false);
    // Example: Navigator.of(context).pop(c); // if you want to return selected
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = ScaleSize.aspectRatio;
    final results = _results;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Main card
          Container(
            width: 750 * r,
            padding: EdgeInsets.fromLTRB(56 * r, 61 * r, 56 * r, 61 * r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16 * r),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// SEARCH EXISTING
                  MyText(
                    'Search existing customer',
                    style: TextStyle(
                      fontSize: 14 * r,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8 * r),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      TextField(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        style: TextStyle(
                          fontSize: 16 * r,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search here for existing customer',
                          hintStyle: TextStyle(
                            color: const Color(0xFFB0B0B0),
                            fontSize: 16 * r,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w400,
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            size: 18,
                            color: Color(0xFFB0B0B0),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 10 * r,
                            vertical: 14 * r,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color(0xFFAEAEAE),
                              width: 0.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10 * r),
                            borderSide: const BorderSide(
                              color: Color(0xFFAEAEAE),
                              width: 0.5,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10 * r),
                            borderSide: const BorderSide(
                              color: Color(0xFFAEAEAE),
                              width: 0.5,
                            ),
                          ),
                          isDense: true,
                        ),
                      ),

                      if (_loading)
                        Positioned(
                          right: 8 * r,
                          top: 0,
                          bottom: 0,
                          child: SizedBox(
                            width: 18 * r,
                            height: 18 * r,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          ),
                        ),

                      if (_showSuggestions && _results.isNotEmpty)
                        Positioned(
                          left: 0,
                          right: 0,
                          top: 8 * r + 52 * r, // just below the TextField
                          child: Material(
                            elevation: 8,
                            borderRadius: BorderRadius.circular(8 * r),
                            child: Container(
                              constraints: BoxConstraints(maxHeight: 160 * r),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8 * r),
                              ),
                              child: ListView.builder(
                                shrinkWrap: true,
                                padding: EdgeInsets.zero,
                                itemCount: _results.length,
                                itemBuilder: (context, index) {
                                  final c = _results[index];
                                  return InkWell(
                                    onTap: () => _onCustomerTap(c),
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12 * r,
                                        vertical: 8 * r,
                                      ),
                                      child: Text(
                                        c.name,
                                        style: TextStyle(
                                          fontSize: 14 * r,
                                          fontFamily: 'Montserrat',
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),

                  SizedBox(height: 40 * r),
                  // Separator line
                  Container(
                    width: double
                        .infinity, // or 703 * r if you want exact Figma width
                    decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(
                          width: 1,
                          color: Color(0xFFBEE4DD),
                          // strokeAlign is optional; default is inside
                          // strokeAlign: BorderSide.strokeAlignCenter,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 30 * r),

                  /// CREATE CART
                  MyText(
                    'Create new cart',
                    style: TextStyle(
                      fontSize: 14 * r,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8 * r),
                  Row(
                    children: [
                      // Name
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Enter customer Name',
                            hintStyle: TextStyle(
                              color: Color(0xFFB0B0B0),
                              fontSize: 14 * r,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w400,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 10 * r,
                              vertical: 14 * r,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10 * r),
                              borderSide: const BorderSide(
                                color: Color(0xFFAEAEAE),
                                width: 0.5,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10 * r),
                              borderSide: const BorderSide(
                                color: Color(0xFFAEAEAE),
                                width: 0.5,
                              ),
                            ),
                            isDense: true,
                          ),
                        ),
                      ),
                      SizedBox(width: 16 * r),

                      // Mobile
                      Expanded(
                        child: TextField(
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            hintText: 'Enter Mobile Number',
                            hintStyle: TextStyle(
                              color: Color(0xFFB0B0B0),
                              fontSize: 14 * r,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w400,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 10 * r,
                              vertical: 14 * r,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10 * r),
                              borderSide: const BorderSide(
                                color: Color(0xFFAEAEAE),
                                width: 0.5,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10 * r),
                              borderSide: const BorderSide(
                                color: Color(0xFFAEAEAE),
                                width: 0.5,
                              ),
                            ),
                            isDense: true,
                          ),
                        ),
                      ),
                      SizedBox(width: 16 * r),

                      // + Create button
                      InkWell(
                        onTap: () {
                          // handle create new cart
                          print('Create new cart');
                        },
                        borderRadius: BorderRadius.circular(10 * r),
                        child: Container(
                          // remove hardcoded height, let padding define it
                          // or set same 52 * r as an explicit height
                          height: 52 * r, // ← matches TextField visual height
                          padding: EdgeInsets.symmetric(
                            horizontal: 16 * r,
                            vertical: 14 * r, // ← same vertical as TextField
                          ),
                          decoration: ShapeDecoration(
                            color: const Color(0xFFF6F6F6),
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(
                                width: 0.5,
                                color: Color(0xFFAEAEAE),
                              ),
                              borderRadius: BorderRadius.circular(10 * r),
                            ),
                          ),
                          child: Center(
                            child: MyText(
                              '+ Create',
                              style: TextStyle(
                                color: const Color(0xFF6B6B6B),
                                fontSize: 14 * r,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 60 * r),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          // handle add to cart
                        },
                        borderRadius: BorderRadius.circular(20 * r),
                        child: Container(
                          width: 384 * r, // Figma width
                          height: 52 * r,
                          padding: EdgeInsets.symmetric(
                            horizontal: 30 * r,
                            vertical: 6 * r,
                          ),
                          decoration: ShapeDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment(0.0, 0.5),
                              end: Alignment(0.96, 1.12),
                              colors: [Color(0xFFBEE4DD), Color(0xA5D1B193)],
                            ),
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(
                                width: 1,
                                color: Color(0xFFACA584),
                              ),
                              borderRadius: BorderRadius.circular(20 * r),
                            ),
                            shadows: [
                              BoxShadow(
                                color: Color(0x7C000000),
                                blurRadius: 4 * r,
                                offset: Offset(2 * r, 2 * r),
                              ),
                            ],
                          ),
                          child: Center(
                            child: MyText(
                              'Add to Cart',
                              style: TextStyle(
                                color: const Color(0xFF6C5022),
                                fontSize: 20 * r,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Close button pinned to top‑right of the card
          Positioned(
            right: 20 * r,
            top: 20 * r,
            child: InkWell(
              onTap: () => Navigator.pop(context),
              child: Icon(Icons.close, size: 24 * r, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }
}
