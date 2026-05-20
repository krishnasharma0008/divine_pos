import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:divine_pos/features/scan_ready/data/product_model.dart';
import '../../../shared/app_bar.dart';
import '../../../shared/routes/app_drawer.dart';
import '../../../shared/utils/enums.dart';
import '../../../shared/widgets/text.dart';
import '../provider/scan_ready_provider.dart';
import 'product_compare_cart_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ScanReadyProductScreen
// ─────────────────────────────────────────────────────────────────────────────

class ScanReadyProductScreen extends ConsumerStatefulWidget {
  const ScanReadyProductScreen({super.key});

  @override
  ConsumerState<ScanReadyProductScreen> createState() =>
      _ScanReadyProductScreenState();
}

class _ScanReadyProductScreenState
    extends ConsumerState<ScanReadyProductScreen> {
  bool _hasNavigatedToCompare = false;

  void _openScanPopup() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ScanPopup(
        onDetected: (product) {
          if (Navigator.canPop(context)) Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scanState = ref.watch(scanReadyProvider);

    ref.listen<AsyncValue<ScanReadyState>>(scanReadyProvider, (previous, next) {
      next.whenOrNull(
        error: (e, _) => ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString()))),
      );

      final prevProducts = previous?.asData?.value.products ?? [];
      final nextProducts = next.asData?.value.products ?? [];

      if (nextProducts.isEmpty) {
        _hasNavigatedToCompare = false;
        return;
      }

      if (!_hasNavigatedToCompare &&
          nextProducts.isNotEmpty &&
          !next.asData!.value.isLoading) {
        _hasNavigatedToCompare = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  ProductCompareCartScreen(initialProducts: nextProducts),
            ),
          ).then((_) {
            if (mounted) {
              _hasNavigatedToCompare = false;
            }
          });
        });
      }
    });

    final isLoading = scanState.asData?.value.isLoading ?? scanState.isLoading;

    return Scaffold(
      appBar: MyAppBar(appBarLeading: AppBarLeading.drawer, showLogo: false),
      drawer: const SideDrawer(),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          child: isLoading
              ? const _LoadingView(key: ValueKey('loading'))
              : _ScanPromptView(
                  key: const ValueKey('prompt'),
                  //onScan: _openScanPopup,
                  onScan: () async {
                    await ref
                        .read(scanReadyProvider.notifier)
                        .addByScannedCode('6YCJ62');

                    if (!context.mounted) return;
                  },
                ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ScanPromptView
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
        return SingleChildScrollView(
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

  static const Color _teal = Color(0xFF2BAFA0);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(color: _teal, strokeWidth: 3),
          ),
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
  const ScanPopup({super.key, required this.onDetected});

  final void Function(ProductModel product) onDetected;

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
  }

  @override
  void dispose() {
    _controller.dispose();
    _lineAnim.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Handlers
  // ---------------------------------------------------------------------------

  void _onDetect(BarcodeCapture capture) async {
    if (!_isScanning || _isProcessing) return;

    // Close the scan sheet.
    if (Navigator.canPop(context)) Navigator.pop(context);

    final Barcode? barcode = capture.barcodes.isNotEmpty
        ? capture.barcodes.first
        : null;
    String? rawValue = barcode?.rawValue;

    if (rawValue == null || rawValue.trim().isEmpty) return;
    rawValue = rawValue.trim();

    try {
      setState(() {
        _isProcessing = true;
        _isScanning = false;
      });
      await _controller.stop();

      final designNo = _extractDesignNo(rawValue);
      if (designNo.isEmpty) throw Exception('Design number not found in QR');

      final product = await ref
          .read(scanReadyProvider.notifier)
          .addByScannedCode(designNo);

      if (!mounted) return;
      widget.onDetected(product);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
        _isScanning = true;
      });
      await _controller.start();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
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

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Container(
        height: screenHeight * 0.8,
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
// Corner painter
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
  bool shouldRepaint(_CornerPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.side != side ||
        oldDelegate.thickness != thickness ||
        oldDelegate.radius != radius;
  }
}
