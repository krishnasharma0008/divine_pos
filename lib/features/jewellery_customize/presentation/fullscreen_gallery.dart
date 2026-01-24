import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../data/product_images.dart';

class FullscreenGallery extends StatefulWidget {
  /// ProductImage list (each color → multiple images)
  final List<ProductImage> images;
  final int initialIndex;

  const FullscreenGallery({
    super.key,
    required this.images,
    required this.initialIndex,
  });

  @override
  State<FullscreenGallery> createState() => _FullscreenGalleryState();
}

class _FullscreenGalleryState extends State<FullscreenGallery> {
  late final PageController _controller;
  late final List<String> _flatUrls;
  late int _current;

  @override
  void initState() {
    super.initState();

    // ✅ Flatten + clean all URLs
    _flatUrls = widget.images
        .expand((e) => e.imageUrls)
        .map(_extractPlainUrl)
        .where((url) => url.isNotEmpty)
        .toList();

    // ✅ Safe initial index
    _current = _flatUrls.isEmpty
        ? 0
        : widget.initialIndex.clamp(0, _flatUrls.length - 1);

    _controller = PageController(initialPage: _current);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Handle empty image list
    if (_flatUrls.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            children: [
              const Center(
                child: Text('No images', style: TextStyle(color: Colors.white)),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            /// FULLSCREEN IMAGE PAGER
            PageView.builder(
              controller: _controller,
              itemCount: _flatUrls.length,
              onPageChanged: (i) => setState(() => _current = i),
              itemBuilder: (_, i) {
                final url = _flatUrls[i];
                final isAsset = !url.startsWith('http');

                return Center(
                  child: InteractiveViewer(
                    minScale: 1,
                    maxScale: 4,
                    child: isAsset
                        ? Image.asset(url, fit: BoxFit.contain)
                        : CachedNetworkImage(
                            imageUrl: url,
                            fit: BoxFit.contain,
                            placeholder: (_, __) => const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                            errorWidget: (_, __, ___) => const Icon(
                              Icons.broken_image,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                  ),
                );
              },
            ),

            /// TOP BAR (CLOSE + INDEX)
            Positioned(
              top: 8,
              left: 8,
              right: 8,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_current + 1}/${_flatUrls.length}',
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// --------------------
/// URL CLEANER (shared logic)
/// --------------------
String _extractPlainUrl(String raw) {
  // markdown-style [alt](url)
  final markdown = RegExp(r'\[([^\]]+)\]\(([^)]+)\)').firstMatch(raw);
  if (markdown != null) {
    return markdown.group(2)!.trim();
  }

  return raw.replaceAll('[', '').replaceAll(']', '').trim();
}
