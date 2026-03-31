import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class FullscreenGallery extends StatefulWidget {
  final List<String> images;
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
  late PageController _controller;
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    _controller = PageController(initialPage: currentIndex);
  }

  Widget buildImage(String url) {
    const noImage = 'assets/jewellery/No_Image_Available.jpg';

    if (url.isEmpty) {
      return Image.asset(noImage, fit: BoxFit.contain);
    }

    if (!url.startsWith('http')) {
      return Image.asset(url, fit: BoxFit.contain);
    }

    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.contain,
      placeholder: (_, __) => const Center(child: CircularProgressIndicator()),
      errorWidget: (_, __, ___) => Image.asset(noImage, fit: BoxFit.contain),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: PageView.builder(
        controller: _controller,
        itemCount: widget.images.length,
        onPageChanged: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        itemBuilder: (_, index) {
          return InteractiveViewer(
            minScale: 1,
            maxScale: 4,
            child: Center(
              child: Hero(
                tag: 'preview_$index',
                child: buildImage(widget.images[index]),
              ),
            ),
          );
        },
      ),
    );
  }
}
