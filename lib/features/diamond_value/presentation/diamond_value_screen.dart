import 'dart:async';

import 'package:divine_pos/features/diamond_value/data/diamond_config_normalizer.dart';
import 'package:divine_pos/features/diamond_value/domain/diamond_rule_engine.dart';
import 'package:divine_pos/features/diamond_value/provider/diamond_price_provider.dart';
import 'package:divine_pos/shared/app_bar.dart';
import 'package:divine_pos/shared/utils/enums.dart';
import 'package:divine_pos/shared/utils/scale_size.dart';
import 'package:divine_pos/shared/widgets/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../presentation/widgets/shape_selector.dart';
import '../presentation/widgets/diamond_display.dart';
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

  late final TextEditingController _caratController;
  String? _caratError;

  @override
  void initState() {
    super.initState();
    _caratController = TextEditingController(
      text: _config.caratDouble.toStringAsFixed(2),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchPrice(_config));
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _caratController.dispose();
    super.dispose();
  }

  // -------------------------------------------------------------------------
  // fetchPrice — debounced 400ms so rapid changes don't spam the API
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
          setState(() {
            _price = price;
            _totalPrice = price * config.caratDouble;
          });
        }
      } catch (e) {
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
  void _onShapeChanged(DiamondShape shape) {
    final newConfig = _config.copyWith(shape: shape, caratIndex: 4);
    final normalized = normalizeConfig(_config, newConfig, _ruleEngine);

    // Reset carat field to the new default
    _caratController.text = normalized.caratDouble.toStringAsFixed(2);
    setState(() => _caratError = null);

    _updateConfig(normalized);
  }

  void _onYellowShapeChanged(String yellowShape) {
    final newConfig = _config.copyWith(yellowShape: yellowShape, caratIndex: 4);

    _caratController.text = newConfig.caratDouble.toStringAsFixed(2);
    setState(() => _caratError = null);

    _updateConfig(newConfig);
  }

  // -------------------------------------------------------------------------
  // Carat validation helpers
  // -------------------------------------------------------------------------
  ({double min, double max}) _caratBounds() {
    final isRound = _config.shape == DiamondShape.round;

    if (_config.shapeType == ShapeType.regular) {
      return isRound ? (min: 0.10, max: 2.99) : (min: 0.10, max: 1.23);
    } else if (solusShapes.contains(_config.yellowShape)) {
      return (min: 0.18, max: 1.50);
    }

    return (min: 0.10, max: 2.99); // fallback
  }

  String _caratValidationMessage() {
    final b = _caratBounds();
    return 'Enter a value between ${b.min.toStringAsFixed(2)} and ${b.max.toStringAsFixed(2)}';
  }

  // -------------------------------------------------------------------------
  // Carat change — text field, accepts 0.10 to 10.00
  // -------------------------------------------------------------------------
  void _onCaratChanged(String raw) {
    final value = double.tryParse(raw);
    final bounds = _caratBounds();

    if (value == null || value < bounds.min || value > bounds.max) {
      setState(() => _caratError = _caratValidationMessage());
      return;
    }

    setState(() => _caratError = null);

    // Clamp to bounds before snapping to nearest caratSteps index
    final clamped = value.clamp(bounds.min, bounds.max);

    int closest = 0;
    double minDiff = double.infinity;
    for (int i = 0; i < caratSteps.length; i++) {
      final stepVal = double.tryParse(caratSteps[i]) ?? 0;
      final diff = (stepVal - clamped).abs();
      if (diff < minDiff) {
        minDiff = diff;
        closest = i;
      }
    }

    final newConfig = _config.copyWith(caratIndex: closest);
    final normalized = normalizeConfig(_config, newConfig, _ruleEngine);
    _updateConfig(normalized);
  }

  // -------------------------------------------------------------------------
  // Color change
  // -------------------------------------------------------------------------
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
    final fem = ScaleSize.aspectRatio;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: MyAppBar(appBarLeading: AppBarLeading.back, showLogo: false),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    12 * fem,
                    28 * fem,
                    8 * fem,
                    0 * fem,
                  ),
                  child: Column(
                    children: [
                      _buildTitle(fem: fem),
                      SizedBox(height: 28 * fem),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 5,
                            child: DiamondDisplay(config: _config),
                          ),
                          SizedBox(width: 28 * fem),
                          Expanded(flex: 7, child: _buildControls(fem: fem)),
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
              totalPrice: _totalPrice,
              isLoading: _loadingPrice,
              onCompare: _showPriceChart,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle({required double fem}) {
    return Column(
      children: [
        MyText(
          'Know Your Diamond Value',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontFamily: 'Rushter Glory',
            fontWeight: FontWeight.w400,
            height: 1.67,
            letterSpacing: 1.20,
          ),
        ),
        SizedBox(height: 6 * fem),
        MyText(
          "Know Your Divine Diamond's Value – Select Shape, Carat, Color & Clarity To Get The Price.",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: const Color(0xFF303030),
            fontSize: 15,
            //fontFamily: 'Montserrat',
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildControls({required double fem}) {
    return Column(
      children: [
        _ControlCard(
          label: 'Shape',
          fem: fem,
          child: ShapeSelector(
            config: _config,
            onShapeChanged: _onShapeChanged,
            onYellowShapeChanged: _onYellowShapeChanged,
          ),
        ),
        SizedBox(height: 12 * fem),
        _ControlCard(
          label: 'Carat',
          fem: fem,
          child: TextField(
            controller: _caratController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 14 * fem,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2A2A2A),
            ),
            decoration: InputDecoration(
              hintText: '0.10 – 2.99',
              hintStyle: TextStyle(
                color: const Color(0xFFAAAAAA),
                fontSize: 14 * fem,
                fontFamily: 'Montserrat',
              ),
              suffixText: 'ct',
              suffixStyle: TextStyle(
                color: const Color(0xFF2A2A2A),
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
                fontSize: 14 * fem,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12 * fem,
                vertical: 10 * fem,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: _caratError != null
                      ? Colors.red
                      : const Color(0xFFE4E4E0),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: _caratError != null
                      ? Colors.red
                      : const Color(0xFF2A2A2A),
                  width: 1.5,
                ),
              ),
              errorText: _caratError,
              errorStyle: TextStyle(
                fontSize: 11 * fem,
                fontFamily: 'Montserrat',
              ),
            ),
            onChanged: _onCaratChanged,
          ),
        ),
        SizedBox(height: 12 * fem),
        _ControlCard(
          label: 'Color',
          fem: fem,
          child: ColorSliderWidget(
            values: _config.colorOptions,
            index: _config.colorIndex.clamp(0, _config.colorOptions.length - 1),
            onChanged: _onColorChanged,
          ),
        ),
        SizedBox(height: 12 * fem),
        _ControlCard(
          label: 'Clarity',
          fem: fem,
          child: ClaritySlider(
            values: _config.clarityOptions,
            index: _config.clarityIndex.clamp(
              0,
              _config.clarityOptions.length - 1,
            ),
            onChanged: _onClarityChanged,
          ),
        ),
      ],
    );
  }
}

class _ControlCard extends StatelessWidget {
  final String label;
  final Widget child;
  final double fem;

  const _ControlCard({
    required this.label,
    required this.child,
    required this.fem,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE4E4E0)),
      ),
      padding: EdgeInsets.fromLTRB(16 * fem, 14 * fem, 16 * fem, 16 * fem),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyText(
            label,
            style: TextStyle(
              fontFamily: 'Georgia',
              fontSize: 16 * fem,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF2A2A2A),
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
