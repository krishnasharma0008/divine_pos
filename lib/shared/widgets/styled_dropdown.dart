import 'package:flutter/material.dart';
import 'package:divine_pos/shared/widgets/text.dart';
import '../../../shared/utils/scale_size.dart';

class StyledDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final double width;

  const StyledDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.width = 160,
  });

  @override
  Widget build(BuildContext context) {
    final fem = ScaleSize.aspectRatio;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// LABEL
        MyText(
          label,
          style: TextStyle(
            fontSize: 12 * fem,
            fontFamily: 'Rushter Glory',
            color: Colors.black,
          ),
        ),

        SizedBox(height: 6 * fem),

        /// DROPDOWN CONTAINER
        Container(
          width: width * fem,
          height: 42 * fem,
          padding: EdgeInsets.symmetric(horizontal: 12 * fem),
          decoration: BoxDecoration(
            color: const Color(0xFFF4F4F4),
            borderRadius: BorderRadius.circular(10 * fem),
            border: Border.all(color: const Color(0xFF90DCD0), width: 1),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Color(0xFF6C5022),
              ),
              style: TextStyle(
                fontSize: 14 * fem,
                fontFamily: 'Rushter Glory',
                color: Colors.black,
              ),
              items: items
                  .map(
                    (e) => DropdownMenuItem<String>(value: e, child: MyText(e)),
                  )
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
