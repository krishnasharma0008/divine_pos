import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../shared/utils/scale_size.dart';
import 'package:divine_pos/shared/widgets/text.dart';

/// ------------------------------------------------------------
/// IMAGE BUILDER
/// ------------------------------------------------------------
Widget buildProductImage(
  String url, {
  double? width,
  double? height,
  BoxFit fit = BoxFit.contain,
}) {
  if (url.isEmpty) {
    return Image.asset(
      'assets/jewellery/No_Image_Available.jpg',
      width: width,
      height: height,
      fit: fit,
    );
  }

  final isAsset = !url.startsWith('http');

  if (isAsset) {
    return Image.asset(url, width: width, height: height, fit: fit);
  }

  return CachedNetworkImage(
    imageUrl: url,
    width: width,
    height: height,
    fit: fit,
    placeholder: (_, __) =>
        const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    errorWidget: (_, __, ___) => Image.asset(
      'assets/jewellery/No_Image_Available.jpg',
      width: width,
      height: height,
      fit: fit,
    ),
  );
}

/// ------------------------------------------------------------
/// SHAPE → IMAGE MAP
/// Keys match the shape codes used by the drawer and providers:
///   RND, PRN, PER, OVL, MAQ, RADQ, CUSQ, HRT
/// ------------------------------------------------------------
const Map<String, List<String>> shapeImages = {
  'RND': [
    'assets/diamond_value/round.png',
    'assets/diamond_value/round.png',
    'assets/diamond_value/round.png',
    'assets/diamond_value/round.png',
  ],
  'OVL': [
    'assets/diamond_value/oval.png',
    'assets/diamond_value/oval.png',
    'assets/diamond_value/oval.png',
    'assets/diamond_value/oval.png',
  ],
  // FIX: was 'PRC' — drawer sends 'PRN'
  'PRN': [
    'assets/diamond_value/princess.png',
    'assets/diamond_value/princess.png',
    'assets/diamond_value/princess.png',
    'assets/diamond_value/princess.png',
  ],
  'PER': [
    'assets/diamond_value/pear.png',
    'assets/diamond_value/pear.png',
    'assets/diamond_value/pear.png',
    'assets/diamond_value/pear.png',
  ],
  // FIX: was 'MRQ' — drawer sends 'MAQ'
  'MAQ': [
    'assets/diamond_value/marquise.png',
    'assets/diamond_value/marquise.png',
    'assets/diamond_value/marquise.png',
    'assets/diamond_value/marquise.png',
  ],
  'RADQ': [
    'assets/diamond_value/radiant.png',
    'assets/diamond_value/radiant.png',
    'assets/diamond_value/radiant.png',
    'assets/diamond_value/radiant.png',
  ],
  // FIX: was 'CUSH' — drawer sends 'CUSQ'
  'CUSQ': [
    'assets/diamond_value/cushion.png',
    'assets/diamond_value/cushion.png',
    'assets/diamond_value/cushion.png',
    'assets/diamond_value/cushion.png',
  ],
  'HRT': [
    'assets/diamond_value/heart.png',
    'assets/diamond_value/heart.png',
    'assets/diamond_value/heart.png',
    'assets/diamond_value/heart.png',
  ],
};

/// ------------------------------------------------------------
/// IMAGE PREVIEW WITH THUMBNAILS
/// ------------------------------------------------------------
class ImagePreviewWithThumbnails extends StatefulWidget {
  final String? title;
  final String? description;
  final String? shape;
  final String? uid;
  final double? r;

  const ImagePreviewWithThumbnails({
    super.key,
    this.title,
    this.description,
    this.shape,
    this.uid,
    this.r,
  });

  @override
  State<ImagePreviewWithThumbnails> createState() =>
      _ImagePreviewWithThumbnailsState();
}

class _ImagePreviewWithThumbnailsState
    extends State<ImagePreviewWithThumbnails> {
  int selectedImageIndex = 0;

  @override
  void didUpdateWidget(ImagePreviewWithThumbnails oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset to the first thumbnail whenever the shape changes so we never
    // land mid-gallery on a new shape's image list.
    if (oldWidget.shape != widget.shape) {
      setState(() => selectedImageIndex = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.r ?? ScaleSize.aspectRatio;

    /// Get images based on shape
    final shapeKey = widget.shape?.toUpperCase() ?? '';
    final allImages = shapeImages[shapeKey] ?? [];

    if (allImages.isEmpty) {
      return const Center(child: Text('No images'));
    }

    final safeIndex = selectedImageIndex.clamp(0, allImages.length - 1);
    final currentUrl = allImages[safeIndex];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── LEFT: THUMBNAILS ─────────────────────────────────────────────────
        Container(
          width: 90 * r,
          padding: EdgeInsets.fromLTRB(22 * r, 67 * r, 0, 0),
          child: SizedBox(
            height: 426 * r,
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: allImages.length,
              itemBuilder: (context, index) {
                final active = safeIndex == index;
                return GestureDetector(
                  onTap: () => setState(() => selectedImageIndex = index),
                  child: Container(
                    margin: EdgeInsets.only(bottom: 20 * r),
                    padding: EdgeInsets.all(3 * r),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: active
                            ? const Color(0xFFB79D4B)
                            : Colors.transparent,
                        width: 2 * r,
                      ),
                      borderRadius: BorderRadius.circular(12 * r),
                    ),
                    child: buildProductImage(
                      allImages[index],
                      width: 62 * r,
                      height: 62 * r,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // ── RIGHT: MAIN IMAGE + INFO ──────────────────────────────────────────
        Expanded(
          child: GestureDetector(
            onTap: () => _openImagePopup(context, allImages, safeIndex),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 20 * r),
                      child: Container(
                        width: 20 * r,
                        height: 22 * r,
                        decoration: ShapeDecoration(
                          color: const Color(0xFFF4F4F4),
                          shape: OvalBorder(
                            side: BorderSide(
                              width: 0.5 * r,
                              color: const Color(0xFFD1D1D1),
                            ),
                          ),
                        ),
                        child: Center(
                          child: Transform.translate(
                            offset: Offset(0, -1 * r),
                            child: Text(
                              '+',
                              style: TextStyle(
                                color: const Color(0xFFB8B8B8),
                                fontSize: 16 * r,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w300,
                                letterSpacing: 0.32,
                              ),
                              textHeightBehavior: const TextHeightBehavior(
                                applyHeightToFirstAscent: false,
                                applyHeightToLastDescent: false,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: constraints.maxWidth,
                      height: 426 * r,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12 * r),
                      ),
                      child: InteractiveViewer(
                        minScale: 1,
                        maxScale: 4,
                        child: buildProductImage(
                          currentUrl,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    SizedBox(height: 16 * r),
                    MyText(
                      widget.title ?? '',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20 * r,
                        fontFamily: 'Rushter Glory',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 8 * r),
                    SizedBox(
                      width: 458 * r,
                      child: Text(
                        widget.description ?? '',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11 * r,
                          fontFamily: 'Montserrat',
                          height: 2 * r,
                        ),
                      ),
                    ),
                    if (widget.uid != null) ...[
                      SizedBox(height: 6 * r),
                      MyText(
                        'Design No. : ${widget.uid ?? ''}',
                        style: TextStyle(
                          fontSize: 11 * r,
                          fontFamily: 'Rushter Glory',
                        ),
                      ),
                      SizedBox(height: 26 * r),
                    ],
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  void _openImagePopup(
    BuildContext context,
    List<String> images,
    int startIndex,
  ) {
    showDialog(
      context: context,
      barrierColor: Colors.black45,
      builder: (_) =>
          _ImagePopupDialog(images: images, initialIndex: startIndex),
    );
  }
}

// =============================================================================
// POPUP DIALOG  —  white card, image centered, close top-right (like screenshot)
// =============================================================================

class _ImagePopupDialog extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const _ImagePopupDialog({required this.images, required this.initialIndex});

  @override
  State<_ImagePopupDialog> createState() => _ImagePopupDialogState();
}

class _ImagePopupDialogState extends State<_ImagePopupDialog> {
  late final PageController _pageController;
  late int _current;

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex.clamp(0, widget.images.length - 1);
    _pageController = PageController(initialPage: _current);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: EdgeInsets.symmetric(
        horizontal: screen.width * 0.06,
        vertical: screen.height * 0.08,
      ),
      child: SizedBox(
        width: double.infinity,
        height: screen.height * 0.65,
        child: Stack(
          children: [
            // ── Swipeable image pager ──────────────────────────────────────
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: widget.images.length,
                  onPageChanged: (i) => setState(() => _current = i),
                  itemBuilder: (_, i) => Padding(
                    padding: const EdgeInsets.fromLTRB(16, 48, 16, 32),
                    child: InteractiveViewer(
                      minScale: 1,
                      maxScale: 4,
                      child: buildProductImage(
                        widget.images[i],
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── Close button — outlined circle, top-right ──────────────────
            Positioned(
              top: 12,
              right: 12,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade300, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.black87,
                    size: 18,
                  ),
                ),
              ),
            ),

            // ── Nav arrows + dot indicators (only when multiple images) ────
            if (widget.images.length > 1) ...[
              Positioned(
                left: 8,
                top: 0,
                bottom: 0,
                child: Center(
                  child: _NavArrow(
                    icon: Icons.chevron_left,
                    enabled: _current > 0,
                    onTap: () => _pageController.previousPage(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 8,
                top: 0,
                bottom: 0,
                child: Center(
                  child: _NavArrow(
                    icon: Icons.chevron_right,
                    enabled: _current < widget.images.length - 1,
                    onTap: () => _pageController.nextPage(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                    ),
                  ),
                ),
              ),

              // Dot indicators
              Positioned(
                bottom: 10,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(widget.images.length, (i) {
                    final active = i == _current;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: active ? 18 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: active
                            ? const Color(0xFFB79D4B)
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NavArrow extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _NavArrow({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedOpacity(
        opacity: enabled ? 1.0 : 0.25,
        duration: const Duration(milliseconds: 150),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade300, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, size: 20, color: Colors.black87),
        ),
      ),
    );
  }
}
