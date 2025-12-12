import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../shared/widgets/grade_selecter.dart';

class SolitaireDetailsPanel extends StatefulWidget {
  final double r;

  // ✅ Pass dynamic grade options
  final List<String> caratGrades;
  final List<String> colorGrades;
  final List<String> clarityGrades;
  final List<String> sizeGrades;

  const SolitaireDetailsPanel({
    super.key,
    required this.r,
    this.caratGrades = const ["0.30", "0.40", "0.50", "0.70"],
    this.colorGrades = const ["D", "E", "F", "G", "H", "I"],
    this.clarityGrades = const ["VVS1", "VVS2", "VS1", "VS2"],
    this.sizeGrades = const ["12", "14", "16", "18"],
  });

  @override
  State<SolitaireDetailsPanel> createState() => _SolitaireDetailsPanelState();
}

class _SolitaireDetailsPanelState extends State<SolitaireDetailsPanel> {
  bool isCustomizing = false;

  double carat = 0.30;
  String color = "F";
  String clarity = "VVS2";
  String size = "14";

  double basePrice = 85000;

  double get finalPrice {
    double value = basePrice;
    value += carat * 45000;
    if (color == "D") value += 8000;
    if (clarity == "VVS1") value += 7000;
    if (size == "16") value += 3000;
    return value;
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.r;
    return Container(
      padding: EdgeInsets.all(20 * r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14 * r),
        boxShadow: const [
          BoxShadow(
            blurRadius: 14,
            offset: Offset(0, 6),
            color: Color(0x14000000),
          ),
        ],
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        child: isCustomizing ? _selectorsView(r) : _infoView(r),
      ),
    );
  }

  Widget _infoView(double r) {
    return Column(
      key: const ValueKey("info"),
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "Eternal Radiance Ring For Her",
          style: TextStyle(fontSize: 18 * r, fontWeight: FontWeight.w700),
        ),
        SizedBox(height: 8 * r),
        Text(
          "Crafted in 18kt gold with heart & arrows diamond.",
          style: TextStyle(fontSize: 13 * r),
        ),
        SizedBox(height: 14 * r),

        _infoCard("Carat", carat.toStringAsFixed(2), r),
        _infoCard("Color", color, r),
        _infoCard("Clarity", clarity, r),
        _infoCard("Size", size, r),

        SizedBox(height: 18 * r),

        Text(
          "₹ ${finalPrice.toStringAsFixed(0)}",
          style: TextStyle(
            fontSize: 22 * r,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF6C5022),
          ),
        ),

        SizedBox(height: 16 * r),

        OutlinedButton(
          onPressed: () => setState(() => isCustomizing = true),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFF6C5022)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12 * r),
            ),
            minimumSize: Size(double.infinity, 48 * r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/icons/customise.svg',
                width: 20 * r,
                colorFilter: const ColorFilter.mode(
                  Color(0xFF6C5022),
                  BlendMode.srcIn,
                ),
              ),
              SizedBox(width: 10 * r),
              Text(
                "Start customizing",
                style: TextStyle(
                  fontSize: 14 * r,
                  color: const Color(0xFF6C5022),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _selectorsView(double r) {
    return Column(
      key: const ValueKey("selectors"),
      children: [
        ColorGradeSelector(
          label: "Color",
          grades: widget.colorGrades,
          initialValue: size,
          onSelected: (v) => setState(() => size = v),
        ),
        ColorGradeSelector(
          label: "Clarity",
          grades: widget.clarityGrades,
          initialValue: size,
          onSelected: (v) => setState(() => size = v),
        ),
        ColorGradeSelector(
          label: "Carat",
          grades: widget.caratGrades,
          initialValue: size,
          onSelected: (v) => setState(() => size = v),
        ),
        ColorGradeSelector(
          label: "Ring Size",
          grades: widget.sizeGrades,
          initialValue: size,
          onSelected: (v) => setState(() => size = v),
        ),

        SizedBox(height: 20 * r),

        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() => isCustomizing = false);
                },
                child: const Text("Apply"),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    carat = 0.30;
                    color = "F";
                    clarity = "VVS2";
                    size = "14";
                    isCustomizing = false;
                  });
                },
                child: const Text("Reset"),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _infoCard(String title, String value, double r) {
    return Container(
      margin: EdgeInsets.only(bottom: 16 * r),
      padding: EdgeInsets.symmetric(horizontal: 18 * r, vertical: 18 * r),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16 * r),
        border: Border.all(color: const Color(0xFFBFEAE4)),
        color: const Color(0xFFF9FEFD),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 14 * r)),
          Text(
            value,
            style: TextStyle(fontSize: 15 * r, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
