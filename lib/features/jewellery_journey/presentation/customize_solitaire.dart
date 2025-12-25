import 'package:flutter/material.dart';
import '../../../shared/widgets/range_selector.dart';
import '../../../shared/utils/scale_size.dart';
//import '../presentation/widget/metal_type.dart';
import '../../jewellery/presentation/widget/metal_type.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../jewellery/data/filter_provider.dart';

class CustomizeSolitaire extends ConsumerStatefulWidget {
  const CustomizeSolitaire({super.key});

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

  @override
  void initState() {
    super.initState();
    priceRangeText = '₹ ${priceSteps[1]} - ₹ ${priceSteps[4]}';
    caratRangeText = '${caratSteps[1]} - ${caratSteps[2]}';
    colorRangeText = '${colorSteps[2]} - ${colorSteps[4]}';
    clarityRangeText = '${claritySteps[1]} - ${claritySteps[4]}';
  }

  @override
  Widget build(BuildContext context) {
    final fem = ScaleSize.aspectRatio;

    final filter = ref.watch(filterProvider); // FilterState
    final notifier = ref.read(filterProvider.notifier); // FilterNotifier

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          // dialog will occupy at most 80% of screen height to avoid overflow
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          // and at most the design width
          maxWidth: 669 * fem,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 18 * fem,
              vertical: 16 * fem,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
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
                SizedBox(height: 10 * fem),

                // PRICE
                RangeSelector(
                  label: 'Price Range',
                  values: priceSteps,
                  initialStartIndex: 1,
                  initialEndIndex: 4,
                  valueToChipText: (v) => '₹ $v',
                  onRangeChanged: (start, end) {
                    setState(() {
                      priceRangeText = '₹ $start - ₹ $end';
                    });
                  },
                ),
                SizedBox(height: 16 * fem),

                // CARAT
                RangeSelector(
                  label: 'Carat',
                  values: caratSteps,
                  initialStartIndex: 1,
                  initialEndIndex: 2,
                  onRangeChanged: (start, end) {
                    setState(() {
                      caratRangeText = '$start - $end';
                    });
                  },
                ),
                SizedBox(height: 16 * fem),

                // COLOR
                RangeSelector(
                  label: 'Color',
                  values: colorSteps,
                  initialStartIndex: 2, // F
                  initialEndIndex: 4, // H
                  onRangeChanged: (start, end) {
                    setState(() {
                      colorRangeText = '$start - $end';
                    });
                  },
                ),
                SizedBox(height: 16 * fem),

                // CLARITY
                RangeSelector(
                  label: 'Clarity',
                  values: claritySteps,
                  initialStartIndex: 1, // VVS1
                  initialEndIndex: 4, // VS2
                  onRangeChanged: (start, end) {
                    setState(() {
                      clarityRangeText = '$start - $end';
                    });
                  },
                ),
                SizedBox(height: 20 * fem),

                // MetalTypeGrid(
                //   fem: fem,
                //   items: _metalItems,
                //   selected: filter.selectedMetal, // Set<String>
                //   onSelected: (metal) => notifier.toggleMetal(metal),
                // ),
                Text(
                  'Divine Mount Selection',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontFamily: 'Rushter Glory',
                    fontWeight: FontWeight.w400,
                    height: 1.60,
                  ),
                ),

                SizedBox(height: 20 * fem),

                // Bottom bar
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16 * fem,
                    vertical: 12 * fem,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFCFF4EE),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          priceRangeText,
                          style: TextStyle(
                            fontSize: 16 * fem,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF90DCD0),
                          foregroundColor: Colors.black87,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          // TODO: pass selected values back
                          Navigator.of(context).pop();
                        },
                        icon: Icon(Icons.tune_rounded, size: 18 * fem),
                        label: const Text('Apply'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
