import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../utils/scale_size.dart';
import '../themes.dart';
import 'drawer_provider.dart';
import 'route_pages.dart';

class SideMenu extends ConsumerWidget {
  final VoidCallback onClose;
  final VoidCallback onLogout;

  const SideMenu({super.key, required this.onClose, required this.onLogout});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final drawerState = ref.watch(drawerProvider);
    final drawerNotifier = ref.read(drawerProvider.notifier);

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
                          _nav(
                            ref,
                            label: "Home",
                            icon: Icons.home_outlined,
                            page: RoutePages.home,
                            context: context,
                            onClose: onClose,
                          ),

                          _nav(
                            ref,
                            label: "Catalogue",
                            icon: Icons.menu_book_outlined,
                            page: RoutePages.catalogue,
                            context: context,
                            onClose: onClose,
                          ),

                          _nav(
                            ref,
                            label: "Feedback Form",
                            icon: Icons.star_border,
                            page: RoutePages.feedback,
                            context: context,
                            onClose: onClose,
                          ),

                          _nav(
                            ref,
                            label: "Know Your Diamond Value",
                            icon: Icons.diamond_outlined,
                            page: RoutePages.knowDiamond,
                            context: context,
                            onClose: onClose,
                          ),

                          _nav(
                            ref,
                            label: "Verify & Track",
                            icon: Icons.track_changes_outlined,
                            page: RoutePages.verifyTrack,
                            context: context,
                            onClose: onClose,
                          ),

                          const SizedBox(height: 12),

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

                          const _SectionCard(
                            icon: Icons.collections_outlined,
                            title: 'Collection',
                            items: ['Ballerina', 'Souls', 'Setu'],
                          ),

                          const SizedBox(height: 12),
                          const Divider(color: Color(0xFFE2E6E5)),
                          const SizedBox(height: 8),

                          _nav(
                            ref,
                            label: "Cart",
                            icon: Icons.shopping_cart_outlined,
                            page: RoutePages.cart,
                            context: context,
                            onClose: onClose,
                          ),

                          _nav(
                            ref,
                            label: "Account",
                            icon: Icons.person_outline,
                            page: RoutePages.account,
                            context: context,
                            onClose: onClose,
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

  /// Central navigation builder (keeps code DRY)
  Widget _nav(
    WidgetRef ref, {
    required String label,
    required IconData icon,
    required RoutePages page,
    required BuildContext context,
    required VoidCallback onClose,
  }) {
    final drawerState = ref.watch(drawerProvider);
    final drawerNotifier = ref.read(drawerProvider.notifier);

    final isActive = drawerState.routePage == page;

    return _PrimaryItem(
      icon: icon,
      label: label,
      isActive: isActive,
      onTap: () {
        drawerNotifier.routePage = page;
        onClose();
        context.go(page.routePath); // 🔥 Enum-driven navigation
      },
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onClose;

  const _Header({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
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
            icon: const Icon(Icons.close, size: 18, color: Colors.black87),
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
  final bool isActive;

  const _PrimaryItem({
    required this.icon,
    required this.label,
    this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? Colors.blue : Colors.black87;
    final weight = isActive ? FontWeight.w600 : FontWeight.w400;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(fontSize: 14, color: color, fontWeight: weight),
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
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
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
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              const Icon(Icons.expand_less, size: 18, color: Colors.black87),
            ],
          ),

          const SizedBox(height: 10),

          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              children: items.map((text) {
                final isFirst = text == items.first;

                return Container(
                  margin: const EdgeInsets.symmetric(
                    vertical: 3,
                    horizontal: 8,
                  ),
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
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      text,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
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
        height: 56,
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFFE2E6E5))),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20.0 * ScaleSize.aspectRatio),
        child: Row(
          children: [
            Icon(
              Icons.logout,
              size: 18 * ScaleSize.aspectRatio,
              color: Colors.red,
            ),
            const SizedBox(width: 12),
            Text(
              'Logout',
              style: TextStyle(
                fontSize: 14,
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
