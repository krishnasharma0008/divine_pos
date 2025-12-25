import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/app_bar.dart';
import '../../../shared/themes.dart';
import '../../../shared/widgets/text.dart';
import '../../../shared/utils/enums.dart';
import '../../auth/data/auth_notifier.dart';
import '../../jewellery/data/listing_provider.dart';
import '../../jewellery/data/store_details.dart';

class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  bool isStoreApiCalled = false;

  @override
  void initState() {
    super.initState();

    /// Call API once
    Future.microtask(() {
      final authRepo = ref.read(authProvider);
      final pjcode = authRepo.user?.pjcode;

      if (pjcode != null && !isStoreApiCalled) {
        ref.read(StoreProvider.notifier).getPJStore(pjcode: pjcode);
        isStoreApiCalled = true;
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final storeState = ref.watch(StoreProvider);
    final store = storeState.selectedStore;

    if (storeState.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (storeState.selectedStore == null) {
      return const Scaffold(body: Center(child: Text('Store not found')));
    }

    // main branch (or first as fallback)
    final mainBranch = storeState.stores.firstWhere(
      (s) => s.locationType.toUpperCase() == 'MAIN BRANCH',
      orElse: () => storeState.stores.first,
    );

    // all other branches
    final subBranches = storeState.stores
        .where((s) => s != mainBranch)
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: MyAppBar(showLogo: false, appBarLeading: AppBarLeading.back),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            //child: _StoreCard(store: mainBranch),
            child: _StoreCard(store: mainBranch, subBranches: subBranches),
          ),
        ),
      ),
    );
  }
}

class _StoreCard extends StatelessWidget {
  final StoreDetail store;
  final List<StoreDetail> subBranches;

  const _StoreCard({required this.store, required this.subBranches});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      decoration: BoxDecoration(
        color: MyThemes.White,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: MyThemes.Black.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _StoreHeader(store: store),
          SizedBox(height: 24),
          _JewellerContact(store: store),
          SizedBox(height: 16),
          _SectionDivider(),
          SizedBox(height: 12),
          SectionTitle(
            icon: Icons.person_outline,
            title: 'Customer Service Executive',
            suffix: '(DIVINE SOLITAIRES MEMBER)',
          ),

          SizedBox(height: 12),
          _InfoField(label: 'Name', value: 'Rajesh Kumar'),
          SizedBox(height: 8),
          _InfoField(label: 'Mobile', value: '+91 98765 43210'),
          SizedBox(height: 24),
          _SectionDivider(),
          SizedBox(height: 12),
          SectionTitle(icon: Icons.store_outlined, title: 'Sub Branches'),
          SizedBox(height: 12),
          if (subBranches.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: subBranches
                  .map(
                    (branch) => BranchTile(
                      title: branch.name,
                      address: branch.address, // adapt to your field names
                    ),
                  )
                  .toList(),
            ),
          // BranchTile(
          //   title: 'KHIMJI - SOAUBHAGYA NAGAR',
          //   address: '123 Main Street',
          // ),

          // BranchTile(
          //   title: 'KHIMJI - SAMANTARAPUR',
          //   address: '456 West Avenue',
          // ),

          // BranchTile(title: 'KHIMJI - PURI', address: '789 East Boulevard'),
        ],
      ),
    );
  }
}

class _StoreHeader extends StatelessWidget {
  final StoreDetail store;
  const _StoreHeader({required this.store});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: MyThemes.Light_Mint,
          child: Icon(Icons.store, size: 26, color: MyThemes.Deep_Teal),
        ),
        SizedBox(height: 12),
        MyText(
          store.name,
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 16,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.4,
            color: Color(0xFF697282),
            height: 1.5,
          ),
        ),
        SizedBox(height: 4),
        MyText(
          store.locationType,
          style: TextStyle(
            fontFamily: MyThemes.labelFontFamily,
            fontSize: 13,
            color: MyThemes.Muted_grey,
          ),
        ),
      ],
    );
  }
}

class _JewellerContact extends StatelessWidget {
  final StoreDetail store;
  const _JewellerContact({required this.store});

  @override
  Widget build(BuildContext context) {
    return Container(
      // width will stretch inside parent, no fixed 624
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0x33BEE4DD), // same mint with opacity
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // circular icon
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Color(0xFFBEE4DD),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.call, size: 20, color: Color(0xFF1D2838)),
          ),
          const SizedBox(width: 16),
          // texts
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText(
                  'Jeweller Contact',
                  style: TextStyle(
                    color: Color(0xFF697282),
                    fontSize: 16,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 2),
                MyText(
                  store.contactNo?.isNotEmpty == true
                      ? store.contactNo!
                      : 'N/A',
                  style: TextStyle(
                    color: Color(0xFF1D2838),
                    fontSize: 16,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      color: MyThemes.Light_Mint.withOpacity(0.5),
      height: 1,
      thickness: 1,
    );
  }
}

class SectionTitle extends StatelessWidget {
  final IconData? icon;
  final String title;
  final String? suffix; // e.g. "(DIVINE SOLITAIRES MEMBER)"

  const SectionTitle({super.key, this.icon, required this.title, this.suffix});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18, color: const Color(0xFF354152)),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: MyText(
            suffix == null ? title : '$title $suffix',
            style: const TextStyle(
              color: Color(0xFF354152),
              fontSize: 16,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _InfoField extends StatelessWidget {
  final String label;
  final String value;

  const _InfoField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          MyText(
            label,
            style: const TextStyle(
              fontFamily: MyThemes.labelFontFamily,
              fontSize: 13,
              color: MyThemes.Muted_grey,
            ),
          ),
          MyText(
            value,
            style: const TextStyle(
              fontFamily: MyThemes.inputFontFamily,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: MyThemes.fontColor,
            ),
          ),
        ],
      ),
    );
  }
}

class BranchTile extends StatelessWidget {
  final String title;
  final String address;

  const BranchTile({super.key, required this.title, required this.address});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: const Color(0x19BEE4DD), // same as Figma
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0x4CBEE4DD), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyText(
            title.toUpperCase(),
            style: const TextStyle(
              color: Color(0xFF1D2838),
              fontSize: 16,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          MyText(
            address,
            style: const TextStyle(
              color: Color(0xFF495565),
              fontSize: 16,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
