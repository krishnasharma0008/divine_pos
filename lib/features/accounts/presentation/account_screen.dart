import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/app_bar.dart';
import '../../../shared/routes/app_drawer.dart';
import '../../../shared/utils/enums.dart';
import '../../../shared/themes.dart';
import '../../../shared/widgets/text.dart';
import '../../auth/data/auth_notifier.dart';
import '../../jewellery/data/listing_provider.dart';
import '../../jewellery/data/store_details.dart';
import '../../../shared/utils/scale_size.dart';

class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  bool _isStoreApiCalled = false;

  @override
  void initState() {
    super.initState();

    /// Call API once
    Future.microtask(() {
      final authRepo = ref.read(authProvider);
      final pjcode = authRepo.user?.pjcode;

      if (pjcode != null && !_isStoreApiCalled) {
        ref.read(StoreProvider.notifier).getPJStore(pjcode: pjcode);
        _isStoreApiCalled = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final storeState = ref.watch(StoreProvider);

    final fem = ScaleSize.aspectRatio;

    // if (storeState.isLoading) {
    //   return const Scaffold(body: Center(child: CircularProgressIndicator()));
    // }

    // if (storeState.stores.isEmpty) {
    //   return const Scaffold(body: Center(child: Text('Store not found')));
    // }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: MyAppBar(
        appBarLeading: AppBarLeading.back,
        showLogo: false,
        // actions: [
        //   AppBarActionConfig(type: AppBarAction.search, onTap: () {}),
        //   AppBarActionConfig(
        //     type: AppBarAction.notification,
        //     badgeCount: 1,
        //     onTap: () => context.push('/notifications'),
        //   ),
        //   AppBarActionConfig(
        //     type: AppBarAction.profile,
        //     onTap: () => context.push('/profile'),
        //   ),
        //   AppBarActionConfig(
        //     type: AppBarAction.cart,
        //     badgeCount: 2,
        //     onTap: () => context.push('/cart'),
        //   ),
        // ],
      ),
      //drawer: const SideDrawer(),
      body: storeState.isLoading
          ? Center(child: CircularProgressIndicator())
          : storeState.stores.isEmpty
          ? Center(
              child: MyText(
                'Store not found',
                style: TextStyle(fontSize: 20 * fem),
              ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(16 * fem),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 640 * fem),
                  //child: _StoreCard(store: mainBranch, subBranches: subBranches),
                  child: _StoreCard(stores: storeState.stores, fem: fem),
                ),
              ),
            ),
    );
  }
}

class _StoreCard extends StatelessWidget {
  // final StoreDetail store;
  // final List<StoreDetail> subBranches;

  // const _StoreCard({required this.store, required this.subBranches});
  final double fem;

  final List<StoreDetail> stores;
  _StoreCard({required this.stores, required this.fem}) {
    store = stores.firstWhere(
      (s) => s.locationType.toUpperCase() == 'MAIN BRANCH',
    );

    subBranches = stores.where((s) {
      return s.locationType.toUpperCase() == 'OUTLET' &&
          s.pCustomerCode == store.code;
    }).toList();
  }

  late final StoreDetail store;
  late final List<StoreDetail> subBranches;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(24 * fem, 32 * fem, 24 * fem, 24 * fem),
      decoration: BoxDecoration(
        color: MyThemes.White,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: MyThemes.Black.withValues(alpha: 0.08),
            blurRadius: 24 * fem,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _StoreHeader(store: store, fem: fem),
          SizedBox(height: 24 * fem),
          _JewellerContact(store: store, fem: fem),
          SizedBox(height: 16 * fem),
          const _SectionDivider(),
          SizedBox(height: 12 * fem),
          SectionTitle(
            icon: Icons.person_outline,
            title: 'Customer Service Executive',
            suffix: '(DIVINE SOLITAIRES MEMBER)',
            fem: fem,
          ),
          SizedBox(height: 12 * fem),
          _InfoField(
            label: 'Name',
            value: store.salesPerson ?? 'N/A',
            fem: fem,
          ),
          SizedBox(height: 8 * fem),
          _InfoField(label: 'Mobile', value: 'N/A', fem: fem),
          SizedBox(height: 24 * fem),
          const _SectionDivider(),
          SizedBox(height: 12 * fem),
          SectionTitle(
            icon: Icons.store_outlined,
            title: 'Sub Branches',
            fem: fem,
          ),
          SizedBox(height: 12 * fem),
          if (subBranches.isNotEmpty)
            Column(
              children: subBranches.map((branch) {
                return BranchTile(
                  title: branch.nickName ?? branch.name,
                  address: branch.address ?? 'Address not available',
                  fem: fem,
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}

class _StoreHeader extends StatelessWidget {
  final StoreDetail store;
  final double fem;
  const _StoreHeader({required this.store, required this.fem});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 28 * fem,
          backgroundColor: MyThemes.Light_Mint,
          child: Icon(Icons.store, size: 26 * fem, color: MyThemes.Deep_Teal),
        ),
        SizedBox(height: 12 * fem),
        MyText(
          store.name,
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 16 * fem,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.4,
            color: Color(0xFF697282),
            height: 1.5,
          ),
        ),
        SizedBox(height: 4 * fem),
        MyText(
          store.locationType ?? '',
          style: TextStyle(
            fontFamily: MyThemes.labelFontFamily,
            fontSize: 13 * fem,
            color: MyThemes.Muted_grey,
          ),
        ),
      ],
    );
  }
}

class _JewellerContact extends StatelessWidget {
  final StoreDetail store;
  final double fem;
  const _JewellerContact({required this.store, required this.fem});

  @override
  Widget build(BuildContext context) {
    final contact = (store.contactNo?.isNotEmpty == true)
        ? store.contactNo!
        : 'N/A';

    return Container(
      height: 64 * fem,
      padding: EdgeInsets.symmetric(horizontal: 16 * fem),
      decoration: BoxDecoration(
        color: const Color(0x33BEE4DD),
        borderRadius: BorderRadius.circular(10 * fem),
      ),
      child: Row(
        children: [
          Container(
            width: 44 * fem,
            height: 44 * fem,
            decoration: const BoxDecoration(
              color: Color(0xFFBEE4DD),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.call, size: 20 * fem, color: Color(0xFF1D2838)),
          ),
          SizedBox(width: 16 * fem),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText(
                  'Jeweller Contact',
                  style: TextStyle(
                    color: Color(0xFF697282),
                    fontSize: 16 * fem,
                    fontFamily: 'Montserrat',
                  ),
                ),
                MyText(
                  contact,
                  style: TextStyle(
                    color: Color(0xFF1D2838),
                    fontSize: 16 * fem,
                    fontFamily: 'Montserrat',
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
    return Divider(color: MyThemes.Light_Mint.withOpacity(0.5), thickness: 1);
  }
}

class SectionTitle extends StatelessWidget {
  final IconData? icon;
  final String title;
  final String? suffix;
  final double fem;

  const SectionTitle({
    super.key,
    this.icon,
    required this.title,
    this.suffix,
    required this.fem,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18 * fem, color: const Color(0xFF354152)),
          SizedBox(width: 8 * fem),
        ],
        Expanded(
          child: MyText(
            suffix == null ? title : '$title $suffix',
            style: TextStyle(
              color: Color(0xFF354152),
              fontSize: 16 * fem,
              fontFamily: 'Montserrat',
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
  final double fem;
  const _InfoField({
    required this.label,
    required this.value,
    required this.fem,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12 * fem, vertical: 10 * fem),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          MyText(
            label,
            style: TextStyle(
              fontFamily: MyThemes.labelFontFamily,
              fontSize: 13 * fem,
              color: MyThemes.Muted_grey,
            ),
          ),
          MyText(
            value,
            style: TextStyle(
              fontFamily: MyThemes.inputFontFamily,
              fontSize: 13 * fem,
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
  final double fem;
  const BranchTile({
    super.key,
    required this.title,
    required this.address,
    required this.fem,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8 * fem),
      padding: EdgeInsets.fromLTRB(16 * fem, 16 * fem, 16 * fem, 12 * fem),
      decoration: BoxDecoration(
        color: const Color(0x19BEE4DD),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0x4CBEE4DD)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyText(
            title.toUpperCase(),
            style: TextStyle(
              color: Color(0xFF1D2838),
              fontSize: 16 * fem,
              fontFamily: 'Montserrat',
            ),
          ),
          SizedBox(height: 4 * fem),
          MyText(
            address,
            style: TextStyle(
              color: Color(0xFF495565),
              fontSize: 16 * fem,
              fontFamily: 'Montserrat',
            ),
          ),
        ],
      ),
    );
  }
}
