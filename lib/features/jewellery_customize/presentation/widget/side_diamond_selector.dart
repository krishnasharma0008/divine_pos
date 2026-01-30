import 'package:flutter/material.dart';

class SideDiamondSelector extends StatefulWidget {
  final String title; // e.g. "Side Diamond : 48 / 0.232"
  final List<String> options; // ['IJ-SI', 'GH-VS', 'EF-VVS']
  final String? selectedValue;
  final ValueChanged<String> onChanged;
  final double r;

  const SideDiamondSelector({
    super.key,
    required this.title,
    required this.options,
    required this.onChanged,
    this.selectedValue,
    required this.r,
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
    return Container(
      width: 249 * widget.r,
      height: 105 * widget.r,
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1 * widget.r, color: Color(0xFFBEE4DD)),
          borderRadius: BorderRadius.circular(15 * widget.r),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          9 * widget.r,
          16 * widget.r,
          9 * widget.r,
          10 * widget.r,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 TITLE
            Text(
              widget.title,
              style: TextStyle(
                color: Colors.black,
                fontSize: 14 * widget.r,
                fontFamily: 'Rushter Glory',
                fontWeight: FontWeight.w400,
              ),
            ),

            SizedBox(height: 16 * widget.r),

            // 🔹 SELECTABLE CHIPS
            Row(
              children: widget.options.map((option) {
                final isSelected = option == _selected;

                return Padding(
                  padding: EdgeInsets.only(right: 9 * widget.r),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(5 * widget.r),
                    onTap: () {
                      setState(() => _selected = option);
                      widget.onChanged(option); // ✅ SEND TO PARENT
                    },
                    child: Container(
                      height: 36 * widget.r,
                      padding: EdgeInsets.symmetric(horizontal: 10 * widget.r),
                      decoration: ShapeDecoration(
                        color: isSelected
                            ? const Color(0xFFF4F4F4)
                            : const Color(0x84F4F4F4),
                        shape: RoundedRectangleBorder(
                          side: isSelected
                              ? BorderSide(
                                  width: 0.5 * widget.r,
                                  color: Color(0xFF90DCD0),
                                )
                              : BorderSide.none,
                          borderRadius: BorderRadius.circular(5 * widget.r),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          option,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14 * widget.r,
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
