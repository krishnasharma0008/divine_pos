import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/carat_range_selector.dart';
import '../../../shared/widgets/range_selector.dart';
import '../../../shared/utils/scale_size.dart';
import '../../../shared/widgets/text.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../data/solitaire_filter.dart';
import '../data/solitaire_constants.dart'; // solitaireShapes, solusShapes, slabs, colors, etc.
import '../presentation/widget/shape_selector.dart';

/// Utility: slab + shape/collection → color options
List<String> getColorOptions({
  required String slab,
  required bool isRound,
  required String collection, // 'SOLITAIRE' or 'SOLUS'
}) {
  final parts = slab.split('-');
  final double caratTo = parts.length > 1 ? double.tryParse(parts[1]) ?? 0 : 0;

  debugPrint(
    'getColorOptions - slab: $slab, isRound: $isRound, collection: $collection, caratTo: $caratTo',
  );

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

/// Utility: slab + shape/collection → clarity options
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
  final String shape;

  /// Called immediately when the user taps a shape in the drawer —
  /// before "Apply Customization" is tapped — so the screen can
  /// update the image in real time.
  final ValueChanged<String>? onShapeChanged;

  const CustomizeSolitaire({
    super.key,
    this.initialValues,
    this.shape = '',
    this.onShapeChanged,
  });

  @override
  ConsumerState<CustomizeSolitaire> createState() => _CustomizeSolitaireState();
}

class _CustomizeSolitaireState extends ConsumerState<CustomizeSolitaire> {
  final colorSteps = colors;
  final claritySteps = clarities;

  int _priceStartIndex = 1;
  int _priceEndIndex = 4;
  int _caratStartIndex = 4;
  int _caratEndIndex = 5;
  int _colorStartIndex = 2;
  int _colorEndIndex = 4;
  int _clarityStartIndex = 1;
  int _clarityEndIndex = 4;

  String shapeText = '';
  String priceRangeText = '';
  String caratRangeText = '';
  String colorRangeText = '';
  String clarityRangeText = '';

  /// shape code: 'RND', 'PRN', etc.
  String _selectedShape = '';

  /// full shape model for UI / type
  DiamondShape? _selectedShapeObj;

  bool get _isRoundShape =>
      _selectedShape.toUpperCase() == 'ROUND' || _selectedShape == 'RND';

  /// collection derived from shape type
  String get _collection {
    final type = _selectedShapeObj?.type.toUpperCase() ?? '';
    if (type == 'SOLUS') return 'SOLUS';
    return 'SOLITAIRE';
  }

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
    }

    if (_selectedShape.isEmpty && widget.shape.isNotEmpty) {
      _selectedShape = widget.shape;
    }
  }

  int _shapeInitialIndex() {
    const allShapes = <String>[
      'RND',
      'PRN',
      'PER',
      'OVL',
      'RADQ',
      'CUSQ',
      'HRT',
    ];
    final index = allShapes.indexWhere(
      (e) => e.toUpperCase() == _selectedShape.toUpperCase(),
    );
    return index >= 0 ? index : 0;
  }

  @override
  Widget build(BuildContext context) {
    final fem = ScaleSize.aspectRatio;
    const bool showPriceRange = true;

    final currentSlab = _currentCaratSlab;
    final isRound = _isRoundShape;

    final colorOptions = getColorOptions(
      slab: currentSlab,
      isRound: isRound,
      collection: _collection,
    );
    final clarityOptions = getClarityOptions(
      slab: currentSlab,
      isRound: isRound,
      collection: _collection,
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

          // Body
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 18 * fem),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 10 * fem),

                        // Shape selector
                        ShapeSelector(
                          selectedShape:
                              _selectedShapeObj?.value ?? _selectedShape,
                          initialIndex: _shapeInitialIndex(),
                          onShapeChanged: (shape) {
                            setState(() {
                              shapeText = shape.label;
                              _selectedShapeObj = shape;
                              _selectedShape = shape.value;
                            });

                            // Notify the screen immediately so the image
                            // updates in real time before Apply is tapped.
                            widget.onShapeChanged?.call(shape.value);
                          },
                        ),

                        SizedBox(height: 16 * fem),

                        // Carat selector
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: CaratRangeSelector(
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
                        ),

                        SizedBox(height: 16 * fem),

                        // Color
                        RangeSelector(
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

                        // Clarity
                        RangeSelector(
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
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom bar
          SafeArea(
            top: false,
            child: Container(
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
                    // if (showPriceRange) ...[
                    //   Row(
                    //     children: [
                    //       MyText(
                    //         double.parse(
                    //           priceSteps[_priceStartIndex].replaceAll(',', ''),
                    //         ).inRupeesFormat(),
                    //         style: TextStyle(
                    //           fontSize: 20 * fem,
                    //           fontWeight: FontWeight.w500,
                    //         ),
                    //       ),
                    //       SizedBox(width: 8 * fem),
                    //       MyText('-', style: TextStyle(fontSize: 20 * fem)),
                    //       SizedBox(width: 8 * fem),
                    //       MyText(
                    //         double.parse(
                    //           priceSteps[_priceEndIndex].replaceAll(',', ''),
                    //         ).inRupeesFormat(),
                    //         style: TextStyle(
                    //           fontSize: 20 * fem,
                    //           fontWeight: FontWeight.w500,
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    //   const Spacer(),
                    // ],
                    SizedBox(
                      height: 52 * fem,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20 * fem),
                        onTap: () {
                          Navigator.of(context).pop(
                            SolitaireFilter(
                              shape: _selectedShape,
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
                            ),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 30 * fem),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFACA584)),
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
          ),
        ],
      ),
    );
  }
}

/// Dialog helper
Future<SolitaireFilter?> showCustomizeDrawer({
  required BuildContext context,
  Map<String, dynamic>? initialValues,
  String shape = '',

  /// Called immediately on every shape tap inside the drawer
  /// so the parent screen can update the image in real time.
  ValueChanged<String>? onShapeChanged,
}) {
  return showGeneralDialog<SolitaireFilter>(
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
            child: SafeArea(
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
                    shape: shape,
                    onShapeChanged: onShapeChanged,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}
