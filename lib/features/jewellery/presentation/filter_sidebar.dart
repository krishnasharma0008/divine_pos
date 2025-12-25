import 'package:flutter/material.dart';
import '../../../shared/utils/scale_size.dart';
import '../presentation/widget/filter_section.dart';
import '../presentation/widget/filter_pill.dart';
import '../presentation/widget/range_selector.dart';
import '../presentation/widget/diamond_shape_grid.dart';
import '../presentation/widget/discrete_range_filter.dart';
import '../presentation/widget/metal_type.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/filter_provider.dart';

class FilterSidebar extends ConsumerStatefulWidget {
  const FilterSidebar({super.key});

  @override
  ConsumerState<FilterSidebar> createState() => _FilterSidebarState();
}

class _FilterSidebarState extends ConsumerState<FilterSidebar> {
  // -----------------------------------------------------------
  // RANGE FILTERS
  // -----------------------------------------------------------
  RangeValues priceRange = const RangeValues(10000, 1000000);
  RangeValues caratRange = const RangeValues(0.10, 2.99);

  // -----------------------------------------------------------
  // COLOR OPTIONS
  // -----------------------------------------------------------
  // final _colorOptions = ['D', 'E', 'F', 'G', 'H', 'I', 'J', 'K'];
  // String colorStartLabel = 'D';
  // String colorEndLabel = 'J';

  // -----------------------------------------------------------
  // CLARITY OPTIONS
  // -----------------------------------------------------------
  // static const _clarityOptions = [
  //   'IF',
  //   'VVS1',
  //   'VVS2',
  //   'VS1',
  //   'VS2',
  //   'SI1',
  //   'SI2',
  // ];
  // String clarityStartLabel = 'IF';
  // String clarityEndLabel = 'SI2';

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
    // if (group == 'Gender') {
    //   ref
    //       .read(filterProvider.notifier)
    //       .setGender(s.contains(value) ? null : value);
    //   return;
    // }
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
    //{'label': 'Cushion', 'asset': 'assets/jewellery/filters/cushion.png'},
    {'label': 'Oval', 'asset': 'assets/jewellery/filters/oval.png'},
    {'label': 'Pear', 'asset': 'assets/jewellery/filters/pear.png'},
    {'label': 'Radiant', 'asset': 'assets/jewellery/filters/radiant.png'},
    {'label': 'Cushion', 'asset': 'assets/jewellery/filters/fancy_cushion.png'},
    {'label': 'Heart', 'asset': 'assets/jewellery/filters/heart.png'},
  ];

  //carat
  final _caratOptions = [
    '0.10',
    '0.25',
    '0.50',
    '0.75',
    '1.00',
    '1.50',
    '2.00',
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
    required void Function(String item) onTapItem,
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
                //onTap: () => toggleSet(selectedSet, item, groupName),
                onTap: () => onTapItem(item),

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

    final filter = ref.watch(filterProvider); // FilterState
    final notifier = ref.read(filterProvider.notifier); // FilterNotifier

    return Container(
      width: 310 * fem,
      color: const Color(0xFFF6F6F6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //------------------------------------------------------
          // FIXED HEADER (NON-SCROLLABLE)
          //------------------------------------------------------
          Padding(
            padding: EdgeInsets.fromLTRB(8 * fem, 18 * fem, 8 * fem, 12 * fem),
            child: Row(
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
                // Icon(Icons.close, size: 22 * fem),
              ],
            ),
          ),

          Divider(height: 1, color: Colors.black.withOpacity(0.08)),

          //------------------------------------------------------
          // SCROLLABLE FILTER SECTIONS
          //------------------------------------------------------
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                8 * fem,
                20 * fem,
                8 * fem,
                18 * fem,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                      values: filter.selectedPriceRange,
                      onChanged: notifier.setPrice,
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
                        'Ring',
                        'Earrings',
                        'Necklaces',
                        'Pendants',
                        'Bangles',
                        'Solitaire',
                        'Bracelets',
                        'Mangalsutra',
                        'Nosepin',
                        'Male Earring',
                      ],
                      selectedSet: filter.selectedCategory,
                      fem: fem,
                      groupName: "Category",
                      onTapItem: notifier.toggleCategory,
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
                      selectedSet: filter.selectedSubCategory,
                      fem: fem,
                      groupName: "Sub Category",
                      onTapItem: notifier.toggleSubCategory,
                    ),
                  ),

                  //------------------------------------------------------
                  // CARAT RANGE
                  //------------------------------------------------------
                  FilterSection(
                    title: 'Carat Weight',
                    fem: fem,
                    child: DiscreteClickRange(
                      title: '',
                      options: _caratOptions,
                      initialStartIndex: _caratOptions.indexOf(
                        filter.caratStartLabel,
                      ),
                      initialEndIndex: _caratOptions.indexOf(
                        filter.caratEndLabel,
                      ),
                      onChanged: (range) {
                        notifier.setCaratRange(
                          _caratOptions[range.start.toInt()],
                          _caratOptions[range.end.toInt()],
                        );
                      },
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
                      fem: fem,
                      items: _diamondItems,
                      selected: filter.selectedShape,
                      onSelected: notifier.toggleShape,
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
                      selected: filter.selectedMetal,
                      onSelected: notifier.toggleMetal,
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
                      selectedSet: filter.selectedGender,
                      fem: fem,
                      groupName: "Gender",
                      onTapItem: notifier.toggleGender,
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
                      selectedSet: filter.selectedOccasions,
                      fem: fem,
                      groupName: "Occasion",
                      onTapItem: notifier.toggleOccasion,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
