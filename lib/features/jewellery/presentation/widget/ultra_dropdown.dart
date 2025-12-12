import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

const Color kMint = Color(0xFF90DCD0);

class UltraDropdown<T> extends StatefulWidget {
  final double width;
  final double height;
  final List<T>? items;
  final T? selectedItem;

  /// Converts item → label for list
  final String Function(T item) itemBuilder;

  /// Converts item → label for main box
  final String Function(T? item) displayBuilder;

  /// Callback
  final ValueChanged<T> onSelected;

  final String placeholder;

  const UltraDropdown({
    super.key,
    required this.width,
    required this.height,
    required this.items,
    required this.selectedItem,
    required this.itemBuilder,
    required this.displayBuilder,
    required this.onSelected,
    this.placeholder = "Select",
  });

  @override
  State<UltraDropdown<T>> createState() => _UltraDropdownState<T>();
}

class _UltraDropdownState<T> extends State<UltraDropdown<T>> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool isOpen = false;

  void _toggleDropdown() {
    if (!mounted) return;

    if (isOpen) {
      _overlayEntry?.remove();
      _overlayEntry = null;
      GestureBinding.instance.pointerRouter.removeGlobalRoute(
        _tapOutsideHandler,
      );
    } else {
      _overlayEntry = _createOverlay();
      Overlay.of(context).insert(_overlayEntry!);
      GestureBinding.instance.pointerRouter.addGlobalRoute(_tapOutsideHandler);
    }

    setState(() => isOpen = !isOpen);
  }

  void _tapOutsideHandler(PointerEvent event) {
    if (event is PointerDownEvent && isOpen) _toggleDropdown();
  }

  OverlayEntry _createOverlay() {
    return OverlayEntry(
      builder: (context) => Positioned(
        width: widget.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          offset: Offset(0, widget.height + 8),
          showWhenUnlinked: false,
          child: Material(
            color: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: kMint.withOpacity(0.28),
                    blurRadius: 14,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: widget.items == null
                  ? const Padding(
                      padding: EdgeInsets.all(14),
                      child: SizedBox(
                        height: 40,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    )
                  : _buildList(widget.items!),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildList(List<T> items) {
    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: Text("No items"),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: items.map((item) {
        final label = widget.itemBuilder(item);
        final selected = widget.selectedItem == item;

        return InkWell(
          onTap: () {
            widget.onSelected(item);
            _toggleDropdown();
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
            decoration: BoxDecoration(
              color: selected ? kMint.withOpacity(0.12) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(child: Text(label, overflow: TextOverflow.ellipsis)),
                if (selected) const Icon(Icons.check, color: kMint, size: 18),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  void dispose() {
    GestureBinding.instance.pointerRouter.removeGlobalRoute(_tapOutsideHandler);
    _overlayEntry?.remove();
    _overlayEntry = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayText = widget.selectedItem == null
        ? widget.placeholder
        : widget.displayBuilder(widget.selectedItem);

    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggleDropdown,
        child: Container(
          width: widget.width,
          height: widget.height,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: kMint, width: 1.2),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(displayText, overflow: TextOverflow.ellipsis),
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
