import 'package:divine_pos/features/auth/data/auth_notifier.dart';
import 'package:divine_pos/features/cart/data/cart_detail_model.dart';
import 'package:divine_pos/features/cart/data/customer_detail_model.dart';
import 'package:divine_pos/features/jewellery/data/branch_provider.dart';
import 'package:divine_pos/features/jewellery/data/listing_provider.dart';
import 'package:divine_pos/features/solitaire_customize/data/solitaire_detail_model.dart'
    show SolitaireDetail;
import 'package:divine_pos/shared/routes/route_pages.dart';
import 'package:divine_pos/shared/utils/currency_formatter.dart';
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
import 'widget/continue_cart_popup.dart';
import '../provider/solitaire_detail_provider.dart';
import '../provider/solitaire_calc_provider.dart';
import '../data/solitaire_constants.dart';
import 'package:collection/collection.dart';
import '../data/add_to_cart_notifier.dart';

class SolitaireCustomiseScreen extends ConsumerStatefulWidget {
  final SolitaireDetail? data;
  // final String customercode;
  // final String customername;
  // final String branch;
  // final int customerid;

  const SolitaireCustomiseScreen({
    super.key,
    required this.data,
    // required this.customercode,
    // required this.customername,
    // required this.branch,
    // required this.customerid,
  });

  @override
  ConsumerState<SolitaireCustomiseScreen> createState() =>
      _SolitaireCustomiseScreenState();
}

class _SolitaireCustomiseScreenState
    extends ConsumerState<SolitaireCustomiseScreen> {
  // Saved drawer indices so it re-opens with the last-used values
  String? selectedShape;
  int? priceStartIndex;
  int? priceEndIndex;
  int? caratStartIndex;
  int? caratEndIndex;
  int? colorStartIndex;
  int? colorEndIndex;
  int? clarityStartIndex;
  int? clarityEndIndex;
  //final bool _isCustomized = false; // ← whether user has applied any customization

  String pjcode = '';
  String loginBranch = '';
  int? loginCustomerId = null;
  String loginCustomerName = '';
  String loginCustomerCode = '';

  int deliveryday = 0;

  @override
  void initState() {
    super.initState();

    selectedShape = widget.data?.shape ?? 'RND';
    _initIndicesFromData();

    // Seed provider + trigger initial price calculation after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _calculateDefault();
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

  // ---------------------------------------------------------------------------
  // Derive initial drawer indices from widget.data
  // ---------------------------------------------------------------------------
  void _initIndicesFromData() {
    if (widget.data == null) return; // ← guard
    // Carat: closest caratSteps entry to widget.data.weight
    double minDiff = double.infinity;
    int closestIdx = 0;
    for (var i = 0; i < caratSteps.length; i++) {
      final stepVal = double.tryParse(caratSteps[i]) ?? 0;
      final diff = (stepVal - widget.data!.weight).abs();
      if (diff < minDiff) {
        minDiff = diff;
        closestIdx = i;
      }
    }
    caratStartIndex = closestIdx;
    caratEndIndex = closestIdx;

    // Build the same filtered color/clarity lists the drawer will use
    final isRound =
        widget.data!.shape.toUpperCase() == 'ROUND' ||
        widget.data!.shape.toUpperCase() == 'RND';
    final collection = widget.data!.productCategory;
    final slab = widget.data!.solitaireSlab;

    final colorOpts = getColorOptions(
      slab: slab,
      isRound: isRound,
      collection: collection,
    );
    final clarityOpts = getClarityOptions(
      slab: slab,
      isRound: isRound,
      collection: collection,
    );

    final cIdx = colorOpts.indexWhere(
      (c) => c.toUpperCase() == widget.data!.color.toUpperCase(),
    );
    colorStartIndex = cIdx >= 0 ? cIdx : 0;
    colorEndIndex = colorStartIndex;

    final clIdx = clarityOpts.indexWhere(
      (c) => c.toUpperCase() == widget.data!.clarity.toUpperCase(),
    );
    clarityStartIndex = clIdx >= 0 ? clIdx : 0;
    clarityEndIndex = clarityStartIndex;
  }

  // ---------------------------------------------------------------------------
  // Seed detail into provider, then calculate using widget.data values
  // This is called on initial load AND when the "Default Value" button is tapped
  // ---------------------------------------------------------------------------
  void _calculateDefault() {
    if (widget.data == null) return;
    ref.read(solitaireDetailProvider.notifier).setDetail(widget.data!);
    ref.read(solitaireCalcProvider.notifier).calculateFromDetail(widget.data!);
  }

  // ---------------------------------------------------------------------------
  // Reset drawer indices to initial values and recalculate
  // ---------------------------------------------------------------------------
  void _onDefaultValueTapped() {
    if (widget.data == null) return;
    //setState(() => _isCustomized = false);
    _initIndicesFromData();
    setState(() {
      priceStartIndex = null;
      priceEndIndex = null;
    });
    _calculateDefault();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reset to default values'),
        backgroundColor: Color(0xFF6C5022),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ------------------------------------------------------------------------
  // DELIVERY DAYS
  // ------------------------------------------------------------------------

  String get _deliveryLabel {
    final calc = ref.watch(solitaireCalcProvider).value;
    final isCustomised = calc?.isCustomised ?? false;

    if (widget.data?.laying_with?.isEmpty ?? true) {
      return 'delivery 15 days';
    }

    if (isCustomised) {
      return 'delivery 15 days';
    }

    if (widget.data?.laying_with == loginCustomerCode) {
      return 'Instant delivery - Available';
    }

    return ' delivery 3 days';
  }

  // ---------------------------------------------------------------------------
  // Add to cart
  // ---------------------------------------------------------------------------
  // Helper inside _SolitaireCustomiseScreenState
  (String, String) _extractRangeFrom(String? range) {
    if (range == null || range.isEmpty) return ('', '');
    final cleaned = range.replaceAll('ct', '');
    final parts = cleaned.split('-').map((e) => e.trim()).toList();
    if (parts.length == 2) return (parts[0], parts[1]);
    return (parts.first, parts.first);
  }

  // ---------------------------------------------------------------------------
  // Add to cart
  // ---------------------------------------------------------------------------
  Future<void> _onAddToCart(
    BuildContext context,
    WidgetRef ref, {
    required CustomerDetail customer,
  }) async {
    try {
      final calcState = ref.read(solitaireCalcProvider);
      final calc = calcState.value;

      if (calc == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Unable to calculate price")),
        );
        return;
      }

      // final auth = ref.read(authProvider);
      // final rawPj = auth.user?.pjcode ?? '';
      // final pjcode = rawPj.split(',').first.trim();

      // final storeState = ref.read(storeProvider);
      // final selectedStore = storeState.selectedStore;

      // final matchedStore = storeState.stores.firstWhereOrNull(
      //   (store) => store.code == pjcode,
      // );

      // final selectedBranch = selectedStore?.nickName ?? '';
      // final customerid = matchedStore?.customerID;
      // final customername = matchedStore?.name;
      // final customercode = matchedStore?.code;

      // debugPrint('Selected branch: $selectedBranch');
      // debugPrint('customerid : $customerid');
      // debugPrint('customercode : $customercode');
      // debugPrint('customername : $customername');

      final (caratFrom, caratTo) = _extractRangeFrom(calc.caratRange);
      final (colorFrom, colorTo) = _extractRangeFrom(calc.colorRange);
      final (clarityFrom, clarityTo) = _extractRangeFrom(calc.clarityRange);

      final isCustomized = calc.isCustomized;

      final cartItem = CartDetail(
        orderFor: 'Customer',
        customerId: isCustomized
            ? loginCustomerId
            : widget.data?.lying_with_id ?? 0,
        customerCode: isCustomized
            ? loginCustomerCode
            : widget.data?.laying_with ?? '',
        customerName: isCustomized
            ? loginCustomerName
            : widget.data?.lying_with_name ?? '',
        customerBranch: isCustomized
            ? loginBranch
            : widget.data?.lying_with_nickname ?? '',
        productType: 'solitaire',
        orderType: 'RCO',
        collection: "",
        productCategory: "",
        productSubCategory: "",
        expDlvDate: DateTime.now()
            .add(const Duration(days: 15))
            .toUtc()
            .toIso8601String(),
        oldVarient: isCustomized ? '' : widget.data?.oldVariant ?? '',
        productCode: isCustomized ? '' : widget.data?.itemNumber ?? '',
        designno: isCustomized ? '' : widget.data?.designNo ?? '',
        solitairePcs: 1,
        productQty: 1,
        productAmtMin: isCustomized ? 0 : calc.solitaireAmountFrom,
        productAmtMax: calc.solitaireAmountTo,
        solitaireShape: SolitaireCalcNotifier.mapShapeCodeToName(
          calc?.solitaireShape ?? '',
        ),
        solitaireSlab: '$caratFrom-$caratTo',
        solitaireColor: '$colorTo-$colorFrom',
        solitaireQuality: '$clarityTo-$clarityFrom',
        solitairePremSize: '',
        solitairePremPct: 0,
        solitaireAmtMin: isCustomized ? 0 : calc.solitaireAmountFrom,
        solitaireAmtMax: calc.solitaireAmountTo,
        mountAmtMin: 0,
        mountAmtMax: 0,
        sizeFrom: '',
        sizeTo: '',
        sideStonePcs: 0,
        sideStoneCts: 0,
        sideStoneColor: '',
        sideStoneQuality: '',
        cartRemarks: '',
        orderRemarks: '',
        style: '',
        wearStyle: '',
        look: '',
        portfolioType: '',
        gender: '',
        end_customer_id: customer.id ?? 0,
        end_customer_name: customer.name ?? '',
      );

      /// 🔹 CALL PROVIDER
      await ref.read(addToCartProvider.notifier).addToCart(detail: cartItem);

      final addState = ref.read(addToCartProvider);

      if (!context.mounted) return;

      if (addState.isSuccess) {
        context.pushNamed(RoutePages.cart.routeName);
      } else if (addState.isError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(addState.errorMessage ?? 'Failed to add to cart'),
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = ScaleSize.aspectRatio;

    // Watch so the UI rebuilds whenever calc state changes
    final calcAsync = ref.watch(solitaireCalcProvider);
    final calc = calcAsync.value;

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
          color: Colors.white,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16 * r),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // LEFT — 60% — Image gallery
                        Expanded(
                          flex: 6,
                          child: ImagePreviewWithThumbnails(
                            title: 'Eternal Radiance Solitaire',
                            description:
                                'Gracefully crafted in 18KT gold, this solitaire '
                                'Oval Bangle features a precision-cut Heart & Arrows '
                                'diamond — a symbol of brilliance, balance, and '
                                'timeless elegance.',
                            shape: widget.data?.shape ?? 'RND',
                            uid: widget.data?.itemNumber.toString() ?? '',
                            r: r,
                          ),
                        ),

                        SizedBox(width: 16 * r),

                        // RIGHT — 40% — Details + customise button
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

                              // Details tab – shows live calc values;
                              // falls back to raw price while API is in flight
                              DetailsScreen(
                                r: r,
                                shape: SolitaireCalcNotifier.mapShapeCodeToName(
                                  calc?.solitaireShape ?? '',
                                ), // ?? widget.data.shape,
                                priceRange: calc
                                    ?.priceRange, // ??  widget.data.price.toString(),
                                caratRange: calc
                                    ?.caratRange, // ?? widget.data.weight.toString(),
                                colorRange: calc
                                    ?.colorRange, // ?? (widget.data.color.isNotEmpty ? widget.data.color : null),
                                clarityRange: calc
                                    ?.clarityRange, // ?? (widget.data.clarity.isNotEmpty ? widget.data.clarity : null),
                                soltpcs: widget.data?.pcs.toString() ?? '1',
                                solitaireAmountFrom: calc
                                    ?.solitaireAmountFrom, // ?? widget.data.price * widget.data.pcs * widget.data.weight,
                                solitaireAmountTo: calc
                                    ?.solitaireAmountTo, // ?? widget.data.price * widget.data.pcs * widget.data.weight,
                                approxPriceFrom: calc
                                    ?.approxPriceFrom, // ?? widget.data.price * widget.data.pcs * widget.data.weight,
                                approxPriceTo: calc
                                    ?.approxPriceTo, // ?? widget.data.price * widget.data.pcs * widget.data.weight,
                                hidePriceBreakup: false,
                              ),

                              SizedBox(height: 12 * r),

                              // ── Start Customizing button ─────────────────
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
                                        final result =
                                            await showCustomizeDrawer(
                                              context: context,
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
                                                'shape':
                                                    selectedShape ??
                                                    widget.data?.shape ??
                                                    'RND',
                                              },
                                              shape:
                                                  selectedShape ??
                                                  widget.data?.shape ??
                                                  'RND',
                                            );

                                        if (!mounted || result == null) return;

                                        // Save indices so drawer re-opens
                                        // with the last-chosen values
                                        setState(() {
                                          selectedShape =
                                              result.shape?.isNotEmpty == true
                                              ? result.shape
                                              : selectedShape;
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

                                        // Recalculate with the chosen filter
                                        // ref
                                        //     .read(
                                        //       solitaireCalcProvider.notifier,
                                        //     )
                                        //     .applyFilter(result);

                                        // ScaffoldMessenger.of(
                                        //   context,
                                        // ).showSnackBar(
                                        //   const SnackBar(
                                        //     content: Text(
                                        //       'Customization applied',
                                        //     ),
                                        //     backgroundColor: Color(0xFF90DCD0),
                                        //     behavior: SnackBarBehavior.floating,
                                        //   ),
                                        // );

                                        final changed = await ref
                                            .read(
                                              solitaireCalcProvider.notifier,
                                            )
                                            .applyFilter(result);
                                        // if (changed) {
                                        //   setState(
                                        //     () => _isCustomized = true,
                                        //   ); // ← mark as customized
                                        // }
                                        if (changed && context.mounted) {
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
                                        }
                                      },
                                      child: Stack(
                                        children: [
                                          Positioned.fill(
                                            child: Container(
                                              decoration: ShapeDecoration(
                                                shape: RoundedRectangleBorder(
                                                  side: const BorderSide(
                                                    width: 1,
                                                    color: Color(0xFF6C5022),
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(20),
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
                                                color: const Color(0xFFCBC4AE),
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
                                                  fontFamily: 'Montserrat',
                                                  fontWeight: FontWeight.w500,
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
                                                color: const Color(0xFF6C5022),
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

      // ── Bottom bar ──────────────────────────────────────────────────────────
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
                padding: EdgeInsets.symmetric(horizontal: 24 * r),
                decoration: const BoxDecoration(
                  color: Color(0xFFBEE4DD),
                  border: Border(
                    top: BorderSide(color: Color(0xFF90DCD0), width: 1),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // ── Approx. price ──────────────────────────────────────
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          MyText(
                            'Approx.',
                            style: TextStyle(
                              fontSize: 13 * r,
                              color: const Color(0xFF757575),
                              fontFamily: 'Montserrat',
                              letterSpacing: 0.30 * r,
                            ),
                          ),
                          SizedBox(width: 10 * r),
                          if (calcAsync.isLoading)
                            SizedBox(
                              width: 20 * r,
                              height: 20 * r,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF6C5022),
                              ),
                            )
                          else
                            Row(
                              children: [
                                MyText(
                                  calc?.isCustomized == false
                                      ? ''
                                      : calc!.approxPriceFrom!.inRupeesFormat(),
                                  // ? calc!.approxPriceFrom!.inRupeesFormat()
                                  // : '—',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20 * r,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.40 * r,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 5 * r,
                                  ),
                                  child: MyText(
                                    calc?.isCustomized == false ? '' : '–',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 20 * r,
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                                MyText(
                                  calc?.approxPriceTo != null
                                      ? calc!.approxPriceTo!.inRupeesFormat()
                                      : '—',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20 * r,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.40 * r,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),

                    // ── Default Value + Continue ───────────────────────────
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Default Value button
                        if (widget.data != null)
                          if (calc?.isCustomised ?? false) ...[
                            _DefaultValueButton(
                              r: r,
                              isLoading: calcAsync.isLoading,
                              onTap: _onDefaultValueTapped,
                            ),

                            SizedBox(width: 148 * r),
                          ],

                        // Continue button
                        InkWell(
                          onTap: () async {
                            final customer = await showDialog<CustomerDetail>(
                              context: context,
                              barrierDismissible: true,
                              builder: (_) =>
                                  ContinueCartPopup(parentContext: context),
                            );
                            // debugPrint(
                            //   'Selected customer: ${customer?.name} (${customer?.id})',
                            // );
                            if (customer == null) return;
                            _onAddToCart(context, ref, customer: customer);
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: 190 * r,
                            height: 52 * r,
                            padding: EdgeInsets.symmetric(
                              horizontal: 20 * r,
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
                                ),
                              ],
                            ),
                            child: Center(
                              child: MyText(
                                'Continue',
                                style: TextStyle(
                                  color: const Color(0xFF6C5022),
                                  fontSize: 18 * r,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Container(height: 4, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Default Value Button
// Styled as an outlined secondary button to visually differ from Continue
// ─────────────────────────────────────────────────────────────────────────────

class _DefaultValueButton extends StatelessWidget {
  final double r;
  final bool isLoading;
  final VoidCallback onTap;

  const _DefaultValueButton({
    required this.r,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(20),
      child: Opacity(
        opacity: isLoading ? 0.5 : 1.0,
        child: Container(
          width: 190 * r, // same as Continue button
          height: 52 * r, // same as Continue button
          padding: EdgeInsets.symmetric(horizontal: 20 * r, vertical: 6 * r),
          decoration: ShapeDecoration(
            gradient: const LinearGradient(
              begin: Alignment(0.0, 0.5),
              end: Alignment(0.96, 1.12),
              colors: [Color(0xFFBEE4DD), Color(0xA5D1B193)],
            ),
            shape: RoundedRectangleBorder(
              side: const BorderSide(width: 1, color: Color(0xFFACA584)),
              borderRadius: const BorderRadius.all(Radius.circular(20)),
            ),
            shadows: const [
              BoxShadow(
                color: Color(0x7C000000),
                blurRadius: 4,
                offset: Offset(2, 2),
              ),
            ],
          ),
          child: Center(
            child: MyText(
              'Reset Price',
              style: TextStyle(
                color: const Color(0xFF6C5022),
                fontSize: 18 * r, // same font size as Continue
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DeliveryBadge
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
      width: 271 * r,
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
