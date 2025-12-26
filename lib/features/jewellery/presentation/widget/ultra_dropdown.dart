import 'dart:ui';
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

  /// Converts item → label for list
  final String Function(T item) itemBuilder;

  /// Converts item → label for main box
  final String Function(T? item) displayBuilder;

  /// Optional: converts item → canonical string used for equality comparison.
  /// If not provided, `itemBuilder` is used as the comparator.
  final String Function(T? item)? itemAsString;

  /// Callback
  final ValueChanged<T> onSelected;

  final String placeholder;

  const UltraDropdown({
    super.key,
    required this.width,
    required this.height,
    this.maxHeight = 240,
    required this.items,
    required this.selectedItem,
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
  bool isOpen = false;

  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween(
      begin: const Offset(0, -0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  /// Rebuild when parent updates selectedItem
  @override
  void didUpdateWidget(covariant UltraDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedItem != oldWidget.selectedItem) {
      setState(() {
        // Forces rebuild to update displayed label
      });
    }
  }

  String _canonicalString(T? item) {
    if (item == null) return '';
    if (widget.itemAsString != null) {
      return widget.itemAsString!(item);
    }
    try {
      return widget.itemBuilder(item);
    } catch (_) {
      return item.toString();
    }
  }

  void _toggleDropdown() {
    if (!mounted) return;

    if (isOpen) {
      _controller.reverse();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          _overlayEntry?.remove();
        } catch (_) {}
        _overlayEntry = null;
      });
    } else {
      if (_overlayEntry == null) {
        _overlayEntry = _createOverlay();
        Overlay.of(context)?.insert(_overlayEntry!);
      }
      _controller.forward();
    }

    setState(() => isOpen = !isOpen);
  }

  OverlayEntry _createOverlay() {
    final renderBox = context.findRenderObject() as RenderBox;
    final targetPosition = renderBox.localToGlobal(Offset.zero);
    final targetSize = renderBox.size;

    return OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            // Full-screen transparent layer to detect outside taps
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  if (mounted && isOpen) _toggleDropdown();
                },
                child: const SizedBox(),
              ),
            ),

            // The dropdown itself, anchored to the field
            Positioned(
              left: targetPosition.dx,
              top: targetPosition.dy + targetSize.height + 8,
              width: widget.width,
              child: Material(
                color: Colors.transparent,
                child: FadeTransition(
                  opacity: _fade,
                  child: SlideTransition(
                    position: _slide,
                    child: Container(
                      constraints: BoxConstraints(maxHeight: widget.maxHeight),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: kMint.withOpacity(0.28),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: widget.items == null
                          ? const Padding(
                              padding: EdgeInsets.all(16),
                              child: SizedBox(
                                height: 40,
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                            )
                          : _buildList(widget.items!),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildList(List<T> items) {
    final fem = ScaleSize.aspectRatio;

    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(14),
        child: Text("No items", style: TextStyle(color: Colors.black54)),
      );
    }

    final selectedCanonical = _canonicalString(widget.selectedItem);

    return ListView.separated(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: 6),
      itemCount: items.length,
      separatorBuilder: (_, __) =>
          const Divider(height: 1, color: Colors.black12),
      itemBuilder: (_, index) {
        final item = items[index];
        final label = widget.itemBuilder(item);

        final selected =
            selectedCanonical.isNotEmpty &&
            selectedCanonical == _canonicalString(item);

        return InkWell(
          onTap: () {
            widget.onSelected(item);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && isOpen) _toggleDropdown();
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: selected ? const Color(0xFF90DCD0) : Colors.transparent,
            ),
            child: Row(
              children: [
                Expanded(
                  child: MyText(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: selected ? Colors.white : const Color(0xFF90DCD0),
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Montserrat',
                      fontSize: 16 * fem,
                    ),
                  ),
                ),
                if (selected)
                  const Icon(Icons.check, size: 18, color: Colors.white),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    try {
      _overlayEntry?.remove();
    } catch (_) {}
    _overlayEntry = null;

    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fem = ScaleSize.aspectRatio;

    final display = widget.selectedItem == null
        ? widget.placeholder
        : widget.displayBuilder(widget.selectedItem);

    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggleDropdown,
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
                  display,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: const Color(0xFF90DCD0),
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Montserrat',
                    fontSize: 16 * fem,
                  ),
                ),
              ),
              Icon(
                isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                color: kMint,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
