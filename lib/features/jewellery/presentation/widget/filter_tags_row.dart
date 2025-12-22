import 'package:flutter/material.dart';
import '../../../../shared/utils/scale_size.dart';

class FilterTagsRow extends StatelessWidget {
  final List<String> selectedFilters;
  final VoidCallback onClearAll;
  final Function(String) onRemoveTag;

  const FilterTagsRow({
    super.key,
    required this.selectedFilters,
    required this.onClearAll,
    required this.onRemoveTag,
  });

  //final r = ScaleSize.aspectRatio;

  @override
  Widget build(BuildContext context) {
    if (selectedFilters.isEmpty) return const SizedBox.shrink();

    final r = ScaleSize.aspectRatio; // ✅ single source

    return SizedBox(
      // ✅ FORCE FULL WIDTH
      width: MediaQuery.of(context).size.width,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12 * r, horizontal: 12 * r),
        alignment: Alignment.centerLeft, // ✅ HARD LEFT ANCHOR
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min, // ✅ Content expands right
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Filtered By:',
                style: TextStyle(fontSize: 16 * r, fontWeight: FontWeight.w500),
              ),

              SizedBox(width: 12 * r),

              // Clear All pill
              _pill(
                label: 'Clear All',
                showClose: false,
                onTap: onClearAll,
                r: r,
              ),
              SizedBox(width: 8 * r),

              // Filter Pills
              ...selectedFilters.map((tag) {
                return Padding(
                  padding: EdgeInsets.only(right: 8 * r),
                  child: _pill(
                    label: tag,
                    showClose: true,
                    onTap: () => onRemoveTag(tag),
                    r: r,
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pill({
    required String label,
    required bool showClose,
    required VoidCallback onTap,
    required double r,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20 * r, vertical: 10 * r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10 * r),
          border: Border.all(color: const Color(0xFFE2D4BF), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 4 * r,
              offset: Offset(0, 2 * r),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 15 * r, fontWeight: FontWeight.w500),
            ),
            if (showClose) ...[
              SizedBox(width: 8 * r),
              Icon(Icons.close, size: 16 * r, color: Colors.grey),
            ],
          ],
        ),
      ),
    );
  }
}
