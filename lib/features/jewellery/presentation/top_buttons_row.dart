import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../shared/utils/scale_size.dart';
import '../presentation/widget/ultra_dropdown.dart';

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

  dynamic _selectedBranch;
  String? _selectedSort;

  /// Title, Type, Width
  final items = [
    ("Products In Store", "tab", 178.0),
    ("Products At Other Branches", "branch", 285.0),
    ("All Designs", "tab", 155.0),
    ("Sort by", "sort", 200.0),
  ];

  @override
  Widget build(BuildContext context) {
    final fem = ScaleSize.aspectRatio;

    return Container(
      color: const Color(0xFFF7F9F8),
      padding: EdgeInsets.symmetric(vertical: 11 * fem, horizontal: 21),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(items.length, (index) {
            final title = items[index].$1;
            final type = items[index].$2;
            final width = items[index].$3;

            return Row(
              children: [
                if (type == "branch")
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

                if (type == "sort")
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

                if (type == "tab")
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
                    onHover: (hover) {
                      setState(() => _hoveredIndex = hover ? index : null);
                    },
                  ),

                SizedBox(width: _spacing(index)),
              ],
            );
          }),
        ),
      ),
    );
  }

  // Spacing rules made simpler & consistent
  double _spacing(int index) {
    return switch (index) {
      0 => 14, // After "Products In Store"
      1 => 14, // After branch dropdown
      2 => 281, // After "All Designs"
      _ => 0,
    };
  }

  // Helper for labels
  String _branchLabel(dynamic item) {
    if (item == null) return '';

    if (item is Map<String, dynamic>) {
      final name = item['name'] ?? item['branchName'] ?? item['title'];
      final code = item['code'] ?? item['branchCode'];

      if (name != null && code != null) return "$name ($code)";
      return name?.toString() ?? item.toString();
    }

    try {
      final name = item.name ?? item.branchName ?? item.title;
      final code = item.code ?? item.branchCode;

      if (name != null && code != null) return "$name ($code)";
      return name?.toString() ?? item.toString();
    } catch (_) {}

    return item.toString();
  }
}

////////////////////////////////////////////////////////////////////////////////
/// Pill Button
////////////////////////////////////////////////////////////////////////////////

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
          duration: const Duration(milliseconds: 180),
          width: width,
          height: height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
            color: filled
                ? kMint
                : isHovered
                ? kMint.withOpacity(0.10)
                : Colors.white,
            border: Border.all(color: filled ? kMint : Colors.black12),
          ),
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
