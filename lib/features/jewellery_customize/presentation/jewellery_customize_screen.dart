import 'package:divine_pos/features/cart/data/customer_detail_model.dart';
import 'package:divine_pos/features/cart/providers/cart_providers.dart';
import 'package:divine_pos/shared/routes/route_pages.dart';
import 'package:divine_pos/shared/widgets/text.dart';
import 'package:flutter/material.dart';
import '../../../shared/utils/scale_size.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/app_bar.dart';
import '../../../shared/utils/enums.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'image_preview_with_thumbnails.dart'; //gallery
import 'tab_row.dart'; //tab panel
import 'customize_solitaire.dart';
import '../presentation/widget/continue_cart_popup.dart';
import '../provider/jewellery_detail_provider.dart';
import '../provider/jewellery_calc_provider.dart';
import '../services/jewellery_calculation_service.dart'; // for message
import 'package:divine_pos/shared/utils/currency_formatter.dart';

class JewelleryCustomiseScreen extends ConsumerStatefulWidget {
  final String productCode;

  const JewelleryCustomiseScreen({super.key, required this.productCode});

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

  @override
  void initState() {
    super.initState();
    // load detail + initial calc
    Future.microtask(() {
      ref.read(jewelleryCalcProvider.notifier).loadDetail(widget.productCode);
    });
  }

  // void _onAddToCart(
  //   BuildContext context,
  //   WidgetRef ref, {
  //   required CustomerDetail customer,
  // }) async {
  //   try {
  //     final notifier = ref.read(jewelleryCalcProvider.notifier);

  //     final cartItem = await notifier.buildCartPayload(customer: customer);

  //     if (cartItem == null) return;

  //     await ref.read(cartNotifierProvider.notifier).createCart(cartItem);
  //     print('context.mounted: ${context.mounted}');
  //     if (context.mounted) {
  //       print('navigating to cart');
  //       context.pushNamed(RoutePages.cart.routeName);
  //     }
  //   } catch (e) {
  //     final message = e is Exception
  //         ? e.toString().replaceFirst('Exception: ', '')
  //         : 'Something went wrong';

  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(SnackBar(content: Text(message)));
  //   }
  // }

  void _onAddToCart(
    BuildContext context,
    WidgetRef ref, {
    required CustomerDetail customer,
  }) async {
    try {
      final notifier = ref.read(jewelleryCalcProvider.notifier);

      print('Step 1: building cart payload');
      final cartItem = await notifier.buildCartPayload(customer: customer);
      print('Step 2: cartItem = ${cartItem?.toJson()}');

      if (cartItem == null) {
        print('Step 3: cartItem is NULL — returning early');
        return;
      }

      print('Step 4: calling createCart');
      await ref.read(cartNotifierProvider.notifier).createCart(cartItem);
      print('Step 5: createCart done, mounted = ${context.mounted}');

      if (!context.mounted) {
        print('Step 6: context NOT mounted — cannot navigate');
        return;
      }

      print('Step 7: attempting navigation');
      context.pushNamed(RoutePages.cart.routeName);
      print('Step 8: pushNamed called successfully');
    } catch (e, st) {
      print('ERROR: $e');
      print('STACKTRACE: $st');
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = ScaleSize.aspectRatio;

    // detail async (for images, meta)
    final detailAsync = ref.watch(jewelleryDetailProvider);
    // calc async (for all pricing + selection state)
    final calcAsync = ref.watch(jewelleryCalcProvider);
    final calc = calcAsync.value;

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

        // IMAGE LOGIC
        final allImages = detail.images ?? [];
        final defaultMetalColor = detail.metalColor.split(',').first.trim();
        final defaultMetalPurity = detail.metalPurity.split(',').first.trim();

        //productPrice = detail.productPrice!;

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

        // MULTI‑SOLITAIRE MESSAGE

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
            setState(() {
              _showMsg = true;
            });

            ScaffoldMessenger.of(context)
              ..clearSnackBars()
              ..showSnackBar(SnackBar(content: Text(msg)));
          });
        }

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: MyAppBar(
            appBarLeading: AppBarLeading.back,
            showLogo: false,
            actions: [
              AppBarActionConfig(
                type: AppBarAction.cart,
                badgeCount: 0,
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
                  /// SCROLLABLE MIDDLE
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16 * r),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// LEFT — 65%
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

                            /// RIGHT — 35%
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
                                  DeliveryBadge(r: r),
                                  SizedBox(height: 23 * r),

                                  /// DETAILS (READ FROM calc)
                                  DetailsScreen(
                                    r: r,
                                    shape: calc.solitaireShape,
                                    priceRange: calc.priceRange,
                                    caratRange: calc.caratRange,
                                    colorRange: calc.colorRange,
                                    clarityRange: calc.clarityRange,
                                    soltpcs: calc.totalSolitairePcs ?? 0,
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
                                                .split(
                                                  ',',
                                                ); // split हमेशा List देगा
                                            final metalPurities = detail
                                                .metalPurity
                                                .split(',');

                                            final result = await showCustomizeDrawer(
                                              context: context,
                                              detail: detail,
                                              totalSidePcs:
                                                  calc.totalSidePcs ?? 0,
                                              totalSideWeight:
                                                  calc.totalSideWeight ?? 0.0,

                                              // 🔹 JS की तरह: collection + multi-size flag
                                              collection: detail
                                                  .collection, // e.g. 'SOLITAIRE' / 'SOLUS'
                                              isMultiSize:
                                                  _showMsg, // bool field तुम model में रख रहे हो
                                              //shape: calc.solitaireShape, // e.g. 'Round'
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

                                                // 🔹 extra: shape + ringSize + metal selections
                                                'shape': calc
                                                    .solitaireShape, // e.g. 'Round'
                                                'ringSizeFrom':
                                                    detail.productSizeFrom,
                                                'ringSizeTo':
                                                    detail.productSizeTo,
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

                                            if (!mounted || result == null)
                                              return;

                                            // indices local state में रखो
                                            setState(() {
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

                                            // provider को filter दो (ये पहले से है)
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
                                          child:
                                              detail.productPrice == null ||
                                                  detail.productPrice == 0
                                              ? Stack(
                                                  children: [
                                                    /// Outer border
                                                    Positioned.fill(
                                                      child: Container(
                                                        decoration: ShapeDecoration(
                                                          shape: RoundedRectangleBorder(
                                                            side:
                                                                const BorderSide(
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

                                                    /// Main button
                                                    Positioned(
                                                      left: 4 * r,
                                                      top: 4 * r,
                                                      bottom: 4 * r,
                                                      right: 84 * r,
                                                      child: Container(
                                                        alignment:
                                                            Alignment.center,
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
                                                          'Start customizing',
                                                          style: TextStyle(
                                                            color: const Color(
                                                              0xFF6C5022,
                                                            ),
                                                            fontSize: 14 * r,
                                                            fontFamily:
                                                                'Montserrat',
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                      ),
                                                    ),

                                                    /// Arrow image button
                                                    Positioned(
                                                      top: 4 * r,
                                                      bottom: 4 * r,
                                                      right: 4 * r,
                                                      width: 72 * r,
                                                      child: Container(
                                                        alignment:
                                                            Alignment.center,
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
                                                )
                                              : SizedBox.shrink(),
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
                /// MAIN BOTTOM BAR
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25 * r),
                    topRight: Radius.circular(25 * r),
                  ),
                  child: Container(
                    height: 82 * r,
                    padding: EdgeInsets.symmetric(horizontal: 40 * r),
                    decoration: BoxDecoration(
                      color: const Color(0xFFBEE4DD),
                      border: const Border(
                        top: BorderSide(color: Color(0xFF90DCD0), width: 1),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        /// PRICE TEXT
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
                                MyText(
                                  detail.productPrice == null ||
                                          detail.productPrice == 0
                                      ? calc.approxPriceFrom != null
                                            ? calc.approxPriceFrom!
                                                  .inRupeesFormat()
                                            : '--'
                                      : detail.productPrice!.inRupeesFormat(),
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
                                const SizedBox(width: 6),
                                MyText(
                                  '-',
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
                                SizedBox(width: 6),
                                Text(
                                  detail.productPrice == null ||
                                          detail.productPrice == 0
                                      ? calc.approxPriceTo != null
                                            ? calc.approxPriceTo!
                                                  .inRupeesFormat()
                                            : '--'
                                      : detail.productPrice!.inRupeesFormat(),
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
                            ),
                          ],
                        ),

                        /// CONTINUE BUTTON
                        InkWell(
                          onTap: () async {
                            final customer = await showDialog<CustomerDetail>(
                              context: context,
                              barrierDismissible: true,
                              builder: (_) => const ContinueCartPopup(),
                            );

                            if (customer == null) return;

                            _onAddToCart(context, ref, customer: customer);

                            //call here cart create and set data
                            //final customerId = customer.id;

                            // debugPrint(
                            //   'Selected customer: ${customer.name} (${customer.id})',
                            // );
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
                                borderRadius: BorderRadius.all(
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

                /// WHITE GAP BELOW BOTTOM BAR
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

class DeliveryBadge extends StatelessWidget {
  final double r;
  const DeliveryBadge({super.key, required this.r});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 271 * r,
      height: 36 * r,
      decoration: BoxDecoration(
        color: const Color(0xFFBEE4DD),
        borderRadius: BorderRadius.circular(10 * r),
        border: Border.all(color: const Color(0xFFEDEDED)),
      ),
      child: Row(
        children: [
          // Left text
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
          // White separator
          Container(
            width: 1,
            margin: EdgeInsets.symmetric(vertical: 6 * r),
            color: Colors.white,
          ),
          // Right text
          Expanded(
            child: Center(
              child: MyText(
                'Est delivery 15 days',
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
