import 'package:flutter/material.dart';
import '../../../../shared/utils/scale_size.dart';
import '../../../../shared/widgets/text.dart';

class DiamondShape {
  final String type;
  final String label;
  final String value;
  final String assetPath;

  const DiamondShape({
    required this.type,
    required this.label,
    required this.value,
    required this.assetPath,
  });
}

class ShapeSelector extends StatefulWidget {
  final String selectedShape;
  final int initialIndex;
  final ValueChanged<DiamondShape> onShapeChanged;

  const ShapeSelector({
    super.key,
    required this.selectedShape,
    required this.initialIndex,
    required this.onShapeChanged,
  });

  static const List<DiamondShape> allShapes = [
    DiamondShape(
      type: 'SOLITAIRE',
      label: 'Round',
      value: 'RND',
      assetPath: 'assets/diamond_value/round.png',
    ),
    DiamondShape(
      type: 'SOLITAIRE',
      label: 'Princess',
      value: 'PRN',
      assetPath: 'assets/diamond_value/princess.png',
    ),
    DiamondShape(
      type: 'SOLITAIRE',
      label: 'Pear',
      value: 'PER',
      assetPath: 'assets/diamond_value/pear.png',
    ),
    DiamondShape(
      type: 'SOLITAIRE',
      label: 'Oval',
      value: 'OVL',
      assetPath: 'assets/diamond_value/oval.png',
    ),
    DiamondShape(
      type: 'SOLUS',
      label: 'Radiant',
      value: 'RADQ',
      assetPath: 'assets/diamond_value/radiant.png',
    ),
    DiamondShape(
      type: 'SOLUS',
      label: 'Cushion',
      value: 'CUSQ',
      assetPath: 'assets/diamond_value/cushion.png',
    ),
    DiamondShape(
      type: 'SOLUS',
      label: 'Heart',
      value: 'HRT',
      assetPath: 'assets/diamond_value/heart.png',
    ),
  ];

  @override
  State<ShapeSelector> createState() => _ShapeSelectorState();
}

class _ShapeSelectorState extends State<ShapeSelector> {
  final ScrollController _scrollController = ScrollController();

  void _scrollLeft() {
    _scrollController.animateTo(
      _scrollController.offset - 120,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _scrollRight() {
    _scrollController.animateTo(
      _scrollController.offset + 120,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final fem = ScaleSize.aspectRatio;
    final shapes = ShapeSelector.allShapes;

    final currentSelectedShape = widget.selectedShape.isNotEmpty
        ? widget.selectedShape
        : (widget.initialIndex >= 0 && widget.initialIndex < shapes.length
              ? shapes[widget.initialIndex].value
              : '');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText(
          "Shape",
          style: TextStyle(fontSize: 14 * fem, fontFamily: 'Rushter Glory'),
        ),
        SizedBox(height: 16 * fem),

        SizedBox(
          height: 90 * fem,
          child: Stack(
            children: [
              ListView.separated(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 50 * fem),
                itemCount: shapes.length,
                separatorBuilder: (_, __) => SizedBox(width: 16 * fem),
                itemBuilder: (context, index) {
                  final shape = shapes[index];
                  final isSelected = currentSelectedShape == shape.value;

                  return ShapeItem(
                    label: shape.label,
                    assetPath: shape.assetPath,
                    isSelected: isSelected,
                    onTap: () => widget.onShapeChanged(shape),
                    fem: fem,
                  );
                },
              ),

              ScrollSideButton(isRight: false, onTap: _scrollLeft, fem: fem),

              ScrollSideButton(isRight: true, onTap: _scrollRight, fem: fem),
            ],
          ),
        ),
      ],
    );
  }
}

class ShapeItem extends StatelessWidget {
  final String label;
  final String assetPath;
  final bool isSelected;
  final VoidCallback onTap;
  final double fem;

  const ShapeItem({
    super.key,
    required this.label,
    required this.assetPath,
    required this.isSelected,
    required this.onTap,
    required this.fem,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18 * fem),
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 220),
        width: 90 * fem,
        padding: EdgeInsets.fromLTRB(0 * fem, 8 * fem, 0 * fem, 0 * fem),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF4FBF9) : Colors.white,
          borderRadius: BorderRadius.circular(8 * fem),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF16A085)
                : const Color(0xFFE5E5E5),
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 12 * fem,
                offset: Offset(0, 4),
              ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 46 * fem,
              height: 46 * fem,
              padding: EdgeInsets.fromLTRB(8 * fem, 8 * fem, 8 * fem, 8 * fem),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFE9F8F4)
                    : const Color(0xFFF7F7F7),
                borderRadius: BorderRadius.circular(12 * fem),
              ),
              child: Image.asset(assetPath, fit: BoxFit.contain),
            ),
            SizedBox(height: 10 * fem),
            MyText(
              label,
              style: TextStyle(
                fontSize: 13 * fem,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? const Color(0xFF1A1A1A)
                    : const Color(0xFF6F6F6F),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ScrollSideButton extends StatelessWidget {
  final bool isRight;
  final VoidCallback onTap;
  final double fem;

  const ScrollSideButton({
    super.key,
    required this.isRight,
    required this.onTap,
    required this.fem,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: isRight ? 0 : null,
      left: isRight ? null : 0,
      top: 20 * fem,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 24 * fem,
          height: 70 * fem,
          decoration: BoxDecoration(
            color: const Color(0xFFAED8CF),
            borderRadius: BorderRadius.horizontal(
              left: isRight ? Radius.circular(12 * fem) : Radius.zero,
              right: isRight ? Radius.zero : Radius.circular(12 * fem),
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 6 * fem,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Icon(
            isRight ? Icons.chevron_right : Icons.chevron_left,
            size: 28 * fem,
            color: const Color(0xFF3F3F3F),
          ),
        ),
      ),
    );
  }
}
