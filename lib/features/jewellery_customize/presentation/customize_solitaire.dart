import 'package:flutter/material.dart';
import '../../../shared/widgets/range_selector.dart';
import '../../../shared/utils/scale_size.dart';
import '../../jewellery/presentation/widget/metal_type.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../jewellery/data/filter_provider.dart';
import '../../../shared/widgets/text.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../shared/utils/currency_formatter.dart';
import 'widget/ringsize_selector.dart';

class CustomizeSolitaire extends ConsumerStatefulWidget {
  final Map<String, dynamic>? initialValues;

  const CustomizeSolitaire({super.key, this.initialValues});

  @override
  ConsumerState<CustomizeSolitaire> createState() => _CustomizeSolitaireState();
}

class _CustomizeSolitaireState extends ConsumerState<CustomizeSolitaire> {
  // Discrete lists
  final priceSteps = [
    '20,000',
    '30,000',
    '50,000',
    '75,000',
    '1,00,000',
    '1,50,000',
    '2,00,000',
    '2,50,000',
    '3,50,000',
    '5,00,000',
  ];

  final caratSteps = [
    '0.10',
    '0.14',
    '0.18',
    '0.23',
    '0.30',
    '0.39',
    '0.45',
    '0.50',
    '0.70',
    '0.80',
    '0.90',
  ];

  final colorSteps = ['D', 'E', 'F', 'G', 'H', 'I', 'J', 'K'];

  final claritySteps = ['IF', 'VVS1', 'VVS2', 'VS1', 'VS2', 'SI1', 'SI2'];

  final ringSizes = [
    '6',
    '7',
    '8',
    '9',
    '10',
    '11',
    '12',
    '13',
    '14',
    '15',
    '16',
    '17',
    '18',
    '19',
    '20',
    '21',
  ];

  // 🔹 Track current indices
  int _priceStartIndex = 1;
  int _priceEndIndex = 4;
  int _caratStartIndex = 0;
  int _caratEndIndex = 10;
  int _colorStartIndex = 2;
  int _colorEndIndex = 4;
  int _clarityStartIndex = 1;
  int _clarityEndIndex = 4;
  String _selectedRingSize = '8';

  String priceRangeText = '';
  String caratRangeText = '';
  String colorRangeText = '';
  String clarityRangeText = '';

  final List<Map<String, String>> _metalItems = [
    {
      'label': 'Yellow Gold',
      'asset': 'assets/jewellery/filters/metal/yellow_gold.png',
    },
    {
      'label': 'Rose Gold',
      'asset': 'assets/jewellery/filters/metal/rose_gold.png',
    },
    {
      'label': 'White Gold',
      'asset': 'assets/jewellery/filters/metal/white_gold.png',
    },
    {
      'label': 'Platinum',
      'asset': 'assets/jewellery/filters/metal/platinum.png',
    },
  ];

  // @override
  // void initState() {
  //   super.initState();
  //   priceRangeText = '₹ ${priceSteps[1]} - ₹ ${priceSteps[4]}';
  //   caratRangeText = '${caratSteps[1]} - ${caratSteps[2]}';
  //   colorRangeText = '${colorSteps[2]} - ${colorSteps[4]}';
  //   clarityRangeText = '${claritySteps[1]} - ${claritySteps[4]}';
  // }

  String _clean(String v) => v.replaceAll('₹', '').replaceAll('ct', '').trim();

  @override
  void initState() {
    super.initState();

    final init = widget.initialValues;
    //print('CustomizeSolitaire initState, initialValues: $init');

    if (init == null) return;

    // PRICE
    if (init['price'] != null) {
      _priceStartIndex = init['price']['startIndex'] ?? _priceStartIndex;
      _priceEndIndex = init['price']['endIndex'] ?? _priceEndIndex;
    }
    //print('Price indices: $_priceStartIndex - $_priceEndIndex');

    // CARAT
    if (init['carat'] != null) {
      _caratStartIndex = init['carat']['startIndex'] ?? _caratStartIndex;
      _caratEndIndex = init['carat']['endIndex'] ?? _caratEndIndex;
    }
    //print('Carat indices: $_caratStartIndex - $_caratEndIndex');

    // COLOR
    if (init['color'] != null) {
      _colorStartIndex = init['color']['startIndex'] ?? _colorStartIndex;
      _colorEndIndex = init['color']['endIndex'] ?? _colorEndIndex;
    }
   // print('Color indices: $_colorStartIndex - $_colorEndIndex');

    // CLARITY
    if (init['clarity'] != null) {
      _clarityStartIndex = init['clarity']['startIndex'] ?? _clarityStartIndex;
      _clarityEndIndex = init['clarity']['endIndex'] ?? _clarityEndIndex;
    }
    //print('Clarity indices: $_clarityStartIndex - $_clarityEndIndex');

    // RING SIZE
    if (init['ringSize'] != null) {
      _selectedRingSize = init['ringSize'];
    }
    //print('Selected ring size: $_selectedRingSize');
  }

  @override
  Widget build(BuildContext context) {
    final fem = ScaleSize.aspectRatio;

    final filter = ref.watch(filterProvider);
    final notifier = ref.read(filterProvider.notifier);

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          maxWidth: 669 * fem,
        ),
        child: Column(
          children: [
            // 🔹 FIXED HEADER
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

            // 🔹 SCROLLABLE CONTENT + FIXED BOTTOM
            Expanded(
              child: Column(
                children: [
                  // Scrollable content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 18 * fem),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 10 * fem),

                          // PRICE RangeSelector
                          RangeSelector(
                            key: ValueKey(
                              'price_${_priceStartIndex}_${_priceEndIndex}',
                            ),
                            label: 'Price Range',
                            values: priceSteps,
                            initialStartIndex: _priceStartIndex,
                            initialEndIndex: _priceEndIndex,
                            valueToChipText: (v) => '₹ $v',
                            onRangeChanged: (start, end) {
                              setState(() {
                                priceRangeText = ' $start, - $end';
                                _priceStartIndex = priceSteps.indexOf(start);
                                _priceEndIndex = priceSteps.indexOf(end);
                              });
                            },
                          ),
                          SizedBox(height: 16 * fem),

                          // CARAT RangeSelector
                          RangeSelector(
                            key: ValueKey(
                              'carat_${_caratStartIndex}_${_caratEndIndex}',
                            ),
                            label: 'Carat',
                            values: caratSteps,
                            initialStartIndex: _caratStartIndex,
                            initialEndIndex: _caratEndIndex,
                            onRangeChanged: (start, end) {
                              setState(() {
                                caratRangeText = '$start - $end';
                                _caratStartIndex = caratSteps.indexOf(start);
                                _caratEndIndex = caratSteps.indexOf(end);
                              });
                            },
                          ),
                          SizedBox(height: 16 * fem),

                          // COLOR RangeSelector
                          RangeSelector(
                            key: ValueKey(
                              'color_${_colorStartIndex}_${_colorEndIndex}',
                            ),
                            label: 'Color',
                            values: colorSteps,
                            initialStartIndex: _colorStartIndex,
                            initialEndIndex: _colorEndIndex,
                            onRangeChanged: (start, end) {
                              setState(() {
                                colorRangeText = '$start - $end';
                                _colorStartIndex = colorSteps.indexOf(start);
                                _colorEndIndex = colorSteps.indexOf(end);
                              });
                            },
                          ),
                          SizedBox(height: 16 * fem),

                          // CLARITY RangeSelector
                          RangeSelector(
                            key: ValueKey(
                              'clarity_${_clarityStartIndex}_${_clarityEndIndex}',
                            ),
                            label: 'Clarity',
                            values: claritySteps,
                            initialStartIndex: _clarityStartIndex,
                            initialEndIndex: _clarityEndIndex,
                            onRangeChanged: (start, end) {
                              setState(() {
                                clarityRangeText = '$start - $end';
                                _clarityStartIndex = claritySteps.indexOf(
                                  start,
                                );
                                _clarityEndIndex = claritySteps.indexOf(end);
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
                          SizedBox(height: 20 * fem),

                          // 🔹 RING SIZE SELECTOR
                          RingSizeSelector(
                            key: ValueKey(_selectedRingSize), // ✅ ADD THIS
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

                  // 🔹 FIXED BOTTOM BAR with Figma Apply button
                  // Container(
                  //   width: 569 * fem,
                  //   height: 82 * fem,
                  //   decoration: ShapeDecoration(
                  //     color: const Color(0xFFBEE4DD),
                  //     shape: RoundedRectangleBorder(
                  //       side: BorderSide(
                  //         width: 1,
                  //         color: const Color(0xFF90DCD0),
                  //       ),
                  //       borderRadius: BorderRadius.only(
                  //         topLeft: Radius.circular(25),
                  //         topRight: Radius.circular(25),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  Container(
                    height: 82 * fem,
                    //padding: EdgeInsets.symmetric(horizontal: 18 * fem),
                    decoration: ShapeDecoration(
                      color: const Color(0xFFBEE4DD),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: Color(0xFF90DCD0)),
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
                        children: [
                          // 🔹 PRICE SUMMARY
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

                          // 🔹 APPLY BUTTON
                          SizedBox(
                            height: 52 * fem,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20 * fem),
                              onTap: () {
                                Navigator.of(context).pop({
                                  'price': {
                                    'startIndex': _priceStartIndex,
                                    'endIndex': _priceEndIndex,
                                    'startValue': priceSteps[_priceStartIndex],
                                    'endValue': priceSteps[_priceEndIndex],
                                  },
                                  'carat': {
                                    'startIndex': _caratStartIndex,
                                    'endIndex': _caratEndIndex,
                                    'startValue': caratSteps[_caratStartIndex],
                                    'endValue': caratSteps[_caratEndIndex],
                                  },
                                  'color': {
                                    'startIndex': _colorStartIndex,
                                    'endIndex': _colorEndIndex,
                                    'start': colorSteps[_colorStartIndex],
                                    'end': colorSteps[_colorEndIndex],
                                  },
                                  'clarity': {
                                    'startIndex': _clarityStartIndex,
                                    'endIndex': _clarityEndIndex,
                                    'start': claritySteps[_clarityStartIndex],
                                    'end': claritySteps[_clarityEndIndex],
                                  },
                                  'ringSize': _selectedRingSize,
                                });
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
      ),
    );
  }
}
