import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../shared/utils/scale_size.dart';
import '../presentation/widget/ultra_dropdown.dart'; // <-- IMPORTANT

const Color kMint = Color(0xFF90DCD0);

class TopButtonsRow extends StatefulWidget {
  final ValueChanged<int>? onTabSelected;
  final ValueChanged<String>? onSortSelected;
  final ValueChanged<dynamic>? onBranchSelected;
  final List<dynamic>? branchStores;

  const TopButtonsRow({
    super.key,
    this.onTabSelected,
    this.onSortSelected,
    this.onBranchSelected,
    this.branchStores,
  });

  @override
  State<TopButtonsRow> createState() => _TopButtonsRowState();
}

class _TopButtonsRowState extends State<TopButtonsRow> {
  int _selectedIndex = 0;
  int? _hoveredIndex;

  dynamic _selectedBranch; // store object/map
  String? _selectedSort;

  final items = const [
    ('Products In Store', 'tab', 178.0),
    ('Products At Other Branches', 'branch', 285.0),
    ('All Designs', 'tab', 155.0),
    ('Sort by', 'sort', 200.0),
  ];

  @override
  Widget build(BuildContext context) {
    final fem = ScaleSize.aspectRatio;

    return Container(
      color: const Color(0xFFF7F9F8),
      padding: EdgeInsets.only(
        left: 21,
        right: 46,
        top: 11 * fem,
        bottom: 11 * fem,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(items.length, (index) {
            final (title, type, width) = items[index];

            double spacing = 0;
            if (index < 2) spacing = 14;
            if (index == 2) spacing = 281;

            // -------------------------------------------------------
            // BRANCH DROPDOWN
            // -------------------------------------------------------
            if (type == 'branch') {
              return Row(
                children: [
                  UltraDropdown<dynamic>(
                    width: width,
                    height: 50,
                    items: widget.branchStores,
                    selectedItem: _selectedBranch,

                    placeholder: "Products At Other Branches",

                    itemBuilder: (item) => _branchLabel(item),
                    displayBuilder: (item) => _branchLabel(item),

                    onSelected: (store) {
                      setState(() => _selectedBranch = store);
                      widget.onBranchSelected?.call(store);
                    },
                  ),
                  SizedBox(width: spacing),
                ],
              );
            }

            // -------------------------------------------------------
            // SORT DROPDOWN
            // -------------------------------------------------------
            if (type == 'sort') {
              return Row(
                children: [
                  UltraDropdown<String>(
                    width: width,
                    height: 50,
                    items: const [
                      "Price: High to Low",
                      "Price: Low to High",
                      "Best Sellers",
                      "New Arrivals",
                    ],
                    selectedItem: _selectedSort,
                    placeholder: "Sort by",
                    itemBuilder: (s) => s,
                    displayBuilder: (s) => s ?? '',

                    onSelected: (value) {
                      setState(() => _selectedSort = value);
                      widget.onSortSelected?.call(value);
                    },
                  ),
                  SizedBox(width: spacing),
                ],
              );
            }

            // -------------------------------------------------------
            // PILL BUTTONS
            // -------------------------------------------------------
            return Row(
              children: [
                _UltraPillButton(
                  title: title,
                  isSelected: _selectedIndex == index,
                  isHovered: _hoveredIndex == index,
                  width: width,
                  height: 50,
                  onTap: () {
                    setState(() => _selectedIndex = index);
                    widget.onTabSelected?.call(index);
                  },
                  onHover: (hover) =>
                      setState(() => _hoveredIndex = hover ? index : null),
                ),
                SizedBox(width: spacing),
              ],
            );
          }),
        ),
      ),
    );
  }

  // helper for labels
  String _branchLabel(dynamic item) {
    if (item == null) return '';

    if (item is Map<String, dynamic>) {
      final name = item['name'] ?? item['branchName'] ?? item['title'];
      final code = item['code'] ?? item['branchCode'];
      if (name != null && code != null) return "$name ($code)";
      if (name != null) return name.toString();
      return item.toString();
    }

    try {
      final dyn = item as dynamic;
      final name = dyn.name ?? dyn.branchName ?? dyn.title;
      final code = dyn.code ?? dyn.branchCode;
      if (name != null && code != null) return "$name ($code)";
      if (name != null) return name.toString();
    } catch (_) {}

    return item.toString();
  }
}

///////////////////////////////////////////////////////////////////////////
/// Pill Button (unchanged)
///////////////////////////////////////////////////////////////////////////

class _UltraPillButton extends StatelessWidget {
  final String title;
  final bool isSelected;
  final bool isHovered;
  final double width;
  final double height;
  final VoidCallback onTap;
  final ValueChanged<bool> onHover;

  const _UltraPillButton({
    required this.title,
    required this.isSelected,
    required this.isHovered,
    required this.width,
    required this.height,
    required this.onTap,
    required this.onHover,
  });

  @override
  Widget build(BuildContext context) {
    final filled = isSelected;
    return MouseRegion(
      onEnter: (_) => onHover(true),
      onExit: (_) => onHover(false),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          width: width,
          height: height,
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
            color: filled
                ? kMint
                : (isHovered ? kMint.withOpacity(0.08) : Colors.white),
            border: Border.all(color: filled ? kMint : Colors.black12),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: filled ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}
