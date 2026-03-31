import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../shared/utils/scale_size.dart';
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
  const noImage = 'assets/jewellery/No_Image_Available.jpg';

  if (url.isEmpty) {
    return Image.asset(noImage, width: width, height: height, fit: fit);
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
    errorWidget: (_, __, ___) =>
        Image.asset(noImage, width: width, height: height, fit: fit),
  );
}

/// ------------------------------------------------------------
/// SHAPE → IMAGE MAP
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
  'PRC': [
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
  'MRQ': [
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
  'CUSH': [
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
  Widget build(BuildContext context) {
    final r = widget.r ?? ScaleSize.aspectRatio;

    /// Get images based on shape
    final shapeKey = widget.shape?.toUpperCase() ?? '';
    final allImages = shapeImages[shapeKey] ?? [];

    if (allImages.isEmpty) {
      return const Center(child: Text('No images'));
    }

    final safeIndex = selectedImageIndex.clamp(0, allImages.length - 1) as int;
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

                    /// TITLE
                    if ((widget.title ?? '').isNotEmpty)
                      MyText(
                        widget.title!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 28 * r,
                          fontFamily: 'Rushter Glory',
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.5 * r,
                        ),
                      ),

                    SizedBox(height: 14 * r),

                    /// DESCRIPTION
                    if ((widget.description ?? '').isNotEmpty)
                      SizedBox(
                        width: 458 * r,
                        child: Text(
                          (widget.description ?? '').toUpperCase(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: const Color(0xFF333333),
                            fontSize: 11 * r,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w400,
                            letterSpacing: 1.2 * r,
                            height: 2.2,
                          ),
                        ),
                      ),

                    SizedBox(height: 10 * r),

                    /// DESIGN NUMBER
                    if ((widget.uid ?? '').isNotEmpty)
                      MyText(
                        'Design No. : ${widget.uid}',
                        style: TextStyle(
                          color: const Color(0xFF888888),
                          fontSize: 11 * r,
                          fontFamily: 'Rushter Glory',
                          letterSpacing: 0.5 * r,
                        ),
                      ),

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

  /// ------------------------------------------------------------
  /// FULLSCREEN VIEW
  /// ------------------------------------------------------------
  void _openFullscreen(BuildContext context, List<String> images) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            FullscreenGallery(images: images, initialIndex: selectedImageIndex),
      ),
    );
  }
}
