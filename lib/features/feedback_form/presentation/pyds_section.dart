import 'dart:io';

import 'package:divine_pos/features/feedback_form/data/feedback_model.dart';
import 'package:divine_pos/shared/utils/scale_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/utils/api_endpointen.dart';
import '../../../shared/utils/http_client.dart';
import '../presentation/widget/shared_widgets.dart';
import '../theme.dart';

final fem = ScaleSize.aspectRatio;

// ─── Constants ────────────────────────────────────────────────────────────────

class _DiamondShapeMeta {
  final String name;
  final String assetPath;
  const _DiamondShapeMeta({required this.name, required this.assetPath});
}

const _diamondShapes = [
  _DiamondShapeMeta(
    name: 'Round',
    assetPath: 'assets/images/diamond_round.png',
  ),
  _DiamondShapeMeta(
    name: 'Princess',
    assetPath: 'assets/images/diamond_princess.png',
  ),
  _DiamondShapeMeta(name: 'Oval', assetPath: 'assets/images/diamond_oval.png'),
  _DiamondShapeMeta(
    name: 'Cushion',
    assetPath: 'assets/images/diamond_cushion.png',
  ),
  _DiamondShapeMeta(name: 'Pear', assetPath: 'assets/images/diamond_pear.png'),
  _DiamondShapeMeta(
    name: 'Emerald',
    assetPath: 'assets/images/diamond_emerald.png',
  ),
];

const _caratSteps = [
  '0.17',
  '0.20',
  '0.30',
  '0.40',
  '0.50',
  '0.70',
  '0.90',
  '1.00',
  '2.00',
  '2.99',
];
const _colorSteps = ['D', 'E', 'F', 'G', 'H', 'I', 'J', 'K'];
const _claritySteps = ['IF', 'VVS1', 'VVS2', 'VS1', 'VS2', 'SI1', 'SI2'];

// ─── PYDS Add Button (ConsumerWidget — needs ref for API call) ────────────────

class _PydsAddButton extends ConsumerStatefulWidget {
  final String shape;
  final String carat;
  final String color;
  final String clarity;
  final void Function(PydsProductEntry entry) onAdd;

  const _PydsAddButton({
    required this.shape,
    required this.carat,
    required this.color,
    required this.clarity,
    required this.onAdd,
  });

  @override
  ConsumerState<_PydsAddButton> createState() => _PydsAddButtonState();
}

class _PydsAddButtonState extends ConsumerState<_PydsAddButton> {
  bool _isFetching = false;

  Future<void> _handleAdd() async {
    setState(() => _isFetching = true);
    try {
      final dio = ref.read(httpClientProvider);
      final response = await dio.post(
        ApiEndPoint.get_price,
        data: {
          'itemgroup': 'SOLITAIRE',
          'weight': double.parse(widget.carat),
          'shape': widget.shape,
          'color': widget.color,
          'quality': widget.clarity,
        },
      );

      if (response.statusCode != HttpStatus.ok) {
        throw HttpException('Failed to fetch solitaire price');
      }

      final body = response.data;
      if (body == null || body['success'] != true) {
        throw Exception('Invalid price response');
      }

      final price = body['price'];
      if (price is! num) throw Exception('Invalid price response: $body');

      widget.onAdd(
        PydsProductEntry(
          shape: widget.shape,
          carat: widget.carat,
          color: widget.color,
          clarity: widget.clarity,
          mrp: price.toDouble(),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isFetching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: _isFetching ? null : _handleAdd,
      icon: _isFetching
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Icon(Icons.add, size: 16),
      label: Text(_isFetching ? 'Fetching...' : 'Add'),
      style: ElevatedButton.styleFrom(
        backgroundColor: FeedbackTheme.teal,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 0,
      ),
    );
  }
}

// ─── PYDS Section (StatefulWidget — GlobalKey works correctly) ────────────────

class PydsSection extends StatefulWidget {
  const PydsSection({super.key});

  @override
  PydsSectionState createState() => PydsSectionState();
}

class PydsSectionState extends State<PydsSection> {
  String _selectedShape = 'Round';
  int _caratIndex = 0;
  int _colorIndex = 0;
  int _clarityIndex = 0;

  List<PydsProductEntry> _products = [];

  // ── Public: collect data for parent submit ────────────────────────────────
  PydsData? buildData(BuildContext context) {
    if (_products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one diamond product.'),
        ),
      );
      return null;
    }
    return PydsData(products: List.from(_products));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Q10 Diamond Shape
        FeedbackFormField(
          number: 10,
          label: 'Diamond Shape',
          required: true,
          child: DiamondShapeSelector(
            selected: _selectedShape,
            onSelect: (s) => setState(() => _selectedShape = s),
          ),
        ),
        SizedBox(height: 28 * fem),

        // Q11 Carat
        FeedbackFormField(
          number: 11,
          label: 'Carat',
          required: true,
          child: DiscreteSlider(
            steps: _caratSteps,
            selectedIndex: _caratIndex,
            onChanged: (i) => setState(() => _caratIndex = i),
          ),
        ),
        SizedBox(height: 28 * fem),

        // Q12 Color
        FeedbackFormField(
          number: 12,
          label: 'Color',
          required: true,
          child: DiscreteSlider(
            steps: _colorSteps,
            selectedIndex: _colorIndex,
            onChanged: (i) => setState(() => _colorIndex = i),
          ),
        ),
        SizedBox(height: 28 * fem),

        // Q13 Clarity
        FeedbackFormField(
          number: 13,
          label: 'Clarity',
          required: true,
          child: DiscreteSlider(
            steps: _claritySteps,
            selectedIndex: _clarityIndex,
            onChanged: (i) => setState(() => _clarityIndex = i),
          ),
        ),
        SizedBox(height: 20 * fem),

        // + Add button — ConsumerWidget handles API call, passes result back
        Align(
          alignment: Alignment.centerRight,
          child: _PydsAddButton(
            shape: _selectedShape,
            carat: _caratSteps[_caratIndex],
            color: _colorSteps[_colorIndex],
            clarity: _claritySteps[_clarityIndex],
            onAdd: (entry) => setState(() => _products.add(entry)),
          ),
        ),
        SizedBox(height: 16 * fem),

        // Product Details table
        if (_products.isNotEmpty)
          PydsProductTable(
            products: _products,
            onRemove: (i) => setState(() => _products.removeAt(i)),
          ),
      ],
    );
  }
}

// ─── Diamond Shape Selector ───────────────────────────────────────────────────

class DiamondShapeSelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;

  const DiamondShapeSelector({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _diamondShapes.map((shape) {
        final isSelected = shape.name == selected;
        return GestureDetector(
          onTap: () => onSelect(shape.name),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64 * fem,
                height: 64 * fem,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12 * fem),
                  border: Border.all(
                    color: isSelected
                        ? FeedbackTheme.teal
                        : FeedbackTheme.borderColor,
                    width: isSelected ? 2 : 1,
                  ),
                  color: isSelected ? FeedbackTheme.tealBg : Colors.white,
                ),
                padding: EdgeInsets.all(8 * fem),
                child: Image.asset(
                  shape.assetPath,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.diamond_outlined,
                    color: isSelected
                        ? FeedbackTheme.teal
                        : FeedbackTheme.textGrey,
                    size: 32 * fem,
                  ),
                ),
              ),
              SizedBox(height: 6 * fem),
              Text(
                shape.name,
                style: TextStyle(
                  fontSize: 12 * fem,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? FeedbackTheme.teal
                      : FeedbackTheme.textGrey,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ─── Discrete Step Slider ─────────────────────────────────────────────────────

class DiscreteSlider extends StatefulWidget {
  final List<String> steps;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const DiscreteSlider({
    super.key,
    required this.steps,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  State<DiscreteSlider> createState() => _DiscreteSliderState();
}

class _DiscreteSliderState extends State<DiscreteSlider> {
  late double _value;

  @override
  void initState() {
    super.initState();
    _value = widget.selectedIndex.clamp(0, widget.steps.length - 1).toDouble();
  }

  @override
  void didUpdateWidget(covariant DiscreteSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      setState(() {
        _value = widget.selectedIndex
            .clamp(0, widget.steps.length - 1)
            .toDouble();
      });
    }
  }

  int get _index => _value.round();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16 * fem, vertical: 16 * fem),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12 * fem),
        border: Border.all(color: FeedbackTheme.borderColor),
      ),
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              const double sliderPadding = 24.0;
              final double trackWidth =
                  constraints.maxWidth - sliderPadding * 2;
              final int count = widget.steps.length;
              final double step = count > 1 ? trackWidth / (count - 1) : 0;

              return Column(
                children: [
                  SizedBox(
                    height: 18 * fem,
                    child: Stack(
                      children: List.generate(count, (i) {
                        final double x = sliderPadding + i * step;
                        final isSelected = i == _index;
                        return Positioned(
                          left: x - 20,
                          width: 40,
                          child: Center(
                            child: Text(
                              widget.steps[i],
                              style: TextStyle(
                                fontSize: 11 * fem,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                                color: isSelected
                                    ? FeedbackTheme.teal
                                    : FeedbackTheme.textGrey,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  SizedBox(height: 4 * fem),
                  SizedBox(
                    height: 48 * fem,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        ...List.generate(count, (i) {
                          final double x = sliderPadding + i * step;
                          return Positioned(
                            left: x - 1,
                            top: 0,
                            child: Container(
                              width: 2 * fem,
                              height: 10 * fem,
                              decoration: BoxDecoration(
                                color: i == _index
                                    ? const Color(0xFFBEE4DD)
                                    : const Color(0xFFCFE1DD),
                                borderRadius: BorderRadius.circular(3 * fem),
                              ),
                            ),
                          );
                        }),
                        Container(
                          height: 6 * fem,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(3 * fem),
                            border: Border.all(
                              color: const Color(0xFFBEE4DD),
                              width: 1,
                            ),
                          ),
                        ),
                        SliderTheme(
                          data: SliderThemeData(
                            trackHeight: 4 * fem,
                            trackShape: const RoundedRectSliderTrackShape(),
                            activeTrackColor: const Color(0xFFCFF4EE),
                            inactiveTrackColor: Colors.transparent,
                            thumbColor: const Color(0xFFA9E7DF),
                            overlayColor: const Color(
                              0xFFBFE8E3,
                            ).withOpacity(0.25),
                            overlayShape: RoundSliderOverlayShape(
                              overlayRadius: 16 * fem,
                            ),
                            thumbShape: DiamondSliderThumbShape(
                              width: 10 * fem,
                              height: 15 * fem,
                            ),
                            tickMarkShape: SliderTickMarkShape.noTickMark,
                          ),
                          child: Slider(
                            value: _value,
                            min: 0,
                            max: (count - 1).toDouble(),
                            divisions: count - 1,
                            onChanged: (v) {
                              final newIndex = v.round();
                              if (newIndex == _index) return;
                              setState(() => _value = newIndex.toDouble());
                              widget.onChanged(newIndex);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─── Diamond Thumb ────────────────────────────────────────────────────────────

class DiamondSliderThumbShape extends SliderComponentShape {
  final double width;
  final double height;

  const DiamondSliderThumbShape({this.width = 10, this.height = 15});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => Size(width, height);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required Size sizeWithOverflow,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double textScaleFactor,
    required double value,
  }) {
    final canvas = context.canvas;
    final paint = Paint()
      ..color = sliderTheme.thumbColor ?? Colors.teal
      ..style = PaintingStyle.fill;

    final halfW = width / 2;
    final halfH = height / 2;

    final path = Path()
      ..moveTo(center.dx, center.dy - halfH)
      ..lineTo(center.dx + halfW, center.dy)
      ..lineTo(center.dx, center.dy + halfH)
      ..lineTo(center.dx - halfW, center.dy)
      ..close();

    canvas.drawPath(path, paint);
  }
}

// ─── PYDS Product Details Table ───────────────────────────────────────────────

class PydsProductTable extends StatelessWidget {
  final List<PydsProductEntry> products;
  final void Function(int) onRemove;

  const PydsProductTable({
    super.key,
    required this.products,
    required this.onRemove,
  });

  String _fmt(double v) {
    final s = v
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');
    return '₹$s';
  }

  double get _totalDownPayment => products.fold(0, (s, p) => s + p.downPayment);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _PydsTableHeader(),
          const Divider(height: 1, color: FeedbackTheme.borderColor),
          ...List.generate(products.length, (i) {
            final p = products[i];
            return Column(
              children: [
                _PydsProductRow(
                  label: p.label,
                  mrp: _fmt(p.mrp),
                  onRemove: () => onRemove(i),
                ),
                const Divider(height: 1, color: FeedbackTheme.borderColor),
                _PydsInstallmentRow(installment: _fmt(p.installment)),
                if (i < products.length - 1)
                  const Divider(height: 1, color: FeedbackTheme.borderColor),
              ],
            );
          }),
          const Divider(height: 1, color: FeedbackTheme.borderColor),
          _PydsTableFooter(downPayment: _fmt(_totalDownPayment)),
        ],
      ),
    );
  }
}

class _PydsTableHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF7FAFD),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: const [
          Expanded(
            child: Text(
              'PRODUCT DETAILS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: FeedbackTheme.textGrey,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Text(
            'MRP',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: FeedbackTheme.textGrey,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(width: 32),
        ],
      ),
    );
  }
}

class _PydsProductRow extends StatelessWidget {
  final String label;
  final String mrp;
  final VoidCallback onRemove;

  const _PydsProductRow({
    required this.label,
    required this.mrp,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: FeedbackTheme.textDark,
              ),
            ),
          ),
          Text(
            mrp,
            style: const TextStyle(fontSize: 14, color: FeedbackTheme.textDark),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(
              Icons.close,
              size: 18,
              color: FeedbackTheme.textGrey,
            ),
          ),
        ],
      ),
    );
  }
}

class _PydsInstallmentRow extends StatelessWidget {
  final String installment;
  const _PydsInstallmentRow({required this.installment});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Installment',
              style: TextStyle(fontSize: 14, color: FeedbackTheme.textDark),
            ),
          ),
          Text(
            installment,
            style: const TextStyle(fontSize: 14, color: FeedbackTheme.textDark),
          ),
          const SizedBox(width: 26),
        ],
      ),
    );
  }
}

class _PydsTableFooter extends StatelessWidget {
  final String downPayment;
  const _PydsTableFooter({required this.downPayment});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: FeedbackTheme.tealBg,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Text(
            'Down payment (min 20%)',
            style: TextStyle(
              fontSize: 13,
              color: FeedbackTheme.teal,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            downPayment,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: FeedbackTheme.textDark,
            ),
          ),
        ],
      ),
    );
  }
}
