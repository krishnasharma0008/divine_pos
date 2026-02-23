import 'package:divine_pos/shared/app_bar.dart';
import 'package:divine_pos/shared/utils/enums.dart';
import 'package:divine_pos/shared/utils/scale_size.dart';
import 'package:divine_pos/shared/widgets/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─── Theme Colors ───────────────────────────────────────────────────────────
const _teal = Color(0xFF7CC8BE);
const _tealLight = Color(0xFFBEE4DD);
const _tealBg = Color(0xFFE8F5F3);
const _tealSelected = Color(0xFF7CC8BE);
const _textDark = Color(0xFF1A1A1A);
const _textGrey = Color(0xFF9E9E9E);
const _borderColor = Color(0xFFE0E0E0);
const _cardBg = Colors.white;
const _pageBg = Color(0xFFF0F7F6);

final fem = ScaleSize.aspectRatio;

// ─── Entry Point ────────────────────────────────────────────────────────────
class FeedbackFormPage extends StatefulWidget {
  const FeedbackFormPage({super.key});

  @override
  State<FeedbackFormPage> createState() => _FeedbackFormPageState();
}

class _FeedbackFormPageState extends State<FeedbackFormPage> {
  int _currentStep = 0; // 0 = Customer Feedback, 1 = Sales Executive

  void _goToStep2() => setState(() => _currentStep = 1);
  void _goToStep1() => setState(() => _currentStep = 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBg,
      appBar: MyAppBar(appBarLeading: AppBarLeading.back, showLogo: false),
      body: Column(
        children: [
          _StepIndicator(currentStep: _currentStep),
          Expanded(
            child: _currentStep == 0
                ? _CustomerFeedbackForm(onNext: _goToStep2)
                : _SalesExecutiveForm(onSubmit: () {}),
          ),
        ],
      ),
    );
  }
}

// ─── Step Indicator ───────────────────────────────────────────────────────────
class _StepIndicator extends StatelessWidget {
  final int currentStep;
  const _StepIndicator({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 16 * fem),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 16 * fem,
              vertical: 8 * fem,
            ),
            decoration: BoxDecoration(
              color: _pageBg,
              borderRadius: BorderRadius.circular(24 * fem),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _StepBubble(
                  number: '1',
                  label: 'Customer feedack',
                  active: currentStep == 0,
                  done: currentStep > 0,
                ),
                _StepLine(done: currentStep > 0),
                _StepBubble(
                  number: '2',
                  label: 'Sales Executive',
                  active: currentStep == 1,
                  done: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StepBubble extends StatelessWidget {
  final String number;
  final String label;
  final bool active;
  final bool done;
  const _StepBubble({
    required this.number,
    required this.label,
    required this.active,
    required this.done,
  });

  @override
  Widget build(BuildContext context) {
    final bg = (active || done) ? _teal : Colors.transparent;
    final textColor = (active || done) ? Colors.white : _textGrey;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28 * fem,
          height: 28 * fem,
          decoration: BoxDecoration(
            color: bg,
            shape: BoxShape.circle,
            border: (active || done)
                ? null
                : Border.all(color: _textGrey, width: 1.5),
          ),
          child: Center(
            child: done
                ? Icon(Icons.check, color: Colors.white, size: 16 * fem)
                : MyText(
                    number,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 13 * fem,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 8),
        MyText(
          label,
          style: TextStyle(
            fontSize: 14 * fem,
            fontWeight: FontWeight.w500,
            color: (active || done) ? _textDark : _textGrey,
          ),
        ),
      ],
    );
  }
}

class _StepLine extends StatelessWidget {
  final bool done;
  const _StepLine({required this.done});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40 * fem,
      height: 2 * fem,
      margin: EdgeInsets.symmetric(horizontal: 10 * fem),
      color: done ? _teal : _borderColor,
    );
  }
}

// ─── STEP 1: Customer Feedback Form ──────────────────────────────────────────
class _CustomerFeedbackForm extends StatefulWidget {
  final VoidCallback onNext;
  const _CustomerFeedbackForm({required this.onNext});

  @override
  State<_CustomerFeedbackForm> createState() => _CustomerFeedbackFormState();
}

class _CustomerFeedbackFormState extends State<_CustomerFeedbackForm> {
  final _nameCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  int _rating = 4;
  String? _heardFrom;
  String? _customerType;
  String? _occasion;

  final _heardOptions = [
    'Social Media',
    'Friends And Family',
    'Radio Or Cinema',
    'Banners, Posters Or Newspaper',
    'Salesman',
  ];

  final _customerTypes = [
    'Repeat Divine Customer',
    'Repeat Store Customer (buying divine first time)',
    'First Time Customer (For store and Divine)',
  ];

  final _occasions = [
    'Birthday or celebration gift',
    'Engagement or wedding',
    'Gift to family',
    'Self gift / self-purchase',
    'Other',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _mobileCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12 * fem,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _FormField(
              number: 1,
              label: 'Name',
              required: true,
              child: _Input(controller: _nameCtrl, hint: 'Sukanya Naiknaware'),
            ),
            SizedBox(height: 28 * fem),
            _FormField(
              number: 2,
              label: 'Mobile Number',
              required: true,
              child: _Input(
                controller: _mobileCtrl,
                hint: 'Enter your mobile number',
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ),
            SizedBox(height: 28 * fem),
            _FormField(
              number: 3,
              label: 'Email ID',
              required: true,
              child: _Input(
                controller: _emailCtrl,
                hint: 'Enter your email id',
                keyboardType: TextInputType.emailAddress,
              ),
            ),
            SizedBox(height: 28 * fem),
            _FormField(
              number: 4,
              label: 'How Was Your Experience With Divine Solitaires?',
              required: true,
              child: _StarRating(
                value: _rating,
                onChanged: (v) => setState(() => _rating = v),
              ),
            ),
            SizedBox(height: 28 * fem),
            _FormField(
              number: 5,
              label: 'How did you know about Divine Solitaires?',
              required: true,
              child: _WrapChips(
                options: _heardOptions,
                selected: _heardFrom,
                onSelect: (v) => setState(() => _heardFrom = v),
              ),
            ),
            SizedBox(height: 28 * fem),
            _FormField(
              number: 6,
              label: 'Please select the option that best describes you',
              child: _RadioGroup(
                options: _customerTypes,
                selected: _customerType,
                onSelect: (v) => setState(() => _customerType = v),
              ),
            ),
            SizedBox(height: 28 * fem),
            _FormField(
              number: 7,
              label: "What's the special occasion you're buying for today?",
              child: _RadioGroup(
                options: _occasions,
                selected: _occasion,
                onSelect: (v) => setState(() => _occasion = v),
              ),
            ),
            SizedBox(height: 36 * fem),
            _SubmitButton(label: 'Submit', onTap: widget.onNext),
            SizedBox(height: 8 * fem),
          ],
        ),
      ),
    );
  }
}

// ─── STEP 2: Sales Executive Form ────────────────────────────────────────────
class _SalesExecutiveForm extends StatefulWidget {
  final VoidCallback onSubmit;
  const _SalesExecutiveForm({required this.onSubmit});

  @override
  State<_SalesExecutiveForm> createState() => _SalesExecutiveFormState();
}

class _SalesExecutiveFormState extends State<_SalesExecutiveForm> {
  final _staffCtrl = TextEditingController();
  final _uidCtrl = TextEditingController();
  String? _purchaseCategory;
  List<_ProductEntry> _products = [];
  bool _showSuggestions = false;

  // Mock staff suggestions
  final _staffList = [
    'Sukanya Anant Naiknaware',
    'Suhani Nitesh Patil',
    'Suresh Kumar',
    'Sunita Sharma',
  ];

  List<String> get _filteredStaff {
    final q = _staffCtrl.text.toLowerCase();
    if (q.isEmpty) return [];
    return _staffList.where((s) => s.toLowerCase().contains(q)).toList();
  }

  void _addProduct() {
    final uid = _uidCtrl.text.trim();
    if (uid.isEmpty) return;
    setState(() {
      _products.add(_ProductEntry(uid: uid, mrp: 67999));
      _uidCtrl.clear();
    });
  }

  void _removeProduct(int index) {
    setState(() => _products.removeAt(index));
  }

  double get _totalMrp => _products.fold(0, (sum, p) => sum + p.mrp);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16 * fem),
      child: Container(
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(16 * fem),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12 * fem,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: EdgeInsets.all(24 * fem),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MyText(
              'Form to be filled by Sales Executive',
              style: TextStyle(
                fontSize: 15 * fem,
                fontWeight: FontWeight.w500,
                color: _textDark,
              ),
            ),
            SizedBox(height: 24 * fem),

            // Q8 Sales Staff
            _FormField(
              number: 8,
              label: 'Sales Staff',
              required: true,
              child: Column(
                children: [
                  _Input(
                    controller: _staffCtrl,
                    hint: 'Enter your full name',
                    onChanged: (v) =>
                        setState(() => _showSuggestions = v.isNotEmpty),
                  ),
                  if (_showSuggestions && _filteredStaff.isNotEmpty)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: _borderColor),
                        borderRadius: BorderRadius.circular(8 * fem),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Column(
                        children: _filteredStaff
                            .map(
                              (s) => InkWell(
                                onTap: () {
                                  _staffCtrl.text = s;
                                  setState(() => _showSuggestions = false);
                                },
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  child: MyText(
                                    s,
                                    style: TextStyle(fontSize: 14 * fem),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 28 * fem),

            // Q9 Purchase Category
            _FormField(
              number: 9,
              label: 'Purchase Category',
              required: true,
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 3.5,
                children: ['Ready Product', 'Upgrade', 'PYDS', 'Exchange'].map((
                  opt,
                ) {
                  final selected = _purchaseCategory == opt;
                  return _ChipButton(
                    label: opt,
                    selected: selected,
                    onTap: () => setState(() => _purchaseCategory = opt),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 28 * fem),

            // Add Product UID
            const MyText(
              'Add Product UID',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: _textDark,
              ),
            ),
            SizedBox(height: 10 * fem),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _uidCtrl,
                    decoration: InputDecoration(
                      hintText: 'Enter UID',
                      hintStyle: TextStyle(
                        color: _textGrey,
                        fontSize: 14 * fem,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 14 * fem,
                        vertical: 12 * fem,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8 * fem),
                        borderSide: const BorderSide(color: _borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8 * fem),
                        borderSide: const BorderSide(color: _borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8 * fem),
                        borderSide: const BorderSide(color: _teal, width: 1.5),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12 * fem),
                ElevatedButton.icon(
                  onPressed: _addProduct,
                  icon: Icon(Icons.add, size: 16 * fem),
                  label: MyText('Add'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Product UID Table
            if (_products.isNotEmpty) ...[
              Container(
                decoration: BoxDecoration(
                  color: _tealBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Row(
                        children: const [
                          Expanded(
                            child: MyText(
                              'PRODUCT UID',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _textGrey,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          MyText(
                            'MRP',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _textGrey,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(width: 32),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: _borderColor),
                    // Rows
                    ...List.generate(_products.length, (i) {
                      final p = _products[i];
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: MyText(
                                    p.uid,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: _textDark,
                                    ),
                                  ),
                                ),
                                MyText(
                                  '${p.mrp}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: _textDark,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () => _removeProduct(i),
                                  child: const Icon(
                                    Icons.close,
                                    size: 18,
                                    color: _textGrey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (i < _products.length - 1)
                            const Divider(height: 1, color: _borderColor),
                        ],
                      );
                    }),
                    // Footer totals
                    const Divider(height: 1, color: _borderColor),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const MyText(
                                'Total UIDs',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: _textGrey,
                                ),
                              ),
                              MyText(
                                '${_products.length}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: _textDark,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const MyText(
                                'Total MRP',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: _textGrey,
                                ),
                              ),
                              MyText(
                                '₹${_totalMrp.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: _textDark,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 36),
            _SubmitButton(label: 'Submit', onTap: widget.onSubmit),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _ProductEntry {
  final String uid;
  final double mrp;
  _ProductEntry({required this.uid, required this.mrp});
}

// ─── Shared Widgets ───────────────────────────────────────────────────────────

class _FormField extends StatelessWidget {
  final int number;
  final String label;
  final bool required;
  final Widget child;

  const _FormField({
    required this.number,
    required this.label,
    this.required = false,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MyText(
              '$number  ',
              style: const TextStyle(
                fontSize: 14,
                color: _textGrey,
                fontWeight: FontWeight.w400,
              ),
            ),
            Expanded(
              child: RichText(
                text: TextSpan(
                  text: label,
                  style: const TextStyle(
                    fontSize: 14,
                    color: _textDark,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Montserrat',
                  ),
                  children: required
                      ? [
                          const TextSpan(
                            text: ' *',
                            style: TextStyle(color: Colors.red),
                          ),
                        ]
                      : [],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        child,
      ],
    );
  }
}

class _Input extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;

  const _Input({
    required this.controller,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 14, color: _textDark),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: _textGrey, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _teal, width: 1.5),
        ),
      ),
    );
  }
}

class _StarRating extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const _StarRating({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (i) {
        final filled = i < value;
        return GestureDetector(
          onTap: () => onChanged(i + 1),
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Icon(
              filled ? Icons.star : Icons.star_border,
              color: filled ? _teal : const Color(0xFFCCCCCC),
              size: 36,
            ),
          ),
        );
      }),
    );
  }
}

class _WrapChips extends StatelessWidget {
  final List<String> options;
  final String? selected;
  final ValueChanged<String> onSelect;

  const _WrapChips({
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: options
          .map(
            (opt) => _ChipButton(
              label: opt,
              selected: selected == opt,
              onTap: () => onSelect(opt),
            ),
          )
          .toList(),
    );
  }
}

class _ChipButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ChipButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? _tealSelected : _tealBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected ? _tealSelected : _tealLight,
            width: 1.5,
          ),
        ),
        child: MyText(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected ? Colors.white : _textDark,
          ),
        ),
      ),
    );
  }
}

class _RadioGroup extends StatelessWidget {
  final List<String> options;
  final String? selected;
  final ValueChanged<String> onSelect;

  const _RadioGroup({
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: options.map((opt) {
        final isSelected = selected == opt;
        return GestureDetector(
          onTap: () => onSelect(opt),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? _teal : _borderColor,
                      width: 1.8,
                    ),
                  ),
                  child: isSelected
                      ? Center(
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: _teal,
                              shape: BoxShape.circle,
                            ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: MyText(
                    opt,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: _textDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SubmitButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 200,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF8ECFC7), Color(0xFFB5D5C5)],
            ),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Center(
            child: MyText(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
