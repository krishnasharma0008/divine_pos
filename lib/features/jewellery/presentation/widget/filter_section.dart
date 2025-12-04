import 'package:flutter/material.dart';
import '../../../../shared/utils/scale_size.dart';

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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 16 * fem,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Montserrat',
                ),
              ),
              Icon(
                expanded ? Icons.expand_less : Icons.expand_more,
                size: 20 * fem,
              ),
            ],
          ),
        ),
        SizedBox(height: 10 * fem),
        if (expanded) widget.child,
        SizedBox(height: 12 * fem),
        Divider(height: 1, color: Colors.black.withOpacity(0.08)),
        SizedBox(height: 13 * fem),
      ],
    );
  }
}
