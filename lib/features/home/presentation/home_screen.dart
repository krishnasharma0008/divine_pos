import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/data/auth_notifier.dart';
import '../../../shared/utils/scale_size.dart';
import '../../../shared/app_bar.dart';
import '../../../shared/utils/scale_size.dart';
import '../../../shared/utils/enums.dart';
import '../../../shared/routes/app_drawer.dart';
import '../../../shared/widgets/carat_selector.dart';
import '../../../shared/widgets/carat_range_slider.dart';
import '../data/home_provider.dart';
import '../../../shared/widgets/grade_selecter.dart';
import '../../jewellery_journey/presentation/customize_solitaire.dart';

class HomeScreen extends ConsumerWidget {
  HomeScreen({super.key});

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    String selectedColor = 'D';
    final caratValues = [
      0.10,
      0.14,
      0.18,
      0.23,
      0.30,
      0.39,
      0.45,
      0.50,
      0.70,
      0.80,
      0.90,
      2.00,
    ];

    final caratRange = ref.watch(caratRangeProvider);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: MyAppBar(showLogo: false, appBarLeading: AppBarLeading.drawer),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome ${auth.user?.userName ?? ''}'),
            const SizedBox(height: 20),

            /// ✅ WORKING CARAT SELECTOR
            // CaratSelector(
            //   values: caratValues,
            //   range: caratRange,
            //   onChanged: (r) {
            //     ref.read(caratRangeProvider.notifier).state = r;
            //   },
            // ),
            ColorGradeSelector(
              label: 'Color',
              grades: const ['D', 'E', 'F', 'G', 'H', 'I', 'J'],
              initialValue: selectedColor,
              onSelected: (value) {
                debugPrint('Selected color: $value');
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final result = await showDialog<Map<String, dynamic>>(
                  context: context,
                  barrierDismissible: true,
                  builder: (_) => const CustomizeSolitaire(),
                );

                if (result != null) {
                  final priceStart = result['price']['start'] as String;
                  final priceEnd = result['price']['end'] as String;
                  final caratStart = result['carat']['start'] as String;
                  final caratEnd = result['carat']['end'] as String;
                  final colorStart = result['color']['start'] as String;
                  final colorEnd = result['color']['end'] as String;
                  final clarityStart = result['clarity']['start'] as String;
                  final clarityEnd = result['clarity']['end'] as String;

                  debugPrint(
                    '✅ Applied Filters:\n'
                    '💎 Price: ₹$priceStart - ₹$priceEnd\n'
                    '💍 Carat: $caratStart - $caratEnd\n'
                    '🎨 Color: $colorStart - $colorEnd\n'
                    '✨ Clarity: $clarityStart - $clarityEnd',
                  );

                  // ✅ Safe snackbar (works in ConsumerWidget)
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Applied: $caratStart-$caratEnd carat'),
                        backgroundColor: const Color(0xFF90DCD0),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              },
              child: const Text('Customize Solitaire'),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () => context.go('/profile'),
              child: const Text('Go to Profile Screen'),
            ),
          ],
        ),
      ),
    );
  }
}
