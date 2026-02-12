import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/carat_range_selector.dart';
import '../../../shared/widgets/range_selector.dart';
import '../../../shared/utils/scale_size.dart';
import '../../../shared/widgets/text.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../shared/utils/currency_formatter.dart';
import 'widget/ringsize_selector.dart';
import '../../../shared/utils/ring_size_utils.dart';
import '../data/jewellery_detail_model.dart';
import 'widget/side_diamond_selector.dart';
import '../../../shared/widgets/styled_dropdown.dart';
import '../data/jewellery_filter.dart';
import '../data/solitaire_constants.dart'; // solitaireShapes, solusShapes, slabs, colors, etc.

// 🔹 Utility: collection / shape से color/clarity options (React getColorOptions/getClarityOptions)
List<String> getColorOptions({
  required String slab,
  required bool isRound,
  required String collection,
}) {
  final parts = slab.split('-');
  final double caratTo = parts.length > 1 ? double.tryParse(parts[1]) ?? 0 : 0;

  if (collection.toUpperCase() == 'SOLUS') {
    return solusColors;
  } else {
    if (isRound) {
      if (caratTo < 0.18) {
        return otherRoundColors;
      } else {
        return colors;
      }
    } else {
      if (caratTo >= 0.10 && caratTo <= 0.17) {
        return otherRoundColorsCarat;
      } else {
        return colors.where((c) => c != 'I' && c != 'J' && c != 'K').toList();
      }
    }
  }
}

List<String> getClarityOptions({
  required String slab,
  required bool isRound,
  required String collection,
}) {
  final parts = slab.split('-');
  final double caratTo = parts.length > 1 ? double.tryParse(parts[1]) ?? 0 : 0;

  if (collection.toUpperCase() == 'SOLUS') {
    return claritiesRoundCarat;
  } else {
    if (isRound) {
      if (caratTo < 0.18) {
        return claritiesRound;
      } else {
        return clarities;
      }
    } else {
      if (caratTo >= 0.10 && caratTo <= 0.17) {
        return claritiesRoundCarat;
      } else {
        return clarities.sublist(0, 5); // IF..VS2
      }
    }
  }
}

class CustomizeSolitaire extends ConsumerStatefulWidget {
  final Map<String, dynamic>? initialValues;
  final List<String>? metalColors;
  final List<String>? metalPurity;
  final JewelleryDetail detail;
  final int totalSidePcs;
  final double totalSideWeight;

  // collection + multi-size flag JS जैसा
  final String collection; // 'SOLITAIRE' / 'SOLUS' जैसा
  final bool isMultiSize;
  final String shape;

  const CustomizeSolitaire({
    super.key,
    this.initialValues,
    this.metalColors,
    this.metalPurity,
    required this.detail,
    required this.totalSidePcs,
    required this.totalSideWeight,
    this.collection = 'SOLITAIRE',
    this.isMultiSize = false,
    this.shape = '',
  });

  @override
  ConsumerState<CustomizeSolitaire> createState() => _CustomizeSolitaireState();
}

class _CustomizeSolitaireState extends ConsumerState<CustomizeSolitaire> {
  final colorSteps = colors; // constants से
  final claritySteps = clarities;

  // indices
  int _priceStartIndex = 1;
  int _priceEndIndex = 4;
  int _caratStartIndex = 0;
  int _caratEndIndex = 10;
  int _colorStartIndex = 2;
  int _colorEndIndex = 4;
  int _clarityStartIndex = 1;
  int _clarityEndIndex = 4;

  String priceRangeText = '';
  String caratRangeText = '';
  String colorRangeText = '';
  String clarityRangeText = '';

  String? selectedMetalColor;
  String? selectedMetalPurity;

  late List<String> ringSizes;
  String _selectedRingSize = '';
  String? selectedSideDiamondQuality;

  // shape state (React popup जैसा)
  String _selectedShape = '';
  // String? _selectedVariantId; // multi-size dropdown
  // String? _selectedMultiBomName;

  //final _multiCaratSteps = [];

  //String _clean(String v) => v.replaceAll('₹', '').replaceAll('ct', '').trim();

  bool get _isRoundShape =>
      _selectedShape.toUpperCase() == 'ROUND' || _selectedShape == 'RND';

  String get _currentCaratSlab {
    final from = caratSteps[_caratStartIndex];
    final to = caratSteps[_caratEndIndex];
    return '$from-$to';
  }

  @override
  void initState() {
    super.initState();

    final init = widget.initialValues;

    if (init != null) {
      if (init['price'] != null) {
        _priceStartIndex = init['price']['startIndex'] ?? _priceStartIndex;
        _priceEndIndex = init['price']['endIndex'] ?? _priceEndIndex;
      }

      if (init['carat'] != null) {
        _caratStartIndex = init['carat']['startIndex'] ?? _caratStartIndex;
        _caratEndIndex = init['carat']['endIndex'] ?? _caratEndIndex;
      }

      if (init['color'] != null) {
        _colorStartIndex = init['color']['startIndex'] ?? _colorStartIndex;
        _colorEndIndex = init['color']['endIndex'] ?? _colorEndIndex;
      }

      if (init['clarity'] != null) {
        _clarityStartIndex =
            init['clarity']['startIndex'] ?? _clarityStartIndex;
        _clarityEndIndex = init['clarity']['endIndex'] ?? _clarityEndIndex;
      }

      _selectedShape = init['shape']?.toString() ?? '';

      debugPrint("Selected shape from init: $_selectedShape");
      debugPrint("Collection : ${widget.collection}");
    }

    ringSizes = buildRingSizes(
      widget.detail.productSizeFrom,
      widget.detail.productSizeTo,
    );

    if (ringSizes.isNotEmpty) {
      _selectedRingSize = ringSizes.first;
    }

    final initRing = init?['ringSize']?.toString();
    if (initRing != null && ringSizes.contains(initRing)) {
      _selectedRingSize = initRing;
    }

    if (widget.metalColors != null && widget.metalColors!.isNotEmpty) {
      selectedMetalColor = init?['metalColor'] ?? widget.metalColors!.first;
    }

    if (widget.metalPurity != null && widget.metalPurity!.isNotEmpty) {
      selectedMetalPurity = init?['metalPurity'] ?? widget.metalPurity!.first;
    }

    selectedSideDiamondQuality = init?['sideDiamondQuality'] ?? 'IJ-SI';

    // debugPrint(
    //   'initial variantId=$_selectedVariantId, shape=$_selectedShape, carat slab=$_currentCaratSlab',
    // );
  }

  // 🔹 multi-size selection -> BOM से slab/color/clarity निकालना
  void _onMultiSizeChanged(String? variantId) {
    if (variantId == null) return;
    // setState(() {
    //   _selectedVariantId = variantId;
    // });

    final bomList = widget.detail.bom.where(
      (b) =>
          '${b.variantId}' == variantId &&
          (b.itemGroup ?? '').trim().toUpperCase() == 'SOLITAIRE' &&
          (b.itemType ?? '').trim().toUpperCase() == 'STONE',
    );

    if (bomList.isEmpty) return;

    final lowestBom = bomList.reduce(
      (min, curr) => (curr.pcs ?? 0) < (min.pcs ?? 0) ? curr : min,
    );

    final name = lowestBom.bomVariantName ?? '';
    // setState(() {
    //   _selectedMultiBomName = name;
    // });

    final parts = name.split('-').map((e) => e.trim()).toList();
    if (parts.length < 4) return;

    // parts[1] = shape code (RND, PRN, ...)
    final shapeCode = parts[1];
    setState(() {
      _selectedShape = shapeCode;
    });

    final caratFrom = parts[2];
    final caratTo = parts[3];

    // _multiCaratSteps.add(caratFrom);
    // _multiCaratSteps.add(caratTo);

    final fromIndex = caratSteps.indexOf(caratFrom);
    final toIndex = caratSteps.indexOf(caratTo);

    debugPrint(
      'Multi-size selected: shape=$shapeCode, caratFrom=$caratFrom, caratTo=$caratTo',
    );

    if (fromIndex != -1 && toIndex != -1) {
      setState(() {
        _caratStartIndex = fromIndex;
        _caratEndIndex = toIndex;
        caratRangeText = '$caratFrom - $caratTo';
      });
    }

    if (parts.length > 4 && parts[4].isNotEmpty) {
      final colorF = parts[4];
      final colorIndex = colorSteps.indexOf(colorF);
      if (colorIndex != -1) {
        setState(() {
          _colorStartIndex = colorIndex;
          _colorEndIndex = colorIndex;
          colorRangeText = '$colorF - $colorF';
        });
      }
    }

    if (parts.length > 5 && parts[5].isNotEmpty) {
      final clarityF = parts[5];
      final clarityIndex = claritySteps.indexOf(clarityF);
      if (clarityIndex != -1) {
        setState(() {
          _clarityStartIndex = clarityIndex;
          _clarityEndIndex = clarityIndex;
          clarityRangeText = '$clarityF - $clarityF';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final fem = ScaleSize.aspectRatio;
    final bool showPriceRange = false;

    final currentSlab = _currentCaratSlab;
    final isRound = _isRoundShape;
    final colorOptions = getColorOptions(
      slab: currentSlab,
      isRound: isRound,
      collection: widget.collection,
    );
    final clarityOptions = getClarityOptions(
      slab: currentSlab,
      isRound: isRound,
      collection: widget.collection,
    );

    return Material(
      color: Colors.white,
      elevation: 8,
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 18 * fem,
              vertical: 16 * fem,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Divine Solitaires Selection',
                    style: TextStyle(
                      fontSize: 18 * fem,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          // Body + bottom
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 18 * fem),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (showPriceRange) ...[
                          SizedBox(height: 10 * fem),
                          RangeSelector(
                            key: ValueKey(
                              'price_${_priceStartIndex}_$_priceEndIndex',
                            ),
                            label: 'Price Range',
                            values: priceSteps,
                            initialStartIndex: _priceStartIndex,
                            initialEndIndex: _priceEndIndex,
                            valueToChipText: (v) => '₹ $v',
                            onRangeChanged: (start, end) {
                              setState(() {
                                priceRangeText = '$start - $end';
                                _priceStartIndex = priceSteps.indexOf(start);
                                _priceEndIndex = priceSteps.indexOf(end);
                              });
                            },
                          ),
                        ],

                        SizedBox(height: 16 * fem),

                        // Shape + Carat / Multi-size
                        Row(
                          children: [
                            // Shape dropdown (single-size mode)
                            if (!widget.isMultiSize) ...[
                              // Expanded(
                              //   flex: 1,
                              //   child: Column(
                              //     crossAxisAlignment: CrossAxisAlignment.start,
                              //     children: [
                              //       Text(
                              //         'Shape',
                              //         style: TextStyle(
                              //           fontSize: 14 * fem,
                              //           fontWeight: FontWeight.w500,
                              //         ),
                              //       ),
                              //       const SizedBox(height: 8),
                              //       DropdownButtonFormField<String>(
                              //         value: _selectedShape.isEmpty
                              //             ? null
                              //             : _selectedShape,
                              //         items:
                              //             (widget.collection.toUpperCase() ==
                              //                         'SOLUS'
                              //                     ? solusShapes
                              //                     : solitaireShapes)
                              //                 .map(
                              //                   (s) => DropdownMenuItem(
                              //                     value: s,
                              //                     child: Text(s),
                              //                   ),
                              //                 )
                              //                 .toList(),
                              //         onChanged: (v) {
                              //           setState(() {
                              //             _selectedShape = v ?? '';
                              //           });
                              //         },
                              //         decoration: const InputDecoration(
                              //           border: OutlineInputBorder(),
                              //           isDense: true,
                              //         ),
                              //       ),
                              //     ],
                              //   ),
                              // ),
                              // const SizedBox(width: 16),
                              Expanded(
                                flex: 2,
                                child: CaratRangeSelector(
                                  // key: ValueKey(
                                  //   'carat_${_caratStartIndex}_$_caratEndIndex',
                                  // ),
                                  label: 'Carat',
                                  values: caratSteps,
                                  initialStartIndex: _caratStartIndex,
                                  initialEndIndex: _caratEndIndex,
                                  onRangeChanged: (start, end) {
                                    setState(() {
                                      caratRangeText = '$start - $end';
                                      _caratStartIndex = caratSteps.indexOf(
                                        start,
                                      );
                                      _caratEndIndex = caratSteps.indexOf(end);
                                    });
                                  },
                                ),
                              ),
                            ] else ...[
                              // Multi-size dropdown
                              // Expanded(
                              //   flex: 1,
                              //   child: Column(
                              //     crossAxisAlignment: CrossAxisAlignment.start,
                              //     children: [
                              //       Text(
                              //         'Multi Size',
                              //         style: TextStyle(
                              //           fontSize: 14 * fem,
                              //           fontWeight: FontWeight.w500,
                              //         ),
                              //       ),
                              //       const SizedBox(height: 8),
                              //       DropdownButtonFormField<String>(
                              //         value: _selectedVariantId,
                              //         items: (widget.detail.variants ?? [])
                              //             .where(
                              //               (v) => (v.variantName ?? '')
                              //                   .isNotEmpty,
                              //             )
                              //             .map(
                              //               (v) => DropdownMenuItem(
                              //                 value: '${v.variantId}',
                              //                 child: Text(v.variantName!),
                              //               ),
                              //             )
                              //             .toList(),
                              //         onChanged: _onMultiSizeChanged,
                              //         decoration: const InputDecoration(
                              //           border: OutlineInputBorder(),
                              //           isDense: true,
                              //         ),
                              //       ),
                              //     ],
                              //   ),
                              // ),
                              // Text(
                              //   _caratStartIndex < caratSteps.length &&
                              //           _caratEndIndex < caratSteps.length
                              //       ? 'Shape: ${_selectedShape.isEmpty ? 'N/A' : _selectedShape}, Carat: ${caratSteps[_caratStartIndex]} - ${caratSteps[_caratEndIndex]}'
                              //       : 'Shape: ${_selectedShape.isEmpty ? 'N/A' : _selectedShape}, Carat: N/A',

                              //   style: TextStyle(
                              //     fontSize: 14 * fem,
                              //     fontWeight: FontWeight.w500,
                              //   ),
                              // ),
                              // Text(
                              //   _multiCaratSteps.toString(),
                              //   style: TextStyle(
                              //     fontSize: 14 * fem,
                              //     fontWeight: FontWeight.w500,
                              //   ),
                              // ),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: 2,
                                child: CaratRangeSelector(
                                  // key: ValueKey(
                                  //   'carat_${_caratStartIndex}_$_caratEndIndex',
                                  // ),
                                  label: 'Carat',
                                  values: caratSteps,
                                  initialStartIndex: _caratStartIndex,
                                  initialEndIndex: _caratEndIndex,
                                  onRangeChanged: (start, end) {
                                    setState(() {
                                      caratRangeText = '$start - $end';
                                      _caratStartIndex = caratSteps.indexOf(
                                        start,
                                      );
                                      _caratEndIndex = caratSteps.indexOf(end);
                                    });
                                  },
                                ),
                              ),
                            ],
                          ],
                        ),

                        SizedBox(height: 16 * fem),

                        // Color range (from indices + options list)
                        RangeSelector(
                          // key: ValueKey(
                          //   'color_${_colorStartIndex}_$_colorEndIndex',
                          // ),
                          label: 'Color',
                          values: colorOptions,
                          initialStartIndex: _colorStartIndex.clamp(
                            0,
                            colorOptions.length - 1,
                          ),
                          initialEndIndex: _colorEndIndex.clamp(
                            0,
                            colorOptions.length - 1,
                          ),
                          onRangeChanged: (start, end) {
                            setState(() {
                              colorRangeText = '$start - $end';
                              _colorStartIndex = colorOptions.indexOf(start);
                              _colorEndIndex = colorOptions.indexOf(end);
                            });
                          },
                        ),

                        SizedBox(height: 16 * fem),

                        RangeSelector(
                          // key: ValueKey(
                          //   'clarity_${_clarityStartIndex}_$_clarityEndIndex',
                          // ),
                          label: 'Clarity',
                          values: clarityOptions,
                          initialStartIndex: _clarityStartIndex.clamp(
                            0,
                            clarityOptions.length - 1,
                          ),
                          initialEndIndex: _clarityEndIndex.clamp(
                            0,
                            clarityOptions.length - 1,
                          ),
                          onRangeChanged: (start, end) {
                            setState(() {
                              clarityRangeText = '$start - $end';
                              _clarityStartIndex = clarityOptions.indexOf(
                                start,
                              );
                              _clarityEndIndex = clarityOptions.indexOf(end);
                            });
                          },
                        ),

                        SizedBox(height: 20 * fem),

                        Text(
                          'Divine Mount Selection',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20 * fem,
                            fontFamily: 'Rushter Glory',
                            fontWeight: FontWeight.w400,
                            height: 1.60,
                          ),
                        ),
                        SizedBox(height: 15 * fem),

                        if ((widget.metalColors?.isNotEmpty ?? false) ||
                            (widget.metalPurity?.isNotEmpty ?? false))
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 300 * fem,
                                height: 110 * fem,
                                decoration: ShapeDecoration(
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                      width: 1 * fem,
                                      color: const Color(0xFFBEE4DD),
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      15 * fem,
                                    ),
                                  ),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10 * fem,
                                    vertical: 8 * fem,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Metal',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 14 * fem,
                                          fontFamily: 'Rushter Glory',
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (widget.metalColors?.isNotEmpty ??
                                              false)
                                            StyledDropdown(
                                              label: '',
                                              value: selectedMetalColor,
                                              items: widget.metalColors!,
                                              onChanged: (value) {
                                                setState(
                                                  () => selectedMetalColor =
                                                      value,
                                                );
                                              },
                                              width: 155 * fem,
                                            ),
                                          if (widget.metalPurity?.isNotEmpty ??
                                              false) ...[
                                            SizedBox(width: 20 * fem),
                                            StyledDropdown(
                                              label: '',
                                              value: selectedMetalPurity,
                                              items: widget.metalPurity!,
                                              onChanged: (value) {
                                                setState(
                                                  () => selectedMetalPurity =
                                                      value,
                                                );
                                              },
                                              width: 100 * fem,
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(width: 12 * fem),
                              SideDiamondSelector(
                                title:
                                    'Side Diamond : ${widget.totalSidePcs} / ${widget.totalSideWeight.toStringAsFixed(3)} ct',
                                options: const ['IJ-SI', 'GH-VS', 'EF-VVS'],
                                selectedValue: selectedSideDiamondQuality,
                                onChanged: (value) {
                                  setState(() {
                                    selectedSideDiamondQuality = value;
                                  });
                                },
                                r: fem,
                              ),
                            ],
                          ),

                        SizedBox(height: 16 * fem),

                        if (ringSizes.isNotEmpty)
                          RingSizeSelector(
                            key: ValueKey(_selectedRingSize),
                            values: ringSizes,
                            initialIndex: ringSizes.indexOf(_selectedRingSize),
                            onChanged: (size) {
                              setState(() {
                                _selectedRingSize = size;
                              });
                            },
                          ),

                        SizedBox(height: 20 * fem),
                      ],
                    ),
                  ),
                ),

                // bottom bar
                Container(
                  height: 82 * fem,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFBEE4DD),
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(color: Color(0xFF90DCD0)),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(25 * fem),
                        topRight: Radius.circular(25 * fem),
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      43 * fem,
                      20 * fem,
                      37 * fem,
                      10 * fem,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (showPriceRange) ...[
                          Row(
                            children: [
                              MyText(
                                double.parse(
                                  priceSteps[_priceStartIndex].replaceAll(
                                    ',',
                                    '',
                                  ),
                                ).inRupeesFormat(),
                                style: TextStyle(
                                  fontSize: 20 * fem,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(width: 8 * fem),
                              MyText('-', style: TextStyle(fontSize: 20 * fem)),
                              SizedBox(width: 8 * fem),
                              MyText(
                                double.parse(
                                  priceSteps[_priceEndIndex].replaceAll(
                                    ',',
                                    '',
                                  ),
                                ).inRupeesFormat(),
                                style: TextStyle(
                                  fontSize: 20 * fem,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                        ],
                        SizedBox(
                          height: 52 * fem,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20 * fem),
                            onTap: () {
                              Navigator.of(context).pop(
                                JewelleryFilter(
                                  price: PriceRangeFilter(
                                    startValue: priceSteps[_priceStartIndex],
                                    endValue: priceSteps[_priceEndIndex],
                                    startIndex: _priceStartIndex,
                                    endIndex: _priceEndIndex,
                                  ),
                                  carat: CaratRangeFilter(
                                    startValue: caratSteps[_caratStartIndex],
                                    endValue: caratSteps[_caratEndIndex],
                                    startIndex: _caratStartIndex,
                                    endIndex: _caratEndIndex,
                                  ),
                                  color: ColorRangeFilter(
                                    start:
                                        colorOptions[_colorStartIndex.clamp(
                                          0,
                                          colorOptions.length - 1,
                                        )],
                                    end:
                                        colorOptions[_colorEndIndex.clamp(
                                          0,
                                          colorOptions.length - 1,
                                        )],
                                    startIndex: _colorStartIndex,
                                    endIndex: _colorEndIndex,
                                  ),
                                  clarity: ClarityRangeFilter(
                                    start:
                                        clarityOptions[_clarityStartIndex.clamp(
                                          0,
                                          clarityOptions.length - 1,
                                        )],
                                    end:
                                        clarityOptions[_clarityEndIndex.clamp(
                                          0,
                                          clarityOptions.length - 1,
                                        )],
                                    startIndex: _clarityStartIndex,
                                    endIndex: _clarityEndIndex,
                                  ),
                                  ringSize: _selectedRingSize,
                                  metalColor: selectedMetalColor,
                                  metalPurity: selectedMetalPurity,
                                  sideDiamondQuality:
                                      selectedSideDiamondQuality,
                                  // चाहो तो multiVariantId भी filter में जोड़ो
                                ),
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 30 * fem,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: const Color(0xFFACA584),
                                ),
                                borderRadius: BorderRadius.circular(20 * fem),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SvgPicture.asset(
                                    'assets/icons/apply_customise.svg',
                                    width: 20 * fem,
                                  ),
                                  SizedBox(width: 8 * fem),
                                  MyText(
                                    'Apply Customization',
                                    style: TextStyle(
                                      fontSize: 16 * fem,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF6C5022),
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Dialog helper
Future<JewelleryFilter?> showCustomizeDrawer({
  required BuildContext context,
  required JewelleryDetail detail,
  required int totalSidePcs,
  required double totalSideWeight,
  Map<String, dynamic>? initialValues,
  List<String>? metalColors,
  List<String>? metalPurity,
  String collection = 'SOLITAIRE',
  bool isMultiSize = false,
}) {
  return showGeneralDialog<JewelleryFilter>(
    context: context,
    barrierLabel: 'Customize',
    barrierDismissible: true,
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      return const SizedBox.shrink();
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final screenWidth = MediaQuery.of(context).size.width;
      final panelWidth = screenWidth * 0.50;

      return Stack(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(color: Colors.transparent),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(1.0, 0.0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
              child: SizedBox(
                width: panelWidth,
                child: CustomizeSolitaire(
                  initialValues: initialValues,
                  metalColors: metalColors,
                  metalPurity: metalPurity,
                  detail: detail,
                  totalSidePcs: totalSidePcs,
                  totalSideWeight: totalSideWeight,
                  collection: collection,
                  isMultiSize: isMultiSize,
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}
