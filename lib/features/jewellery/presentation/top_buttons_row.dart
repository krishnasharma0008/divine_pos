import 'package:flutter/material.dart';
import '../../../shared/utils/scale_size.dart';

class TopButtonsRow extends StatefulWidget {
  final ValueChanged<int>? onTabSelected;
  const TopButtonsRow({super.key, this.onTabSelected});

  @override
  State<TopButtonsRow> createState() => _TopButtonsRowState();
}

class _TopButtonsRowState extends State<TopButtonsRow> {
  int _selectedIndex = 0;
  int? _hoveredIndex;

  static const Color mint = Color(0xFF9CE3D6);

  @override
  Widget build(BuildContext context) {
    final fem = ScaleSize.aspectRatio;

    final items = [
      ('Products In Store', false, 178.0),
      ('Products At Other Branches', true, 285.0),
      ('All Designs', false, 155.0),
      ('Sort by', true, 200.0),
    ];

    return Container(
      color: const Color(0xFFF7F9F8),
      padding: EdgeInsets.only(
        left: 21,
        right: 46,
        top: 11 * fem,
        bottom: 11 * fem,
      ),
      child: SizedBox(
        width: double.infinity,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(items.length, (index) {
              final (title, showDropdown, width) = items[index];

              // spacing logic
              double spacing = 0;
              if (index < 2) spacing = 14; // btn1→btn2, btn2→btn3
              if (index == 2) spacing = 281; // btn3→btn4

              return Row(
                children: [
                  _TopPillButton(
                    title: title,
                    isSelected: _selectedIndex == index,
                    isHovered: _hoveredIndex == index,
                    showDropdown: showDropdown,
                    width: width,
                    height: 50,
                    onTap: () {
                      setState(() => _selectedIndex = index);
                      widget.onTabSelected?.call(index);
                    },
                    onHover: (hover) =>
                        setState(() => _hoveredIndex = hover ? index : null),
                  ),
                  if (index != items.length - 1) SizedBox(width: spacing),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _TopPillButton extends StatelessWidget {
  final String title;
  final bool isSelected;
  final bool isHovered;
  final bool showDropdown;
  final VoidCallback onTap;
  final ValueChanged<bool> onHover;
  final double width;
  final double height;

  static const Color mint = Color(0xFF90DCD0);

  const _TopPillButton({
    required this.title,
    required this.isSelected,
    required this.isHovered,
    required this.showDropdown,
    required this.onTap,
    required this.onHover,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final bool filled = isSelected;
    final Color baseColor = filled ? mint : Colors.white;
    final Color textColor = filled ? Colors.white : mint;

    return MouseRegion(
      onEnter: (_) => onHover(true),
      onExit: (_) => onHover(false),
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        hoverColor: Colors.transparent,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: width,
          height: height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isHovered && !filled ? mint.withOpacity(0.08) : baseColor,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Color(0xFF90DCD0), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
                textAlign: TextAlign.center,
              ),
              if (showDropdown) ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: textColor,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
