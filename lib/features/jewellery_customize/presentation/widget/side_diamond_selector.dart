import 'package:divine_pos/shared/widgets/text.dart';
import 'package:flutter/material.dart';
import '../../../../shared/utils/scale_size.dart';

class SideDiamondSelector extends StatefulWidget {
  final String title; // e.g. "Side Diamond : 48 / 0.232"
  final List<String> options; // ['IJ-SI', 'GH-VS', 'EF-VVS']
  final String? selectedValue;
  final ValueChanged<String> onChanged;
  //final double r;

  const SideDiamondSelector({
    super.key,
    required this.title,
    required this.options,
    required this.onChanged,
    this.selectedValue,
    //required this.r,
  });

  @override
  State<SideDiamondSelector> createState() => _SideDiamondSelectorState();
}

class _SideDiamondSelectorState extends State<SideDiamondSelector> {
  late String _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.selectedValue ?? widget.options.first;
  }

  @override
  Widget build(BuildContext context) {
    final r = ScaleSize.aspectRatio;

    return Container(
      //width: 270 * widget.r,
      height: 110 * r,
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1 * r, color: Color(0xFFBEE4DD)),
          borderRadius: BorderRadius.circular(15 * r),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(9 * r, 16 * r, 9 * r, 10 * r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 TITLE
            MyText(
              widget.title,
              style: TextStyle(
                color: Colors.black,
                fontSize: 14 * r,
                fontFamily: 'Rushter Glory',
                fontWeight: FontWeight.w400,
              ),
            ),

            SizedBox(height: 22 * r),

            // 🔹 SELECTABLE CHIPS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: widget.options.map((option) {
                final isSelected = option == _selected;

                return Padding(
                  padding: EdgeInsets.only(right: 9 * r),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(5 * r),
                    onTap: () {
                      setState(() => _selected = option);
                      widget.onChanged(option); // ✅ SEND TO PARENT
                    },
                    child: Container(
                      height: 36 * r,
                      padding: EdgeInsets.symmetric(horizontal: 10 * r),
                      decoration: ShapeDecoration(
                        color: isSelected
                            ? const Color(0xFFF4F4F4)
                            : const Color(0x84F4F4F4),
                        shape: RoundedRectangleBorder(
                          side: isSelected
                              ? BorderSide(
                                  width: 0.5 * r,
                                  color: Color(0xFF90DCD0),
                                )
                              : BorderSide.none,
                          borderRadius: BorderRadius.circular(5 * r),
                        ),
                      ),
                      child: Center(
                        child: MyText(
                          option,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14 * r,
                            fontFamily: 'Rushter Glory',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
