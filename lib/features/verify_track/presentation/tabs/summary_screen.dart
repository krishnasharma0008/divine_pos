import 'package:divine_pos/shared/utils/scale_size.dart';
import 'package:http/http.dart' as http;
import 'package:divine_pos/shared/utils/currency_formatter.dart';
import '../../../../shared/widgets/text.dart';
import 'package:flutter/material.dart';
import '../../data/verify_track_model.dart';
import '../verify_detail_shell.dart';

class SummaryScreen extends StatefulWidget {
  final VerifyTrackByUid product;
  const SummaryScreen({super.key, required this.product});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  int _imgIndex = 0;
  bool _sltExpanded = false;
  bool _mountExpanded = false;
  bool _purchaseExpanded = false;
  bool _zoomOpen = false;
  int _zoomIndex = 0;
  double _swipeStartX = 0;

  Set<String> _availableVideos = {};

  VerifyTrackByUid get p => widget.product;

  final fem = ScaleSize.aspectRatio;

  @override
  void initState() {
    super.initState();
    _checkVideoAvailability();
  }

  Future<void> _checkVideoAvailability() async {
    final candidates = p.videos
        .where(
          (v) =>
              v.isNotEmpty &&
              Uri.tryParse(v)?.isAbsolute == true &&
              _isVideo(v),
        )
        .toList();

    if (candidates.isEmpty) return;

    final available = <String>{};
    for (final url in candidates) {
      try {
        final response = await http
            .head(Uri.parse(url))
            .timeout(const Duration(seconds: 5));
        if (response.statusCode == 200) available.add(url);
      } catch (_) {}
    }
    if (mounted) setState(() => _availableVideos = available);
  }

  // ── Image list ─────────────────────────────────────────────────────────────
  List<String> get _images {
    if (p.isDiamond && p.sltDetails.isNotEmpty) {
      final shape = p.sltDetails.first.shape;
      final main = switch (shape) {
        'RND' => 'assets/vtdia/carousel_1.png',
        'PRN' => 'assets/vtdia/image8.png',
        'OVL' => 'assets/vtdia/image9.png',
        'PER' => 'assets/vtdia/image_9.png',
        'RADQ' => 'assets/vtdia/radiant.png',
        'CUSQ' => 'assets/vtdia/cushion.png',
        'HRT' => 'assets/vtdia/heart.png',
        'MAQ' => 'assets/vtdia/marquise.jpg',
        _ => '',
      };
      return [
        main,
        if (shape == 'RND') 'assets/vtdia/carousel_2.png',
        'assets/vtdia/carousel_3.png',
        if (shape == 'RND') 'assets/vtdia/carousel_4.png',
      ].where((e) => e.isNotEmpty).toList();
    }

    final validImages = p.images
        .where(
          (v) =>
              v.isNotEmpty &&
              Uri.tryParse(v)?.isAbsolute == true &&
              !_isVideo(v),
        )
        .toList();

    final all = [..._availableVideos.toList(), ...validImages];
    if (all.isNotEmpty) return all;
    if (p.image.isNotEmpty) return [p.image];
    return [];
  }

  bool get _isUidImage =>
      _images.isNotEmpty && _images[_imgIndex].contains('carousel_3');

  bool _isVideo(String s) =>
      s.endsWith('.mp4') ||
      s.endsWith('.webm') ||
      s.endsWith('.mov') ||
      s.endsWith('.m4v') ||
      s.contains('/video/');

  bool _isAsset(String s) => s.startsWith('assets/');

  double get _totalCts => p.sltDetails.fold(0.0, (a, s) => a + s.carat);

  double? get _growthPct {
    if (!p.isSold || p.sltDetails.isEmpty) return null;
    final slt = p.sltDetails.first;
    if (slt.purchasePrice <= 0) return null;
    return ((slt.currentPrice - slt.purchasePrice) / slt.purchasePrice) * 100;
  }

  static const double _imgH = 300;

  void _nextImage() {
    if (_images.length > 1) {
      setState(() => _imgIndex = (_imgIndex + 1) % _images.length);
    }
  }

  void _prevImage() {
    if (_images.length > 1) {
      setState(
        () => _imgIndex = (_imgIndex - 1 + _images.length) % _images.length,
      );
    }
  }

  void _openZoom(int index) => setState(() {
    _zoomOpen = true;
    _zoomIndex = index;
  });

  void _closeZoom() => setState(() => _zoomOpen = false);

  void _zoomNext() {
    if (_images.length > 1) {
      setState(() => _zoomIndex = (_zoomIndex + 1) % _images.length);
    }
  }

  void _zoomPrev() {
    if (_images.length > 1) {
      setState(
        () => _zoomIndex = (_zoomIndex - 1 + _images.length) % _images.length,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: Colors.white,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCarousel(),
                _buildMeta(),
                _buildHairline(),
                if (p.isJewellery) ...[
                  _buildJewellerySltAccordion(),
                  _buildMountAccordion(),
                ],
                if (p.isDiamond) _buildDiamondSltSection(),
                SizedBox(height: 16 * fem),
                if (p.isSold) _buildPurchaseSection(),
                SizedBox(height: 16 * fem),
                _buildHairline(),
                // _buildButtons(),
                // const SizedBox(height: 24),
              ],
            ),
          ),
        ),
        if (_zoomOpen) _buildZoomOverlay(),
      ],
    );
  }

  // ── Carousel ───────────────────────────────────────────────────────────────
  Widget _buildCarousel() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16 * fem, 16 * fem, 16 * fem, 0 * fem),
      child: Column(
        children: [
          _buildMainImage(),
          if (_images.length > 1) ...[
            SizedBox(height: 16 * fem),
            _buildThumbnails(),
          ],
          SizedBox(height: 16 * fem),
        ],
      ),
    );
  }

  Widget _buildMainImage() {
    if (_images.isEmpty) {
      return const SizedBox(height: _imgH, child: _Placeholder());
    }
    final src = _images[_imgIndex];

    return GestureDetector(
      onTap: () => _openZoom(_imgIndex),
      onHorizontalDragStart: (d) => _swipeStartX = d.localPosition.dx,
      onHorizontalDragEnd: (d) {
        final dx = d.localPosition.dx - _swipeStartX;
        if (dx.abs() >= 40) dx < 0 ? _nextImage() : _prevImage();
      },
      child: SizedBox(
        height: _imgH,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildMediaWidget(src, height: _imgH, fit: BoxFit.contain),
            if (_isUidImage) _buildUidOverlay(),
            Positioned(
              bottom: 10 * fem,
              right: 10 * fem,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 8 * fem,
                  vertical: 4 * fem,
                ),
                decoration: BoxDecoration(
                  color: Colors.black38,
                  borderRadius: BorderRadius.circular(4 * fem),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.zoom_in, size: 14 * fem, color: Colors.white),
                    SizedBox(width: 4),
                    MyText(
                      'Tap to zoom',
                      style: TextStyle(fontSize: 10 * fem, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Fullscreen zoom ────────────────────────────────────────────────────────
  Widget _buildZoomOverlay() {
    final src = _images[_zoomIndex];
    return Positioned.fill(
      child: Material(
        color: Colors.black,
        child: Stack(
          children: [
            Center(
              child: _isVideo(src)
                  ? _buildMediaWidget(src)
                  : InteractiveViewer(
                      minScale: 1.0,
                      maxScale: 5.0,
                      child: _buildMediaWidget(src),
                    ),
            ),
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onHorizontalDragStart: (d) => _swipeStartX = d.localPosition.dx,
                onHorizontalDragEnd: (d) {
                  final dx = d.localPosition.dx - _swipeStartX;
                  if (dx.abs() >= 40) dx < 0 ? _zoomNext() : _zoomPrev();
                },
              ),
            ),
            // ✕ Close
            Positioned(
              top: 16 * fem,
              right: 16 * fem,
              child: GestureDetector(
                onTap: _closeZoom,
                child: Container(
                  width: 40 * fem,
                  height: 40 * fem,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.4)),
                  ),
                  child: Icon(Icons.close, color: Colors.white, size: 22 * fem),
                ),
              ),
            ),
            if (_images.length > 1) ...[
              // ‹ Prev
              Positioned(
                left: 12 * fem,
                top: 0,
                bottom: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: _zoomPrev,
                    child: Container(
                      width: 44 * fem,
                      height: 44 * fem,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.4),
                        ),
                      ),
                      child: Icon(
                        Icons.chevron_left,
                        color: Colors.white,
                        size: 28 * fem,
                      ),
                    ),
                  ),
                ),
              ),
              // › Next
              Positioned(
                right: 12 * fem,
                top: 0,
                bottom: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: _zoomNext,
                    child: Container(
                      width: 44 * fem,
                      height: 44 * fem,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.4),
                        ),
                      ),
                      child: Icon(
                        Icons.chevron_right,
                        color: Colors.white,
                        size: 28 * fem,
                      ),
                    ),
                  ),
                ),
              ),
              // Counter
              Positioned(
                bottom: 20 * fem,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: MyText(
                      '${_zoomIndex + 1} / ${_images.length}',
                      style: TextStyle(color: Colors.white, fontSize: 13 * fem),
                    ),
                  ),
                ),
              ),
            ],
            // UID overlay in zoom
            if (src.contains('carousel_3'))
              Positioned(
                bottom: 140 * fem,
                left: 200 * fem,
                right: 0,
                child: Center(child: _GirdleText(p.uid, 48)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUidOverlay() {
    return Positioned(
      bottom: 80,
      left: 150,
      right: 0,
      child: Center(child: _GirdleText(p.uid, 36)),
    );
  }

  // ── Thumbnails ─────────────────────────────────────────────────────────────
  Widget _buildThumbnails() {
    return SizedBox(
      height: 64,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _images.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) => GestureDetector(
          onTap: () => setState(() => _imgIndex = i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.white,
              border: Border.all(
                color: i == _imgIndex ? AppColors.textDark : AppColors.divider,
                width: 1.5,
              ),
            ),
            child: _isVideo(_images[i])
                ? const _VideoThumb()
                : ClipRect(child: _thumbImg(_images[i])),
          ),
        ),
      ),
    );
  }

  // ── Media helpers ──────────────────────────────────────────────────────────
  Widget _buildMediaWidget(
    String src, {
    double? height,
    BoxFit fit = BoxFit.contain,
  }) {
    if (src.isEmpty) return const _Placeholder();
    if (_isVideo(src)) {
      return Container(
        height: height,
        color: Colors.black,
        child: const Center(
          child: Icon(Icons.play_circle_outline, size: 64, color: Colors.white),
        ),
      );
    }
    if (_isAsset(src)) {
      return Image.asset(
        src,
        height: height,
        fit: fit,
        width: double.infinity,
        errorBuilder: (_, __, ___) => const _Placeholder(),
      );
    }
    return Image.network(
      src,
      height: height,
      fit: fit,
      width: double.infinity,
      loadingBuilder: (_, child, prog) => prog == null
          ? child
          : SizedBox(
              height: height,
              child: const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  color: AppColors.mintDark,
                ),
              ),
            ),
      errorBuilder: (_, __, ___) => const _Placeholder(),
    );
  }

  Widget _thumbImg(String src) {
    if (_isAsset(src)) {
      return Image.asset(
        src,
        fit: BoxFit.cover,
        width: 64,
        height: 64,
        errorBuilder: (_, __, ___) => const _Placeholder(),
      );
    }
    return Image.network(
      src,
      fit: BoxFit.cover,
      width: 64,
      height: 64,
      errorBuilder: (_, __, ___) => const _Placeholder(),
    );
  }

  // ── Meta ───────────────────────────────────────────────────────────────────
  Widget _buildMeta() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'UID : ${p.uid}',
                style: const TextStyle(fontSize: 14, color: AppColors.textMid),
              ),
              Text(
                'Design No. : ${p.designNo}',
                style: const TextStyle(fontSize: 14, color: AppColors.textMid),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              MyText(
                p.currentPrice.inRupeesFormat(),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gold,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Excl. GST',
                style: TextStyle(fontSize: 14, color: AppColors.textMid),
              ),
              const Spacer(),
              if (p.isDiamond && !p.isCoin)
                const Tooltip(
                  message: 'Premium charges may be applicable',
                  child: Icon(
                    Icons.info_outline,
                    size: 20,
                    color: AppColors.textDark,
                  ),
                ),
            ],
          ),
          if (_totalCts > 3 && p.isSold) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              color: AppColors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'The price displayed is over a month old and may '
                    'not reflect the current value.',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.textMid,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 4),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF646464),
                        height: 1.5,
                      ),
                      children: [
                        const TextSpan(text: 'please '),
                        WidgetSpan(
                          child: GestureDetector(
                            onTap: () {},
                            child: const Text(
                              'click here',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF646464),
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                        const TextSpan(
                          text:
                              ' to submit your request, and we '
                              'will get back to you within 24 hours.',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 4),
          if (p.category.isNotEmpty)
            Text(
              p.collection.isNotEmpty
                  ? '${p.category} - ${p.collection}'
                  : p.category,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textDark,
                letterSpacing: 0.3,
              ),
            ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildHairline() => Container(height: 1, color: AppColors.divider);

  // ── Diamond solitaires ─────────────────────────────────────────────────────
  Widget _buildDiamondSltSection() {
    if (p.sltDetails.isEmpty) return const SizedBox.shrink();
    final growth = _growthPct;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BorderedHeader(
            title: 'Divine Solitaires:',
            trailing: growth != null
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Growth: ${growth.toStringAsFixed(2)} %',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: growth >= 0 ? Colors.green : Colors.red,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        growth >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                        size: 16,
                        color: growth >= 0 ? Colors.green : Colors.red,
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              children: [
                Row(
                  children: const [
                    Expanded(child: _ColHeader('Shape')),
                    Expanded(child: _ColHeader('Carat')),
                    Expanded(child: _ColHeader('Colour')),
                    Expanded(child: _ColHeader('Clarity')),
                  ],
                ),
                const SizedBox(height: 6),
                ...p.sltDetails.map(
                  (s) => Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Row(
                      children: [
                        Expanded(child: _ColValue(s.shape)),
                        Expanded(child: _ColValue(s.carat.toStringAsFixed(2))),
                        Expanded(child: _ColValue(s.colour)),
                        Expanded(child: _ColValue(s.clarity)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          _buildHairline(),
        ],
      ),
    );
  }

  // ── Jewellery solitaires accordion ─────────────────────────────────────────
  Widget _buildJewellerySltAccordion() {
    if (p.sltDetails.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        children: [
          _BorderedHeader(
            title: 'Divine Solitaires:',
            trailing: Icon(
              _sltExpanded ? Icons.remove : Icons.add,
              size: 20,
              color: AppColors.textDark,
            ),
            onTap: () => setState(() => _sltExpanded = !_sltExpanded),
          ),
          const SizedBox(height: 8),
          _sltExpanded
              ? _buildJewellerySltExpanded()
              : _buildJewellerySltCollapsed(),
          const SizedBox(height: 12),
          _buildHairline(),
        ],
      ),
    );
  }

  Widget _buildJewellerySltCollapsed() {
    final slt = p.sltDetails.first;
    final line =
        '${p.sltTotalPcs} pcs | '
        '${slt.shape} ${slt.carat}cts. ${slt.colour}, ${slt.clarity}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          line,
          style: const TextStyle(fontSize: 14, color: AppColors.textDark),
        ),
        const SizedBox(height: 6),
        Text(
          'Current Price: ${p.sltTotalCurrentPrice.inRupeesFormat()}',
          style: const TextStyle(fontSize: 14, color: AppColors.textDark),
        ),
      ],
    );
  }

  Widget _buildJewellerySltExpanded() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Expanded(child: _ColHeader('UID')),
            Expanded(child: _ColHeader('Shape')),
            Expanded(child: _ColHeader('Carat')),
            Expanded(child: _ColHeader('Colour')),
            Expanded(child: _ColHeader('Clarity')),
            Expanded(
              child: _ColHeader('Current\nPrice', align: TextAlign.right),
            ),
          ],
        ),
        const SizedBox(height: 6),
        const Divider(color: AppColors.divider, height: 1),
        const SizedBox(height: 6),
        ...p.sltDetails.map(
          (s) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              children: [
                Expanded(child: _ColValue(s.uid)),
                Expanded(child: _ColValue(s.shape)),
                Expanded(child: _ColValue(s.carat.toStringAsFixed(2))),
                Expanded(child: _ColValue(s.colour)),
                Expanded(child: _ColValue(s.clarity)),
                Expanded(
                  child: _ColValue(
                    s.currentPrice.inRupeesFormat(),
                    align: TextAlign.right,
                    bold: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Mount accordion ────────────────────────────────────────────────────────
  Widget _buildMountAccordion() {
    if (p.mountDetails1.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        children: [
          _BorderedHeader(
            title: 'Divine Mount',
            trailing: Icon(
              _mountExpanded ? Icons.remove : Icons.add,
              size: 20,
              color: AppColors.textDark,
            ),
            onTap: () => setState(() => _mountExpanded = !_mountExpanded),
          ),
          const SizedBox(height: 8),
          _mountExpanded ? _buildMountExpanded() : _buildMountCollapsed(),
          const SizedBox(height: 12),
          _buildHairline(),
        ],
      ),
    );
  }

  Widget _buildMountCollapsed() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Metal line — from mountDetails1 e.g. "GOLD 18 KT WHITE"
        if (p.mountDetails1.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            '${p.netWt} gms | ${p.mountDetails1} ',
            style: const TextStyle(fontSize: 14, color: AppColors.textDark),
          ),
        ],

        // Side diamonds — from mountDetails2 or sdPcs
        if (p.mountDetails2.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            p.mountDetails2,
            style: const TextStyle(fontSize: 14, color: AppColors.textDark),
          ),
        ] else if (p.sdPcs > 0) ...[
          const SizedBox(height: 6),
          Text(
            '${p.sdPcs} pcs ${p.sdCts} cts | ${p.sdColourClarity}',
            style: const TextStyle(fontSize: 14, color: AppColors.textDark),
          ),
        ],

        // Current price
        if (p.metalTotalCurrentPrice > 0) ...[
          const SizedBox(height: 6),
          Text(
            'Current Price :  ${p.metalTotalCurrentPrice.inRupeesFormat()}',
            style: const TextStyle(fontSize: 14, color: AppColors.textDark),
          ),
        ],
      ],
    );
  }

  Widget _buildMountExpanded() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Gold Details',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.textDark,
        ),
      ),
      const SizedBox(height: 8),
      // Metal — extracted from mountDetails1 after the pipe
      _DetailRow(
        label: 'Metal',
        value: _extractMetal(p.mountDetails1),
        valueColor: AppColors.gold,
      ),
      // ── FIX: Metal weight ─────────────────────────────────────────────────
      // Use grossWt/netWt if API provides them, otherwise parse from
      // mountDetails1 which contains e.g. "2.557 gms | GOLD 18 KT WHITE"
      _DetailRow(
        label: 'Gross | Net Weight',
        value: (p.grossWt > 0 || p.netWt > 0)
            ? '${p.grossWt} | ${p.netWt} gms'
            : _extractWeight(p.mountDetails1),
      ),
      if (p.sdPcs > 0 || p.sdCts > 0) ...[
        const SizedBox(height: 16),
        const Text(
          'Side Diamonds',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        _DetailRow(
          label: 'Pcs | Carat',
          value: '${p.sdPcs} pcs | ${p.sdCts} Cts.',
        ),
        if (p.sdColourClarity.isNotEmpty)
          _DetailRow(label: 'Quality', value: p.sdColourClarity),
      ],
    ],
  );

  // Extract metal type: "2.557 gms | GOLD 18 KT WHITE" → "GOLD 18 KT WHITE"
  String _extractMetal(String s) {
    if (s.contains('|')) return s.split('|').last.trim();
    return s;
  }

  // ── FIX: Extract weight from mountDetails1 when grossWt/netWt are 0 ───────
  // "2.685 gms | GOLD 18 KT WHITE" → "2.685 gms"
  // "2.685 | 2.557 gms | GOLD 18 KT WHITE" → "2.685 | 2.557 gms"
  String _extractWeight(String s) {
    if (!s.contains('|')) return s;
    final parts = s.split('|');
    if (parts.length >= 3) {
      // "gross | net | metal" format
      return '${parts[0].trim()} | ${parts[1].trim()}';
    }
    // "weight | metal" format
    return parts.first.trim();
  }

  // ── Purchase section (SOLD only) ───────────────────────────────────────────
  Widget _buildPurchaseSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bordered box contains Purchase Amount / Premium / Discount / Total
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.divider),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              children: [
                // Header
                GestureDetector(
                  onTap: () =>
                      setState(() => _purchaseExpanded = !_purchaseExpanded),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        const Text(
                          'Purchase Information -',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textDark,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          _purchaseExpanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          size: 22,
                          color: AppColors.textDark,
                        ),
                      ],
                    ),
                  ),
                ),
                // Body
                if (_purchaseExpanded && p.purchasePrice > 0) ...[
                  const Divider(color: AppColors.divider, height: 1),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Purchase Amount (two-line label)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Purchase Amount:',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                  Text(
                                    'Excl. GST',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textMid,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Text(
                                p.purchasePrice.inRupeesFormat(),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Premium
                        _DetailRow(label: 'Premium', value: '₹0'),
                        // ── FIX: Discount ─────────────────────────────────────
                        // API may return negative or positive discount value.
                        // Use abs() so display is always positive with '-' prefix.
                        _DetailRow(
                          label: 'Discount:',
                          value: p.purchaseDiscount != 0
                              ? '-${p.purchaseDiscount.abs().inRupeesFormat()}'
                              : '₹0',
                        ),
                        const SizedBox(height: 8),
                        const Divider(color: AppColors.divider, height: 1),
                        const SizedBox(height: 8),
                        // Total
                        _DetailRow(
                          label: 'Total Purchase Amount:',
                          value: p.purchasePriceFinal.inRupeesFormat(),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Jeweller's Name — outside the box
          const SizedBox(height: 20),
          const Text(
            "Jeweller's Name:",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            p.purchaseFrom.isNotEmpty
                ? p.purchaseFrom.toUpperCase()
                : 'DIVINE SOLITAIRES',
            style: const TextStyle(fontSize: 14, color: AppColors.textMid),
          ),

          // Date Of Purchase — outside the box
          const SizedBox(height: 14),
          const Text(
            'Date Of Purchase:',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            p.purchaseDate.isNotEmpty ? p.purchaseDate : '—',
            style: const TextStyle(fontSize: 14, color: AppColors.textMid),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // ── Buttons ────────────────────────────────────────────────────────────────
  Widget _buildButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: p.isSold
            ? MainAxisAlignment.spaceBetween
            : MainAxisAlignment.center,
        children: [
          Expanded(
            child: SizedBox(
              height: 50,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textDark,
                  side: const BorderSide(color: AppColors.textDark),
                  shape: const RoundedRectangleBorder(),
                ),
                child: const Text(
                  'INSURE NOW',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ),
          if (p.isSold) ...[
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.textDark,
                    foregroundColor: AppColors.white,
                    elevation: 0,
                    shape: const RoundedRectangleBorder(),
                  ),
                  child: const Text(
                    'ADD TO PORTFOLIO',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// =============================================================================
// BORDERED ACCORDION HEADER
// =============================================================================

class _BorderedHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _BorderedHeader({required this.title, this.trailing, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          border: Border.all(color: AppColors.divider),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const Spacer(),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// UID GIRDLE TEXT
// =============================================================================

class _GirdleText extends StatelessWidget {
  final String text;
  final double fontsize;
  const _GirdleText(this.text, this.fontsize);

  @override
  Widget build(BuildContext context) {
    final baseStyle = TextStyle(
      fontSize: fontsize,
      fontWeight: FontWeight.w800,
      letterSpacing: 3.5,
      height: 1,
      color: Colors.white,
    );
    return Stack(
      children: [
        MyText(
          text,
          style: baseStyle.copyWith(
            color: const Color(0xFF0A0A0A),
            shadows: const [
              Shadow(
                offset: Offset(1, 1.5),
                blurRadius: 1,
                color: Color(0xBB000000),
              ),
            ],
          ),
        ),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF666666), Color(0xFF1C1C1C), Color(0xFF444444)],
            stops: [0.0, 0.5, 1.0],
          ).createShader(bounds),
          child: Text(
            text,
            style: baseStyle.copyWith(
              color: Colors.white,
              shadows: const [
                Shadow(
                  offset: Offset(0, -1),
                  blurRadius: 0.5,
                  color: Color(0x66FFFFFF),
                ),
                Shadow(
                  offset: Offset(0.5, 1.5),
                  blurRadius: 1,
                  color: Color(0xDD000000),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// REUSABLE WIDGETS
// =============================================================================

class _ColHeader extends StatelessWidget {
  final String text;
  final TextAlign align;
  const _ColHeader(this.text, {this.align = TextAlign.left});

  @override
  Widget build(BuildContext context) => Text(
    text,
    textAlign: align,
    style: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: AppColors.textDark,
    ),
  );
}

class _ColValue extends StatelessWidget {
  final String text;
  final TextAlign align;
  final bool bold;
  const _ColValue(this.text, {this.align = TextAlign.left, this.bold = false});

  @override
  Widget build(BuildContext context) => Text(
    text,
    textAlign: align,
    style: TextStyle(
      fontSize: 14,
      fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
      color: AppColors.textDark,
    ),
  );
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _DetailRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: AppColors.textMid),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: valueColor ?? AppColors.textDark,
          ),
        ),
      ],
    ),
  );
}

class _VideoThumb extends StatelessWidget {
  const _VideoThumb();
  @override
  Widget build(BuildContext context) => Container(
    color: AppColors.textDark,
    child: const Center(
      child: Icon(Icons.play_arrow, size: 22, color: AppColors.white),
    ),
  );
}

class _Placeholder extends StatelessWidget {
  const _Placeholder();
  @override
  Widget build(BuildContext context) => const Center(
    child: Icon(Icons.diamond_outlined, size: 80, color: AppColors.textLight),
  );
}
