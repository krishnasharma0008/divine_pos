import 'package:flutter/material.dart';

import '../../../../shared/widgets/text.dart';

class FilterSection extends StatefulWidget {
  final String title;
  final Widget child;
  final bool initiallyExpanded;
  final double fem;

  const FilterSection({
    super.key,
    required this.title,
    required this.child,
    this.initiallyExpanded = false,
    this.fem = 1.0,
  });

  @override
  State<FilterSection> createState() => _FilterSectionState();
}

class _FilterSectionState extends State<FilterSection> {
  late bool expanded;

  @override
  void initState() {
    expanded = widget.initiallyExpanded;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final fem = widget.fem;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => expanded = !expanded),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 15 * fem),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MyText(
                  widget.title,
                  style: TextStyle(
                    fontSize: 16 * fem,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Icon(
                  expanded ? Icons.expand_less : Icons.expand_more,
                  size: 20 * fem,
                ),
              ],
            ),
          ),
        ),
        //SizedBox(height: 13 * fem),
        if (expanded)
          Padding(
            padding: EdgeInsets.only(bottom: fem * 15),
            child: widget.child,
          ),
        // SizedBox(height: 15 * fem),
        // Divider(height: 1, color: Colors.black.withValues(alpha: 0.08)),
        // SizedBox(height: 15 * fem),
      ],
    );
  }
}
