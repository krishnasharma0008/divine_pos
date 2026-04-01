import 'package:flutter/material.dart';
import 'package:divine_pos/shared/widgets/text.dart';
import 'package:divine_pos/shared/utils/currency_formatter.dart';

/// ================= MAIN SCREEN =================

class DetailsScreen extends StatefulWidget {
  final double r;
  final String? priceRange;
  final String? caratRange;
  final String? colorRange;
  final String? clarityRange;
  final String? soltpcs;
  final String? ringSize;
  //const DetailsScreen({super.key, required this.r});
  final String metalColors; // ✅ from database
  final String metalPurity;
  final double totalMetalWeight;
  final int totalSidePcs;
  final double totalSideWeight;
  final String? sideDiamondQuality;
  final String? shape;

  // all amount presen
  final double? metalAmount;
  final double? sideDiamondAmount;
  final double? solitaireAmountFrom;
  final double? solitaireAmountTo;
  final double? approxPriceFrom;
  final double? approxPriceTo;

  final bool hidePriceBreakup; // 🔹 NEW

  const DetailsScreen({
    super.key,
    required this.r,
    this.priceRange,
    this.caratRange,
    this.colorRange,
    this.clarityRange,
    this.soltpcs,
    this.ringSize,
    required this.metalColors,
    required this.metalPurity,
    required this.totalMetalWeight,
    required this.totalSidePcs,
    required this.totalSideWeight,
    required this.sideDiamondQuality,
    this.shape,
    //
    required this.metalAmount,
    required this.sideDiamondAmount,
    required this.solitaireAmountFrom,
    required this.solitaireAmountTo,
    required this.approxPriceFrom,
    required this.approxPriceTo,
    this.hidePriceBreakup = false, // 🔹 default
  });

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  int activeTab = 1;

  @override
  Widget build(BuildContext context) {
    final r = widget.r;

    return Container(
      color: Colors.white,
      //padding: EdgeInsets.all(16 * r),
      padding: EdgeInsets.fromLTRB(0, 0 * r, 30 * r, 15 * r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 SELECTED VALUES (shown only if present)
          // if (widget.priceRange != null) MyText('Price: ${widget.priceRange}'),

          // if (widget.caratRange != null) MyText('Carat: ${widget.caratRange}'),

          // if (widget.colorRange != null) MyText('Color: ${widget.colorRange}'),

          // if (widget.clarityRange != null)
          //   MyText('Clarity: ${widget.clarityRange}'),

          // if (widget.ringSize != null) MyText('Ring Size: ${widget.ringSize}'),
          _TabHeader(
            r: r,
            activeTab: activeTab,
            //onTabChange: (v) => setState(() => activeTab = v),
            onTabChange: (v) {
              if (widget.hidePriceBreakup && v == 2) return; // block tab2
              setState(() => activeTab = v);
            },
            hidePriceBreakup: widget.hidePriceBreakup,
          ),
          SizedBox(height: 16 * r),
          // NO Expanded here -> parent controls height
          // if hide, always show ProductDetailsTab
          widget.hidePriceBreakup || activeTab == 1
              ? ProductDetailsTab(
                  r: r,
                  Shape: widget.shape,
                  caratRange: widget.caratRange,
                  colorRange: widget.colorRange,
                  clarityRange: widget.clarityRange,
                  soltpcs: widget.soltpcs,
                  ringSize: widget.ringSize,
                  metalColors: widget.metalColors,
                  metalPurity: widget.metalPurity,
                  totalSidePcs: widget.totalSidePcs,
                  totalSideWeight: widget.totalSideWeight,
                  sideDiamondQuality: widget.sideDiamondQuality,
                  totalMetalWeight: widget.totalMetalWeight,
                )
              : PriceBreakupTab(
                  r,
                  metalAmount: widget.metalAmount,
                  sideDiamondAmount: widget.sideDiamondAmount,
                  solitaireAmountFrom: widget.solitaireAmountFrom,
                  solitaireAmountTo: widget.solitaireAmountTo,
                  approxPriceFrom: widget.approxPriceFrom,
                  approxPriceTo: widget.approxPriceTo,
                ),
        ],
      ),
    );
  }
}

/// ================= TAB HEADER =================

class _TabHeader extends StatelessWidget {
  final double r;
  final int activeTab;
  final ValueChanged<int> onTabChange;
  final bool hidePriceBreakup;

  const _TabHeader({
    required this.r,
    required this.activeTab,
    required this.onTabChange,
    this.hidePriceBreakup = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _tab(
              'Product Details',
              isActive: activeTab == 1,
              onTap: () => onTabChange(1),
            ),
            if (!hidePriceBreakup)
              _tab(
                'Price Breakup',
                isActive: activeTab == 2,
                onTap: () => onTabChange(2),
              ),
            // _tab(
            //   'Price Breakup',
            //   isActive: activeTab == 2,
            //   onTap: () => onTabChange(2),
            // ),
          ],
        ),
        SizedBox(height: 6 * r),
        Stack(
          children: [
            Container(height: 1, color: const Color(0xFFEDEDED)),
            Align(
              alignment: activeTab == 1
                  ? Alignment.centerLeft
                  : Alignment.centerRight,
              child: Container(
                width: 120 * r,
                height: 3,
                decoration: BoxDecoration(
                  color: const Color(0xFF90DCD0),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _tab(
    String title, {
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 130 * r,
        child: MyText(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12 * r,
            fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
            height: 2.2,
          ),
        ),
      ),
    );
  }
}

/// ================= LEGEND CARD =================

Widget legendCard({
  required double r,
  required String title,
  required Widget child,
}) {
  return Stack(
    children: [
      Container(
        margin: EdgeInsets.only(top: 18 * r),
        padding: EdgeInsets.fromLTRB(18 * r, 28 * r, 20 * r, 24 * r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15 * r),
          border: Border.all(color: const Color(0xFF90DCD0)),
        ),
        child: child,
      ),
      Positioned(
        left: 0 * r,
        top: 0,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14 * r, vertical: 6 * r),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF90DCD0), Color(0xFFE1E4E4)],
            ),
            //borderRadius: BorderRadius.circular(8 * r),
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(8 * r),
              bottomRight: Radius.circular(8 * r),
              topLeft: Radius.zero,
              bottomLeft: Radius.zero,
            ),
          ),
          child: MyText(
            title,
            style: TextStyle(fontSize: 14 * r, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    ],
  );
}

/// ================= PRODUCT DETAILS TAB =================

class ProductDetailsTab extends StatelessWidget {
  final double r;
  final String? Shape;
  final String? priceRange;
  final String? caratRange;
  final String? colorRange;
  final String? clarityRange;
  final String? soltpcs;
  final String? ringSize;
  final String metalColors; // ✅ from database
  final String metalPurity;
  final int totalSidePcs;
  final double totalSideWeight;
  final String? sideDiamondQuality;
  final double totalMetalWeight;

  const ProductDetailsTab({
    super.key,
    required this.r,
    this.Shape,
    this.priceRange,
    this.caratRange,
    this.colorRange,
    this.clarityRange,
    this.soltpcs,
    this.ringSize,
    required this.metalColors,
    required this.metalPurity,
    required this.totalSidePcs,
    required this.totalSideWeight,
    required this.sideDiamondQuality,

    required this.totalMetalWeight,
  });

  @override
  Widget build(BuildContext context) {
    return legendCard(
      r: r,
      title: 'Divine Solitaires',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //MyText(_buildSolitaireLine(), style: TextStyle(fontSize: 12 * r)),
          _buildSolitaireLine(r),
          SizedBox(height: 24 * r),
          _sectionHeader(r, 'Divine Mount'),
          SizedBox(height: 16 * r),
          _row(r, 'Metal Type', '$metalPurity $metalColors Gold'),
          _row(r, 'Net Weight', '${totalMetalWeight.toStringAsFixed(2)} Gms'),
          if (totalSidePcs > 0)
            _row(
              r,
              'Side Diamond',
              'Qty  $totalSidePcs / ${totalSideWeight.toStringAsFixed(2)} ct ${sideDiamondQuality ?? 'IJ - SI'}',
            ),
          if (ringSize != null && ringSize != "")
            _row(r, 'Ring Size', ringSize ?? ''),
        ],
      ),
    );
  }

  List<String> _splitComma(String? value) {
    if (value == null || value.trim().isEmpty) return [];
    return value
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  Widget _buildSolitaireLine(double r) {
    // debugPrint('Building solitaire line with:');
    // debugPrint('Shape: $Shape');
    // debugPrint('Carat Range: $caratRange');
    // debugPrint('Color Range: $colorRange');
    // debugPrint('Clarity Range: $clarityRange');
    // debugPrint('Solitaire Pcs: $soltpcs');

    final shapes = _splitComma(Shape); // e.g. ["Round", "Round"]
    final carats = _splitComma(caratRange); // ["0.10-0.13", "0.18-0.22"]
    final colors = _splitComma(colorRange); // ["IJ-EF", "D-D"]
    final clarities = _splitComma(clarityRange); // ["SI-VVS", "IF-IF"]
    final pcsList = _splitComma(soltpcs); // ["2", "1"]

    // Fallback: old single line when we can't split
    if (shapes.isEmpty || carats.isEmpty) {
      final pcs = soltpcs ?? '1';
      return MyText(
        '$Shape ${caratRange ?? ''} ${colorRange ?? ''} ${clarityRange ?? ''} ( $pcs Pcs )',
        style: TextStyle(fontSize: 12 * r),
      );
    }

    final itemCount = [
      shapes.length,
      carats.length,
      colors.isEmpty ? shapes.length : colors.length,
      clarities.isEmpty ? shapes.length : clarities.length,
      pcsList.isEmpty ? shapes.length : pcsList.length,
    ].reduce((a, b) => a < b ? a : b);

    // debugPrint('itemCount: $itemCount');
    // debugPrint('shapes: $shapes');
    // debugPrint('carats: $carats');
    // debugPrint('colors: $colors');
    // debugPrint('clarities: $clarities');
    // debugPrint('pcsList: $pcsList');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(itemCount, (i) {
        final shape = shapes[i];
        final carat = carats[i];
        final color = i < colors.length ? colors[i] : (colorRange ?? 'F-G');
        final clarity = i < clarities.length
            ? clarities[i]
            : (clarityRange ?? 'VVS1-VS1');
        final pcsStr = i < pcsList.length ? pcsList[i] : (soltpcs ?? '1');

        return MyText(
          '$shape $carat $color $clarity ( $pcsStr Pcs )',
          style: TextStyle(fontSize: 12 * r),
        );
      }),
    );
  }
}

/// ================= PRICE BREAKUP TAB =================

class PriceBreakupTab extends StatelessWidget {
  final double r;
  final double? metalAmount;
  final double? sideDiamondAmount;
  final double? solitaireAmountFrom;
  final double? solitaireAmountTo;
  final double? approxPriceFrom;
  final double? approxPriceTo;

  const PriceBreakupTab(
    this.r, {
    super.key,
    // all amount presen
    required this.metalAmount,
    required this.sideDiamondAmount,
    required this.solitaireAmountFrom,
    required this.solitaireAmountTo,
    required this.approxPriceFrom,
    required this.approxPriceTo,
  });

  @override
  Widget build(BuildContext context) {
    final grandFrom = (approxPriceFrom ?? 0);
    final grandTo = (approxPriceTo ?? 0);

    return legendCard(
      r: r,
      title: 'Divine Solitaires',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _priceRow(
            r,
            'Solitaire Value',
            '${solitaireAmountFrom!.inRupeesFormat()}  - ${solitaireAmountTo!.inRupeesFormat()}',
          ),
          SizedBox(height: 16 * r),
          _sectionHeader(r, 'Divine Mount'),
          SizedBox(height: 16 * r),
          _priceRow(
            r,
            (sideDiamondAmount ?? 0) > 0 ? 'Metal + Side Diamonds' : 'Metal',
            //'${metalAmount!.inRupeesFormat()} - ${sideDiamondAmount!.inRupeesFormat()}',
            (sideDiamondAmount ?? 0) > 0
                //? '${metalAmount!.inRupeesFormat()} - ${sideDiamondAmount!.inRupeesFormat()}'
                ? '${(metalAmount! + sideDiamondAmount!).inRupeesFormat()} - ${(metalAmount! + sideDiamondAmount!).inRupeesFormat()}'
                : metalAmount!.inRupeesFormat(),
          ),
          Divider(height: 32 * r),
          _priceRow(
            r,
            'Grand Total',
            '${grandFrom.inRupeesFormat()} - ${grandTo.inRupeesFormat()}',
            bold: true,
          ),
        ],
      ),
    );
  }
}

/// ================= HELPERS =================

Widget _sectionHeader(double r, String title) {
  return Transform.translate(
    offset: Offset(-18 * r, 0), // cancel legend left padding
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 14 * r, vertical: 6 * r),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF90DCD0), Color(0xFFE1E4E4)],
        ),
        //borderRadius: BorderRadius.circular(8 * r),
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(8 * r),
          bottomRight: Radius.circular(8 * r),
          topLeft: Radius.zero,
          bottomLeft: Radius.zero,
        ),
      ),
      child: MyText(
        title,
        style: TextStyle(fontSize: 14 * r, fontWeight: FontWeight.w500),
      ),
    ),
  );
}

Widget _row(double r, String label, String value) {
  return Padding(
    padding: EdgeInsets.only(bottom: 12 * r),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        MyText(label, style: TextStyle(fontSize: 12 * r)),
        MyText(
          value,
          style: TextStyle(fontSize: 12 * r, fontWeight: FontWeight.w500),
        ),
      ],
    ),
  );
}

Widget _priceRow(double r, String label, String value, {bool bold = false}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      MyText(
        label,
        style: TextStyle(
          fontSize: 12 * r,
          fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      MyText(
        value,
        style: TextStyle(
          fontSize: 12 * r,
          fontWeight: bold ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
    ],
  );
}
