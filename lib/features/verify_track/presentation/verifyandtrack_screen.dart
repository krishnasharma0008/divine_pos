import 'package:divine_pos/features/auth/data/auth_notifier.dart';
import 'package:divine_pos/shared/app_bar.dart';
import 'package:divine_pos/shared/routes/app_drawer.dart';
import 'package:divine_pos/shared/routes/route_pages.dart';
import 'package:divine_pos/shared/utils/enums.dart';
import 'package:divine_pos/shared/utils/scale_size.dart';
import 'package:divine_pos/shared/widgets/text.dart';
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
    final fem = ScaleSize.aspectRatio;
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
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _MintAccentBar(),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: fem * 20,
                      vertical: fem * 15,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _SectionLabel(
                          title: 'VERIFY & TRACK',
                          subtitle:
                              'Enter your UID or scan the QR code on your product',
                        ),
                        SizedBox(height: fem * 15),
                        _ContentCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _UidTextField(
                                controller: uidController,
                                enabled: !isLoading,
                                onSubmitted: (_) =>
                                    _doSearch(uidController.text),
                              ),
                              SizedBox(height: fem * 16),
                              _SubmitButton(
                                //isLoading: isLoading,
                                onPressed: () => _doSearch(uidController.text),
                              ),
                              SizedBox(height: fem * 20),
                              _OrDivider(),
                              SizedBox(height: fem * 16),
                              // _QrScannerFrame(),
                              // SizedBox(height: fem * 16),
                              _ScanQrButton(
                                isLoading: isLoading,
                                onPressed: isLoading
                                    ? null
                                    : () {
                                        // On result: _doSearch(scannedUid)
                                        debugPrint('Open QR scanner');
                                      },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: fem * 20),
                        _AboutCard(),
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
    final fem = ScaleSize.aspectRatio;
    return Column(
      children: [
        MyText(
          title,
          style: TextStyle(
            fontSize: fem * 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 3,
            color: AppColors.textDark,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: fem * 6),
        MyText(
          subtitle,
          style: TextStyle(
            fontSize: fem * 12,
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
    final fem = ScaleSize.aspectRatio;
    return Container(
      padding: EdgeInsets.all(fem * 20),
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
    final fem = ScaleSize.aspectRatio;
    return TextField(
      controller: controller,
      enabled: enabled,
      textCapitalization: TextCapitalization.characters,
      textInputAction: TextInputAction.search,
      onSubmitted: onSubmitted,
      style: TextStyle(fontSize: 14 * fem, color: AppColors.textDark),
      decoration: InputDecoration(
        hintText: 'Enter Unique Identification Numb...',
        hintStyle: TextStyle(color: AppColors.textLight, fontSize: 14 * fem),
        filled: true,
        fillColor: AppColors.bgGrey,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16 * fem,
          vertical: 16 * fem,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8 * fem),
          borderSide: const BorderSide(color: AppColors.divider, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8 * fem),
          borderSide: const BorderSide(color: AppColors.mintDark, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8 * fem),
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
    final fem = ScaleSize.aspectRatio;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: fem * 400),
        child: SizedBox(
          height: fem * 45,
          child: ElevatedButton(
            onPressed: onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textDark,
              backgroundColor: AppColors.mintLight,
              disabledBackgroundColor: AppColors.mintLight.withValues(
                alpha: 0.5,
              ),
              side: const BorderSide(color: AppColors.mintDark, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: isLoading
                ? SizedBox(
                    width: fem * 18,
                    height: fem * 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.mintDark,
                      ),
                    ),
                  )
                : MyText(
                    'SUBMIT',
                    style: TextStyle(
                      fontSize: 14,
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
    final fem = ScaleSize.aspectRatio;
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.divider, thickness: 1)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 14 * fem),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 12 * fem,
              vertical: 4 * fem,
            ),
            decoration: BoxDecoration(
              color: AppColors.mintLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: MyText(
              'OR',
              style: TextStyle(
                fontSize: 11 * fem,
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

class _ScanQrButton extends StatelessWidget {
  const _ScanQrButton({required this.onPressed, this.isLoading = false});
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final fem = ScaleSize.aspectRatio;
    return Center(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: isLoading ? null : onPressed,
        child: IntrinsicWidth(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/vtdia/barcode_big.jpeg'),

              SizedBox(height: fem * 16),

              // Custom button container
              Container(
                height: fem * 40,
                padding: EdgeInsets.symmetric(horizontal: fem * 16),
                decoration: BoxDecoration(
                  color: AppColors.mintLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.mintDark, width: 1.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.qr_code_scanner, size: 18),

                    SizedBox(width: fem * 8),

                    MyText(
                      'Scan QR Code',
                      style: TextStyle(
                        fontSize: fem * 14,
                        fontWeight: FontWeight.w600,
                        //letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
    final fem = ScaleSize.aspectRatio;
    return Container(
      padding: EdgeInsets.all(fem * 16),
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
              SizedBox(width: fem * 10),
              MyText(
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
          SizedBox(height: fem * 12),
          MyText(
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
