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

  // Growth for collapsed solitaire view (works even when purchasePrice == 0)
  double? get _collapsedGrowthPct {
    if (p.sltDetails.isEmpty) return null;
    final slt = p.sltDetails.first;
    if (slt.purchasePrice <= 0) return 0.0;
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
        Column(
          children: [
            // ── Scrollable body ──────────────────────────────────────────────
            Expanded(
              child: Container(
                color: Colors.white,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCarousel(),
                      _buildMeta(),
                      _buildHairline(),

                      // "Jewellery Details:" plain-text section header
                      if (p.isJewellery) ...[
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                            16 * fem,
                            16 * fem,
                            16 * fem,
                            8 * fem,
                          ),
                          child: MyText(
                            'Jewellery Details:',
                            style: TextStyle(
                              fontSize: 16 * fem,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                        _buildJewellerySltAccordion(),
                        _buildMountAccordion(),
                      ],

                      if (p.isDiamond) _buildDiamondSltSection(),

                      SizedBox(height: 16 * fem),
                      if (p.isSold) _buildPurchaseSection(),
                      SizedBox(height: 16 * fem),
                      _buildHairline(),
                      SizedBox(height: 8 * fem),
                    ],
                  ),
                ),
              ),
            ),

            // ── Sticky bottom buttons ────────────────────────────────────────
            //_buildButtons(),
          ],
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
            if (src.contains('carousel_3'))
              Positioned(
                bottom: 140 * fem,
                left: 200 * fem,
                right: 0,
                child: Center(child: _GirdleText(p.uid, 48, fem)),
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
      child: Center(child: _GirdleText(p.uid, 36, fem)),
    );
  }

  // ── Thumbnails ─────────────────────────────────────────────────────────────
  Widget _buildThumbnails() {
    return SizedBox(
      height: 64 * fem,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _images.length,
        separatorBuilder: (_, __) => SizedBox(width: 8 * fem),
        itemBuilder: (_, i) => GestureDetector(
          onTap: () => setState(() => _imgIndex = i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 64 * fem,
            height: 64 * fem,
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
        height: (height ?? 0) * fem,
        color: Colors.black,
        child: Center(
          child: Icon(
            Icons.play_circle_outline,
            size: 64 * fem,
            color: Colors.white,
          ),
        ),
      );
    }
    if (_isAsset(src)) {
      return Image.asset(
        src,
        height: (height ?? 0) * fem,
        fit: fit,
        width: double.infinity,
        errorBuilder: (_, __, ___) => const _Placeholder(),
      );
    }
    return Image.network(
      src,
      height: (height ?? 0) * fem,
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
        width: 64 * fem,
        height: 64 * fem,
        errorBuilder: (_, __, ___) => const _Placeholder(),
      );
    }
    return Image.network(
      src,
      fit: BoxFit.cover,
      width: 64 * fem,
      height: 64 * fem,
      errorBuilder: (_, __, ___) => const _Placeholder(),
    );
  }

  // ── Meta ───────────────────────────────────────────────────────────────────
  Widget _buildMeta() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16 * fem),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MyText(
                'UID : ${p.uid}',
                style: TextStyle(fontSize: 14 * fem, color: AppColors.textMid),
              ),
              MyText(
                'Design No. : ${p.designNo}',
                style: TextStyle(fontSize: 14 * fem, color: AppColors.textMid),
              ),
            ],
          ),
          SizedBox(height: 8 * fem),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              MyText(
                p.currentPrice.inRupeesFormat(),
                style: TextStyle(
                  fontSize: 28 * fem,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gold,
                ),
              ),
              SizedBox(width: 8 * fem),
              MyText(
                'Excl. GST',
                style: TextStyle(fontSize: 14, color: AppColors.textMid),
              ),
              const Spacer(),
              if (p.isDiamond && !p.isCoin)
                Tooltip(
                  message: 'Premium charges may be applicable',
                  child: Icon(
                    Icons.info_outline,
                    size: 20 * fem,
                    color: AppColors.textDark,
                  ),
                ),
            ],
          ),
          if (_totalCts > 3 && p.isSold) ...[
            SizedBox(height: 8 * fem),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 8 * fem,
                vertical: 10 * fem,
              ),
              color: AppColors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyText(
                    'The price displayed is over a month old and may '
                    'not reflect the current value.',
                    style: TextStyle(
                      fontSize: 10 * fem,
                      color: AppColors.textMid,
                      height: 1.6,
                    ),
                  ),
                  SizedBox(height: 4 * fem),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 11 * fem,
                        color: Color(0xFF646464),
                        height: 1.5,
                      ),
                      children: [
                        const TextSpan(text: 'please '),
                        WidgetSpan(
                          child: GestureDetector(
                            onTap: () {},
                            child: MyText(
                              'click here',
                              style: TextStyle(
                                fontSize: 11 * fem,
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
          SizedBox(height: 4 * fem),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (p.category.isNotEmpty)
                MyText(
                  p.collection.isNotEmpty
                      ? '${p.category} - ${p.collection}'
                      : p.category,
                  style: TextStyle(
                    fontSize: 13 * fem,
                    color: AppColors.textDark,
                    letterSpacing: 0.3,
                  ),
                ),
              if (p.jewellerySize.isNotEmpty)
                MyText(
                  'Size : ${p.jewellerySize}',
                  style: TextStyle(
                    fontSize: 14 * fem,
                    color: AppColors.textMid,
                  ),
                ),
            ],
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
      padding: EdgeInsets.fromLTRB(16 * fem, 12 * fem, 16 * fem, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BorderedHeader(
            title: 'Divine Solitaires:',
            trailing: growth != null
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      MyText(
                        'Growth: ${growth.toStringAsFixed(2)} %',
                        style: TextStyle(
                          fontSize: 13 * fem,
                          fontWeight: FontWeight.w500,
                          color: growth >= 0 ? Colors.green : Colors.red,
                        ),
                      ),
                      SizedBox(width: 4 * fem),
                      Icon(
                        growth >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                        size: 16 * fem,
                        color: growth >= 0 ? Colors.green : Colors.red,
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
            fem: fem,
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12 * fem),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _ColHeader('Shape', fem)),
                    Expanded(child: _ColHeader('Carat', fem)),
                    Expanded(child: _ColHeader('Colour', fem)),
                    Expanded(child: _ColHeader('Clarity', fem)),
                  ],
                ),
                SizedBox(height: 6 * fem),
                ...p.sltDetails.map(
                  (s) => Padding(
                    padding: EdgeInsets.only(top: 6 * fem),
                    child: Row(
                      children: [
                        Expanded(child: _ColValue(s.shape, fem)),
                        Expanded(
                          child: _ColValue(s.carat.toStringAsFixed(2), fem),
                        ),
                        Expanded(child: _ColValue(s.colour, fem)),
                        Expanded(child: _ColValue(s.clarity, fem)),
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
      padding: EdgeInsets.fromLTRB(16 * fem, 0, 16 * fem, 0),
      child: Column(
        children: [
          _BorderedHeader(
            title: 'Divine Solitaires :',
            trailing: Icon(
              _sltExpanded ? Icons.remove : Icons.add,
              size: 20 * fem,
              color: AppColors.textDark,
            ),
            onTap: () => setState(() => _sltExpanded = !_sltExpanded),
            fem: fem,
          ),
          SizedBox(height: 8 * fem),
          _sltExpanded
              ? _buildJewellerySltExpanded()
              : _buildJewellerySltCollapsed(),
          SizedBox(height: 12 * fem),
        ],
      ),
    );
  }

  /// Collapsed solitaire — matches screenshot:
  /// "1 pcs | RND 0.25cts. F, VVS1"
  /// Purchase Price   Current Price   Growth
  ///      ₹0             ₹57,500       0.0%  (green)
  Widget _buildJewellerySltCollapsed() {
    final slt = p.sltDetails.first;
    final line =
        '${p.sltTotalPcs} pcs | '
        '${slt.shape} ${slt.carat}cts. ${slt.colour}, ${slt.clarity}';

    final growth = _collapsedGrowthPct;
    final growthColor = (growth != null && growth >= 0)
        ? Colors.green
        : Colors.red;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary line
        MyText(
          line,
          style: TextStyle(fontSize: 14 * fem, color: AppColors.textDark),
        ),
        SizedBox(height: 10 * fem),

        // 3-column header: Purchase Price | Current Price | Growth
        Row(
          children: [
            Expanded(
              child: MyText(
                'Purchase Price',
                style: TextStyle(fontSize: 13 * fem, color: AppColors.textMid),
              ),
            ),
            Expanded(
              child: MyText(
                'Current Price',
                style: TextStyle(fontSize: 13 * fem, color: AppColors.textMid),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: MyText(
                'Growth',
                style: TextStyle(fontSize: 13 * fem, color: AppColors.textMid),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
        SizedBox(height: 6 * fem),

        // 3-column values
        Row(
          children: [
            // Purchase price
            Expanded(
              child: MyText(
                slt.purchasePrice > 0
                    ? slt.purchasePrice.inRupeesFormat()
                    : '₹ 0',
                style: TextStyle(
                  fontSize: 14 * fem,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ),
            // Current price
            Expanded(
              child: MyText(
                slt.currentPrice.inRupeesFormat(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14 * fem,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ),
            // Growth
            Expanded(
              child: MyText(
                growth != null ? '${growth.toStringAsFixed(1)} %' : '—',
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 14 * fem,
                  fontWeight: FontWeight.w600,
                  color: growthColor,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildJewellerySltExpanded() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4 * fem),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: UID | Solitaire | Purchase | Current | Growth
          Table(
            columnWidths: const {
              0: FlexColumnWidth(1.4), // UID
              1: FlexColumnWidth(2.2), // Solitaire
              2: FlexColumnWidth(1.4), // Purchase
              3: FlexColumnWidth(1.4), // Current
              4: FlexColumnWidth(1.2), // Growth
            },
            children: [
              TableRow(
                children: [
                  _tHeader('UID'),
                  _tHeader('Solitaire'),
                  _tHeader('Purchase'),
                  _tHeader('Current'),
                  _tHeader('Growth', align: TextAlign.right),
                ],
              ),
            ],
          ),
          SizedBox(height: 6 * fem),
          const Divider(color: AppColors.divider, height: 1),
          SizedBox(height: 6 * fem),
          // Data rows
          ...p.sltDetails.map((s) {
            // Solitaire string: "RND-0.33-F-SI2"
            final solitaire =
                '${s.shape}-${s.carat.toStringAsFixed(2)}-${s.colour}-${s.clarity}';
            final purchaseStr = s.purchasePrice > 0
                ? s.purchasePrice.inRupeesFormat()
                : '₹ 0';
            final growth = s.purchasePrice > 0
                ? ((s.currentPrice - s.purchasePrice) / s.purchasePrice) * 100
                : 0.0;
            final growthColor = growth >= 0 ? Colors.green : Colors.red;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Table(
                columnWidths: const {
                  0: FlexColumnWidth(1.4),
                  1: FlexColumnWidth(2.2),
                  2: FlexColumnWidth(1.4),
                  3: FlexColumnWidth(1.4),
                  4: FlexColumnWidth(1.2),
                },
                children: [
                  TableRow(
                    children: [
                      _tCell(s.uid),
                      _tCell(solitaire),
                      _tCell(purchaseStr),
                      _tCell(s.currentPrice.inRupeesFormat()),
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          '${growth.toStringAsFixed(1)} %',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: growthColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _tHeader(String text, {TextAlign align = TextAlign.left}) => Padding(
    padding: EdgeInsets.only(bottom: 2 * fem),
    child: MyText(
      text,
      textAlign: align,
      style: TextStyle(
        fontSize: 13 * fem,
        fontWeight: FontWeight.w500,
        color: AppColors.textMid,
      ),
    ),
  );

  Widget _tCell(String text, {TextAlign align = TextAlign.left}) => Padding(
    padding: EdgeInsets.only(top: 2 * fem),
    child: MyText(
      text,
      textAlign: align,
      style: TextStyle(fontSize: 13 * fem, color: AppColors.textDark),
    ),
  );

  // ── Mount accordion ────────────────────────────────────────────────────────
  Widget _buildMountAccordion() {
    if (p.mountDetails1.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.fromLTRB(16 * fem, 0, 16 * fem, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // ← ADD THIS
        children: [
          _BorderedHeader(
            title: 'Divine Mount :',
            trailing: Icon(
              _mountExpanded ? Icons.remove : Icons.add,
              size: 20 * fem,
              color: AppColors.textDark,
            ),
            onTap: () => setState(() => _mountExpanded = !_mountExpanded),
            fem: fem,
          ),
          SizedBox(height: 8 * fem),
          _mountExpanded ? _buildMountExpanded() : _buildMountCollapsed(),
          SizedBox(height: 12 * fem),
        ],
      ),
    );
  }

  Widget _buildMountCollapsed() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (p.mountDetails1.isNotEmpty) ...[
          const SizedBox(height: 6),
          MyText(
            '${p.netWt} gms | ${p.mountDetails1} ',
            style: TextStyle(fontSize: 14 * fem, color: AppColors.textDark),
          ),
        ],
        if (p.mountDetails2.isNotEmpty) ...[
          const SizedBox(height: 6),
          MyText(
            p.mountDetails2,
            style: TextStyle(fontSize: 14 * fem, color: AppColors.textDark),
          ),
        ] else if (p.sdPcs > 0) ...[
          const SizedBox(height: 6),
          MyText(
            '${p.sdPcs} pcs ${p.sdCts} cts | ${p.sdColourClarity}',
            style: TextStyle(fontSize: 14 * fem, color: AppColors.textDark),
          ),
        ],
        if (p.metalTotalCurrentPrice > 0) ...[
          const SizedBox(height: 6),
          MyText(
            'Current Price',
            style: TextStyle(fontSize: 14 * fem, color: AppColors.textDark),
          ),
          SizedBox(height: 2 * fem),
          MyText(
            (p.metalTotalCurrentPrice + p.sdTotalCurrentPrice).inRupeesFormat(),
            style: TextStyle(
              fontSize: 14 * fem,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMountExpanded() => Padding(
    padding: EdgeInsets.symmetric(vertical: 4 * fem),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText(
          'Gold Details :',
          style: TextStyle(
            fontSize: 15 * fem,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        SizedBox(height: 12 * fem),
        _ColonRow(
          label: 'Metal',
          value: _extractMetal(p.mountDetails1),
          fem: fem,
        ),
        SizedBox(height: 10 * fem),
        _ColonRow(
          label: 'Gross | Net Weight',
          value: (p.grossWt > 0 || p.netWt > 0)
              ? '${p.grossWt} | ${p.netWt} gms'
              : _extractWeight(p.mountDetails1),
          fem: fem,
        ),
        if (p.sdPcs > 0 || p.sdCts > 0) ...[
          SizedBox(height: 20 * fem),
          MyText(
            'Side Diamonds :',
            style: TextStyle(
              fontSize: 15 * fem,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          SizedBox(height: 12 * fem),
          _ColonRow(
            label: 'Pcs | Carat',
            value: '${p.sdPcs} Pcs | ${p.sdCts} Cts.',
            fem: fem,
          ),
          if (p.sdColourClarity.isNotEmpty) ...[
            SizedBox(height: 10 * fem),
            _ColonRow(label: 'Quality', value: p.sdColourClarity, fem: fem),
          ],
        ],
        SizedBox(height: 8 * fem),
      ],
    ),
  );

  String _extractMetal(String s) {
    if (s.contains('|')) return s.split('|').last.trim();
    return s;
  }

  String _extractWeight(String s) {
    if (!s.contains('|')) return s;
    final parts = s.split('|');
    if (parts.length >= 3) {
      return '${parts[0].trim()} | ${parts[1].trim()}';
    }
    return parts.first.trim();
  }

  // ── Purchase section (SOLD only) ───────────────────────────────────────────
  Widget _buildPurchaseSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16 * fem),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bordered box — Purchase Information accordion
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.divider),
              borderRadius: BorderRadius.circular(6 * fem),
            ),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () =>
                      setState(() => _purchaseExpanded = !_purchaseExpanded),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16 * fem,
                      vertical: 14 * fem,
                    ),
                    child: Row(
                      children: [
                        MyText(
                          'Purchase Information -',
                          style: TextStyle(
                            fontSize: 15 * fem,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textDark,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          _purchaseExpanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          size: 22 * fem,
                          color: AppColors.textDark,
                        ),
                      ],
                    ),
                  ),
                ),
                if (_purchaseExpanded && p.purchasePrice > 0) ...[
                  const Divider(color: AppColors.divider, height: 1),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      16 * fem,
                      12 * fem,
                      16 * fem,
                      16 * fem,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  MyText(
                                    'Purchase Amount:',
                                    style: TextStyle(
                                      fontSize: 14 * fem,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                  MyText(
                                    'Excl. GST',
                                    style: TextStyle(
                                      fontSize: 12 * fem,
                                      color: AppColors.textMid,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              MyText(
                                p.purchasePrice.inRupeesFormat(),
                                style: TextStyle(
                                  fontSize: 14 * fem,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _DetailRow(label: 'Premium', value: '₹0', fem: fem),
                        _DetailRow(
                          label: 'Discount:',
                          value: p.purchaseDiscount != 0
                              ? '-${p.purchaseDiscount.abs().inRupeesFormat()}'
                              : '₹0',
                          fem: fem,
                        ),
                        SizedBox(height: 8 * fem),
                        const Divider(color: AppColors.divider, height: 1),
                        SizedBox(height: 8 * fem),
                        _DetailRow(
                          label: 'Total Purchase Amount:',
                          value: p.purchasePriceFinal.inRupeesFormat(),
                          fem: fem,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Jeweller's Name — label + bold value on separate lines
          SizedBox(height: 20 * fem),
          MyText(
            "Jeweller's Name:",
            style: TextStyle(
              fontSize: 15 * fem,
              fontWeight: FontWeight.w500,
              color: AppColors.textDark,
            ),
          ),
          SizedBox(height: 6 * fem),
          MyText(
            p.purchaseFrom.isNotEmpty
                ? p.purchaseFrom.toUpperCase()
                : 'DIVINE SOLITAIRES',
            style: TextStyle(
              fontSize: 15 * fem,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),

          // Date Of Purchase — label + value on separate lines
          SizedBox(height: 14 * fem),
          MyText(
            'Date Of Purchase:',
            style: TextStyle(
              fontSize: 15 * fem,
              fontWeight: FontWeight.w500,
              color: AppColors.textDark,
            ),
          ),
          SizedBox(height: 6 * fem),
          MyText(
            p.purchaseDate.isNotEmpty ? p.purchaseDate : '—',
            style: TextStyle(
              fontSize: 15 * fem,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // ── Sticky bottom buttons ──────────────────────────────────────────────────
  // Widget _buildButtons() {
  //   return Container(
  //     color: Colors.white,
  //     padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
  //     child: Row(
  //       children: [
  //         Expanded(
  //           child: SizedBox(
  //             height: 50,
  //             child: OutlinedButton(
  //               onPressed: () {},
  //               style: OutlinedButton.styleFrom(
  //                 foregroundColor: AppColors.textDark,
  //                 side: const BorderSide(color: AppColors.textDark),
  //                 shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.circular(6),
  //                 ),
  //               ),
  //               child: const Text(
  //                 'INSURE NOW',
  //                 style: TextStyle(
  //                   fontSize: 13,
  //                   fontWeight: FontWeight.w700,
  //                   letterSpacing: 1.2,
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ),
  //         if (p.isSold) ...[
  //           const SizedBox(width: 12),
  //           Expanded(
  //             child: SizedBox(
  //               height: 50,
  //               child: ElevatedButton(
  //                 onPressed: () {},
  //                 style: ElevatedButton.styleFrom(
  //                   backgroundColor: AppColors.textDark,
  //                   foregroundColor: AppColors.white,
  //                   elevation: 0,
  //                   shape: RoundedRectangleBorder(
  //                     borderRadius: BorderRadius.circular(6),
  //                   ),
  //                 ),
  //                 child: const Text(
  //                   'ADD TO PORTFOLIO',
  //                   style: TextStyle(
  //                     fontSize: 13,
  //                     fontWeight: FontWeight.w700,
  //                     letterSpacing: 1.2,
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ],
  //       ],
  //     ),
  //   );
  // }
}

// =============================================================================
// BORDERED ACCORDION HEADER
// =============================================================================

class _BorderedHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;
  final double fem;

  const _BorderedHeader({
    required this.title,
    this.trailing,
    this.onTap,
    required this.fem,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16 * fem, vertical: 14 * fem),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          border: Border.all(color: AppColors.divider),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            MyText(
              title,
              style: TextStyle(
                fontSize: 15 * fem,
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
  final double fem;
  const _GirdleText(this.text, this.fontsize, this.fem);

  @override
  Widget build(BuildContext context) {
    final baseStyle = TextStyle(
      fontSize: fontsize * fem,
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
          child: MyText(
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
  final double fem;
  const _ColHeader(this.text, this.fem, {this.align = TextAlign.left});

  @override
  Widget build(BuildContext context) => MyText(
    text,
    textAlign: align,
    style: TextStyle(
      fontSize: 13 * fem,
      fontWeight: FontWeight.w600,
      color: AppColors.textDark,
    ),
  );
}

class _ColValue extends StatelessWidget {
  final String text;
  final TextAlign align;
  final bool bold;
  final double fem;
  const _ColValue(
    this.text,
    this.fem, {
    this.align = TextAlign.left,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) => MyText(
    text,
    textAlign: align,
    style: TextStyle(
      fontSize: 14 * fem,
      fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
      color: AppColors.textDark,
    ),
  );
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final double fem;
  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
    required this.fem,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      children: [
        MyText(
          label,
          style: const TextStyle(fontSize: 14, color: AppColors.textMid),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 14 * fem,
            fontWeight: FontWeight.w500,
            color: valueColor ?? AppColors.textDark,
          ),
        ),
      ],
    ),
  );
}

class _ColonRow extends StatelessWidget {
  final String label;
  final String value;
  final double fem;
  const _ColonRow({
    required this.label,
    required this.value,
    required this.fem,
  });

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        width: 140,
        child: MyText(
          label,
          style: TextStyle(fontSize: 14 * fem, color: AppColors.textDark),
        ),
      ),
      MyText(
        ':',
        style: TextStyle(fontSize: 14 * fem, color: AppColors.textDark),
      ),
      SizedBox(width: 12 * fem),
      Expanded(
        child: MyText(
          value,
          textAlign: TextAlign.right,
          style: TextStyle(
            fontSize: 14 * fem,
            fontWeight: FontWeight.w500,
            color: AppColors.gold,
          ),
        ),
      ),
    ],
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
