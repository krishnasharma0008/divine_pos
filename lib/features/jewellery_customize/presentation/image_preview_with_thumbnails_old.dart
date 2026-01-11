import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../shared/utils/scale_size.dart';
import '../data/product_images.dart';
import 'fullscreen_gallery.dart';
import 'package:divine_pos/shared/widgets/text.dart';

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
      return const Center(child: Text('No images'));
    }

    final current = widget.images[selectedIndex];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// LEFT THUMBNAILS
        Container(
          width: 90 * r,
          padding: EdgeInsets.fromLTRB(22 * r, 67 * r, 0, 0),
          child: SizedBox(
            height: 426 * r,
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: widget.images.length,
              itemBuilder: (context, index) {
                final active = selectedIndex == index;

                return GestureDetector(
                  onTap: () => setState(() => selectedIndex = index),
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
        ),

        /// RIGHT SIDE: MAIN IMAGE + DETAILS
        Expanded(
          child: GestureDetector(
            onTap: () => _openFullscreen(context),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
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

                    //SizedBox(height: 4 * r),

                    /// MAIN IMAGE + OVERLAYS
                    // Padding(
                    //   padding: EdgeInsets.only(top: 0 * r),
                    //   child:
                    Hero(
                      tag: 'preview_${current.id}',
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: constraints.maxWidth,
                            height: 426 * r,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.transparent,
                                //color: Colors.black,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(12 * r),
                            ),
                            child: InteractiveViewer(
                              minScale: 1,
                              maxScale: 4,
                              child: buildProductImage(
                                current.url,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),

                          /// TAG
                          if (current.tagText.isNotEmpty)
                            Positioned(
                              left: 20 * r,
                              //top: 67 * r,
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

                    //),
                    SizedBox(height: 16 * r),

                    /// TITLE
                    MyText(
                      'Eternal Radiance Ring for her',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20 * r,
                        fontFamily: 'Rushter Glory',
                        fontWeight: FontWeight.w400,
                        height: 1.35 * r,
                        letterSpacing: 0.40 * r,
                      ),
                    ),

                    SizedBox(height: 8 * r),

                    /// DESCRIPTION
                    SizedBox(
                      width: 458 * r,
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'G',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 11 * r,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w500,
                                height: 2 * r,
                                letterSpacing: 0.22 * r,
                              ),
                            ),
                            TextSpan(
                              text:
                                  'racefully crafted in 18kt gold, this solitaire ring features a precision-cut heart & arrows diamond — a symbol of brilliance, balance, and timeless elegance.',
                              style: TextStyle(fontSize: 11 * r, height: 2 * r),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 6 * r),

                    /// CODE
                    MyText(
                      'RF3189 | UID: DT123',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 11 * r,
                        fontFamily: 'Rushter Glory',
                        fontWeight: FontWeight.w400,
                        height: 2.45 * r,
                        letterSpacing: 0.22 * r,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

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
