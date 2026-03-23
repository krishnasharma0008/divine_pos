import 'package:divine_pos/features/auth/data/auth_notifier.dart';
import 'package:divine_pos/shared/app_bar.dart';
import 'package:divine_pos/shared/routes/app_drawer.dart';
import 'package:divine_pos/shared/routes/route_pages.dart';
import 'package:divine_pos/shared/utils/enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../provider/verify_track_providers.dart';

class AppColors {
  static const mintGreen = Color(0xFFB2CFCA);
  static const mintLight = Color(0xFFD4E8E4);
  static const mintDark = Color(0xFF7AADA6);
  static const white = Color(0xFFFFFFFF);
  static const bgGrey = Color(0xFFF8F8F8);
  static const textDark = Color(0xFF1A1A1A);
  static const textMid = Color(0xFF555555);
  static const textLight = Color(0xFF999999);
  static const divider = Color(0xFFDDDDDD);
  static const cardShadow = Color(0x14000000);
}

// =============================================================================
// Screen
// =============================================================================

class VerifyAndTrackScreen extends ConsumerStatefulWidget {
  const VerifyAndTrackScreen({super.key});

  @override
  ConsumerState<VerifyAndTrackScreen> createState() =>
      _VerifyAndTrackScreenState();
}

class _VerifyAndTrackScreenState extends ConsumerState<VerifyAndTrackScreen> {
  @override
  void initState() {
    super.initState();
    // Mirror of JS useEffect on mount — auto-search if portfolio UID stored
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkPortfolioUid());
  }

  Future<void> _checkPortfolioUid() async {
    // TODO: replace with your portfolioStorageService
    // final storedUid = ref.read(portfolioStorageProvider).getPortfolioUid();
    const String? storedUid = null;

    if (storedUid != null && storedUid.isNotEmpty) {
      ref.read(uidControllerProvider).text = storedUid;
      await _doSearch(storedUid, isPortfolio: true);
    }
  }

  Future<void> _doSearch(String uid, {bool isPortfolio = false}) async {
    if (uid.trim().isEmpty) {
      _showError("Please enter UID");
      return;
    }

    await ref
        .read(verifyTrackProvider.notifier)
        .searchData(
          uid: uid.trim(),
          isPortfolio: isPortfolio,
          onNavigate: (path, {isPortfolio = false}) {
            if (isPortfolio) {
              context.push(path, extra: {'portfolio': 'yes'});
            } else {
              context.push(path);
            }
          },
          onError: (msg) => _showError(msg),
        );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uidController = ref.watch(uidControllerProvider);
    final isLoading = ref.watch(verifyTrackProvider.select((s) => s.isLoading));

    return Scaffold(
      backgroundColor: AppColors.bgGrey,

      // ---- Swap with your shared MyAppBar ----
      appBar: MyAppBar(
        appBarLeading: AppBarLeading.drawer,
        showLogo: true,
        actions: [
          AppBarActionConfig(type: AppBarAction.search, onTap: () {}),
          AppBarActionConfig(
            type: AppBarAction.notification,
            badgeCount: ref.watch(authProvider).user?.cartCount ?? 0,
            onTap: () {},
          ),
          AppBarActionConfig(
            type: AppBarAction.profile,
            onTap: () => context.push('/profile'),
          ),
          AppBarActionConfig(
            type: AppBarAction.cart,
            badgeCount: 0,
            onTap: () => context.pushNamed(RoutePages.cart.routeName),
          ),
        ],
      ),

      // ---- Swap with your SideDrawer ----
      drawer: SideDrawer(),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _MintAccentBar(),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 28,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _SectionLabel(
                        title: 'VERIFY & TRACK',
                        subtitle:
                            'Enter your UID or scan the QR code on your product',
                      ),
                      const SizedBox(height: 24),
                      _ContentCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _UidTextField(
                              controller: uidController,
                              enabled: !isLoading,
                              onSubmitted: (_) => _doSearch(uidController.text),
                            ),
                            const SizedBox(height: 16),
                            _SubmitButton(
                              //isLoading: isLoading,
                              onPressed: () => _doSearch(uidController.text),
                            ),
                            const SizedBox(height: 24),
                            const _OrDivider(),
                            const SizedBox(height: 24),
                            const _QrScannerFrame(),
                            const SizedBox(height: 20),
                            _ScanQrButton(
                              isLoading: isLoading,
                              onPressed: isLoading
                                  ? null
                                  : () {
                                      // TODO: open mobile_scanner
                                      // On result: _doSearch(scannedUid)
                                      debugPrint('Open QR scanner');
                                    },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      const _AboutCard(),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Full-screen loader — mirrors JS showLoader/hideLoader
          if (isLoading) const _LoaderOverlay(),
        ],
      ),
    );
  }
}

// =============================================================================
// Reusable Widgets
// =============================================================================

class _MintAccentBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 3,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.mintLight,
            AppColors.mintGreen,
            AppColors.mintLight,
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 3,
            color: AppColors.textDark,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textMid,
            letterSpacing: 0.2,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _ContentCard extends StatelessWidget {
  const _ContentCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _UidTextField extends StatelessWidget {
  const _UidTextField({
    required this.controller,
    this.enabled = true,
    this.onSubmitted,
  });
  final TextEditingController controller;
  final bool enabled;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      textCapitalization: TextCapitalization.characters,
      textInputAction: TextInputAction.search,
      onSubmitted: onSubmitted,
      style: const TextStyle(fontSize: 14, color: AppColors.textDark),
      decoration: InputDecoration(
        hintText: 'Enter Unique Identification Numb...',
        hintStyle: const TextStyle(color: AppColors.textLight, fontSize: 14),
        filled: true,
        fillColor: AppColors.bgGrey,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.divider, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.mintDark, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.divider, width: 1.5),
        ),
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({required this.onPressed, this.isLoading = false});
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: SizedBox(
          height: 50,
          child: ElevatedButton(
            onPressed: onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textDark,
              backgroundColor: AppColors.mintLight,
              disabledBackgroundColor: AppColors.mintLight.withOpacity(0.5),
              side: const BorderSide(color: AppColors.mintDark, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.mintDark,
                      ),
                    ),
                  )
                : const Text(
                    'SUBMIT',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.divider, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.mintLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'OR',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.mintDark,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.divider, thickness: 1)),
      ],
    );
  }
}

class _QrScannerFrame extends StatelessWidget {
  const _QrScannerFrame();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 190,
        height: 190,
        decoration: BoxDecoration(
          color: AppColors.bgGrey,
          borderRadius: BorderRadius.circular(8),
        ),
        child: CustomPaint(
          painter: _QrFramePainter(),
          child: Center(
            child: Icon(
              Icons.bar_chart,
              size: 68,
              color: AppColors.textDark.withOpacity(0.65),
            ),
          ),
        ),
      ),
    );
  }
}

class _QrFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.mintDark
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;
    const c = 32.0;
    final w = size.width;
    final h = size.height;
    canvas.drawLine(const Offset(0, c), Offset.zero, paint);
    canvas.drawLine(Offset.zero, Offset(c, 0), paint);
    canvas.drawLine(Offset(w - c, 0), Offset(w, 0), paint);
    canvas.drawLine(Offset(w, 0), Offset(w, c), paint);
    canvas.drawLine(Offset(0, h - c), Offset(0, h), paint);
    canvas.drawLine(Offset(0, h), Offset(c, h), paint);
    canvas.drawLine(Offset(w - c, h), Offset(w, h), paint);
    canvas.drawLine(Offset(w, h), Offset(w, h - c), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _ScanQrButton extends StatelessWidget {
  const _ScanQrButton({required this.onPressed, this.isLoading = false});
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: SizedBox(
          height: 50,
          child: OutlinedButton.icon(
            onPressed: onPressed,
            icon: isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.mintDark,
                      ),
                    ),
                  )
                : const Icon(Icons.qr_code_scanner, size: 18),
            label: const Text(
              'Scan QR Code',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.4,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textDark,
              backgroundColor: AppColors.mintLight,
              side: const BorderSide(color: AppColors.mintDark, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AboutCard extends StatelessWidget {
  const _AboutCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 3,
                height: 18,
                decoration: BoxDecoration(
                  color: AppColors.mintGreen,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'About Verify & Track',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            "Divine Solitaires 'Verify & Track' is a never-seen-before digital experience "
            "which brings a distinctive diamond experience to the consumers' fingertips. "
            "With the help of the UID (Product ID), you can know the price & quality of your "
            "Divine Solitaires, know its journey from mining to the finished product, avail a "
            "one-year free insurance and a lot more!.",
            textAlign: TextAlign.justify,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textMid,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoaderOverlay extends StatelessWidget {
  const _LoaderOverlay();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black26,
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.mintDark),
        ),
      ),
    );
  }
}
