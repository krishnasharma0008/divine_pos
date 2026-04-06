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
  //final ValueChanged<StoreDetail>? onBranchSelected;
  final ValueChanged<StoreDetail?>? onBranchSelected;
  final List<StoreDetail>? branchStores;
  final bool isSolitaire;

  const TopButtonsRow({
    super.key,
    this.onTabSelected,
    this.onSortSelected,
    this.onBranchSelected,
    this.branchStores,
    required this.isSolitaire,
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
      height: fem * 50,
      padding: EdgeInsets.symmetric(horizontal: 16 * fem, vertical: 7 * fem),
      child: CustomScrollView(
        scrollDirection: Axis.horizontal,
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Row(
              children: [
                SizedBox(width: 14 * fem),

                _PillButton(
                  title: 'Products In Store',
                  selected: _selectedTab == 0,
                  width: 178 * fem,
                  onTap: () => _selectTab(0),
                ),

                SizedBox(width: 14),

                // ── NEW: All Store button ──────────────────────────────────
                // _PillButton(
                //   title: 'All Store',
                //   selected: _selectedTab == 1,
                //   width: 130 * fem,
                //   onTap: () => _selectTab(1),
                // ),

                // SizedBox(width: 14),

                // UltraDropdown<StoreDetail>(
                //   width: 420 * fem,
                //   height: 50 * fem,
                //   items: widget.branchStores,
                //   selectedItem: _selectedBranch,
                //   placeholder: 'Products At Other Branches',
                //   itemBuilder: _branchLabel,
                //   displayBuilder: (item) => item == null
                //       ? 'Products At Other Branches'
                //       : _branchLabel(item),
                //   onSelected: (store) {
                //     setState(() => _selectedBranch = store);
                //     widget.onBranchSelected?.call(store);
                //   },
                // ),
                UltraDropdown<Object>(
                  width: 420 * fem,
                  height: 50 * fem,
                  items: [
                    'ALL', // All Store
                    ...?widget.branchStores, // real branches
                  ],
                  selectedItem: _selectedBranch, // ?? 'ALL',
                  placeholder: 'Products At Other Branches',
                  itemBuilder: (item) {
                    if (item is String && item == 'ALL') return 'All Store';
                    final store = item as StoreDetail;
                    return _branchLabel(store);
                  },
                  // displayBuilder: (item) {
                  //   if (item == null || (item is String && item == 'ALL')) {
                  //     return 'Products At Other Branches';
                  //   }
                  //   final store = item as StoreDetail;
                  //   return _branchLabel(store);
                  // },
                  displayBuilder: (item) {
                    if (item == null) {
                      return 'Products At Other Branches';
                    }
                    if (item is String && item == 'ALL') {
                      return 'All Store';
                    }
                    final store = item as StoreDetail;
                    return _branchLabel(store);
                  },
                  onSelected: (item) {
                    if (item is String && item == 'ALL') {
                      setState(() {
                        _selectedBranch = null;
                      });
                      widget.onBranchSelected?.call(null); // All Store
                    } else {
                      final store = item as StoreDetail;
                      setState(() {
                        _selectedBranch = store;
                      });
                      widget.onBranchSelected?.call(store);
                    }
                  },
                ),

                SizedBox(width: 14),

                if (!widget.isSolitaire)
                  _PillButton(
                    title: 'All Designs',
                    selected: _selectedTab == 1,
                    width: 155 * fem,
                    onTap: () => _selectTab(1),
                  )
                else
                  SizedBox(width: 155 * fem),
                Spacer(),

                UltraDropdown<String>(
                  width: 200 * fem,
                  height: 50 * fem,
                  items: const ['Low to high', 'High to low', 'New Arrivals'],
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
        ],
      ),
    );
  }

  void _selectTab(int index) {
    setState(() {
      _selectedTab = index;
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
    final fem = ScaleSize.aspectRatio;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: width,
        height: 50 * fem,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? kMint : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: kMint, width: 0.5),
        ),
        child: MyText(
          title,
          style: TextStyle(
            fontSize: 15 * fem,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : kMint,
          ),
        ),
      ),
    );
  }
}
