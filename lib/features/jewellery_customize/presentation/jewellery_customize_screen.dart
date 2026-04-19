import 'package:divine_pos/features/auth/data/auth_notifier.dart';
import 'package:divine_pos/features/cart/data/customer_detail_model.dart';
import 'package:divine_pos/features/cart/providers/cart_providers.dart';
import 'package:divine_pos/features/jewellery/data/listing_provider.dart';
import 'package:divine_pos/shared/routes/route_pages.dart';
import 'package:divine_pos/shared/widgets/text.dart';
import 'package:flutter/material.dart';
import '../../../shared/utils/scale_size.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/app_bar.dart';
import '../../../shared/utils/enums.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'image_preview_with_thumbnails.dart';
import 'tab_row.dart';
import 'customize_solitaire.dart';
import '../presentation/widget/continue_cart_popup.dart';
import '../provider/jewellery_detail_provider.dart';
import '../provider/jewellery_calc_provider.dart';
import '../services/jewellery_calculation_service.dart';
import 'package:divine_pos/shared/utils/currency_formatter.dart';
import 'package:collection/collection.dart';

class JewelleryCustomiseScreen extends ConsumerStatefulWidget {
  final String productCode;
  final String customercode;
  final String customername;
  final String branch;
  final int customerid;

  const JewelleryCustomiseScreen({
    super.key,
    required this.productCode,
    required this.customercode,
    required this.customername,
    required this.branch,
    required this.customerid,
  });

  @override
  ConsumerState<JewelleryCustomiseScreen> createState() =>
      _JewelleryCustomiseScreenState();
}

class _JewelleryCustomiseScreenState
    extends ConsumerState<JewelleryCustomiseScreen> {
  int activeTab = 0;

  int? priceStartIndex;
  int? priceEndIndex;

  int? caratStartIndex;
  int? caratEndIndex;

  int? colorStartIndex;
  int? colorEndIndex;

  int? clarityStartIndex;
  int? clarityEndIndex;

  bool _showMsg = false;

  /// Tracks whether the user has actively applied customization.
  /// Drives the three UI conditions (Reset button, price-to range, button label)
  /// independently from calc.isCustomised so they don't appear on initial load.
  bool _hasBeenCustomised = false;

  String pjcode = '';
  String loginBranch = '';
  int? loginCustomerId = null;
  String loginCustomerName = '';
  String loginCustomerCode = '';

  int deliveryday = 0;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      debugPrint(
        'Loading jewellery detail for '
        'productCode=${widget.productCode}, '
        'customercode=${widget.customercode}',
      );
      ref
          .read(jewelleryCalcProvider.notifier)
          .loadDetail(widget.productCode, widget.customercode);
    });

    final auth = ref.read(authProvider);
    final raw = auth.user?.pjcode ?? '';
    pjcode = raw.split(',').first.trim();

    final storeState = ref.read(storeProvider);

    final matchedStore = storeState.stores.firstWhereOrNull(
      (store) => store.code == pjcode,
    );

    loginBranch = storeState.selectedStore?.nickName ?? '';
    loginCustomerId = matchedStore?.customerID ?? null;
    loginCustomerName = matchedStore?.name ?? '';
    loginCustomerCode = matchedStore?.code ?? '';
  }

  // ------------------------------------------------------------------------
  // DELIVERY DAYS
  // ------------------------------------------------------------------------

  String get _deliveryLabel {
    final calc = ref.watch(jewelleryCalcProvider).value;
    final isCustomised = calc?.isCustomised ?? false;

    if (widget.customercode.isEmpty) {
      return 'delivery 15 days';
    }

    if (isCustomised) {
      return 'delivery 15 days';
    }

    if (widget.customercode == loginCustomerCode) {
      return 'Instant delivery - Available';
    }

    return ' delivery 3 days';
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ADD TO CART
  // ─────────────────────────────────────────────────────────────────────────

  void _onAddToCart(
    BuildContext context,
    WidgetRef ref, {
    required CustomerDetail customer,
    required String customercode,
    required String customername,
    required String branch,
    required int? customerid,
    bool isCustomised = false,
  }) async {
    try {
      final notifier = ref.read(jewelleryCalcProvider.notifier);

      final cartItem = await notifier.buildCartPayload(
        orderCustomer: customer,
        customerCode: isCustomised
            ? loginCustomerCode
            : (customercode.isEmpty ? loginCustomerCode : customercode),
        customerName: isCustomised
            ? loginCustomerName
            : (customername.isEmpty ? loginCustomerName : customername),
        branch: isCustomised
            ? loginBranch
            : (branch.isEmpty ? loginBranch : branch),
        customerId: isCustomised
            ? loginCustomerId
            : (customerid ?? loginCustomerId),
      );

      if (cartItem == null) return;

      await ref.read(cartNotifierProvider.notifier).createCart(cartItem);

      if (!context.mounted) return;
      context.pushNamed(RoutePages.cart.routeName);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: MyText(e.toString())));
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final r = ScaleSize.aspectRatio;

    final detailAsync = ref.watch(jewelleryDetailProvider);
    final calcAsync = ref.watch(jewelleryCalcProvider);
    final calc = calcAsync.value;

    final isCalculating = detailAsync.isLoading || calcAsync.isLoading;

    return detailAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, _) => Scaffold(
        body: Center(
          child: Text(
            err.toString(),
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
      data: (detail) {
        if (detail == null || calc == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final newdata = calc.calcDetail;

        final allImages = detail.images;
        final defaultMetalColor = detail.metalColor.split(',').first.trim();
        final defaultMetalPurity = detail.metalPurity.split(',').first.trim();

        debugPrint(
          'Default metal color: $defaultMetalColor, purity: $defaultMetalPurity',
        );

        final activeColor = calc.selectedMetalColor ?? defaultMetalColor;
        final activePurity = calc.selectedMetalPurity ?? defaultMetalPurity;

        final displayedImages = allImages
            .where(
              (img) =>
                  (img.color ?? '').toLowerCase() == activeColor.toLowerCase(),
            )
            .toList();

        final msg =
            calc.solitaireMessage ??
            JewelleryCalculationService.getMultiSolitaireMessage(
              variants: detail.variants,
              bom: detail.bom,
              totalPcs: calc.totalSolitairePcs ?? 0,
            );

        if (msg.isNotEmpty && !_showMsg) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            setState(() => _showMsg = true);
            ScaffoldMessenger.of(context)
              ..clearSnackBars()
              ..showSnackBar(SnackBar(content: Text(msg)));
          });
        }

        final isMultiSize =
            calc.solitaireMessage != null && calc.solitaireMessage!.isNotEmpty;

        final hidePriceBreakup =
            detail.productCategory == 'COIN' ||
            detail.productSubCategory == 'Solitaire Coin' ||
            detail.productSubCategory == 'Locket';

        final cartCount = ref.watch(authProvider).user?.cartCount ?? 0;

        // ── Price display resolved here ─────────────────────────────────────
        // Initial load / reset  → approxPriceFrom only
        // After customise       → approxPriceFrom – approxPriceTo
        final isCustomised = calc.isCustomised;
        final priceFrom = calc.approxPriceFrom;
        final priceTo = calc.approxPriceTo;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: MyAppBar(
            appBarLeading: AppBarLeading.back,
            showLogo: false,
            actions: [
              AppBarActionConfig(
                type: AppBarAction.cart,
                badgeCount: cartCount,
                onTap: () => context.pushNamed(RoutePages.cart.routeName),
              ),
            ],
          ),
          body: SafeArea(
            bottom: false,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(color: Colors.white),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16 * r),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 6,
                              child: ImagePreviewWithThumbnails(
                                images: displayedImages,
                                title: detail.collection,
                                description: detail.productDescription,
                                productCode: widget.productCode,
                                uid: detail.productName,
                                r: r,
                              ),
                            ),

                            SizedBox(width: 16 * r),

                            Expanded(
                              flex: 4,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 40 * r),
                                  SizedBox(
                                    width: 335 * r,
                                    child: Text(
                                      'Customize your Divine jewellery',
                                      style: TextStyle(
                                        fontSize: 20 * r,
                                        fontFamily: 'Rushter Glory',
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 18 * r),
                                  DeliveryBadge(
                                    r: r,
                                    deliveryLabel: _deliveryLabel,
                                  ),
                                  SizedBox(height: 23 * r),

                                  DetailsScreen(
                                    r: r,
                                    shape: calc.solitaireShape,
                                    priceRange: calc.priceRange,
                                    caratRange: calc.caratRange,
                                    colorRange: calc.colorRange,
                                    clarityRange: calc.clarityRange,
                                    soltpcs: calc.SolitairePcs,
                                    ringSize: calc.ringSize,
                                    totalMetalWeight:
                                        calc.netMetalWeight ?? 0.0,
                                    metalColors: activeColor,
                                    metalPurity: activePurity,
                                    totalSidePcs: calc.totalSidePcs ?? 0,
                                    totalSideWeight:
                                        calc.totalSideWeight ?? 0.0,
                                    sideDiamondQuality:
                                        calc.selectedSideDiamondQuality,
                                    metalAmount: calc.metalAmount,
                                    sideDiamondAmount: calc.sideDiamondAmount,
                                    solitaireAmountFrom:
                                        calc.solitaireAmountFrom,
                                    solitaireAmountTo: calc.solitaireAmountTo,
                                    approxPriceFrom: calc.approxPriceFrom,
                                    approxPriceTo: calc.approxPriceTo,
                                    hidePriceBreakup: hidePriceBreakup,
                                    hasBeenCustomised: _hasBeenCustomised,
                                  ),

                                  Padding(
                                    padding: EdgeInsets.only(right: 34 * r),
                                    child: SizedBox(
                                      width: 483 * r,
                                      height: 41 * r,
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(
                                            20 * r,
                                          ),
                                          onTap: () async {
                                            final metalColors = detail
                                                .metalColor
                                                .split(',');
                                            final metalPurities = detail
                                                .metalPurity
                                                .split(',');

                                            debugPrint(
                                              'sizeFrom: ${calc.sizeFrom}, '
                                              'sizeTo: ${calc.sizeTo}, '
                                              'ringSize: ${calc.ringSize}',
                                            );

                                            final result = await showCustomizeDrawer(
                                              context: context,
                                              detail: newdata ?? detail,
                                              totalSidePcs:
                                                  calc.totalSidePcs ?? 0,
                                              totalSideWeight:
                                                  calc.totalSideWeight ?? 0.0,
                                              collection: detail.collection,
                                              isMultiSize: isMultiSize,
                                              initialValues: {
                                                if (priceStartIndex != null &&
                                                    priceEndIndex != null)
                                                  'price': {
                                                    'startIndex':
                                                        priceStartIndex,
                                                    'endIndex': priceEndIndex,
                                                  },
                                                if (caratStartIndex != null &&
                                                    caratEndIndex != null)
                                                  'carat': {
                                                    'startIndex':
                                                        caratStartIndex,
                                                    'endIndex': caratEndIndex,
                                                  },
                                                if (colorStartIndex != null &&
                                                    colorEndIndex != null)
                                                  'color': {
                                                    'startIndex':
                                                        colorStartIndex,
                                                    'endIndex': colorEndIndex,
                                                  },
                                                if (clarityStartIndex != null &&
                                                    clarityEndIndex != null)
                                                  'clarity': {
                                                    'startIndex':
                                                        clarityStartIndex,
                                                    'endIndex': clarityEndIndex,
                                                  },
                                                'shape': calc.solitaireShape,
                                                'ringSizeFrom': calc.sizeFrom,
                                                'ringSizeTo': calc.sizeTo,
                                                if (calc.ringSize != null)
                                                  'ringSize': calc.ringSize,
                                                'metalColor':
                                                    calc.selectedMetalColor ??
                                                    metalColors.first.trim(),
                                                'metalPurity':
                                                    calc.selectedMetalPurity ??
                                                    metalPurities.first.trim(),
                                                'sideDiamondQuality': calc
                                                    .selectedSideDiamondQuality,
                                              },
                                              metalColors: metalColors
                                                  .map((e) => e.trim())
                                                  .toList(),
                                              metalPurity: metalPurities
                                                  .map((e) => e.trim())
                                                  .toList(),
                                            );

                                            if (!mounted || result == null) {
                                              return;
                                            }

                                            setState(() {
                                              _hasBeenCustomised = true;
                                              priceStartIndex =
                                                  result.price?.startIndex;
                                              priceEndIndex =
                                                  result.price?.endIndex;
                                              caratStartIndex =
                                                  result.carat?.startIndex;
                                              caratEndIndex =
                                                  result.carat?.endIndex;
                                              colorStartIndex =
                                                  result.color?.startIndex;
                                              colorEndIndex =
                                                  result.color?.endIndex;
                                              clarityStartIndex =
                                                  result.clarity?.startIndex;
                                              clarityEndIndex =
                                                  result.clarity?.endIndex;
                                            });

                                            ref
                                                .read(
                                                  jewelleryCalcProvider
                                                      .notifier,
                                                )
                                                .applyFilter(result);

                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Customization applied',
                                                ),
                                                backgroundColor: Color(
                                                  0xFF90DCD0,
                                                ),
                                                behavior:
                                                    SnackBarBehavior.floating,
                                              ),
                                            );
                                          },
                                          child: Stack(
                                            children: [
                                              Positioned.fill(
                                                child: Container(
                                                  decoration: ShapeDecoration(
                                                    shape: RoundedRectangleBorder(
                                                      side: const BorderSide(
                                                        width: 1,
                                                        color: Color(
                                                          0xFF6C5022,
                                                        ),
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            20,
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                              ),

                                              Positioned(
                                                left: 4 * r,
                                                top: 4 * r,
                                                bottom: 4 * r,
                                                right: 84 * r,
                                                child: Container(
                                                  alignment: Alignment.center,
                                                  decoration: ShapeDecoration(
                                                    color: const Color(
                                                      0xFFCBC4AE,
                                                    ),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            15 * r,
                                                          ),
                                                    ),
                                                  ),
                                                  child: MyText(
                                                    _hasBeenCustomised
                                                        ? 'Edit Customization'
                                                        : 'Start customizing',
                                                    style: TextStyle(
                                                      color: const Color(
                                                        0xFF6C5022,
                                                      ),
                                                      fontSize: 14 * r,
                                                      fontFamily: 'Montserrat',
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ),

                                              Positioned(
                                                top: 4 * r,
                                                bottom: 4 * r,
                                                right: 4 * r,
                                                width: 72 * r,
                                                child: Container(
                                                  alignment: Alignment.center,
                                                  decoration: ShapeDecoration(
                                                    color: const Color(
                                                      0xFF6C5022,
                                                    ),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            15 * r,
                                                          ),
                                                    ),
                                                  ),
                                                  child: Image.asset(
                                                    'assets/jewellery_pdp/cus-ticon.png',
                                                    width: 18 * r,
                                                    height: 18 * r,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          bottomNavigationBar: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25 * r),
                    topRight: Radius.circular(25 * r),
                  ),
                  child: Container(
                    height: 82 * r,
                    padding: EdgeInsets.symmetric(horizontal: 40 * r),
                    decoration: const BoxDecoration(
                      color: Color(0xFFBEE4DD),
                      border: Border(
                        top: BorderSide(color: Color(0xFF90DCD0), width: 1),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        /// Approx price display
                        /// Initial / reset  → approxPriceFrom only
                        /// After customise  → approxPriceFrom – approxPriceTo
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MyText(
                              'Approx.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20 * r,
                                color: const Color(0xFF757575),
                                fontFamily: 'Montserrat',
                                height: 1.35 * r,
                                letterSpacing: 0.40 * r,
                              ),
                            ),
                            SizedBox(width: 30 * r),
                            Row(
                              children: [
                                // approxPriceFrom — always shown
                                MyText(
                                  isCalculating
                                      ? '--'
                                      : priceFrom?.inRupeesFormat() ?? '--',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 30 * r,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w500,
                                    height: 0.90 * r,
                                    letterSpacing: 0.60 * r,
                                  ),
                                ),

                                // separator + approxPriceTo — only after customise
                                if (!isCalculating && _hasBeenCustomised) ...[
                                  const SizedBox(width: 6),
                                  MyText(
                                    '-',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 30 * r,
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.w500,
                                      height: 0.90 * r,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  MyText(
                                    priceTo?.inRupeesFormat() ?? '',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 30 * r,
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.w500,
                                      height: 0.90 * r,
                                      letterSpacing: 0.60 * r,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),

                        if (_hasBeenCustomised) ...[
                          SizedBox(width: 50 * r),

                          /// Reset price button
                          InkWell(
                            onTap: () async {
                              setState(() => _hasBeenCustomised = false);
                              await ref
                                  .read(jewelleryCalcProvider.notifier)
                                  .resetPriceToInitial();
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              width: 258 * r,
                              height: 52 * r,
                              padding: EdgeInsets.symmetric(
                                horizontal: 30 * r,
                                vertical: 6 * r,
                              ),
                              decoration: ShapeDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment(0.0, 0.5),
                                  end: Alignment(0.96, 1.12),
                                  colors: [
                                    Color(0xFFBEE4DD),
                                    Color(0xA5D1B193),
                                  ],
                                ),
                                shape: RoundedRectangleBorder(
                                  side: const BorderSide(
                                    width: 1,
                                    color: Color(0xFFACA584),
                                  ),
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(20),
                                  ),
                                ),
                                shadows: const [
                                  BoxShadow(
                                    color: Color(0x7C000000),
                                    blurRadius: 4,
                                    offset: Offset(2, 2),
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: MyText(
                                  'Reset Price',
                                  style: TextStyle(
                                    color: const Color(0xFF6C5022),
                                    fontSize: 20 * r,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],

                        /// Continue / add to cart button
                        InkWell(
                          onTap: () async {
                            final customer = await showDialog<CustomerDetail>(
                              context: context,
                              barrierDismissible: true,
                              builder: (_) =>
                                  ContinueCartPopup(parentContext: context),
                            );

                            if (customer == null) return;

                            _onAddToCart(
                              context,
                              ref,
                              customer: customer,
                              customerid: widget.customerid,
                              customercode: widget.customercode,
                              customername: widget.customername,
                              branch: widget.branch,
                              isCustomised: calc.isCustomised,
                            );

                            debugPrint(
                              'Selected customer: ${customer.name} '
                              '(${customer.id}, ${customer.contactNo})',
                            );
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: 258 * r,
                            height: 52 * r,
                            padding: EdgeInsets.symmetric(
                              horizontal: 30 * r,
                              vertical: 6 * r,
                            ),
                            decoration: ShapeDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment(0.0, 0.5),
                                end: Alignment(0.96, 1.12),
                                colors: [Color(0xFFBEE4DD), Color(0xA5D1B193)],
                              ),
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(
                                  width: 1,
                                  color: Color(0xFFACA584),
                                ),
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(20),
                                ),
                              ),
                              shadows: const [
                                BoxShadow(
                                  color: Color(0x7C000000),
                                  blurRadius: 4,
                                  offset: Offset(2, 2),
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: Center(
                              child: MyText(
                                'Continue',
                                style: TextStyle(
                                  color: const Color(0xFF6C5022),
                                  fontSize: 20 * r,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Container(
                  height: 4,
                  width: double.infinity,
                  color: Colors.white,
                ),
                const SizedBox(
                  height: 4,
                  child: ColoredBox(color: Colors.white),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DELIVERY BADGE
// ─────────────────────────────────────────────────────────────────────────────

class DeliveryBadge extends StatelessWidget {
  final double r;
  final String deliveryLabel;

  const DeliveryBadge({
    super.key,
    required this.r,
    required this.deliveryLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400 * r,
      height: 36 * r,
      decoration: BoxDecoration(
        color: const Color(0xFFBEE4DD),
        borderRadius: BorderRadius.circular(10 * r),
        border: Border.all(color: const Color(0xFFEDEDED)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Center(
              child: MyText(
                'Made to order',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: const Color(0xFF6C5022),
                  fontSize: 12 * r,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          Container(
            width: 1,
            margin: EdgeInsets.symmetric(vertical: 6 * r),
            color: Colors.white,
          ),
          Expanded(
            child: Center(
              child: MyText(
                deliveryLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFF6C5022),
                  fontSize: 12 * r,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
