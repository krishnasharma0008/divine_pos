import 'package:flutter/material.dart';
import 'widgets/shape_selector.dart';
import 'widgets/diamond_display.dart';
import 'widgets/carat_slider.dart';
import 'widgets/color_slider.dart';
import 'widgets/clarity_slider.dart';
import 'widgets/price_footer.dart';
import 'widgets/price_chart_modal.dart';
import '../data/diamond_config.dart';

class DiamondValueScreen extends StatefulWidget {
  const DiamondValueScreen({super.key});

  @override
  State<DiamondValueScreen> createState() => _DiamondValueScreenState();
}

class _DiamondValueScreenState extends State<DiamondValueScreen> {
  DiamondConfig _config = DiamondConfig(
    shape: DiamondShape.round,
    caratIndex: 4,
    colorIndex: 2,
    clarityIndex: 2,
  );

  void _updateConfig(DiamondConfig newConfig) {
    setState(() => _config = newConfig);
  }

  void _showPriceChart() {
    showDialog(
      context: context,
      barrierColor: Colors.black26,
      builder: (_) => PriceChartModal(config: _config),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F5F2),
      body: Column(
        children: [
          // Top mint header bar
          _buildHeader(),

          // Main content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(32, 28, 32, 0),
                    child: Column(
                      children: [
                        // Title
                        _buildTitle(),
                        const SizedBox(height: 28),
                        // Two-column layout
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left: Diamond display
                            Expanded(
                              flex: 5,
                              child: DiamondDisplay(config: _config),
                            ),
                            const SizedBox(width: 28),
                            // Right: Controls
                            Expanded(flex: 7, child: _buildControls()),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Footer price bar
          PriceFooter(config: _config, onCompare: _showPriceChart),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      color: const Color(0xFFB8D8D0),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {},
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SizedBox(height: 2),
                _HamburgerLine(),
                SizedBox(height: 5),
                _HamburgerLine(),
                SizedBox(height: 5),
                _HamburgerLine(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        Text(
          'Know Your Diamond Value',
          style: TextStyle(
            fontFamily: 'Georgia',
            fontSize: 26,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF2A2A2A),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "Know Your Divine Diamond's Value – Select Shape, Carat, Color & Clarity To Get The Price.",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: const Color(0xFF6B6B6B),
            fontWeight: FontWeight.w300,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildControls() {
    return Column(
      children: [
        // Shape
        _ControlCard(
          label: 'Shape',
          child: ShapeSelector(
            selected: _config.shape,
            onChanged: (shape) => _updateConfig(_config.copyWith(shape: shape)),
          ),
        ),
        const SizedBox(height: 12),
        // Carat
        _ControlCard(
          label: 'Carat',
          child: CaratSlider(
            index: _config.caratIndex,
            onChanged: (i) => _updateConfig(_config.copyWith(caratIndex: i)),
          ),
        ),
        const SizedBox(height: 12),
        // Color
        _ControlCard(
          label: 'Color',
          child: ColorSliderWidget(
            index: _config.colorIndex,
            onChanged: (i) => _updateConfig(_config.copyWith(colorIndex: i)),
          ),
        ),
        const SizedBox(height: 12),
        // Clarity
        _ControlCard(
          label: 'Clarity',
          child: ClaritySlider(
            index: _config.clarityIndex,
            onChanged: (i) => _updateConfig(_config.copyWith(clarityIndex: i)),
          ),
        ),
      ],
    );
  }
}

class _HamburgerLine extends StatelessWidget {
  const _HamburgerLine();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 2,
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(2),
      ),
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
        border: Border.all(color: const Color(0xFFE4E4E0), width: 1),
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
