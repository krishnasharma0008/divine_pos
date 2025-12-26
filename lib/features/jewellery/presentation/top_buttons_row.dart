import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/utils/scale_size.dart';
import '../presentation/widget/ultra_dropdown.dart';
import '../../../shared/widgets/text.dart';
import '../data/ui_providers.dart';

const Color kMint = Color(0xFF90DCD0);

class TopButtonsRow extends ConsumerStatefulWidget {
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
  ConsumerState<TopButtonsRow> createState() => _TopButtonsRowState();
}

class _TopButtonsRowState extends ConsumerState<TopButtonsRow> {
  int _selectedIndex = 0;
  int? _hoveredIndex;

  dynamic _selectedBranch;
  String? _selectedSort;

  // 👇 reset keys for forcing rebuild of dropdowns
  Key _branchKey = UniqueKey();
  Key _sortKey = UniqueKey();

  // 🔹 Public API that parent or notifier can call
  void clearAll() {
    setState(() {
      _selectedIndex = 0;
      _selectedBranch = null;
      _selectedSort = null;

      // 🔥 force rebuild of dropdowns
      _branchKey = UniqueKey();
      _sortKey = UniqueKey();
    });
  }

  /// Title, Type, Width
  final items = [
    ("Products In Store", "tab", 178.0),
    ("Products At Other Branches", "branch", 285.0),
    ("All Designs", "tab", 155.0),
    ("Sort by", "sort", 200.0),
  ];

  int _lastReset = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // 🔹 Listen to reset notifier
    final reset = ref.watch(topButtonsResetProvider);
    if (reset != _lastReset) {
      _lastReset = reset;
      clearAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    final fem = ScaleSize.aspectRatio;

    return Container(
      color: const Color(0xFFF6F6F6),
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 11 * fem, horizontal: 21 * fem),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(items.length, (index) {
            final title = items[index].$1;
            final type = items[index].$2;
            final width = items[index].$3;

            return Row(
              children: [
                if (index == 0) SizedBox(width: 48 * fem),
                if (type == "branch")
                  UltraDropdown<dynamic>(
                    key: _branchKey,
                    width: width * fem,
                    height: 50 * fem,
                    items: widget.branchStores,
                    selectedItem: _selectedBranch,
                    placeholder: "Products At Other Branches",
                    itemBuilder: (item) => _branchLabel(item),
                    displayBuilder: (item) => item == null
                        ? "Products At Other Branches"
                        : _branchLabel(item),
                    onSelected: (store) {
                      setState(() => _selectedBranch = store);
                      widget.onBranchSelected?.call(store);
                    },
                  ),

                if (type == "sort")
                  UltraDropdown<String>(
                    key: _sortKey,
                    width: width * fem,
                    height: 50 * fem,
                    items: const ["Best Sellers", "New Arrivals"],
                    selectedItem: _selectedSort,
                    placeholder: "Sort by",
                    itemBuilder: (s) => s,
                    //displayBuilder: (s) => s ?? '',
                    displayBuilder: (s) => s ?? 'Sort by',
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
                    width: width * fem,
                    height: 50 * fem,
                    onTap: () {
                      setState(() {
                        _selectedIndex = index;

                        if (index == 0 || index == 2) {
                          _selectedBranch = null;
                        }
                      });

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

  double _spacing(int index) {
    return switch (index) {
      0 => 14,
      1 => 14,
      2 => 251,
      _ => 0,
    };
  }

  String _branchLabel(dynamic item) {
    if (item == null) return '';

    if (item is Map<String, dynamic>) {
      final nickName = item['nickName'];
      final name = item['name'] ?? item['branchName'] ?? item['title'];
      final code = item['code'] ?? item['branchCode'];

      if (nickName != null) return nickName.toString();
      if (name != null && code != null) return "$name ($code)";
      return name?.toString() ?? item.toString();
    }

    try {
      final nickName = item.nickName;
      final name = item.name ?? item.branchName ?? item.title;
      final code = item.code ?? item.branchCode;

      if (nickName != null) return nickName.toString();
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
            borderRadius: BorderRadius.circular(15),
            color: filled
                ? kMint
                : isHovered
                ? kMint.withOpacity(0.10)
                : Colors.white,
            border: Border.all(
              width: 0.50,
              color: filled ? kMint : Color(0xFF90DCD0),
            ),
          ),
          child: MyText(
            title,
            style: TextStyle(
              fontSize: 16 * ScaleSize.aspectRatio,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w600,
              color: filled ? Colors.white : Color(0xFF90DCD0),
            ),
          ),
        ),
      ),
    );
  }
}
