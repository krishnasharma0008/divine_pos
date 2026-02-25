import 'package:divine_pos/features/feedback_form/data/feedback_model.dart';
import 'package:divine_pos/shared/utils/scale_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

// ─── MRP Input Dialog ─────────────────────────────────────────────────────────

Future<double?> showMrpDialog(BuildContext context) async {
  final ctrl = TextEditingController();
  return showDialog<double>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Enter MRP'),
      content: TextField(
        controller: ctrl,
        autofocus: true,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: const InputDecoration(
          hintText: 'e.g. 3516000',
          prefixText: '₹ ',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: FeedbackTheme.teal),
          onPressed: () {
            final v = double.tryParse(ctrl.text.trim());
            Navigator.pop(ctx, v);
          },
          child: const Text('Add', style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}

// ─── PYDS Section ─────────────────────────────────────────────────────────────

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

  // ── Add product ───────────────────────────────────────────────────────────
  Future<void> _handleAdd() async {
    final mrp = await showMrpDialog(context);
    if (mrp == null || mrp <= 0) return;
    setState(() {
      _products.add(
        PydsProductEntry(
          shape: _selectedShape,
          carat: _caratSteps[_caratIndex],
          color: _colorSteps[_colorIndex],
          clarity: _claritySteps[_clarityIndex],
          mrp: mrp,
        ),
      );
    });
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

        // + Add button
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton.icon(
            onPressed: _handleAdd,
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Add'),
            style: ElevatedButton.styleFrom(
              backgroundColor: FeedbackTheme.teal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
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

class DiscreteSlider extends StatelessWidget {
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
          // Labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(steps.length, (i) {
              final isSelected = i == selectedIndex;
              return Expanded(
                child: Center(
                  child: Text(
                    steps[i],
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
          SizedBox(height: 6 * fem),
          // Tick marks
          Row(
            children: List.generate(
              steps.length,
              (i) => Expanded(
                child: Center(
                  child: Container(
                    width: 1.5,
                    height: 8 * fem,
                    color: i == selectedIndex
                        ? FeedbackTheme.teal
                        : FeedbackTheme.borderColor,
                  ),
                ),
              ),
            ),
          ),
          // Slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 2,
              activeTrackColor: FeedbackTheme.teal,
              inactiveTrackColor: FeedbackTheme.borderColor,
              thumbColor: FeedbackTheme.teal,
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 9 * fem),
              overlayShape: RoundSliderOverlayShape(overlayRadius: 16 * fem),
              overlayColor: FeedbackTheme.teal.withOpacity(0.15),
              tickMarkShape: SliderTickMarkShape.noTickMark,
            ),
            child: Slider(
              value: selectedIndex.toDouble(),
              min: 0,
              max: (steps.length - 1).toDouble(),
              divisions: steps.length - 1,
              onChanged: (v) => onChanged(v.round()),
            ),
          ),
        ],
      ),
    );
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
          // Header
          _PydsTableHeader(),
          const Divider(height: 1, color: FeedbackTheme.borderColor),

          // Product + installment rows
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

          // Footer
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
          const SizedBox(width: 26), // aligns with × column above
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
