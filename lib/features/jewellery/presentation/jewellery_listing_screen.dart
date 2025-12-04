import 'package:flutter/material.dart';
import 'top_buttons_row.dart';
import 'filter_sidebar.dart';
// import '../widgets/filter_tags_row.dart';
// import '../widgets/product_grid.dart';

class JewelleryListingScreen extends StatelessWidget {
  const JewelleryListingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // top button row
            TopButtonsRow(
              onTabSelected: (index) {
                switch (index) {
                  case 0:
                    // Products In Store clicked
                    print("Products In Store clicked");
                    break;
                  case 1:
                    // Products At Other Branches clicked
                    print("Products At Other Branches clicked");
                    break;
                  case 2:
                    // All Designs clicked
                    print("All Designs clicked");
                    break;
                  case 3:
                    // Sort by clicked
                    print("Sort by clicked");
                    break;
                }
              },
            ),

            Expanded(
              child: Row(
                children: [
                  const FilterSidebar(), // left panel
                  Expanded(
                    // right panel placeholder
                    child: Container(color: Colors.white),
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
