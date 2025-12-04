import 'package:flutter/material.dart';
import '../shared/utils/scale_size.dart';
import '../shared/themes.dart';
import 'package:go_router/go_router.dart';
//import '../features/jewellery/jewellery_listing_screen.dart';

class SideMenu extends StatelessWidget {
  final VoidCallback onClose;
  final VoidCallback onLogout;

  const SideMenu({super.key, required this.onClose, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: 0.82,
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F8F7),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.18),
                    blurRadius: 22,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _Header(onClose: onClose),
                  const Divider(height: 1, color: Color(0xFFE2E6E5)),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Home
                          const _PrimaryItem(
                            icon: Icons.home_outlined,
                            label: 'Home',
                          ),

                          // Jewellery Listing (NO CONST)
                          _PrimaryItem(
                            icon: Icons.diamond_outlined,
                            label: 'Jewellery Listing',
                            onTap: () {
                              onClose();
                              context.go('/jewellery_listing');
                            },
                          ),

                          const _PrimaryItem(
                            icon: Icons.menu_book_outlined,
                            label: 'Catalogue',
                          ),
                          const _PrimaryItem(
                            icon: Icons.star_border,
                            label: 'Feedback Form',
                          ),
                          const _PrimaryItem(
                            icon: Icons.diamond_outlined,
                            label: 'Know Your Diamond Value',
                          ),
                          const _PrimaryItem(
                            icon: Icons.track_changes_outlined,
                            label: 'Verify & Track',
                          ),

                          const SizedBox(height: 12),

                          // Categories Section
                          const _SectionCard(
                            icon: Icons.layers_outlined,
                            title: 'Categories',
                            items: [
                              'Necklaces',
                              'Bangles',
                              'Mangalsutra',
                              'Rings',
                              'Solitaire',
                              'Bracelets',
                              'Earrings',
                            ],
                          ),

                          const SizedBox(height: 12),

                          // Collection Section
                          const _SectionCard(
                            icon: Icons.collections_outlined,
                            title: 'Collection',
                            items: ['Ballerina', 'Souls', 'Setu'],
                          ),

                          const SizedBox(height: 12),
                          const Divider(color: Color(0xFFE2E6E5)),

                          const SizedBox(height: 8),

                          const _PrimaryItem(
                            icon: Icons.shopping_cart_outlined,
                            label: 'Cart',
                          ),
                          const _PrimaryItem(
                            icon: Icons.person_outline,
                            label: 'Account',
                          ),
                        ],
                      ),
                    ),
                  ),

                  _LogoutRow(onLogout: onLogout),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onClose;
  const _Header({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 12),
      child: Row(
        children: [
          IconButton(
            onPressed: onClose,
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.all(8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: const Icon(Icons.close, color: Colors.black87, size: 18),
          ),
        ],
      ),
    );
  }
}

class _PrimaryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _PrimaryItem({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Icon(icon, size: 18, color: Colors.black87),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<String> items;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEFF4F3),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: Colors.black87),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              const Icon(Icons.expand_less, size: 18, color: Colors.black87),
            ],
          ),
          const SizedBox(height: 10),

          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: items.map((text) {
                final bool isFirst = text == items.first;

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: isFirst
                      ? BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: const Color(0xFFCED4D1),
                            width: 1,
                          ),
                        )
                      : null,
                  child: Text(
                    text,
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoutRow extends StatelessWidget {
  final VoidCallback onLogout;
  const _LogoutRow({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onLogout,
      child: Container(
        height: 56.0,
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFFE2E6E5))),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20.0 * ScaleSize.aspectRatio),
        child: Row(
          children: [
            Icon(
              Icons.logout,
              size: 18.0 * ScaleSize.aspectRatio,
              color: Colors.red,
            ),
            const SizedBox(width: 12.0),
            Text(
              'Logout',
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.red,
                fontWeight: FontWeight.w500,
                fontFamily: MyThemes.labelFontFamily,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
