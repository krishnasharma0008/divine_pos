import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/utils/scale_size.dart';
import '../../../shared/widgets/text.dart';
import '../presentation/widget/ultra_dropdown.dart';
import '../../jewellery/data/store_details.dart';

const Color kMint = Color(0xFF90DCD0);

class TopButtonsRow extends ConsumerStatefulWidget {
  final ValueChanged<int>? onTabSelected;
  final ValueChanged<String>? onSortSelected;
  final ValueChanged<StoreDetail>? onBranchSelected;
  final List<StoreDetail>? branchStores;

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
  int _selectedTab = 0;
  StoreDetail? _selectedBranch;
  String? _selectedSort;

  @override
  Widget build(BuildContext context) {
    final fem = ScaleSize.aspectRatio;

    return Container(
      color: const Color(0xFFF6F6F6),
      padding: EdgeInsets.symmetric(horizontal: 21 * fem, vertical: 11 * fem),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            SizedBox(width: 48 * fem),

            _PillButton(
              title: 'Products In Store',
              selected: _selectedTab == 0,
              width: 178 * fem,
              onTap: () => _selectTab(0),
            ),

            SizedBox(width: 14),

            UltraDropdown<StoreDetail>(
              width: 420 * fem,
              height: 50 * fem,
              items: widget.branchStores,
              selectedItem: _selectedBranch,
              placeholder: 'Products At Other Branches',
              itemBuilder: _branchLabel,
              displayBuilder: (item) => item == null
                  ? 'Products At Other Branches'
                  : _branchLabel(item),
              onSelected: (store) {
                setState(() => _selectedBranch = store);
                widget.onBranchSelected?.call(store);
              },
            ),

            SizedBox(width: 14),

            _PillButton(
              title: 'All Designs',
              selected: _selectedTab == 2,
              width: 155 * fem,
              onTap: () => _selectTab(2),
            ),

            SizedBox(width: 251),

            UltraDropdown<String>(
              width: 200 * fem,
              height: 50 * fem,
              items: const ['Best Sellers', 'New Arrivals'],
              selectedItem: _selectedSort,
              placeholder: 'Sort by',
              itemBuilder: (s) => s,
              displayBuilder: (s) => s ?? 'Sort by',
              onSelected: (value) {
                setState(() => _selectedSort = value);
                widget.onSortSelected?.call(value);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _selectTab(int index) {
    setState(() {
      _selectedTab = index;
      //_selectedBranch = null;
    });
    widget.onTabSelected?.call(index);
  }

  String _branchLabel(StoreDetail item) {
    return item.nickName.isNotEmpty
        ? item.nickName
        : '${item.name} (${item.code})';
  }
}

////////////////////////////////////////////////////////////////////////////////
/// Pill Button
////////////////////////////////////////////////////////////////////////////////

class _PillButton extends StatelessWidget {
  final String title;
  final bool selected;
  final double width;
  final VoidCallback onTap;

  const _PillButton({
    required this.title,
    required this.selected,
    required this.width,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: width,
        height: 50 * ScaleSize.aspectRatio,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? kMint : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: kMint, width: 0.5),
        ),
        child: MyText(
          title,
          style: TextStyle(
            fontSize: 16 * ScaleSize.aspectRatio,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : kMint,
          ),
        ),
      ),
    );
  }
}
