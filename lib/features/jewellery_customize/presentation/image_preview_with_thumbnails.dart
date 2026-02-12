import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../shared/utils/scale_size.dart';
import '../data/product_images.dart';
import 'fullscreen_gallery.dart';
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
    return const Icon(Icons.image_not_supported, size: 40);
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
    errorWidget: (_, __, ___) => const Icon(Icons.broken_image, size: 40),
  );
}

/// ------------------------------------------------------------
/// IMAGE PREVIEW WITH THUMBNAILS
/// ------------------------------------------------------------
class ImagePreviewWithThumbnails extends StatefulWidget {
  /// Each ProductImage = one metal color
  final List<ProductImage> images;
  final String? title;
  final String? description;
  final String? productCode;
  final String? uid;
  final double? r;

  const ImagePreviewWithThumbnails({
    super.key,
    required this.images,
    this.title,
    this.description,
    this.productCode,
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
  Widget build(BuildContext context) {
    final r = widget.r ?? ScaleSize.aspectRatio;

    if (widget.images.isEmpty || widget.images.first.imageUrls.isEmpty) {
      return const Center(child: Text('No images'));
    }

    /// 🔥 Flatten all images for thumbnails
    final allImages = widget.images.first.imageUrls;
    final safeIndex = selectedImageIndex.clamp(0, allImages.length - 1);
    final currentUrl = allImages[safeIndex];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// --------------------------------------------------
        /// LEFT — THUMBNAILS
        /// --------------------------------------------------
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

        /// --------------------------------------------------
        /// RIGHT — MAIN IMAGE + DESCRIPTION
        /// --------------------------------------------------
        Expanded(
          child: GestureDetector(
            onTap: () => _openFullscreen(context, allImages),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    /// + ICON
                    // + ICON ABOVE IMAGE
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

                    /// MAIN IMAGE
                    Hero(
                      tag: 'preview_$safeIndex',
                      child: Container(
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
                    ),

                    SizedBox(height: 16 * r),

                    /// --------------------------------------------------
                    /// DESCRIPTION (FROM OLD CODE)
                    /// --------------------------------------------------
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

                    SizedBox(height: 6 * r),

                    // MyText(
                    //   '${widget.productCode ?? ''} | UID: ${widget.uid ?? ''}',
                    //   style: TextStyle(
                    //     fontSize: 11 * r,
                    //     fontFamily: 'Rushter Glory',
                    //   ),
                    // ),
                    SizedBox(height: 26 * r),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  void _openFullscreen(BuildContext context, List<String> images) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FullscreenGallery(
          images: widget.images,
          initialIndex: selectedImageIndex,
        ),
      ),
    );
  }
}
