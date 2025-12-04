import 'package:flutter/material.dart';
import '../../../shared/utils/scale_size.dart';
import '../presentation/widget/filter_section.dart';
import '../presentation/widget/filter_pill.dart';
import '../presentation/widget/range_selector.dart';
import '../presentation/widget/diamond_shape_grid.dart';
import '../presentation/widget/discrete_range_filter.dart';
import '../presentation/widget/metal_type.dart';

class FilterSidebar extends StatefulWidget {
  const FilterSidebar({super.key});

  @override
  State<FilterSidebar> createState() => _FilterSidebarState();
}

class _FilterSidebarState extends State<FilterSidebar> {
  // -----------------------------------------------------------
  // RANGE FILTERS
  // -----------------------------------------------------------
  RangeValues priceRange = const RangeValues(10000, 1000000);
  RangeValues caratRange = const RangeValues(0.10, 2.99);

  // -----------------------------------------------------------
  // COLOR OPTIONS
  // -----------------------------------------------------------
  final _colorOptions = ['D', 'E', 'F', 'G', 'H', 'I', 'J', 'K'];
  String colorStartLabel = 'D';
  String colorEndLabel = 'J';

  // -----------------------------------------------------------
  // CLARITY OPTIONS
  // -----------------------------------------------------------
  static const _clarityOptions = [
    'IF',
    'VVS1',
    'VVS2',
    'VS1',
    'VS2',
    'SI1',
    'SI2',
  ];
  String clarityStartLabel = 'IF';
  String clarityEndLabel = 'SI2';

  // -----------------------------------------------------------
  // SELECTED SETS (MULTI SELECT)
  // -----------------------------------------------------------
  final Set<String> selectedCategories = {'Solitaires'};
  final Set<String> selectedSubCat = {'Classic Rings'};
  final Set<String> selectedMetals = {'Rose Gold'};
  final Set<String> selectedGender = {'Men'};
  final Set<String> selectedOccasion = {'Engagement'};

  // -----------------------------------------------------------
  // GENERIC TOGGLE
  // -----------------------------------------------------------
  void toggleSet(Set<String> s, String value, String group) {
    setState(() {
      s.contains(value) ? s.remove(value) : s.add(value);
    });
    print("[$group] → $s");
  }

  // -----------------------------------------------------------
  // DIAMOND SHAPE
  // -----------------------------------------------------------
  final _diamondItems = [
    {'label': 'Round', 'asset': 'assets/jewellery/filters/round.png'},
    {'label': 'Princess', 'asset': 'assets/jewellery/filters/princess.png'},
    {'label': 'Cushion', 'asset': 'assets/jewellery/filters/cushion.png'},
    {'label': 'Oval', 'asset': 'assets/jewellery/filters/oval.png'},
    {'label': 'Pear', 'asset': 'assets/jewellery/filters/pear.png'},
    {'label': 'Radiant', 'asset': 'assets/jewellery/filters/radiant.png'},
    {'label': 'Cushion', 'asset': 'assets/jewellery/filters/fancy_cushion.png'},
    {'label': 'Heart', 'asset': 'assets/jewellery/filters/heart.png'},
  ];

  // -----------------------------------------------------------
  // Metal
  // -----------------------------------------------------------
  final List<Map<String, String>> _metalItems = [
    {
      'label': 'Yellow Gold',
      'asset': 'assets/jewellery/filters/metal/yellow_gold.png',
    },
    {
      'label': 'White Gold',
      'asset': 'assets/jewellery/filters/metal/white_gold.png',
    },
    {
      'label': 'Rose Gold',
      'asset': 'assets/jewellery/filters/metal/rose_gold.png',
    },
    {
      'label': 'Platinum',
      'asset': 'assets/jewellery/filters/metal/platinum.png',
    },
  ];

  String? selectedMetal;

  Widget twoColumnGrid({
    required List<String> items,
    required Set<String> selectedSet,
    required double fem,
    required String groupName,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const double spacing = 10; // same as before
        // width for 2 items per row inside available width
        final double cellWidth = (constraints.maxWidth - spacing) / 2;

        return Wrap(
          spacing: spacing,
          runSpacing: 10,
          children: items.map((item) {
            return SizedBox(
              width: cellWidth,
              child: FilterPill(
                label: item,
                selected: selectedSet.contains(item),
                onTap: () => toggleSet(selectedSet, item, groupName),
                fem: fem,
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // -----------------------------------------------------------
  // MAIN BUILD
  // -----------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final fem = ScaleSize.aspectRatio;

    return Container(
      width: 310 * fem,
      color: const Color(0xFFF6F6F6),
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 8 * fem, vertical: 18 * fem),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //------------------------------------------------------
            // HEADER
            //------------------------------------------------------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filters',
                  style: TextStyle(
                    fontSize: 24 * fem,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Montserrat',
                  ),
                ),
                Icon(Icons.close, size: 22 * fem),
              ],
            ),
            SizedBox(height: 41 * fem),

            //------------------------------------------------------
            // solitaire header
            //------------------------------------------------------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Solitaire',
                  style: TextStyle(
                    fontSize: 20 * fem,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Montserrat',
                  ),
                ),
                Icon(Icons.expand_less, size: 22 * fem),
              ],
            ),
            SizedBox(height: 30 * fem),
            Divider(height: 1, color: Colors.black.withOpacity(0.08)),
            SizedBox(height: 7 * fem),

            //------------------------------------------------------
            // PRICE RANGE
            //------------------------------------------------------
            FilterSection(
              title: 'Price Range',
              fem: fem,
              initiallyExpanded: true,
              child: RangeSelector(
                min: 10000,
                max: 1000000,
                title: '',
                onChanged: (range) {
                  setState(() => priceRange = range);
                  print('Price range: ${range.start} - ${range.end}');
                },
              ),
            ),

            //------------------------------------------------------
            // CATEGORY
            //------------------------------------------------------
            FilterSection(
              title: 'Category',
              fem: fem,
              child: twoColumnGrid(
                items: [
                  'Solitaires',
                  'Rings',
                  'Earrings',
                  'Necklaces',
                  'Bracelets',
                  'Pendants',
                  'Bangles',
                ],
                selectedSet: selectedCategories,
                fem: fem,
                groupName: "Category",
              ),
            ),

            //------------------------------------------------------
            // SUB CATEGORY
            //------------------------------------------------------
            FilterSection(
              title: 'Sub Category',
              fem: fem,
              child: twoColumnGrid(
                items: [
                  'Classic Rings',
                  'Band Rings',
                  'Couple Rings',
                  'Daily Wear',
                  'Office Wear',
                ],
                selectedSet: selectedSubCat,
                fem: fem,
                groupName: "Sub Category",
              ),
            ),

            //------------------------------------------------------
            // CARAT WEIGHT
            //------------------------------------------------------
            FilterSection(
              title: 'Carat Weight',
              fem: fem,
              initiallyExpanded: true,
              child: RangeSelector(
                min: 0.10,
                max: 2.99,
                title: '',
                formatter: (v) => '${v.toStringAsFixed(2)} ct',
              ),
            ),

            //------------------------------------------------------
            // DIAMOND SHAPE
            //------------------------------------------------------
            FilterSection(
              title: 'Diamond Shape',
              fem: fem,
              initiallyExpanded: true,
              child: DiamondShapeGrid(
                fem: ScaleSize.aspectRatio,
                items: _diamondItems,
                initialSelected: 'Round',
                onSelected: (shape) {
                  print('Shape selected → $shape');
                },
              ),
            ),

            //------------------------------------------------------
            // COLOR RANGE
            //------------------------------------------------------
            FilterSection(
              title: 'Color',
              fem: fem,
              child: DiscreteClickRange(
                title: '',
                options: _colorOptions,
                initialStartIndex: _colorOptions.indexOf(colorStartLabel),
                initialEndIndex: _colorOptions.indexOf(colorEndLabel),
                onChanged: (range) {
                  setState(() {
                    colorStartLabel = _colorOptions[range.start.toInt()];
                    colorEndLabel = _colorOptions[range.end.toInt()];
                  });
                  print('Color range: $colorStartLabel - $colorEndLabel');
                },
              ),
            ),

            //------------------------------------------------------
            // CLARITY RANGE
            //------------------------------------------------------
            FilterSection(
              title: 'Clarity',
              fem: fem,
              child: DiscreteClickRange(
                title: '',
                options: _clarityOptions,
                initialStartIndex: _clarityOptions.indexOf(clarityStartLabel),
                initialEndIndex: _clarityOptions.indexOf(clarityEndLabel),
                onChanged: (range) {
                  setState(() {
                    clarityStartLabel = _clarityOptions[range.start.toInt()];
                    clarityEndLabel = _clarityOptions[range.end.toInt()];
                  });
                  print('Clarity: $clarityStartLabel - $clarityEndLabel');
                },
              ),
            ),

            //------------------------------------------------------
            // METAL
            //------------------------------------------------------
            FilterSection(
              title: 'Metal',
              fem: fem,
              child: MetalTypeGrid(
                fem: fem,
                items: _metalItems,
                initialSelected: selectedMetal,
                onSelected: (metal) {
                  setState(() => selectedMetal = metal);
                  print('Selected metal → $metal');
                },
              ),
            ),

            //------------------------------------------------------
            // GENDER
            //------------------------------------------------------
            FilterSection(
              title: 'Gender',
              fem: fem,
              child: twoColumnGrid(
                items: ['Men', 'Women', 'Unisex', 'Children'],
                selectedSet: selectedGender,
                fem: fem,
                groupName: "Gender",
              ),
            ),

            //------------------------------------------------------
            // OCCASION
            //------------------------------------------------------
            FilterSection(
              title: 'Occasion',
              fem: fem,
              child: twoColumnGrid(
                items: [
                  'Engagement',
                  'Wedding',
                  'Anniversary',
                  'Daily Wear',
                  'Gifting',
                ],
                selectedSet: selectedOccasion,
                fem: fem,
                groupName: "Occasion",
              ),
            ),

            //SizedBox(height: 30 * fem),
          ],
        ),
      ),
    );
  }
}
