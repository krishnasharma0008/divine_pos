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
import '../data/jewellery_listing_constant.dart';

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

  //final _diamondItems = [];

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

    final bool isSolitaire = filter.selectedCategory.any(
      (c) => c.trim().toLowerCase() == 'solitaires',
    );

    // const String kDefaultCaratStart = '0.10';
    // const String kDefaultCaratEnd = '2.99';

    // final int defaultStartIndex = caratOptions.indexOf(kDefaultCaratStart);
    // final int defaultEndIndex = caratOptions.indexOf(kDefaultCaratEnd);

    // final int startIndex = filter.caratStartLabel != null
    //     ? caratOptions.indexOf(filter.caratStartLabel!)
    //     : defaultStartIndex;

    // final int endIndex = filter.caratEndLabel != null
    //     ? caratOptions.indexOf(filter.caratEndLabel!)
    //     : defaultEndIndex;

    // ───────── CARAT INDICES ─────────
    const String kDefaultCaratStart = '0.10';
    const String kDefaultCaratEnd = '2.99';

    final int caratDefaultStart = caratOptions.indexOf(kDefaultCaratStart);
    final int caratDefaultEnd = caratOptions.indexOf(kDefaultCaratEnd);

    final int caratStartIndex = filter.caratStartLabel != null
        ? caratOptions.indexOf(filter.caratStartLabel!)
        : caratDefaultStart;

    final int caratEndIndex = filter.caratEndLabel != null
        ? caratOptions.indexOf(filter.caratEndLabel!)
        : caratDefaultEnd;

    // ───────── COLOR INDICES ─────────
    const String kDefaultColorStart = 'D';
    const String kDefaultColorEnd = 'J';

    final int colorDefaultStart = Coloroption.indexOf(kDefaultColorStart);
    final int colorDefaultEnd = Coloroption.indexOf(kDefaultColorEnd);

    final int colorStartIndex = filter.colorStartLabel != null
        ? Coloroption.indexOf(filter.colorStartLabel!)
        : colorDefaultStart;

    final int colorEndIndex = filter.colorEndLabel != null
        ? Coloroption.indexOf(filter.colorEndLabel!)
        : colorDefaultEnd;

    // ───────── CLARITY INDICES ───────
    const String kDefaultClarityStart = 'IF';
    const String kDefaultClarityEnd = 'SI2';

    final int clarityDefaultStart = Clarityoption.indexOf(kDefaultClarityStart);
    final int clarityDefaultEnd = Clarityoption.indexOf(kDefaultClarityEnd);

    final int clarityStartIndex = filter.clarityStartLabel != null
        ? Clarityoption.indexOf(filter.clarityStartLabel!)
        : clarityDefaultStart;

    final int clarityEndIndex = filter.clarityEndLabel != null
        ? Clarityoption.indexOf(filter.clarityEndLabel!)
        : clarityDefaultEnd;

    final TextEditingController uidController = TextEditingController();
    final FocusNode uidFocusNode = FocusNode();

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
                  //-----------------------------------------------------
                  // SEarch By Item Number
                  //-----------------------------------------------------
                  if (!isSolitaire) ...[
                    // ───── UID SEARCH ─────

                    // SEARCH BOX LIKE IMAGE
                    Padding(
                      padding: EdgeInsets.only(top: 8 * fem, bottom: 12 * fem),
                      child: Container(
                        height: 44 * fem,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8 * fem),
                          border: Border.all(
                            color: const Color(0xFF90DCD0),
                          ), // outline color
                        ),
                        child: Row(
                          children: [
                            // text input with icon
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(left: 12 * fem),
                                child: TextField(
                                  controller: uidController,
                                  focusNode: uidFocusNode,
                                  style: TextStyle(
                                    fontSize: 16 * fem, // ← input text size
                                  ),
                                  decoration: InputDecoration(
                                    isDense: true,
                                    border: InputBorder.none,
                                    hintText: 'Search Design no.',
                                    hintStyle: TextStyle(
                                      fontSize: 16 * fem,
                                      color: Colors
                                          .grey, // ← change this to any Color
                                    ),
                                  ),
                                  textInputAction: TextInputAction.search,
                                  onEditingComplete: () {
                                    final value = uidController.text.trim();
                                    if (value.isEmpty) return;
                                    debugPrint('Search Design No. : $value');
                                    // notifier.searchByUid(value);
                                    uidFocusNode.unfocus();
                                    notifier.setItemno(value);
                                  },
                                ),
                              ),
                            ),

                            // vertical divider between field and button
                            Container(width: 1, color: const Color(0xFF90DCD0)),

                            // right "Search" button part
                            InkWell(
                              onTap: () {
                                final value = uidController.text.trim();
                                if (value.isEmpty) return;
                                debugPrint('Search UID: $value');
                                // notifier.searchByUid(value);
                                uidFocusNode.unfocus();
                              },
                              child: Container(
                                width: 90 * fem,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Color(
                                    0xFF90DCD0,
                                  ), // your teal / kMint alternative
                                  borderRadius: BorderRadius.horizontal(
                                    right: Radius.circular(8 * fem),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.search,
                                  color: Colors.white,
                                  size: 22,
                                ),
                                // child: MyText(
                                //   'Search',
                                //   style: TextStyle(
                                //     color: Colors.white,
                                //     fontWeight: FontWeight.w500,
                                //   ),
                                //),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  Divider(
                    height: 1,
                    color: Colors.black.withValues(alpha: 0.08),
                  ),

                  //------------------------------------------------------
                  // PRICE RANGE
                  //------------------------------------------------------
                  if (!isSolitaire) ...[
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
                            const RangeValues(
                              10000,
                              1000000,
                            ), // UI default ONLY
                        onChanged: (v) {
                          notifier.setPrice(v); // state set ONLY on interaction
                        },
                        //onChanged: notifier.setPrice,
                      ),
                    ),
                  ],
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
                      items: !isSolitaire
                          ? jewellerydiamondShape
                          : SolotaireShape,
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
                      options: caratOptions,
                      // initialStartIndex: caratOptions.indexOf(
                      //   filter.caratStartLabel,
                      // ),
                      // initialEndIndex: _caratOptions.indexOf(
                      //   filter.caratEndLabel,
                      // ),
                      initialStartIndex: caratStartIndex,
                      initialEndIndex: caratEndIndex,
                      showlabels: false,
                      onChanged: (range) {
                        notifier.setCaratRange(
                          caratOptions[range.start.toInt()],
                          caratOptions[range.end.toInt()],
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
                  if (!isSolitaire) ...[
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
                    divider(fem),
                  ],
                  //------------------------------------------------------
                  // SUB CATEGORY
                  //------------------------------------------------------

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
                  if (!isSolitaire) ...[
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
                    divider(fem),
                  ],
                  //------------------------------------------------------
                  // METAL Purity
                  //------------------------------------------------------

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
                  if (!isSolitaire) ...[
                    FilterSection(
                      title: 'Metal Purity',
                      fem: fem,
                      child: twoColumnGrid(
                        items: metalPurity.map((e) => e['label']!).toList(),
                        isCorrectLabel: false,
                        selectedSet: filter.selectedMetalPurity,
                        fem: fem,
                        groupName: "Metal Purity",
                        onTapItem: notifier.toggleMetalPurity,
                      ),
                    ),
                    divider(fem),
                  ],
                  //------------------------------------------------------
                  // METAL
                  //------------------------------------------------------
                  //------------------------------------------------------

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
                  if (!isSolitaire) ...[
                    FilterSection(
                      title: 'Metal Color',
                      fem: fem,
                      child: twoColumnGrid(
                        items: metalColor.map((e) => e['label']!).toList(),
                        selectedSet: filter.selectedMetalColor,
                        fem: fem,
                        groupName: "Metal Color",
                        onTapItem: notifier.toggleMetalColor,
                      ),
                    ),
                  ],
                  //------------------------------------------------------
                  // GENDER
                  //------------------------------------------------------
                  if (!isSolitaire) ...[
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
                  ],
                  //------------------------------------------------------
                  // OCCASION
                  //------------------------------------------------------
                  if (!isSolitaire) ...[
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

                  if (isSolitaire) ...[
                    divider(fem),

                    FilterSection(
                      title: 'Color',
                      fem: fem,
                      child: DiscreteRangeSlider(
                        title: '',
                        options: Coloroption,
                        initialStartIndex: colorStartIndex,
                        initialEndIndex: colorEndIndex,
                        showlabels: true,
                        onChanged: (range) {
                          notifier.setColorRange(
                            Coloroption[range.start.toInt()],
                            Coloroption[range.end.toInt()],
                          );
                        },
                      ),
                    ),

                    divider(fem),
                    FilterSection(
                      title: 'Clarity',
                      fem: fem,
                      child: DiscreteRangeSlider(
                        title: '',
                        options: Clarityoption,
                        initialStartIndex: clarityStartIndex,
                        initialEndIndex: clarityEndIndex,
                        showlabels: true,
                        onChanged: (range) {
                          notifier.setClarityRange(
                            Clarityoption[range.start.toInt()],
                            Clarityoption[range.end.toInt()],
                          );
                        },
                      ),
                    ),
                  ],
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
