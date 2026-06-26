import 'package:divine_pos/shared/widgets/text.dart';

import '../data/product_model.dart';
import '../provider/ready_product_provider.dart';
import 'package:divine_pos/shared/utils/enums.dart';
import '../presentation/widget/product_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../shared/app_bar.dart';

class ReadyProductScreen extends ConsumerStatefulWidget {
  const ReadyProductScreen({super.key});

  @override
  ConsumerState<ReadyProductScreen> createState() => _ReadyProductScreenState();
}

class _ReadyProductScreenState extends ConsumerState<ReadyProductScreen> {
  static const Color _bg = Color(0xFFF5F3EF);
  static const Color _teal = Color(0xFF2BAFA0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(readyProductProvider.notifier).clearAll();
    });
  }

  // ✅ testing — swap onScan: _testLoad → _openScanPopup when done
  Future<void> _testLoad() async {
    await ref.read(readyProductProvider.notifier).addByScannedCode('9ENX79');
  }

  Future<void> _openScanPopup() async {
    final scannedCode = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) => const _ScanPopup(),
    );

    if (!mounted || scannedCode == null || scannedCode.trim().isEmpty) return;

    final messenger = ScaffoldMessenger.of(context);

    try {
      final product = await ref
          .read(readyProductProvider.notifier)
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

  void _removeProduct(ProductModel removed) {
    ref.read(readyProductProvider.notifier).removeProduct(removed);
  }

  void _addToCart(ProductModel product) {
    // TODO: wire up to your actual cart provider / use-case.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Added ${product.designno ?? product.itemno ?? 'product'} to cart',
        ),
        backgroundColor: _teal,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final readyState = ref.watch(readyProductProvider);

    ref.listen<AsyncValue<ReadyProductState>>(readyProductProvider, (_, next) {
      next.whenOrNull(
        error: (e, _) => ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString()))),
      );
    });

    final isLoading =
        readyState.asData?.value.isLoading ?? readyState.isLoading;
    final products = readyState.asData?.value.products ?? [];

    return Scaffold(
      backgroundColor: _bg,
      appBar: MyAppBar(appBarLeading: AppBarLeading.back, showLogo: false),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: isLoading
              ? const _LoadingView(key: ValueKey('loading'))
              : products.isEmpty
              ? _ScanPromptView(
                  key: const ValueKey('prompt'),
                  onScan: _testLoad, // ← swap to _openScanPopup when done
                )
              : _buildCardGrid(products),
        ),
      ),
    );
  }

  // ── Card-grid view ─────────────────────────────────────────────────────────

  Widget _buildCardGrid(List<ProductModel> products) {
    return Column(
      key: const ValueKey('grid'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Pill scan button row ─────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
          child: OutlinedButton.icon(
            onPressed: _openScanPopup,
            style: OutlinedButton.styleFrom(
              foregroundColor: _teal,
              side: const BorderSide(color: _teal, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            icon: const Icon(Icons.crop_free_rounded, size: 20),
            label: const Text(
              'Scan Ready Products',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ),

        // ── Header ──────────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: RichText(
                  text: TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Product Compare Cart',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      TextSpan(
                        text: ' (${products.length})',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF888888),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () =>
                    ref.read(readyProductProvider.notifier).clearAll(),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('Clear All', style: TextStyle(fontSize: 13)),
              ),
            ],
          ),
        ),

        // ── Responsive tablet grid ───────────────────────────────────────────
        // portrait  (~768 px)  → 3 columns
        // landscape (~1024 px) → 4 columns
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final cols = (constraints.maxWidth / 240).floor().clamp(3, 4);
              final cardWidth =
                  (constraints.maxWidth - 24 - (cols - 1) * 10) / cols;

              // ── Single product: center it ──────────────────────────────────
              if (products.length == 1) {
                final p = products.first;
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 100),
                  child: Center(
                    child: SizedBox(
                      width: cardWidth,
                      child: ProductCard(
                        key: ValueKey(
                          p.id != 0 ? p.id : (p.itemno ?? p.designno ?? 0),
                        ),
                        product: p,
                        onRemove: () => _removeProduct(p),
                        //onAddToCart: () => _addToCart(p),
                      ),
                    ),
                  ),
                );
              }

              // ── Multiple products: grid ────────────────────────────────────
              return GridView.builder(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 100),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.68,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return ProductCard(
                    key: ValueKey(
                      product.id != 0
                          ? product.id
                          : (product.itemno ?? product.designno ?? index),
                    ),
                    product: product,
                    onRemove: () => _removeProduct(product),
                    onAddToCart: () => _addToCart(product),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Scan popup
// ─────────────────────────────────────────────────────────────────────────────

class _ScanPopup extends StatefulWidget {
  const _ScanPopup();

  @override
  State<_ScanPopup> createState() => _ScanPopupState();
}

class _ScanPopupState extends State<_ScanPopup> {
  static const Color _teal = Color(0xFF2BAFA0);
  late final MobileScannerController _ctrl;
  bool _torchOn = false;
  bool _scanned = false;

  @override
  void initState() {
    super.initState();
    _ctrl = MobileScannerController(
      formats: [BarcodeFormat.qrCode, BarcodeFormat.code128],
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_scanned) return;
    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw == null || raw.trim().isEmpty) return;
    _scanned = true;
    Navigator.of(context).pop(raw.trim());
  }

  @override
  Widget build(BuildContext context) {
    final sheetH = MediaQuery.of(context).size.height * 0.75;

    return Container(
      height: sheetH,
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 6),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white30,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(
                  Icons.qr_code_scanner,
                  color: Colors.white70,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Scan QR Code',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    setState(() => _torchOn = !_torchOn);
                    await _ctrl.toggleTorch();
                  },
                  icon: Icon(
                    _torchOn ? Icons.flash_on : Icons.flash_off,
                    color: _torchOn ? Colors.amber : Colors.white54,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Colors.white54),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    MobileScanner(controller: _ctrl, onDetect: _onDetect),
                    ..._CornerSide.values.map(
                      (s) => Positioned(
                        top:
                            s == _CornerSide.topLeft ||
                                s == _CornerSide.topRight
                            ? 16
                            : null,
                        bottom:
                            s == _CornerSide.bottomLeft ||
                                s == _CornerSide.bottomRight
                            ? 16
                            : null,
                        left:
                            s == _CornerSide.topLeft ||
                                s == _CornerSide.bottomLeft
                            ? 16
                            : null,
                        right:
                            s == _CornerSide.topRight ||
                                s == _CornerSide.bottomRight
                            ? 16
                            : null,
                        width: 36,
                        height: 36,
                        child: CustomPaint(
                          painter: _CornerPainter(
                            side: s,
                            color: _teal,
                            thickness: 3,
                            radius: 8,
                          ),
                        ),
                      ),
                    ),
                    const Align(
                      alignment: Alignment(0, 0.82),
                      child: Text(
                        'Align QR code within the frame',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Scan prompt (empty state)
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
// Loading view
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
          CircularProgressIndicator(color: _teal, strokeWidth: 2.5),
          SizedBox(height: 16),
          Text(
            'Fetching product…',
            style: TextStyle(color: Color(0xFF666666), fontSize: 14),
          ),
        ],
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
  bool shouldRepaint(_CornerPainter old) =>
      old.color != color ||
      old.side != side ||
      old.thickness != thickness ||
      old.radius != radius;
}
