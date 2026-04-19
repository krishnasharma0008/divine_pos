import 'package:divine_pos/constants/tax_constants.dart';
import 'package:divine_pos/shared/utils/scale_size.dart';
import 'package:divine_pos/shared/widgets/text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../shared/utils/currency_formatter.dart';
import '../data/cart_detail_model.dart';

class CartSummaryPanel extends StatelessWidget {
  final List<CartDetail> orderProducts;
  final List<CartDetail> readyProducts;
  final double subtotal;

  //final String customerName;
  //final String expDlvDate;

  // ← typed callback instead of VoidCallback
  final void Function({
    required double engravingCost, //1000 per item
    required double engravingGst, //18% of 1000
    required double engravingtaxamt, // GST amount for engraving
    required double gst, //3% of product subtotal
    required double productTaxAmt, // GST amount for products
    required double grandTotal, // subtotal + engravingCost + gst + engravingGst
    //required String expDlvDate,
    required List<CartDetail> items,
  })?
  onConfirm;

  const CartSummaryPanel({
    super.key,
    required this.orderProducts,
    required this.readyProducts,
    required this.subtotal,
    //required this.customerName,
    //required this.expDlvDate,
    this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final fem = ScaleSize.aspectRatio;
    // 1) Base subtotal comes from parent (product amounts only)
    final baseSubtotal = subtotal;

    // Compute engraving cost using constant
    double engravingTotal = 0;
    for (final item in [...orderProducts, ...readyProducts]) {
      final hasEngraving =
          item.engraving != null && item.engraving!.trim().isNotEmpty;
      if (hasEngraving) {
        engravingTotal += TaxConstants.engravingCostPerItem; // Use constant
      }
    }

    debugPrint("Engraving Total: $engravingTotal");

    // 3) Compute taxes
    final engravingGst = TaxConstants.calculateEngravingGst(engravingTotal);
    final gst = TaxConstants.calculateGst(baseSubtotal);
    final grandTotal = baseSubtotal + engravingTotal + engravingGst + gst;

    // ✅ combine all items shown in summary
    final allItems = [...orderProducts, ...readyProducts];

    // Get the latest (max) expDlvDate across all items
    final maxExpDlvDate = allItems
        .map((item) => item.expDlvDate)
        .where((d) => d != null && d.trim().isNotEmpty)
        .map((d) => DateTime.tryParse(d!))
        .whereType<DateTime>()
        .fold<DateTime?>(
          null,
          (max, date) => max == null || date.isAfter(max) ? date : max,
        );

    return Dialog(
      backgroundColor: Colors.white,
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16 * fem),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          children: [
            // Header
            _buildHeader(fem, context),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Scrollable products (Flexible instead of Expanded)
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.4,
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: 32 * fem),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            //SizedBox(height: 24 * fem),
                            if (orderProducts.isNotEmpty) ...[
                              _buildSectionTitle('Order Product', fem),
                              SizedBox(height: 8 * fem),
                              for (int i = 0; i < orderProducts.length; i++)
                                _buildProductCard(
                                  itemNumber: '${i + 1}',
                                  productName: _formatProductName(
                                    orderProducts[i].productCategory,
                                    orderProducts[i].productCode,
                                  ),
                                  priceRange: _formatPriceRange(
                                    orderProducts[i].productAmtMin,
                                    orderProducts[i].productAmtMax,
                                  ),
                                  description:
                                      'Divine Solitaire: ${orderProducts[i].solitaireShape ?? ''} '
                                      '${orderProducts[i].solitaireSlab ?? ''} '
                                      '${orderProducts[i].solitaireColor ?? ''} '
                                      '${orderProducts[i].solitaireQuality ?? ''} '
                                      '(${orderProducts[i].solitairePcs ?? 0} Pcs)',
                                  quantity: orderProducts[i].productQty ?? 1,
                                  isTopRounded: i == 0,
                                  isBottomRounded:
                                      i == orderProducts.length - 1,
                                  fem: fem,
                                ),
                              SizedBox(height: 32 * fem),
                            ],

                            if (readyProducts.isNotEmpty) ...[
                              _buildSectionTitle('Ready Product', fem),
                              const SizedBox(height: 8),
                              for (int i = 0; i < readyProducts.length; i++)
                                _buildProductCard(
                                  itemNumber: '${i + 1}',
                                  productName: _formatProductName(
                                    readyProducts[i].productCategory,
                                    readyProducts[i].productCode,
                                  ),
                                  // priceRange: _formatPriceRange(
                                  //   readyProducts[i].productAmtMin,
                                  //   readyProducts[i].productAmtMax,
                                  // ),
                                  priceRange: _formatPriceRange(
                                    readyProducts[i].productAmtMin,
                                    readyProducts[i].productAmtMax,
                                  ),
                                  description:
                                      'Divine Solitaire: ${readyProducts[i].solitaireShape ?? ''} '
                                      '${readyProducts[i].solitaireSlab ?? ''} '
                                      '${readyProducts[i].solitaireColor ?? ''} '
                                      '${readyProducts[i].solitaireQuality ?? ''} '
                                      '(${readyProducts[i].solitairePcs ?? 0} Pcs)',
                                  quantity: readyProducts[i].productQty ?? 1,
                                  isTopRounded: i == 0,
                                  isBottomRounded:
                                      i == readyProducts.length - 1,
                                  fem: fem,
                                ),
                              SizedBox(height: 24 * fem),
                            ],
                          ],
                        ),
                      ),
                    ),

                    // Price Summary
                    _buildPriceSummary(
                      subtotal: subtotal,
                      engravingCost: engravingTotal,
                      engravingGst: engravingGst,
                      gst: gst,
                      grandTotal: grandTotal,
                      fem: fem,
                    ),

                    // Delivery Info
                    _buildDeliveryInfo(fem, maxExpDlvDate),
                  ],
                ),
              ),
            ),
            //Spacer(),
            SizedBox(height: 10 * fem),
            // Confirm Button
            _buildConfirmButton(
              engravingCost: engravingTotal, //1000 per item
              engravingGst: TaxConstants.engravingGstPercent, //18% of 1000
              engravingtaxamt: engravingGst, // GST amount for engraving
              gst: TaxConstants.gstPercent, // 3% of product subtotal
              productTaxAmt: gst, // GST amount for products
              grandTotal:
                  grandTotal, // subtotal + engravingCost + gst + engravingGst
              items: allItems,
              //expDlvDate: expDlvDate,
              fem: fem,
            ),
          ],
        ),
      ),
    );
  }

  /// Formats min/max price into a clean string.
  /// Treats both null and 0 as "not available".
  ///
  ///  min & max both absent  →  '-'
  ///  min == max             →  '₹74,932'
  ///  only min               →  'From ₹74,932'
  ///  only max               →  'Up to ₹80,000'
  ///  both present           →  '₹74,932 - ₹80,000'
  String _formatPriceRange(num? min, num? max) {
    final hasMin = min != null && min != 0;
    final hasMax = max != null && max != 0;

    if (!hasMin && !hasMax) return '-';
    if (hasMin && hasMax && min == max) return min!.inRupeesFormat();
    if (hasMin && hasMax)
      return '${min!.inRupeesFormat()} - ${max!.inRupeesFormat()}';
    if (hasMin) return 'From ${min!.inRupeesFormat()}';
    return 'Up to ${max!.inRupeesFormat()}';
  }

  /// Formats category + code into a clean title.
  /// Drops the ' - ' separator if category is null/empty.
  ///
  ///  category & code both present  →  'EARRING - DEF8634'
  ///  only code                     →  'DEF8634'
  ///  only category                 →  'EARRING'
  ///  both absent                   →  ''
  String _formatProductName(String? category, String? code) {
    final parts = [
      category?.trim() ?? '',
      code?.trim() ?? '',
    ].where((s) => s.isNotEmpty).toList();

    return parts.join(' - ');
  }

  Widget _buildHeader(double fem, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Row(
        children: [
          // Icon container
          Container(
            width: 39.99,
            height: 39.99,
            padding: const EdgeInsets.only(right: 0.01),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment(0.0, 0.0),
                end: Alignment(1.0, 1.0),
                colors: [Color(0xFF90DCD0), Color(0xFFBEE4DD)],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x19000000),
                  blurRadius: 6,
                  offset: Offset(0, 4),
                  spreadRadius: -4,
                ),
                BoxShadow(
                  color: Color(0x19000000),
                  blurRadius: 15,
                  offset: Offset(0, 10),
                  spreadRadius: -3,
                ),
              ],
            ),
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: Image.asset(
                  'assets/cart/cart_summary.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          SizedBox(width: 12 * fem),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order Summary',
                  style: TextStyle(
                    fontSize: 22 * fem,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF0E162B),
                    letterSpacing: -0.55,
                  ),
                ),
                Text(
                  '#123456',
                  style: TextStyle(
                    fontSize: 13 * fem,
                    color: Color(0xFF61738D),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(), // dialog close
            child: Container(
              width: 32 * fem,
              height: 32 * fem,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16 * fem),
              ),
              child: Icon(
                Icons.close,
                size: 20 * fem,
                color: const Color(0xFF61738D),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, double fem) {
    return MyText(
      title,
      style: TextStyle(
        fontSize: 12 * fem,
        color: Color(0xFF0A0A0A),
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget _buildProductCard({
    required String itemNumber,
    required String productName,
    required String priceRange,
    required String description,
    required int quantity,
    bool isTopRounded = false,
    bool isBottomRounded = false,
    required double fem,
  }) {
    return Container(
      padding: EdgeInsets.all(20 * fem),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF8F9FB), Color(0x7FF0F4F9)],
        ),
        border: Border.all(color: const Color(0x99E1E8F0), width: 0.88),
        borderRadius: BorderRadius.vertical(
          top: isTopRounded ? Radius.circular(16 * fem) : Radius.zero,
          bottom: isBottomRounded ? Radius.circular(16 * fem) : Radius.zero,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32 * fem,
                height: 32 * fem,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: const Color(0xFFE1E8F0),
                    width: 0.88,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    itemNumber,
                    style: TextStyle(
                      fontSize: 13 * fem,
                      color: Color(0xFF90DCD0),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12 * fem),
              Expanded(
                child: MyText(
                  productName,
                  style: TextStyle(
                    fontSize: 15 * fem,
                    color: Color(0xFF0E162B),
                  ),
                ),
              ),
              Text(
                priceRange,
                style: TextStyle(fontSize: 15 * fem, color: Color(0xFF0E162B)),
              ),
            ],
          ),
          SizedBox(height: 12 * fem),
          Padding(
            padding: EdgeInsets.only(left: 44 * fem),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText(
                  description,
                  style: TextStyle(fontSize: 12 * fem, color: Colors.black),
                ),
                SizedBox(height: 4 * fem),
                Text(
                  'Quantity: $quantity',
                  style: TextStyle(fontSize: 12 * fem, color: Colors.black),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSummary({
    required double subtotal,
    required double engravingCost,
    required double engravingGst,
    required double gst,
    required double grandTotal,
    required double fem,
  }) {
    // String fmt(num v) => '₹${v.toStringAsFixed(0)}';

    return Container(
      padding: EdgeInsets.all(32 * fem),
      decoration: const BoxDecoration(
        color: Color(0xCCF8FAFC),
        border: Border(top: BorderSide(color: Color(0xFFE1E8F0), width: 0.88)),
      ),
      child: Column(
        children: [
          _buildPriceRow('Subtotal', subtotal!.inRupeesFormat()),
          SizedBox(height: 16 * fem),
          _buildPriceRow(
            'Engraving Cost',
            //fmt(TaxConstants.engravingCostPerItem),
            engravingCost!.inRupeesFormat(),
          ),
          SizedBox(height: 16),
          _buildPriceRowWithBadge(
            'Engraving GST',
            '${TaxConstants.engravingGstPercent.toStringAsFixed(0)}%', // Use constant
            engravingGst!.inRupeesFormat(),
            // '${engravingGstPercent.toStringAsFixed(0)}%',
            // fmt(engravingGst),
          ),
          SizedBox(height: 16 * fem),
          _buildPriceRowWithBadge(
            'GST',
            '${TaxConstants.gstPercent.toStringAsFixed(0)}%', // Use constant
            gst!.inRupeesFormat(),
            // '${gstPercent.toStringAsFixed(0)}%',
            // fmt(gst),
          ),
          SizedBox(height: 16 * fem),
          Container(
            padding: EdgeInsets.only(top: 16 * fem),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Color(0xFFCAD5E2), width: 0.88),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MyText(
                  'Grand Total',
                  style: TextStyle(
                    fontSize: 16 * fem,
                    color: Color(0xFF0E162B),
                  ),
                ),
                MyText(
                  grandTotal!.inRupeesFormat(),
                  style: TextStyle(
                    fontSize: 20 * fem,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12 * fem),
          MyText(
            '*This is an estimated amount, price may vary plus minus 5%',
            textAlign: TextAlign.right,
            style: TextStyle(fontSize: 11 * fem, color: Color(0xFF7D7D7D)),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Color(0xFF45556C)),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 14, color: Color(0xFF0E162B)),
        ),
      ],
    );
  }

  Widget _buildPriceRowWithBadge(String label, String badge, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 14, color: Color(0xFF45556C)),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                badge,
                style: const TextStyle(fontSize: 11, color: Color(0xFF45556C)),
              ),
            ),
          ],
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 14, color: Color(0xFF0E162B)),
        ),
      ],
    );
  }

  Widget _buildDeliveryInfo(double fem, DateTime? maxExpDlvDate) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32 * fem, vertical: 10 * fem),
      child: Container(
        padding: EdgeInsets.all(16 * fem),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F8F8),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 36 * fem,
              height: 36 * fem,
              decoration: BoxDecoration(
                color: const Color(0xFF2B7FFF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.local_shipping,
                color: Colors.white,
                size: 20 * fem,
              ),
            ),
            SizedBox(width: 12 * fem),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyText(
                    'Estimated Delivery',
                    style: TextStyle(
                      fontSize: 12 * fem,
                      color: Color(0xFF434343),
                    ),
                  ),
                  MyText(
                    maxExpDlvDate != null
                        ? DateFormat('dd-MM-yyyy').format(maxExpDlvDate)
                        : 'N/A',
                    style: TextStyle(
                      fontSize: 15 * fem,
                      color: Color(0xFF155CFB),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmButton({
    required double engravingCost, //1000 per item
    required double engravingGst, //18% of 1000
    required double engravingtaxamt, // GST amount for engraving
    required double gst, //3% of product subtotal
    required double productTaxAmt, // GST amount for products
    required double grandTotal, // subtotal + engravingCost + gst + engravingGst
    //required String expDlvDate,
    required List<CartDetail> items,
    required double fem,
  }) {
    return Padding(
      padding: EdgeInsets.fromLTRB(32 * fem, 0, 32 * fem, 20 * fem),
      child: GestureDetector(
        // tap पकड़ने के लिए
        //onTap: onConfirm,
        onTap: () {
          // ← data flows OUT to parent here

          onConfirm?.call(
            engravingCost: engravingCost,
            engravingGst: engravingGst,
            engravingtaxamt: engravingtaxamt,
            gst: gst,
            productTaxAmt: productTaxAmt,
            grandTotal: grandTotal,
            //expDlvDate: expDlvDate,
            items: items,
          );
        },
        child: Container(
          width: double.infinity,
          height: 51 * fem,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFBEE4DD), Color(0xA5D1B193)],
            ),
            border: Border.all(color: const Color(0xFFACA584)),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 4 * fem,
                offset: const Offset(2, 2),
              ),
            ],
          ),
          child: Center(
            child: MyText(
              'Confirm order',
              style: TextStyle(
                fontSize: 16 * fem,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6C5022),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
