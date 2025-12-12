import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../shared/utils/scale_size.dart';
import 'fullscreen_gallery.dart';
import '../data/product_images.dart';

Widget buildProductImage(
  String url, {
  double? width,
  double? height,
  BoxFit fit = BoxFit.contain,
}) {
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

class ImagePreviewWithThumbnails extends StatefulWidget {
  final List<ProductImage> images;

  const ImagePreviewWithThumbnails({super.key, required this.images});

  @override
  State<ImagePreviewWithThumbnails> createState() =>
      _ImagePreviewWithThumbnailsState();
}

class _ImagePreviewWithThumbnailsState
    extends State<ImagePreviewWithThumbnails> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final r = ScaleSize.aspectRatio;

    if (widget.images.isEmpty) {
      return const Center(child: Text("No images"));
    }

    final current = widget.images[selectedIndex];

    return Row(
      children: [
        /// ✅ LEFT THUMBNAILS (PERFECT SIZE)
        Container(
          width: 90 * r,
          padding: EdgeInsets.symmetric(vertical: 28 * r),
          child: ListView.builder(
            itemCount: widget.images.length,
            itemBuilder: (context, index) {
              final active = selectedIndex == index;

              return GestureDetector(
                onTap: () => setState(() => selectedIndex = index),
                child: Container(
                  margin: EdgeInsets.only(bottom: 14 * r),
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
                    widget.images[index].url,
                    width: 62 * r,
                    height: 62 * r,
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),

        /// ✅ MAIN IMAGE (FULL SIZE + TAG + ZOOM + FULLSCREEN)
        Expanded(
          child: GestureDetector(
            onTap: () => _openFullscreen(context),
            child: Center(
              child: Stack(
                alignment: Alignment.topRight,
                children: [
                  /// ✅ HERO + ZOOM IMAGE
                  Hero(
                    tag: "preview_${current.id}",
                    child: InteractiveViewer(
                      minScale: 1,
                      maxScale: 4,
                      child: buildProductImage(
                        current.url,
                        height: 420 * r, // ✅ big like your design
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  /// ✅ TAG (TOP-RIGHT)
                  if (current.tagText.isNotEmpty)
                    Positioned(
                      right: 18 * r,
                      top: 18 * r,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12 * r,
                          vertical: 5 * r,
                        ),
                        decoration: BoxDecoration(
                          color: current.tagColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20 * r),
                        ),
                        child: Text(
                          current.tagText,
                          style: TextStyle(
                            fontSize: 12 * r,
                            color: current.tagColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// ✅ FULLSCREEN IMAGE VIEWER
  void _openFullscreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FullscreenGallery(
          images: widget.images,
          initialIndex: selectedIndex,
        ),
      ),
    );
  }
}
