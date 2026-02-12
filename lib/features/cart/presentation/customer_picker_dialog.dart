import 'package:divine_pos/features/cart/providers/cart_providers.dart';
import 'package:divine_pos/shared/utils/scale_size.dart';
import 'package:divine_pos/shared/widgets/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/cart_detail_model.dart';

/// Shows a dialog to select a customer for filtering the cart
/// Returns CustomerSelectionResult containing customerId, name, and items
Future<CustomerSelectionResult?> showCustomerPickerDialog(
  BuildContext context,
  WidgetRef ref,
) {
  final notifier = ref.read(cartNotifierProvider.notifier);
  final customers = notifier.cartCustomers;

  // Handle empty customer list
  if (customers.isEmpty) {
    _showNoCustomersDialog(context);
    return Future.value(null);
  }

  return showDialog<CustomerSelectionResult>(
    context: context,
    barrierDismissible: false, // Prevent accidental dismissal
    builder: (ctx) {
      int? selectedId;
      String? selectedName;

      return StatefulBuilder(
        builder: (ctx, setState) {
          final fem = ScaleSize.aspectRatio;

          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16 * fem),
            ),
            backgroundColor: Colors.white,
            contentPadding: EdgeInsets.zero,

            // Custom title with styling
            title: Container(
              padding: EdgeInsets.all(20 * fem),
              decoration: BoxDecoration(
                color: const Color(0xFFBEE4DD),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16 * fem),
                  topRight: Radius.circular(16 * fem),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.person_search,
                    color: const Color(0xFF6C5022),
                    size: 24 * fem,
                  ),
                  SizedBox(width: 12 * fem),
                  Expanded(
                    child: MyText(
                      'Select Customer',
                      style: TextStyle(
                        fontSize: 18 * fem,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Montserrat',
                        color: const Color(0xFF6C5022),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            content: Container(
              width: 400 * fem,
              padding: EdgeInsets.all(20 * fem),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyText(
                    'Choose a customer to filter cart items',
                    style: TextStyle(
                      fontSize: 14 * fem,
                      color: Colors.black54,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  SizedBox(height: 16 * fem),

                  // Dropdown with custom styling
                  DropdownButtonFormField<int>(
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: 'Customer',
                      labelStyle: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 14 * fem,
                      ),
                      prefixIcon: Icon(
                        Icons.person_outline,
                        size: 20 * fem,
                        color: const Color(0xFF6C5022),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8 * fem),
                        borderSide: const BorderSide(color: Color(0xFFBEE4DD)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8 * fem),
                        borderSide: const BorderSide(
                          color: Color(0xFFBEE4DD),
                          width: 1.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8 * fem),
                        borderSide: const BorderSide(
                          color: Color(0xFF6CC6B4),
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF9FFFE),
                    ),
                    items: customers
                        .map(
                          (c) => DropdownMenuItem<int>(
                            value: c.id,
                            child: Text(
                              c.name ?? '',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 14 * fem,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    value: selectedId,
                    onChanged: (val) {
                      setState(() {
                        selectedId = val;
                        selectedName = customers
                            .firstWhere((c) => c.id == val)
                            .name;
                      });
                    },
                    hint: Text(
                      'Select a customer...',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 14 * fem,
                        color: Colors.black45,
                      ),
                    ),
                  ),

                  // Show customer count info
                  if (selectedId != null) ...[
                    SizedBox(height: 12 * fem),
                    Container(
                      padding: EdgeInsets.all(12 * fem),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE7F7F4),
                        borderRadius: BorderRadius.circular(8 * fem),
                        border: Border.all(color: const Color(0xFFBEE4DD)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 18 * fem,
                            color: const Color(0xFF6C5022),
                          ),
                          SizedBox(width: 8 * fem),
                          Expanded(
                            child: Builder(
                              builder: (context) {
                                final itemCount = notifier
                                    .getItemsForCustomer(selectedId!)
                                    .length;
                                return Text(
                                  '$itemCount item${itemCount != 1 ? 's' : ''} in cart',
                                  style: TextStyle(
                                    fontSize: 13 * fem,
                                    fontFamily: 'Montserrat',
                                    color: const Color(0xFF6C5022),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            actions: [
              Padding(
                padding: EdgeInsets.fromLTRB(20 * fem, 0, 20 * fem, 16 * fem),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Cancel button
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20 * fem,
                          vertical: 12 * fem,
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 14 * fem,
                          fontFamily: 'Montserrat',
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    SizedBox(width: 12 * fem),

                    // Apply button
                    ElevatedButton(
                      onPressed: selectedId == null
                          ? null
                          : () {
                              final items = notifier.getItemsForCustomer(
                                selectedId!,
                              );
                              Navigator.of(ctx).pop(
                                CustomerSelectionResult(
                                  customerId: selectedId!,
                                  name: selectedName!,
                                  items: items,
                                ),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFBEE4DD),
                        foregroundColor: const Color(0xFF6C5022),
                        disabledBackgroundColor: Colors.grey[300],
                        disabledForegroundColor: Colors.grey[600],
                        padding: EdgeInsets.symmetric(
                          horizontal: 24 * fem,
                          vertical: 12 * fem,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8 * fem),
                        ),
                        elevation: selectedId == null ? 0 : 2,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check, size: 18 * fem),
                          SizedBox(width: 6 * fem),
                          Text(
                            'Apply Filter',
                            style: TextStyle(
                              fontSize: 14 * fem,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      );
    },
  );
}

/// Shows a dialog when no customers are available
void _showNoCustomersDialog(BuildContext context) {
  final fem = ScaleSize.aspectRatio;

  showDialog(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16 * fem),
        ),
        title: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.orange, size: 24 * fem),
            SizedBox(width: 12 * fem),
            const Text('No Customers Available'),
          ],
        ),
        content: Text(
          'There are no customers with items in the cart. Add items to cart first.',
          style: TextStyle(fontSize: 14 * fem, fontFamily: 'Montserrat'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}

/// Result returned from customer picker dialog
/// Contains all necessary information for filtering and display
class CustomerSelectionResult {
  /// The ID of the selected customer
  final int customerId;

  /// The name of the selected customer (for display)
  final String name;

  /// Cart items belonging to this customer
  final List<CartDetail> items;

  CustomerSelectionResult({
    required this.customerId,
    required this.name,
    required this.items,
  });

  @override
  String toString() =>
      'CustomerSelectionResult(id: $customerId, name: $name, items: ${items.length})';
}
