import 'dart:async';

import 'package:divine_pos/features/diamond_value/data/diamond_config_normalizer.dart';
import 'package:divine_pos/features/diamond_value/domain/diamond_rule_engine.dart';
import 'package:divine_pos/features/diamond_value/provider/diamond_price_provider.dart';
import 'package:divine_pos/shared/app_bar.dart';
import 'package:divine_pos/shared/utils/enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../presentation/widgets/shape_selector.dart';
import '../presentation/widgets/diamond_display.dart';
import '../presentation/widgets/carat_range_selector.dart';
import '../presentation/widgets/color_slider.dart';
import '../presentation/widgets/clarity_slider.dart';
import '../presentation/widgets/price_footer.dart';
import '../presentation/widgets/price_chart_modal.dart';
import '../data/diamond_config.dart';

class DiamondValueScreen extends ConsumerStatefulWidget {
  const DiamondValueScreen({super.key});

  @override
  ConsumerState<DiamondValueScreen> createState() => _DiamondValueScreenState();
}

class _DiamondValueScreenState extends ConsumerState<DiamondValueScreen> {
  DiamondConfig _config = DiamondConfig(
    shape: DiamondShape.round,
    yellowShape: 'Radiant',
    shapeType: ShapeType.regular,
    caratIndex: 4, // 0.18
    colorIndex: 0,
    clarityIndex: 0,
  );

  double? _price;
  bool _loadingPrice = false;
  Timer? _debounce;
  final _ruleEngine = DiamondRuleEngine();
  double? _totalPrice;

  @override
  void initState() {
    super.initState();
    // Fetch initial price after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchPrice(_config));
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  // -------------------------------------------------------------------------
  // fetchPrice — debounced 400ms so rapid slider moves don't spam the API
  // -------------------------------------------------------------------------
  void _fetchPrice(DiamondConfig config) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      if (!mounted) return;
      setState(() => _loadingPrice = true);
      try {
        final price = await ref
            .read(diamondPriceRepositoryProvider)
            .fetchPrice(
              itemGroup: 'SOLITAIRE',
              slab: config.caratLabel,
              shape: config.shapeCode,
              color: config.colorLabel,
              quality: config.clarityLabel,
            );
        if (mounted) {
          //setState(() => _price = price);
          setState(() {
            _price = price;
            _totalPrice = price * config.caratDouble;
          });
        }
      } catch (e) {
        // Keep previous price on error; optionally show snackbar
        debugPrint('fetchPrice error: $e');
      } finally {
        if (mounted) setState(() => _loadingPrice = false);
      }
    });
  }

  // -------------------------------------------------------------------------
  // Config update — always triggers a price fetch
  // -------------------------------------------------------------------------
  void _updateConfig(DiamondConfig newConfig) {
    setState(() => _config = newConfig);
    _fetchPrice(newConfig);
  }

  // -------------------------------------------------------------------------
  // Shape change
  // -------------------------------------------------------------------------
  // void _onShapeChanged(DiamondShape shape) {
  //   const resetCaratIndex = 4; // 0.18
  //   const resetCts = 0.18;

  //   final isRound =
  //       shape == DiamondShape.round && _config.shapeType == ShapeType.regular;
  //   final newColorOptions = DiamondConfig.getColorOptions(
  //     caratTo: resetCts,
  //     isRound: isRound,
  //     shapeType: _config.shapeType,
  //   );
  //   final newClarityOptions = DiamondConfig.getClarityOptions(
  //     caratTo: resetCts,
  //     isRound: isRound,
  //     shapeType: _config.shapeType,
  //   );

  //   final currentColor =
  //       _config.colorOptions[_config.colorIndex.clamp(
  //         0,
  //         _config.colorOptions.length - 1,
  //       )];
  //   final currentClarity =
  //       _config.clarityOptions[_config.clarityIndex.clamp(
  //         0,
  //         _config.clarityOptions.length - 1,
  //       )];

  //   _updateConfig(
  //     _config.copyWith(
  //       shape: shape,
  //       caratIndex: resetCaratIndex,
  //       colorIndex: newColorOptions.contains(currentColor)
  //           ? newColorOptions.indexOf(currentColor)
  //           : 0,
  //       clarityIndex: newClarityOptions.contains(currentClarity)
  //           ? newClarityOptions.indexOf(currentClarity)
  //           : 0,
  //     ),
  //   );
  // }

  void _onShapeChanged(DiamondShape shape) {
    final newConfig = _config.copyWith(shape: shape, caratIndex: 4);

    final normalized = normalizeConfig(_config, newConfig, _ruleEngine);

    _updateConfig(normalized);
  }

  void _onYellowShapeChanged(String yellowShape) {
    _updateConfig(_config.copyWith(yellowShape: yellowShape));
  }

  // -------------------------------------------------------------------------
  // Carat change
  // -------------------------------------------------------------------------
  // void _onCaratChanged(String value) {
  //   final i = caratSteps.indexOf(value);
  //   if (i < 0) return;
  //   final newCts = double.parse(value);
  //   final isRound =
  //       _config.shape == DiamondShape.round &&
  //       _config.shapeType == ShapeType.regular;

  //   final newColorOptions = DiamondConfig.getColorOptions(
  //     caratTo: newCts,
  //     isRound: isRound,
  //     shapeType: _config.shapeType,
  //   );
  //   final newClarityOptions = DiamondConfig.getClarityOptions(
  //     caratTo: newCts,
  //     isRound: isRound,
  //     shapeType: _config.shapeType,
  //   );

  //   final currentColor =
  //       _config.colorOptions[_config.colorIndex.clamp(
  //         0,
  //         _config.colorOptions.length - 1,
  //       )];
  //   final currentClarity =
  //       _config.clarityOptions[_config.clarityIndex.clamp(
  //         0,
  //         _config.clarityOptions.length - 1,
  //       )];

  //   _updateConfig(
  //     _config.copyWith(
  //       caratIndex: i,
  //       colorIndex: newColorOptions.contains(currentColor)
  //           ? newColorOptions.indexOf(currentColor)
  //           : 0,
  //       clarityIndex: newClarityOptions.contains(currentClarity)
  //           ? newClarityOptions.indexOf(currentClarity)
  //           : 0,
  //     ),
  //   );
  // }

  void _onCaratChanged(String value) {
    final i = caratSteps.indexOf(value);
    if (i < 0) return;

    final newConfig = _config.copyWith(caratIndex: i);

    final normalized = normalizeConfig(_config, newConfig, _ruleEngine);

    _updateConfig(normalized);
  }

  // -------------------------------------------------------------------------
  // Color change
  // -------------------------------------------------------------------------
  // void _onColorChanged(int newColorIndex) {
  //   final colorList = _config.colorOptions;
  //   final selectedColor =
  //       colorList[newColorIndex.clamp(0, colorList.length - 1)];

  //   ShapeType newShapeType;
  //   if (selectedColor == 'Yellow Vivid') {
  //     newShapeType = ShapeType.vdf;
  //   } else if (selectedColor == 'Yellow Intense') {
  //     newShapeType = ShapeType.iny;
  //   } else {
  //     newShapeType = ShapeType.regular;
  //   }

  //   final newClarityOptions = DiamondConfig.getClarityOptions(
  //     caratTo: _config.caratDouble,
  //     isRound:
  //         _config.shape == DiamondShape.round &&
  //         newShapeType == ShapeType.regular,
  //     shapeType: newShapeType,
  //   );
  //   final currentClarity =
  //       _config.clarityOptions[_config.clarityIndex.clamp(
  //         0,
  //         _config.clarityOptions.length - 1,
  //       )];

  //   _updateConfig(
  //     _config.copyWith(
  //       shapeType: newShapeType,
  //       colorIndex: newColorIndex.clamp(0, colorList.length - 1),
  //       clarityIndex: newClarityOptions.contains(currentClarity)
  //           ? newClarityOptions.indexOf(currentClarity)
  //           : 0,
  //     ),
  //   );
  // }

  void _onColorChanged(int index) {
    final newConfig = _config.copyWith(colorIndex: index);

    final normalized = normalizeConfig(_config, newConfig, _ruleEngine);

    _updateConfig(normalized);
  }

  // -------------------------------------------------------------------------
  // Clarity change
  // -------------------------------------------------------------------------
  void _onClarityChanged(int newClarityIndex) {
    _updateConfig(
      _config.copyWith(
        clarityIndex: newClarityIndex.clamp(
          0,
          _config.clarityOptions.length - 1,
        ),
      ),
    );
  }

  void _showPriceChart() {
    showDialog(
      context: context,
      barrierColor: Colors.black26,
      builder: (_) => PriceChartModal(config: _config, currentPrice: _price),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F5F2),
      appBar: MyAppBar(appBarLeading: AppBarLeading.back, showLogo: false),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(32, 28, 32, 0),
                  child: Column(
                    children: [
                      _buildTitle(),
                      const SizedBox(height: 28),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 5,
                            child: DiamondDisplay(config: _config),
                          ),
                          const SizedBox(width: 28),
                          Expanded(flex: 7, child: _buildControls()),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
            PriceFooter(
              config: _config,
              //price: _price,
              //carats: _config.caratDouble,
              totalPrice: _totalPrice,
              isLoading: _loadingPrice,
              onCompare: _showPriceChart,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        const Text(
          'Know Your Diamond Value',
          style: TextStyle(
            fontFamily: 'Georgia',
            fontSize: 26,
            fontWeight: FontWeight.w400,
            color: Color(0xFF2A2A2A),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "Know Your Divine Diamond's Value – Select Shape, Carat, Color & Clarity To Get The Price.",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[500],
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    );
  }

  Widget _buildControls() {
    return Column(
      children: [
        _ControlCard(
          label: 'Shape',
          child: ShapeSelector(
            config: _config,
            onShapeChanged: _onShapeChanged,
            onYellowShapeChanged: _onYellowShapeChanged,
          ),
        ),
        const SizedBox(height: 12),
        CaratSelector(
          label: 'Carat',
          values: caratSteps,
          initialIndex: _config.caratIndex,
          onChanged: _onCaratChanged,
        ),
        const SizedBox(height: 12),
        ColorSliderWidget(
          values: _config.colorOptions,
          index: _config.colorIndex.clamp(0, _config.colorOptions.length - 1),
          onChanged: _onColorChanged,
        ),
        const SizedBox(height: 12),
        ClaritySlider(
          values: _config.clarityOptions,
          index: _config.clarityIndex.clamp(
            0,
            _config.clarityOptions.length - 1,
          ),
          onChanged: _onClarityChanged,
        ),
      ],
    );
  }
}

class _ControlCard extends StatelessWidget {
  final String label;
  final Widget child;
  const _ControlCard({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE4E4E0)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Georgia',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2A2A2A),
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
