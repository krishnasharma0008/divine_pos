import 'package:flutter/material.dart';
import '../../../../shared/utils/scale_size.dart';
import '../../../../shared/widgets/text.dart';

const Color kMint = Color(0xFF90DCD0);

class UltraDropdown<T> extends StatefulWidget {
  final double width;
  final double height;
  final double maxHeight;
  final List<T>? items;
  final T? selectedItem;

  final String Function(T item) itemBuilder;
  final String Function(T? item) displayBuilder;
  final String Function(T? item)? itemAsString;
  final ValueChanged<T> onSelected;
  final String placeholder;

  const UltraDropdown({
    super.key,
    required this.width,
    required this.height,
    this.maxHeight = 240,
    this.items,
    this.selectedItem,
    required this.itemBuilder,
    required this.displayBuilder,
    required this.onSelected,
    this.itemAsString,
    this.placeholder = "Select",
  });

  @override
  State<UltraDropdown<T>> createState() => _UltraDropdownState<T>();
}

class _UltraDropdownState<T> extends State<UltraDropdown<T>>
    with SingleTickerProviderStateMixin {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 180),
  );

  late final Animation<double> _fade = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOut,
  );

  late final Animation<Offset> _slide = Tween(
    begin: const Offset(0, -0.04),
    end: Offset.zero,
  ).animate(_fade);

  String _canon(T? item) {
    if (item == null) return '';
    return widget.itemAsString?.call(item) ?? widget.itemBuilder(item);
  }

  void _toggle() {
    if (_isOpen) {
      _controller.reverse();
      _overlayEntry?.remove();
      _overlayEntry = null;
    } else {
      _overlayEntry = _createOverlay();
      Overlay.of(context).insert(_overlayEntry!);
      _controller.forward();
    }
    setState(() => _isOpen = !_isOpen);
  }

  OverlayEntry _createOverlay() {
    final fem = ScaleSize.aspectRatio;

    return OverlayEntry(
      builder: (_) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: _toggle,
              behavior: HitTestBehavior.translucent,
            ),
          ),
          CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: const Offset(0, 58),
            child: Material(
              color: Colors.transparent,
              child: FadeTransition(
                opacity: _fade,
                child: SlideTransition(
                  position: _slide,
                  child: Container(
                    width: widget.width * fem,
                    constraints: BoxConstraints(maxHeight: widget.maxHeight),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: kMint.withOpacity(0.25),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: widget.items == null
                        ? const Padding(
                            padding: EdgeInsets.all(20),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        : _buildList(widget.items!, fem),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<T> items, double fem) {
    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(14),
        child: Text("No items", style: TextStyle(color: Colors.black54)),
      );
    }

    final selected = _canon(widget.selectedItem);

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 6),
      shrinkWrap: true,
      itemCount: items.length,
      separatorBuilder: (_, __) =>
          const Divider(height: 1, color: Colors.black12),
      itemBuilder: (_, i) {
        final item = items[i];
        final label = widget.itemBuilder(item);
        final isSelected = selected == _canon(item);

        return InkWell(
          onTap: () {
            widget.onSelected(item);
            _toggle();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: isSelected ? kMint : Colors.transparent,
            child: Row(
              children: [
                Expanded(
                  child: MyText(
                    label,
                    style: TextStyle(
                      color: isSelected ? Colors.white : kMint,
                      fontWeight: FontWeight.w600,
                      fontSize: 16 * fem,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ),
                if (isSelected)
                  const Icon(Icons.check, color: Colors.white, size: 18),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fem = ScaleSize.aspectRatio;

    final text = widget.selectedItem == null
        ? widget.placeholder
        : widget.displayBuilder(widget.selectedItem);

    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggle,
        child: Container(
          width: widget.width * fem,
          height: widget.height,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: kMint, width: 0.5),
          ),
          child: Row(
            children: [
              Expanded(
                child: MyText(
                  text,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: kMint,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                _isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                color: kMint,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
