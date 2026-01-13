import 'package:flutter/material.dart';
import '../../../shared/utils/scale_size.dart';
import '../../../shared/widgets/text.dart';
import '../presentation/widget/filter_section.dart';
import '../presentation/widget/filter_pill.dart';
import '../presentation/widget/range_selector.dart';
import '../presentation/widget/diamond_shape_grid.dart';
import '../presentation/widget/discrete_range_filter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/filter_provider.dart';

class FilterSidebar extends ConsumerStatefulWidget {
  final List<String> categories;
  final List<String> subCategories;
  final List<String> collections;

  const FilterSidebar({
    super.key,
    required this.categories,
    required this.subCategories,
    required this.collections,
  });

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
    //print("[$group] → $s");
  }

  final _diamondItems = [
    {
      'code': 'RND',
      'label': 'Round',
      'asset': 'assets/jewellery/filters/round.png',
    },
    {
      'code': 'PRN',
      'label': 'Princess',
      'asset': 'assets/jewellery/filters/princess.png',
    },
    {
      'code': 'OVL',
      'label': 'Oval',
      'asset': 'assets/jewellery/filters/oval.png',
    },
    {
      'code': 'PER',
      'label': 'Pear',
      'asset': 'assets/jewellery/filters/pear.png',
    },
    {
      'code': 'RADQ',
      'label': 'Radiant',
      'asset': 'assets/jewellery/filters/radiant.png',
    },
    {
      'code': 'CUSQ',
      'label': 'Cushion',
      'asset': 'assets/jewellery/filters/fancy_cushion.png',
    },
    {
      'code': 'HRT',
      'label': 'Heart',
      'asset': 'assets/jewellery/filters/heart.png',
    },
  ];

  //carat
  final _caratOptions = [
    '0.10',
    '0.14',
    '0.18',
    '0.25',
    '0.50',
    '0.75',
    '1.00',
    '1.50',
    '2.00',
    '2.50',
    '2.99',
  ];
  // -----------------------------------------------------------
  // Metal
  // -----------------------------------------------------------
  final List<Map<String, String>> _metalPurity = [
    {'label': '10KT'},
    {'label': '14KT'},
    {'label': '18KT'},
    {'label': '22KT'},
    {'label': '950PT'},
  ];

  final List<Map<String, String>> _metalColor = [
    {'label': 'Yellow'},
    {'label': 'White'},
    {'label': 'Rose'},
  ];

  String? selectedMetal;

  Widget twoColumnGrid({
    required List<String> items,
    bool isCorrectLabel = true,
    required Set<String> selectedSet,
    required double fem,
    required String groupName,
    required void Function(String item) onTapItem,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double spacing = fem * 10; // same as before
        // width for 2 items per row inside available width
        final double cellWidth = (constraints.maxWidth - spacing) / 2;

        return Wrap(
          spacing: spacing,
          runSpacing: fem * 10,
          children: items.map((item) {
            return SizedBox(
              width: cellWidth,
              child: FilterPill(
                label: item,
                isCorrectLabel: isCorrectLabel,
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

    const String kDefaultCaratStart = '0.10';
    const String kDefaultCaratEnd = '2.99';

    final int defaultStartIndex = _caratOptions.indexOf(kDefaultCaratStart);
    final int defaultEndIndex = _caratOptions.indexOf(kDefaultCaratEnd);

    final int startIndex = filter.caratStartLabel != null
        ? _caratOptions.indexOf(filter.caratStartLabel!)
        : defaultStartIndex;

    final int endIndex = filter.caratEndLabel != null
        ? _caratOptions.indexOf(filter.caratEndLabel!)
        : defaultEndIndex;

    return Container(
      width: fem * 310,
      padding: EdgeInsets.symmetric(horizontal: fem * 4, vertical: fem * 4),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //------------------------------------------------------
          // FIXED HEADER (NON-SCROLLABLE)
          //------------------------------------------------------
          Padding(
            padding: EdgeInsets.only(top: fem * 5, bottom: fem * 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MyText(
                  'Filters',
                  style: TextStyle(
                    fontSize: fem * 22,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                // Icon(Icons.close, size: 22 * fem),
              ],
            ),
          ),

          Divider(height: 1, color: Colors.black.withValues(alpha: 0.08)),

          //------------------------------------------------------
          // SCROLLABLE FILTER SECTIONS
          //------------------------------------------------------
          Expanded(
            child: SingleChildScrollView(
              //padding: EdgeInsets.only(top: fem * 10),
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
                      //values: filter.selectedPriceRange,
                      values:
                          filter.selectedPriceRange ??
                          const RangeValues(10000, 1000000), // UI default ONLY
                      onChanged: (v) {
                        notifier.setPrice(v); // state set ONLY on interaction
                      },
                      //onChanged: notifier.setPrice,
                    ),
                  ),

                  //------------------------------------------------------
                  // DIAMOND SHAPE
                  //------------------------------------------------------
                  divider(fem),
                  FilterSection(
                    title: 'Diamond Shape',
                    fem: fem,
                    initiallyExpanded: true,
                    child: DiamondShapeGrid(
                      fem: fem,
                      items: _diamondItems,
                      selected: filter.selectedShape, // Set<String> of codes
                      onSelected: notifier.toggleShape, // now passes code
                    ),
                  ),

                  //------------------------------------------------------
                  // CARAT RANGE
                  //------------------------------------------------------
                  divider(fem),

                  FilterSection(
                    title: 'Carat Weight',
                    fem: fem,
                    child: DiscreteRangeSlider(
                      title: '',
                      options: _caratOptions,
                      // initialStartIndex: _caratOptions.indexOf(
                      //   filter.caratStartLabel,
                      // ),
                      // initialEndIndex: _caratOptions.indexOf(
                      //   filter.caratEndLabel,
                      // ),
                      initialStartIndex: startIndex,
                      initialEndIndex: endIndex,
                      onChanged: (range) {
                        notifier.setCaratRange(
                          _caratOptions[range.start.toInt()],
                          _caratOptions[range.end.toInt()],
                        );
                      },
                    ),
                  ),
                  // FilterSection(
                  //   title: 'Carat Weight',
                  //   fem: fem,
                  //   initiallyExpanded: true,
                  //   child: RangeSelector(
                  //     min: startIndex.toDouble(),
                  //     max: endIndex.toDouble(),
                  //     title: '',
                  //     values: RangeValues(
                  //       startIndex.toDouble(),
                  //       endIndex.toDouble(),
                  //     ),
                  //     onChanged: (range) {
                  //       notifier.setCaratRange(
                  //         _caratOptions[range.start.toInt()],
                  //         _caratOptions[range.end.toInt()],
                  //       );
                  //     },
                  //     // values:
                  //     //     filter.selectedPriceRange ??
                  //     //     const RangeValues(10000, 1000000), // UI default ONLY
                  //     // onChanged: (v) {
                  //     //   notifier.setPrice(v); // state set ONLY on interaction
                  //     // },
                  //     //onChanged: notifier.setPrice,
                  //   ),
                  // ),

                  //------------------------------------------------------
                  // CATEGORY
                  //------------------------------------------------------
                  divider(fem),

                  // FilterSection(
                  //   title: 'Category',
                  //   fem: fem,
                  //   child: twoColumnGrid(
                  //     items: [
                  //       'Ring',
                  //       'Earrings',
                  //       'Necklaces',
                  //       'Pendants',
                  //       'Bangles',
                  //       'Solitaire',
                  //       'Bracelets',
                  //       'Mangalsutra',
                  //       'Nosepin',
                  //       'Male Earring',
                  //     ],
                  //     selectedSet: filter.selectedCategory,
                  //     fem: fem,
                  //     groupName: "Category",
                  //     onTapItem: notifier.toggleCategory,
                  //   ),
                  // ),
                  FilterSection(
                    title: 'Category',
                    fem: fem,
                    child: twoColumnGrid(
                      items: widget.categories,
                      selectedSet: filter.selectedCategory,
                      fem: fem,
                      groupName: "Category",
                      onTapItem: notifier.toggleCategory,
                    ),
                  ),

                  //------------------------------------------------------
                  // SUB CATEGORY
                  //------------------------------------------------------
                  divider(fem),

                  // FilterSection(
                  //   title: 'Sub Category',
                  //   fem: fem,
                  //   child: twoColumnGrid(
                  //     items: [
                  //       'Classic Rings',
                  //       'Band Rings',
                  //       'Couple Rings',
                  //       'Daily Wear',
                  //       'Office Wear',
                  //     ],
                  //     selectedSet: filter.selectedSubCategory,
                  //     fem: fem,
                  //     groupName: "Sub Category",
                  //     onTapItem: notifier.toggleSubCategory,
                  //   ),
                  // ),
                  FilterSection(
                    title: 'Sub Category',
                    fem: fem,
                    child: twoColumnGrid(
                      items: widget.subCategories,
                      selectedSet: filter.selectedSubCategory,
                      fem: fem,
                      groupName: "Sub Category",
                      onTapItem: notifier.toggleSubCategory,
                    ),
                  ),

                  //------------------------------------------------------
                  // METAL Purity
                  //------------------------------------------------------
                  divider(fem),
                  // FilterSection(
                  //   title: 'Metal Purity',
                  //   fem: fem,
                  //   child: MetalTypeList(
                  //     fem: fem,
                  //     items: _metalPurity,
                  //     selected: filter.selectedMetalPurity,
                  //     onSelected: notifier.toggleMetalPurity,
                  //   ),
                  // ),
                  FilterSection(
                    title: 'Metal Purity',
                    fem: fem,
                    child: twoColumnGrid(
                      items: _metalPurity.map((e) => e['label']!).toList(),
                      isCorrectLabel: false,
                      selectedSet: filter.selectedMetalPurity,
                      fem: fem,
                      groupName: "Metal Purity",
                      onTapItem: notifier.toggleMetalPurity,
                    ),
                  ),

                  //------------------------------------------------------
                  // METAL
                  //------------------------------------------------------
                  //------------------------------------------------------
                  divider(fem),

                  // FilterSection(
                  //   title: 'Metal Color',
                  //   fem: fem,
                  //   child: MetalTypeList(
                  //     fem: fem,
                  //     items: _metalColor,
                  //     selected: filter.selectedMetalColor,
                  //     onSelected: notifier.toggleMetalColor,
                  //   ),
                  // ),
                  FilterSection(
                    title: 'Metal Color',
                    fem: fem,
                    child: twoColumnGrid(
                      items: _metalColor.map((e) => e['label']!).toList(),
                      selectedSet: filter.selectedMetalColor,
                      fem: fem,
                      groupName: "Metal Color",
                      onTapItem: notifier.toggleMetalColor,
                    ),
                  ),

                  //------------------------------------------------------
                  // GENDER
                  //------------------------------------------------------
                  divider(fem),
                  FilterSection(
                    title: 'Gender',
                    fem: fem,
                    child: twoColumnGrid(
                      items: ['Men', 'Women', 'Children'],
                      selectedSet: filter.selectedGender,
                      fem: fem,
                      groupName: "Gender",
                      onTapItem: notifier.toggleGender,
                    ),
                  ),

                  //------------------------------------------------------
                  // OCCASION
                  //------------------------------------------------------
                  divider(fem),
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

  Divider divider(double fem) {
    return Divider(height: 1, color: Colors.black.withValues(alpha: 0.08));
  }
}
