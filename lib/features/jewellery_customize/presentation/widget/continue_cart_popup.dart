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
  final _newNameController = TextEditingController();
  final _newMobileController = TextEditingController();
  final LayerLink _fieldLink = LayerLink();

  OverlayEntry? _overlayEntry;
  double _textFieldWidth = 0;
  Timer? _debounce;
  bool _loading = false;
  List<CustomerDetail> _results = [];

  @override
  void dispose() {
    _debounce?.cancel();
    _overlayEntry?.remove();
    _searchController.dispose();
    _newNameController.dispose();
    _newMobileController.dispose();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _buildOverlay() {
    final r = ScaleSize.aspectRatio;
    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: _removeOverlay,
              behavior: HitTestBehavior.translucent,
            ),
          ),
          CompositedTransformFollower(
            link: _fieldLink,
            showWhenUnlinked: false,
            offset: Offset(0, 54 * r),
            child: Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: _textFieldWidth,
                  constraints: BoxConstraints(maxHeight: 200 * r),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFFAEAEAE),
                      width: 0.5,
                    ),
                  ),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: _results.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      final c = _results[index];
                      return InkWell(
                        onTap: () => _onCustomerTap(c),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12 * r,
                            vertical: 10 * r,
                          ),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: index < _results.length - 1
                                  ? BorderSide(
                                      color: const Color(0xFFE0E0E0),
                                      width: 0.5,
                                    )
                                  : BorderSide.none,
                            ),
                          ),
                          child: Text(
                            c.name,
                            style: TextStyle(
                              fontSize: 14 * r,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w400,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () async {
      final query = value.trim();
      if (query.isEmpty) {
        setState(() {
          _results = [];
          _loading = false;
        });
        _removeOverlay();
        return;
      }

      setState(() => _loading = true);

      try {
        final list = await ref
            .read(cartNotifierProvider.notifier)
            .searchCustomer(query);
        if (!mounted) return;

        setState(() => _results = list);

        if (list.isNotEmpty) {
          if (_overlayEntry == null) {
            _overlayEntry = _buildOverlay();
            Overlay.of(context).insert(_overlayEntry!);
          } else {
            _overlayEntry!.markNeedsBuild();
          }
        } else {
          _removeOverlay();
        }
      } catch (e) {
        if (!mounted) return;
        setState(() => _results = []);
        _removeOverlay();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Search failed: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _loading = false);
      }
    });
  }

  void _onCustomerTap(CustomerDetail c) {
    _searchController.text = c.name;
    _searchController.selection = TextSelection.fromPosition(
      TextPosition(offset: _searchController.text.length),
    );
    _removeOverlay();
    FocusScope.of(context).unfocus();
  }

  void _handleAddToCart() {
    final selectedExisting = _searchController.text.trim();
    final newName = _newNameController.text.trim();
    final newMobile = _newMobileController.text.trim();

    if (selectedExisting.isEmpty && newName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please search for a customer or enter new customer details',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    Navigator.of(context).pop({
      'existingCustomerName': selectedExisting.isNotEmpty
          ? selectedExisting
          : null,
      'newCustomerName': newName.isNotEmpty ? newName : null,
      'newCustomerMobile': newMobile.isNotEmpty ? newMobile : null,
    });
  }

  @override
  Widget build(BuildContext context) {
    final r = ScaleSize.aspectRatio;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
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
                  MyText(
                    'Search existing customer',
                    style: TextStyle(
                      fontSize: 14 * r,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8 * r),
                  CompositedTransformTarget(
                    link: _fieldLink,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (_textFieldWidth != constraints.maxWidth) {
                            setState(
                              () => _textFieldWidth = constraints.maxWidth,
                            );
                          }
                        });
                        return Stack(
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
                                child: Center(
                                  child: SizedBox(
                                    width: 18 * r,
                                    height: 18 * r,
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 40 * r),
                  Container(
                    width: double.infinity,
                    decoration: const ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        side: BorderSide(width: 1, color: Color(0xFFBEE4DD)),
                      ),
                    ),
                  ),
                  SizedBox(height: 30 * r),
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
                      Expanded(
                        child: TextField(
                          controller: _newNameController,
                          decoration: InputDecoration(
                            hintText: 'Enter customer Name',
                            hintStyle: TextStyle(
                              color: const Color(0xFFB0B0B0),
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
                      Expanded(
                        child: TextField(
                          controller: _newMobileController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            hintText: 'Enter Mobile Number',
                            hintStyle: TextStyle(
                              color: const Color(0xFFB0B0B0),
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
                      InkWell(
                        onTap: () {
                          if (_newNameController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter customer name'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          }
                        },
                        borderRadius: BorderRadius.circular(10 * r),
                        child: Container(
                          height: 52 * r,
                          padding: EdgeInsets.symmetric(
                            horizontal: 16 * r,
                            vertical: 14 * r,
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
                        onTap: _handleAddToCart,
                        borderRadius: BorderRadius.circular(20 * r),
                        child: Container(
                          width: 384 * r,
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
                                color: const Color(0x7C000000),
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
