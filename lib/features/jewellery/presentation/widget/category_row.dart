import 'package:divine_pos/shared/widgets/text.dart';
import 'package:flutter/material.dart';
import '../../../../shared/utils/scale_size.dart';
import '../../data/category_item.dart';

class CategoryRow extends StatelessWidget {
  final List<CategoryItem> items;
  final List<int> selectedIndexes;
  final void Function(int) onSelect;

  const CategoryRow({
    super.key,
    required this.items,
    required this.selectedIndexes,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final fem = ScaleSize.aspectRatio;
    return SizedBox(
      width: MediaQuery.of(context).size.width, // ✅ FULL WIDTH
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 12 * fem),
        child: Row(
          children: List.generate(items.length, (index) {
            final item = items[index];
            final isSelected = selectedIndexes.contains(index);

            return GestureDetector(
              onTap: () => onSelect(index),
              child: Container(
                margin: const EdgeInsets.only(right: 18),

                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 55 * fem,
                      height: 55 * fem,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFFEEEEEE)
                              : Colors.transparent,
                          width: 3 * fem,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFFE9E9E9),
                            blurRadius: 4,
                            offset: Offset(2, 1),
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          item.image,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              Icon(Icons.image_not_supported, size: 30 * fem),
                        ),
                      ),
                    ),
                    SizedBox(height: 6 * fem),
                    MyText(
                      item.label,
                      style: TextStyle(
                        fontSize: 14 * fem,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: const Color(0xFF333333),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
