import 'package:flutter/material.dart';
import '../../../../shared/utils/scale_size.dart';
import '../../../../shared/widgets/text.dart';

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

  @override
  Widget build(BuildContext context) {
    if (selectedFilters.isEmpty) return const SizedBox.shrink();

    final r = ScaleSize.aspectRatio.clamp(0.7, 1.3);

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 0 * r, horizontal: 12 * r),
        alignment: Alignment.centerLeft,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /// FIXED LABEL
            MyText(
              'Filtered By:',
              style: TextStyle(
                fontSize: 14 * r,
                fontWeight: FontWeight.w400,
                color: Color(0xFF222222),
              ),
            ),

            SizedBox(width: 15 * r),

            /// FIXED CLEAR ALL PILL
            _pill(
              label: 'Clear All',
              showClose: false,
              onTap: onClearAll,
              r: r,
            ),

            SizedBox(width: 12 * r),

            /// 👇 ONLY THIS SCROLLS
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: selectedFilters
                      .map(
                        (tag) => Padding(
                          padding: EdgeInsets.only(right: 8 * r),
                          child: _pill(
                            label: tag,
                            showClose: true,
                            onTap: () => onRemoveTag(tag),
                            r: r,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ],
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
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10 * r),
      child: InkWell(
        borderRadius: BorderRadius.circular(10 * r),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12 * r, vertical: 7 * r),
          decoration: BoxDecoration(
            color: showClose ? null : Color(0xFFEBEBEB),
            borderRadius: BorderRadius.circular(10 * r),
            border: Border.all(
              color: showClose
                  ? const Color(0xFFC3C3C3)
                  : const Color(0xFFC8AC7D),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 4 * r,
                offset: Offset(0, 2 * r),
              ),
            ],
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                MyText(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14 * r,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF222222),
                  ),
                ),
                if (showClose) ...[
                  SizedBox(width: 8 * r),
                  Icon(Icons.close, size: 14 * r, color: Color(0xFFE3E3E3)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
