import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PUBLIC ENTRY POINT
// Call this from anywhere you have a single image URL (network or asset).
// ─────────────────────────────────────────────────────────────────────────────
void showProductImagePopup(
  BuildContext context, {
  required String imageUrl,
  String? heroTag,
}) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Product Image',
    barrierColor: Colors.black.withOpacity(0.82),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (_, __, ___) =>
        _ProductImagePopup(imageUrl: imageUrl, heroTag: heroTag),
    transitionBuilder: (_, anim, __, child) {
      final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween(begin: 0.90, end: 1.0).animate(curved),
          child: child,
        ),
      );
    },
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// POPUP WIDGET
// ─────────────────────────────────────────────────────────────────────────────
class _ProductImagePopup extends StatefulWidget {
  final String imageUrl;
  final String? heroTag;

  const _ProductImagePopup({required this.imageUrl, this.heroTag});

  @override
  State<_ProductImagePopup> createState() => _ProductImagePopupState();
}

class _ProductImagePopupState extends State<_ProductImagePopup> {
  static const _fallback = 'assets/jewellery/No_Image_Available.jpg';
  static const _gold = Color(0xFFB79D4B);

  final TransformationController _transformCtrl = TransformationController();
  bool _isZoomed = false;

  @override
  void dispose() {
    _transformCtrl.dispose();
    super.dispose();
  }

  void _resetZoom() {
    _transformCtrl.value = Matrix4.identity();
    setState(() => _isZoomed = false);
  }

  void _zoomIn(Offset tapPosition, BuildContext context) {
    final size = MediaQuery.of(context).size;
    final scale = 2.8;
    final x = -tapPosition.dx * (scale - 1);
    final y = -tapPosition.dy * (scale - 1);

    _transformCtrl.value = Matrix4.identity()
      ..translate(x, y)
      ..scale(scale);
    setState(() => _isZoomed = true);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isNetwork = widget.imageUrl.startsWith('http');

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: size.width * 0.05,
        vertical: size.height * 0.06,
      ),
      child: Container(
        width: size.width * 0.90,
        height: size.height * 0.80,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.65),
              blurRadius: 50,
              spreadRadius: 10,
            ),
            BoxShadow(
              color: _gold.withOpacity(0.10),
              blurRadius: 30,
              spreadRadius: -5,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            children: [
              // ── Zoomable image ───────────────────────────────────────────
              Positioned.fill(
                top: 56,
                bottom: 52,
                child: GestureDetector(
                  onDoubleTapDown: (d) {
                    if (_isZoomed) {
                      _resetZoom();
                    } else {
                      _zoomIn(d.localPosition, context);
                    }
                  },
                  child: InteractiveViewer(
                    transformationController: _transformCtrl,
                    minScale: 0.8,
                    maxScale: 6.0,
                    clipBehavior: Clip.none,
                    onInteractionEnd: (_) {
                      // detect if user manually zoomed back to ~1x
                      final scale = _transformCtrl.value.getMaxScaleOnAxis();
                      if (scale < 1.05) _resetZoom();
                    },
                    child: Center(child: _buildImage(isNetwork)),
                  ),
                ),
              ),

              // ── Top bar ──────────────────────────────────────────────────
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    // border: Border(
                    //   bottom: BorderSide(
                    //     color: Colors.black.withOpacity(0.06),
                    //     width: 1,
                    //   ),
                    // ),
                  ),
                  child: Row(
                    children: [
                      // Zoom-state badge (left side)
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: _isZoomed
                            ? GestureDetector(
                                key: const ValueKey('reset'),
                                onTap: _resetZoom,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _gold.withOpacity(0.10),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: _gold.withOpacity(0.40),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.zoom_out_rounded,
                                        color: _gold,
                                        size: 15,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        'Reset zoom',
                                        style: TextStyle(
                                          color: _gold,
                                          fontSize: 12,
                                          fontFamily: 'Montserrat',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(key: ValueKey('empty')),
                      ),

                      const Spacer(),

                      // Close button — right side
                      _CircleIconButton(
                        icon: Icons.close_rounded,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Bottom hint bar ──────────────────────────────────────────
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    // border: Border(
                    //   top: BorderSide(
                    //     color: Colors.black.withOpacity(0.06),
                    //     width: 1,
                    //   ),
                    // ),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.pinch_rounded,
                        size: 14,
                        color: Colors.black.withOpacity(0.30),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Pinch to zoom  ·  Double-tap to enlarge',
                        style: TextStyle(
                          color: Colors.black.withOpacity(0.35),
                          fontSize: 11,
                          letterSpacing: 0.3,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage(bool isNetwork) {
    if (widget.imageUrl.isEmpty) {
      return Image.asset(_fallback, fit: BoxFit.contain);
    }

    if (!isNetwork) {
      return Image.asset(widget.imageUrl, fit: BoxFit.contain);
    }

    return Image.network(
      widget.imageUrl,
      fit: BoxFit.contain,
      loadingBuilder: (_, child, progress) {
        if (progress == null) return child;
        final value = progress.expectedTotalBytes != null
            ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
            : null;
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 48,
                height: 48,
                child: CircularProgressIndicator(
                  value: value,
                  strokeWidth: 2.5,
                  color: _gold,
                  backgroundColor: Colors.white12,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                value != null ? '${(value * 100).toInt()}%' : 'Loading...',
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 12,
                  fontFamily: 'Montserrat',
                ),
              ),
            ],
          ),
        );
      },
      errorBuilder: (_, __, ___) => Image.asset(_fallback, fit: BoxFit.contain),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CIRCLE ICON BUTTON
// ─────────────────────────────────────────────────────────────────────────────
class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withOpacity(0.06),
          border: Border.all(color: Colors.black.withOpacity(0.12)),
        ),
        child: Icon(icon, color: Colors.black87, size: 18),
      ),
    );
  }
}
