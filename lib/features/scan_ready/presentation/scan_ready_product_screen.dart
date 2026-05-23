import 'dart:convert';

import 'package:divine_pos/features/scan_ready/data/product_model.dart';
import 'package:divine_pos/features/scan_ready/provider/scan_ready_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../shared/app_bar.dart';
import '../../../shared/routes/app_drawer.dart';
import '../../../shared/utils/enums.dart';
import '../../../shared/widgets/text.dart';

class ScanReadyProductScreen extends ConsumerStatefulWidget {
  const ScanReadyProductScreen({super.key});

  @override
  ConsumerState<ScanReadyProductScreen> createState() =>
      _ScanReadyProductScreenState();
}

class _ScanReadyProductScreenState
    extends ConsumerState<ScanReadyProductScreen> {
  bool _showBreakup = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(scanReadyProvider.notifier).clearAll();
    });
  }

  static const Color _bg = Color(0xFFF5F3EF);
  static const Color _teal = Color(0xFF2BAFA0);

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _uniqueKey(ProductModel p) {
    final key = p.itemno?.trim().isNotEmpty == true
        ? p.itemno!.trim()
        : p.designno?.trim().isNotEmpty == true
        ? p.designno!.trim()
        : p.id?.toString() ?? '';
    return key;
  }

  void _removeProduct(ProductModel removed) {
    ref.read(scanReadyProvider.notifier).removeProduct(removed);
  }

  Future<void> _openScanPopup() async {
    final scannedCode = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) => const ScanPopup(),
    );

    if (!mounted || scannedCode == null || scannedCode.trim().isEmpty) return;

    final messenger = ScaffoldMessenger.of(context);

    try {
      final product = await ref
          .read(scanReadyProvider.notifier)
          .addByScannedCode(scannedCode.trim());

      if (!mounted) return;

      final name = (product.designno?.trim().isNotEmpty ?? false)
          ? product.designno!.trim()
          : (product.itemno?.trim().isNotEmpty ?? false)
          ? product.itemno!.trim()
          : 'Item';

      messenger.showSnackBar(SnackBar(content: Text('Product added: $name')));
    } catch (e) {
      if (!mounted) return;

      final raw = e.toString();

      String message;

      if (raw.contains('already in the comparison')) {
        message = 'This product is already in the comparison.';
      } else if (raw.contains('No product found')) {
        message = 'Product not found.';
      } else if (raw.contains('Invalid QR code')) {
        message = 'Invalid QR code.';
      } else {
        message = raw.replaceFirst('Exception: ', '');
      }

      messenger.showSnackBar(SnackBar(content: Text(message)));
    }
  }

  // ── Row / section definitions ──────────────────────────────────────────────

  List<_RowDef> get _mainRows => [
    _RowDef('MRP', (p) {
      if (p.productAmtMax != null && p.productAmtMax! > 0) {
        return '₹${_fmtIndian(p.productAmtMax!)}';
      }
      return '—';
    }, bold: true),
    _RowDef('Solitaire weight', (p) => _v(p.solitaireSlab)),
    _RowDef(
      'Metal weight',
      (p) => p.metalWeight != null ? '${p.metalWeight} g' : '—',
    ),
    _RowDef('UID', (p) => _v(p.itemno)),
    _RowDef('Design number', (p) => _v(p.designno)),
  ];

  List<_SectionDef> get _breakupSections => [
    _SectionDef('SOLITAIRE BREAKUP', [
      _RowDef('Cut / Shape', (p) => _v(p.solitaireShape)),
      _RowDef('Color', (p) => _v(p.solitaireColor)),
      _RowDef('Clarity', (p) => _v(p.solitaireQuality)),
      _RowDef(
        'Pieces',
        (p) => p.solitairePcs != null && p.solitairePcs! > 0
            ? '${p.solitairePcs} pcs'
            : '—',
      ),
      _RowDef('Amount', (p) {
        if (p.solitaireAmtMax != null && p.solitaireAmtMax! > 0) {
          return '₹${_fmtIndian(p.solitaireAmtMax!)}';
        }
        return '—';
      }),
    ]),
    _SectionDef('METAL BREAKUP', [
      _RowDef('Metal type', (p) {
        final parts = [
          p.metalType,
          p.metalColor,
        ].where((s) => s != null && s.isNotEmpty).join(' ');
        return parts.isNotEmpty ? parts : '—';
      }),
      _RowDef('Purity', (p) => _v(p.metalPurity)),
      _RowDef(
        'Weight',
        (p) => p.metalWeight != null ? '${p.metalWeight} g' : '—',
      ),
      _RowDef('Price', (p) {
        if (p.metalPrice != null && p.metalPrice! > 0) {
          return '₹${_fmtIndian(p.metalPrice!)}';
        }
        return '—';
      }),
    ]),
    _SectionDef('SIDE DIAMONDS', [
      _RowDef(
        'Count',
        (p) => p.sideStoneCtw != null && p.sideStoneCtw! > 0
            ? '${p.sideStonePcs} pcs'
            : '—',
      ),
      _RowDef(
        'Total weight',
        (p) => p.sideStoneCtw != null && p.sideStoneCtw! > 0
            ? '${p.sideStoneCtw} ct'
            : '—',
      ),

      _RowDef(
        'Clarity',
        (p) => p.sideStoneCtw != null && p.sideStoneCtw! > 0
            ? '${p.sideStoneColor} '
            : '—',
      ),
      _RowDef(
        'Total weight',
        (p) => p.sideStoneCtw != null && p.sideStoneCtw! > 0
            ? '${p.sideStoneQuality}'
            : '—',
      ),

      // _RowDef('Color', (p) => _v(p.sideStoneColor)),
      // _RowDef('Clarity', (p) => _v(p.sideStoneQuality)),
    ]),
  ];

  String _v(String? s) {
    final t = s?.trim() ?? '';
    return t.isNotEmpty ? t : '—';
  }

  String _fmtIndian(double v) {
    final s = v.toStringAsFixed(0);
    if (s.length <= 3) return s;
    final last3 = s.substring(s.length - 3);
    final rest = s.substring(0, s.length - 3);
    final buf = StringBuffer();
    for (int i = 0; i < rest.length; i++) {
      if (i > 0 && (rest.length - i) % 2 == 0) buf.write(',');
      buf.write(rest[i]);
    }
    return '${buf.toString()},$last3';
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final scanState = ref.watch(scanReadyProvider);

    // Show errors via snackbar
    ref.listen<AsyncValue<ScanReadyState>>(scanReadyProvider, (_, next) {
      next.whenOrNull(
        error: (e, _) => ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString()))),
      );
    });

    final isLoading = scanState.asData?.value.isLoading ?? scanState.isLoading;
    final products = scanState.asData?.value.products ?? [];

    // return PopScope(
    //   onPopInvokedWithResult: (didPop, result) {
    //     if (didPop) {
    //       ref.read(scanReadyProvider.notifier).clearAll();
    //     }
    //   },
    //   child:
    return Scaffold(
      backgroundColor: _bg,
      appBar: MyAppBar(appBarLeading: AppBarLeading.drawer, showLogo: false),
      drawer: const SideDrawer(),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: isLoading
              ? const _LoadingView(key: ValueKey('loading'))
              : products.isEmpty
              ? _ScanPromptView(
                  key: const ValueKey('prompt'),

                  onScan: _openScanPopup,
                  // onScan: () async {
                  //   await ref
                  //       .read(scanReadyProvider.notifier)
                  //       .addByScannedCode('6YCJ62');

                  //   if (!context.mounted) return;
                  // },
                )
              : _buildCompareView(products),
        ),
      ),
      //),
    );
  }

  // ── Compare view (previously ProductCompareCartScreen) ─────────────────────

  Widget _buildCompareView(List<ProductModel> products) {
    return Column(
      key: const ValueKey('compare'),
      children: [
        _buildCompareHeader(products),
        Expanded(child: _buildTableView(products)),
      ],
    );
  }

  Widget _buildCompareHeader(List<ProductModel> products) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Compare jewelry',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      TextSpan(
                        text:
                            '  ·  ${products.length} item${products.length == 1 ? '' : 's'}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF999999),
                        ),
                      ),
                    ],
                  ),
                ),
                // const Text(
                //   'Tap "Scan product" to add more',
                //   style: TextStyle(fontSize: 11, color: Color(0xFFBBBBBB)),
                // ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _openScanPopup,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                //color: const Color(0xFF1A1A1A),
                color: _teal,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.qr_code_scanner, color: Colors.white, size: 14),
                  SizedBox(width: 5),
                  Text(
                    'Scan to add product',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableView(List<ProductModel> products) {
    return Column(
      children: [
        Flexible(
          child: _CompareTable(
            products: products,
            mainRows: _mainRows,
            breakupSections: _breakupSections,
            showBreakup: _showBreakup,
            onRemove: (index) => _removeProduct(products[index]),
            onAddProduct: _openScanPopup,
          ),
        ),
        _buildToggle(),
      ],
    );
  }

  Widget _buildToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: GestureDetector(
        onTap: () => setState(() => _showBreakup = !_showBreakup),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFE2DDD8)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _showBreakup ? 'Hide breakup' : 'Show full breakup',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF444444),
                ),
              ),
              const SizedBox(width: 5),
              AnimatedRotation(
                turns: _showBreakup ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                child: const Icon(
                  Icons.keyboard_arrow_down,
                  size: 17,
                  color: Color(0xFF666666),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ScanPromptView  (empty state – no products yet)
// ─────────────────────────────────────────────────────────────────────────────

class _ScanPromptView extends StatelessWidget {
  const _ScanPromptView({super.key, required this.onScan});

  final VoidCallback onScan;

  static const Color _teal = Color(0xFF2BAFA0);
  static const Color _tealLight = Color(0xFFE0F5F2);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SafeArea(
          child: SingleChildScrollView(
            hitTestBehavior: HitTestBehavior.translucent,
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 32),
                      const Text(
                        'SCAN READY PRODUCT',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.4,
                          color: Color(0xFF333333),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      MyText(
                        'Position the QR code within the frame to scan',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[500],
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 32),
                      GestureDetector(
                        onTap: onScan,
                        behavior: HitTestBehavior.opaque,
                        child: _buildFrame(),
                      ),
                      const SizedBox(height: 28),
                      _buildCaptureButton(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFrame() {
    const size = 280.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _tealLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          _corner(top: 16, left: 16, side: _CornerSide.topLeft),
          _corner(top: 16, right: 16, side: _CornerSide.topRight),
          _corner(bottom: 16, left: 16, side: _CornerSide.bottomLeft),
          _corner(bottom: 16, right: 16, side: _CornerSide.bottomRight),
          Center(
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.camera_alt_outlined,
                color: _teal,
                size: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _corner({
    double? top,
    double? left,
    double? right,
    double? bottom,
    required _CornerSide side,
  }) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: SizedBox(
        width: 36,
        height: 36,
        child: CustomPaint(
          painter: _CornerPainter(
            side: side,
            color: _teal,
            thickness: 3.5,
            radius: 10,
          ),
        ),
      ),
    );
  }

  Widget _buildCaptureButton() {
    return GestureDetector(
      onTap: onScan,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 68,
        height: 68,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey[200],
          border: Border.all(color: Colors.grey[300]!, width: 2),
        ),
        child: Center(
          child: Container(
            width: 54,
            height: 54,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF2BAFA0),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _LoadingView
// ─────────────────────────────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  const _LoadingView({super.key});

  //static const Color _teal = Color(0xFF2BAFA0);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(width: 48, height: 48, child: CircularProgressIndicator()),
          SizedBox(height: 20),
          Text(
            'Fetching product details…',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF9E9E9E),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ScanPopup
// ─────────────────────────────────────────────────────────────────────────────

class ScanPopup extends ConsumerStatefulWidget {
  const ScanPopup({super.key});

  @override
  ConsumerState<ScanPopup> createState() => _ScanPopupState();
}

class _ScanPopupState extends ConsumerState<ScanPopup>
    with SingleTickerProviderStateMixin {
  final MobileScannerController _controller = MobileScannerController();

  bool _isScanning = true;
  bool _flashOn = false;
  bool _isProcessing = false;

  late AnimationController _lineAnim;
  late Animation<double> _linePosition;

  static const Color _teal = Color(0xFF2BAFA0);

  @override
  void initState() {
    super.initState();

    _lineAnim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _linePosition = Tween<double>(
      begin: 0.05,
      end: 0.92,
    ).animate(CurvedAnimation(parent: _lineAnim, curve: Curves.easeInOut));

    //_scanNotifier = ref.read(scanReadyProvider.notifier);
  }

  @override
  void dispose() {
    _controller.dispose();
    _lineAnim.dispose();
    super.dispose();
  }

  // ── Handlers ───────────────────────────────────────────────────────────────

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (!_isScanning || _isProcessing) return;

    final barcode = capture.barcodes.firstOrNull;
    final rawValue = barcode?.rawValue?.trim();

    if (rawValue == null || rawValue.isEmpty) return;

    _isProcessing = true;
    _isScanning = false;

    try {
      if (mounted) setState(() {});

      await _controller.stop();

      final designNo = _extractDesignNo(rawValue);

      if (designNo.isEmpty) {
        throw Exception('Invalid QR code');
      }

      if (!mounted) return;
      Navigator.pop(context, designNo);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );

      _isProcessing = false;
      _isScanning = true;

      setState(() {});

      await _controller.start();
    }
  }

  String _extractDesignNo(String rawValue) {
    final value = rawValue.trim();

    if (value.startsWith('{') && value.endsWith('}')) {
      try {
        final map = jsonDecode(value) as Map<String, dynamic>;
        final extracted =
            (map['designno'] ??
                    map['design_no'] ??
                    map['item_number'] ??
                    map['product_id'] ??
                    '')
                .toString()
                .trim();
        if (extracted.isNotEmpty) return extracted;
      } catch (_) {}
    }

    final uri = Uri.tryParse(value);
    if (uri != null && uri.hasScheme) {
      final queryValue =
          uri.queryParameters['designno'] ??
          uri.queryParameters['design_no'] ??
          uri.queryParameters['item_number'] ??
          uri.queryParameters['product_id'];
      if (queryValue != null && queryValue.trim().isNotEmpty) {
        return queryValue.trim();
      }
      final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
      if (segments.isNotEmpty) return segments.last;
    }

    return value;
  }

  Future<void> _toggleFlash() async {
    setState(() => _flashOn = !_flashOn);
    await _controller.toggleTorch();
  }

  Future<void> _toggleScanning() async {
    if (_isProcessing) return;
    if (_isScanning) {
      await _controller.stop();
    } else {
      await _controller.start();
    }
    if (!mounted) return;
    setState(() => _isScanning = !_isScanning);
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Container(
        height: screenHeight * 0.88,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            _handle(),
            _header(context),
            const SizedBox(height: 8),
            Text(
              'Position the QR code within the frame',
              style: TextStyle(fontSize: 13, color: Colors.grey[500]),
            ),
            const SizedBox(height: 24),
            Expanded(child: _scanArea()),
            _bottomControls(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _handle() {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 18, color: Colors.black54),
            ),
          ),
          const Spacer(),
          const Text(
            'SCAN QR CODE',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
              color: Color(0xFF333333),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: _toggleFlash,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _flashOn ? _teal.withOpacity(0.15) : Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                _flashOn ? Icons.flash_on : Icons.flash_off,
                size: 18,
                color: _flashOn ? _teal : Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _scanArea() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final frameSize = constraints.maxWidth * 0.78;
        return Center(
          child: Container(
            width: frameSize,
            height: frameSize,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: MobileScanner(
                    controller: _controller,
                    onDetect: _onDetect,
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        radius: 0.75,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.35),
                        ],
                      ),
                    ),
                  ),
                ),
                _pc(top: 16, left: 16, side: _CornerSide.topLeft),
                _pc(top: 16, right: 16, side: _CornerSide.topRight),
                _pc(bottom: 16, left: 16, side: _CornerSide.bottomLeft),
                _pc(bottom: 16, right: 16, side: _CornerSide.bottomRight),
                AnimatedBuilder(
                  animation: _linePosition,
                  builder: (_, __) => Positioned(
                    top: frameSize * _linePosition.value,
                    left: 20,
                    right: 20,
                    child: Container(
                      height: 2.5,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _teal.withOpacity(0),
                            _teal,
                            _teal.withOpacity(0),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(2),
                        boxShadow: [
                          BoxShadow(
                            color: _teal.withOpacity(0.5),
                            blurRadius: 8,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _pc({
    double? top,
    double? left,
    double? right,
    double? bottom,
    required _CornerSide side,
  }) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: SizedBox(
        width: 40,
        height: 40,
        child: CustomPaint(
          painter: _CornerPainter(
            side: side,
            color: _teal,
            thickness: 3.5,
            radius: 12,
          ),
        ),
      ),
    );
  }

  Widget _bottomControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      child: GestureDetector(
        onTap: _toggleScanning,
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey[200],
            border: Border.all(color: Colors.grey[300]!, width: 2.5),
          ),
          child: Center(
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isScanning ? _teal : Colors.grey[400],
              ),
              child: Icon(
                _isScanning ? Icons.qr_code_scanner : Icons.play_arrow,
                color: Colors.white,
                size: 26,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Data classes
// ─────────────────────────────────────────────────────────────────────────────

class _RowDef {
  final String label;
  final String Function(ProductModel) value;
  final bool bold;
  const _RowDef(this.label, this.value, {this.bold = false});
}

class _SectionDef {
  final String title;
  final List<_RowDef> rows;
  const _SectionDef(this.title, this.rows);
}

// ─────────────────────────────────────────────────────────────────────────────
// _CompareTable
// ─────────────────────────────────────────────────────────────────────────────

class _CompareTable extends StatefulWidget {
  final List<ProductModel> products;
  final List<_RowDef> mainRows;
  final List<_SectionDef> breakupSections;
  final bool showBreakup;
  final void Function(int) onRemove;
  final VoidCallback onAddProduct;

  const _CompareTable({
    required this.products,
    required this.mainRows,
    required this.breakupSections,
    required this.showBreakup,
    required this.onRemove,
    required this.onAddProduct,
  });

  @override
  State<_CompareTable> createState() => _CompareTableState();
}

class _CompareTableState extends State<_CompareTable> {
  final _hScrollHeader = ScrollController(); // ← split into two
  final _hScrollBody = ScrollController();
  final _vScroll = ScrollController();

  bool _isSyncing = false; // prevents infinite loop

  static const double _labelColW = 130.0;
  static const double _minColW = 110.0;
  static const double _addColW = 80.0;
  static const double _headerH = 104.0;
  static const double _rowH = 44.0;
  static const double _sectionH = 30.0;

  static const Color _teal = Color(0xFF2BAFA0);
  static const Color _tealLight = Color(0xFFE0F5F2);
  static const Color _border = Color(0xFFE2DDD8);
  static const Color _labelBg = Color(0xFFF7F5F2);
  static const Color _sectionBg = Color(0xFFEEEBE6);
  static const Color _addColBg = Color(0xFFFAFAFA);
  static const Color _white = Colors.white;

  @override
  void initState() {
    super.initState();
    _hScrollHeader.addListener(_onHeaderScroll);
    _hScrollBody.addListener(_onBodyScroll);
  }

  void _onHeaderScroll() {
    if (_isSyncing) return;
    if (!_hScrollBody.hasClients) return;
    _isSyncing = true;
    _hScrollBody.jumpTo(_hScrollHeader.offset);
    _isSyncing = false;
  }

  void _onBodyScroll() {
    if (_isSyncing) return;
    if (!_hScrollHeader.hasClients) return;
    _isSyncing = true;
    _hScrollHeader.jumpTo(_hScrollBody.offset);
    _isSyncing = false;
  }

  @override
  void dispose() {
    _hScrollHeader.removeListener(_onHeaderScroll);
    _hScrollBody.removeListener(_onBodyScroll);
    _hScrollHeader.dispose();
    _hScrollBody.dispose();
    _vScroll.dispose();
    super.dispose();
  }

  int get _count => widget.products.length;

  double _colW(BuildContext context) {
    final screen = MediaQuery.of(context).size.width;
    const overhead = 16.0 + 16.0 + 1.0 + 1.0 + _labelColW + 1.0;
    final available = screen - overhead;
    if (_count <= 0 || available <= 0) return _minColW;
    final each = available / _count;
    return each >= _minColW ? each : _minColW;
  }

  @override
  Widget build(BuildContext context) {
    final colW = _colW(context);

    return LayoutBuilder(
      // ← knows available height
      builder: (context, constraints) {
        //final maxBodyH = constraints.maxHeight - _headerH; // space below header
        const borderWidth = 1.0; // matches Border.all default
        final maxBodyH =
            constraints.maxHeight -
            _headerH -
            (borderWidth * 2); // ← subtract 2px border

        return Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          decoration: BoxDecoration(
            color: _white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _border),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Column(
              mainAxisSize: MainAxisSize.min, // ← shrinks to content
              children: [
                _buildStickyHeader(colW),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: maxBodyH,
                  ), // ← cap, not force
                  child: SingleChildScrollView(
                    controller: _vScroll,
                    physics: const ClampingScrollPhysics(),
                    child: _buildScrollableBody(colW),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStickyHeader(double colW) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(width: _labelColW, height: _headerH, color: _labelBg),
        //Container(width: 1, height: _headerH, color: _border),
        Expanded(
          child: SingleChildScrollView(
            controller: _hScrollHeader,
            scrollDirection: Axis.horizontal,
            physics: const ClampingScrollPhysics(),
            child: Row(
              children: [
                for (int i = 0; i < _count; i++)
                  Container(
                    width: colW,
                    decoration: BoxDecoration(
                      border: i == _count - 1
                          ? null
                          : const Border(
                              right: BorderSide(color: _border, width: 1),
                            ),
                    ),
                    child: _ph(_headerH, p: widget.products[i], index: i),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScrollableBody(double colW) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: _labelColW, child: _buildLabelColumnBody()),

        //Container(width: 1, color: _border),
        Expanded(
          child: SingleChildScrollView(
            controller: _hScrollBody,
            scrollDirection: Axis.horizontal,
            physics: const ClampingScrollPhysics(),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < _count; i++)
                  Container(
                    width: colW,
                    // decoration: BoxDecoration(
                    //   border: Border(
                    //     right: BorderSide(color: Colors.grey.shade300),
                    //   ),
                    // ),
                    child: _buildProductColumnBody(i),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLabelColumnBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final row in widget.mainRows) _lc(row.label),

        if (widget.showBreakup)
          for (final sec in widget.breakupSections) ...[
            _ls(sec.title),
            for (final row in sec.rows) _lc(row.label),
          ],
      ],
    );
  }

  Widget _buildProductColumnBody(int index) {
    final p = widget.products[index];

    return Container(
      decoration: BoxDecoration(
        border: index == _count - 1
            ? null
            : const Border(right: BorderSide(color: _border, width: 1)),
      ),
      child: Column(
        children: [
          for (final row in widget.mainRows) _vc(row.value(p), bold: row.bold),
          if (widget.showBreakup)
            for (final sec in widget.breakupSections) ...[
              _vs(),
              for (final row in sec.rows) _vc(row.value(p)),
            ],
        ],
      ),
    );
  }

  // ── Cell helpers ───────────────────────────────────────────────────────────

  Widget _lh(double h, {required Widget child}) => Container(
    height: h,
    width: double.infinity,
    color: _labelBg,
    alignment: Alignment.centerLeft,
    padding: const EdgeInsets.symmetric(horizontal: 12),
    child: child,
  );

  Widget _lc(String label) => Container(
    height: _rowH,
    width: double.infinity,
    alignment: Alignment.centerLeft,
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: const BoxDecoration(
      color: _labelBg,
      border: Border(top: BorderSide(color: _border)),
    ),
    child: Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontSize: 11.5,
        color: Color(0xFF555555),
        fontWeight: FontWeight.w400,
      ),
    ),
  );

  Widget _ls(String title) => Container(
    height: _sectionH,
    width: double.infinity,
    alignment: Alignment.centerLeft,
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: const BoxDecoration(
      color: _sectionBg,
      border: Border(top: BorderSide(color: _border)),
    ),
    child: MyText(
      title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontSize: 9.5,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        color: Color(0xFF999990),
      ),
    ),
  );

  Widget _ph(double h, {required ProductModel p, required int index}) {
    return Container(
      height: h,
      width: double.infinity,
      color: _white,
      child: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 10, 20, 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _thumbnail(p),
                  const SizedBox(height: 6),
                  Text(
                    _name(p),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF222222),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 6,
            right: 6,
            child: GestureDetector(
              onTap: () => widget.onRemove(index),
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: _white,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFCCCCCC)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 3,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.close,
                  size: 12,
                  color: Color(0xFF888888),
                ),
              ),
            ),
          ),
          // Positioned(
          //   bottom: 0,
          //   left: 0,
          //   right: 0,
          //   child: Container(height: 1, color: _border),
          // ),
        ],
      ),
    );
  }

  Widget _vc(String value, {bool bold = false}) {
    final empty = value == '—';
    return Container(
      height: _rowH,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: _white,
        border: Border(top: BorderSide(color: _border)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Text(
        value,
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: bold ? 12.5 : 11.5,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
          color: empty
              ? const Color(0xFFCCCCCC)
              : bold
              ? const Color(0xFF1A1A1A)
              : const Color(0xFF444444),
        ),
      ),
    );
  }

  Widget _vs() => Container(
    height: _sectionH,
    width: double.infinity,
    decoration: const BoxDecoration(
      color: _sectionBg,
      border: Border(top: BorderSide(color: _border)),
    ),
  );

  Widget _emptyCell() => Container(
    height: _rowH,
    width: double.infinity,
    decoration: const BoxDecoration(
      color: _addColBg,
      border: Border(top: BorderSide(color: _border)),
    ),
  );

  Widget _emptySectionCell() => Container(
    height: _sectionH,
    width: double.infinity,
    decoration: const BoxDecoration(
      color: _sectionBg,
      border: Border(top: BorderSide(color: _border)),
    ),
  );

  Widget _thumbnail(ProductModel p) {
    final url = p.imageUrl?.trim() ?? '';
    if (url.startsWith('http')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.network(
          url,
          width: 54,
          height: 54,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => _icon(p),
        ),
      );
    }
    return _icon(p);
  }

  Widget _icon(ProductModel p) {
    final cat = (p.productSubCategory ?? p.productCategory ?? '').toLowerCase();
    Color bg, fg;
    IconData icon;
    if (cat.contains('ring')) {
      bg = const Color(0xFFF5E8D5);
      fg = const Color(0xFFB8863A);
      icon = Icons.circle_outlined;
    } else if (cat.contains('stud') || cat.contains('ear')) {
      bg = const Color(0xFFE8E8E8);
      fg = const Color(0xFF666666);
      icon = Icons.stop_rounded;
    } else if (cat.contains('pendant') || cat.contains('drop')) {
      bg = const Color(0xFFFDE8F0);
      fg = const Color(0xFFD4489A);
      icon = Icons.diamond_outlined;
    } else if (cat.contains('nose')) {
      bg = const Color(0xFFFFF3E0);
      fg = const Color(0xFFE6891A);
      icon = Icons.circle;
    } else if (cat.contains('bangle') || cat.contains('bracelet')) {
      bg = const Color(0xFFE8F0FF);
      fg = const Color(0xFF3A6AB8);
      icon = Icons.circle_outlined;
    } else if (cat.contains('chain') || cat.contains('necklace')) {
      bg = const Color(0xFFEDE7F6);
      fg = const Color(0xFF7B1FA2);
      icon = Icons.link;
    } else {
      bg = const Color(0xFFE0F5F2);
      fg = _teal;
      icon = Icons.diamond;
    }
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Icon(icon, size: 24, color: fg),
    );
  }

  String _name(ProductModel p) {
    final sub = p.productSubCategory?.trim() ?? '';
    if (sub.isNotEmpty) return _tc(sub);
    final cat = p.productCategory?.trim() ?? '';
    if (cat.isNotEmpty) return _tc(cat);
    return p.designno ?? '#${p.id}';
  }

  String _tc(String s) => s
      .split(' ')
      .map(
        (w) => w.isEmpty
            ? ''
            : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}',
      )
      .join(' ');
}

// ─────────────────────────────────────────────────────────────────────────────
// Corner painter (shared by ScanPopup + _ScanPromptView)
// ─────────────────────────────────────────────────────────────────────────────

enum _CornerSide { topLeft, topRight, bottomLeft, bottomRight }

class _CornerPainter extends CustomPainter {
  final _CornerSide side;
  final Color color;
  final double thickness;
  final double radius;

  const _CornerPainter({
    required this.side,
    required this.color,
    required this.thickness,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    final w = size.width;
    final h = size.height;
    final r = radius;

    switch (side) {
      case _CornerSide.topLeft:
        path.moveTo(0, h);
        path.lineTo(0, r);
        path.arcToPoint(Offset(r, 0), radius: Radius.circular(r));
        path.lineTo(w, 0);
        break;
      case _CornerSide.topRight:
        path.moveTo(0, 0);
        path.lineTo(w - r, 0);
        path.arcToPoint(Offset(w, r), radius: Radius.circular(r));
        path.lineTo(w, h);
        break;
      case _CornerSide.bottomLeft:
        path.moveTo(w, h);
        path.lineTo(r, h);
        path.arcToPoint(Offset(0, h - r), radius: Radius.circular(r));
        path.lineTo(0, 0);
        break;
      case _CornerSide.bottomRight:
        path.moveTo(w, 0);
        path.lineTo(w, h - r);
        path.arcToPoint(Offset(w - r, h), radius: Radius.circular(r));
        path.lineTo(0, h);
        break;
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CornerPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.side != side ||
      oldDelegate.thickness != thickness ||
      oldDelegate.radius != radius;
}
