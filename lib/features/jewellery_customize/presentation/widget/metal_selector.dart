import 'package:flutter/material.dart';
import '../../../../shared/widgets/styled_dropdown.dart';

class MetalSelectorCard extends StatelessWidget {
  final List<String>? metalColors;
  final List<String>? metalPurity;
  final String? selectedMetalColor;
  final String? selectedMetalPurity;
  final ValueChanged<String>? onMetalColorChanged;
  final ValueChanged<String>? onMetalPurityChanged;
  final double r;

  const MetalSelectorCard({
    super.key,
    required this.metalColors,
    required this.metalPurity,
    required this.selectedMetalColor,
    required this.selectedMetalPurity,
    required this.onMetalColorChanged,
    required this.onMetalPurityChanged,
    required this.r,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 290 * r, // same as SideDiamondSelector
      height: 105 * r, // same height
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1 * r, color: const Color(0xFFBEE4DD)),
          borderRadius: BorderRadius.circular(15 * r),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          9 * r,
          16 * r,
          9 * r,
          10 * r,
        ), // same padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 TITLE (matches style)
            Text(
              'Metal',
              style: TextStyle(
                color: Colors.black,
                fontSize: 14 * r,
                fontFamily: 'Rushter Glory',
                fontWeight: FontWeight.w400,
              ),
            ),

            SizedBox(height: 16 * r), // same vertical gap as options row
            // 🔹 TWO DROPDOWNS (same place where chips row is)
            Row(
              children: [
                if (metalColors?.isNotEmpty ?? false)
                  SizedBox(
                    width: 110 * r,
                    child: StyledDropdown(
                      label: '',
                      value: selectedMetalColor,
                      items: metalColors!,
                      onChanged: (value) {
                        if (value != null) {
                          onMetalColorChanged?.call(value);
                        }
                      },
                      width: 110 * r,
                    ),
                  ),

                if (metalPurity?.isNotEmpty ?? false) ...[
                  SizedBox(width: 9 * r),
                  SizedBox(
                    width: 110 * r,
                    child: StyledDropdown(
                      label: '',
                      value: selectedMetalPurity,
                      items: metalPurity!,
                      onChanged: (value) {
                        if (value != null) {
                          onMetalPurityChanged?.call(value);
                        }
                      },
                      width: 110 * r,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
