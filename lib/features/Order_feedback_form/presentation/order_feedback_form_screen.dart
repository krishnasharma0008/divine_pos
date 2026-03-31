import 'package:divine_pos/features/Order_feedback_form/data/order_feedback_model.dart';
import 'package:divine_pos/features/Order_feedback_form/provider/feedback_notifier.dart';
import 'package:divine_pos/features/cart/data/customer_detail_model.dart';
import 'package:divine_pos/shared/routes/route_pages.dart';
import 'package:divine_pos/shared/widgets/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../shared/app_bar.dart';
import '../../../shared/utils/enums.dart';
import '../../../shared/utils/scale_size.dart';
import '../../feedback_form/provider/sales_staff_provider.dart';
import '../../feedback_form/presentation/widget/shared_widgets.dart';

class DivineFeedbackScreen extends ConsumerStatefulWidget {
  final CustomerDetail customer;
  final int? orderNo;

  const DivineFeedbackScreen({super.key, required this.customer, this.orderNo});

  @override
  ConsumerState<DivineFeedbackScreen> createState() =>
      _DivineFeedbackScreenState();
}

class _DivineFeedbackScreenState extends ConsumerState<DivineFeedbackScreen> {
  int _currentStep = 1;

  double _experienceRating = 0; // ← 0 means not selected
  final List<String> _sources = const [
    'Social Media',
    'Friends And Family',
    'Radio Or Cinema',
    'Banners, Posters Or Newspaper',
    'Salesman',
  ];
  String? _selectedSource; // ← null means not selected
  String? _customerType;
  String? _occasion;

  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _mobileController;
  late TextEditingController _emailController;
  late TextEditingController _salesStaffController;
  late TextEditingController _staffCtrl;
  bool _showSuggestions = false;

  List<String> _filteredStaff(List<String> allStaff) {
    final q = _staffCtrl.text.toLowerCase();
    if (q.isEmpty) return [];
    return allStaff.where((s) => s.toLowerCase().contains(q)).toList();
  }

  // ── Validation flags (set true on Next / Submit tap) ─────────────────────
  bool _step1Submitted = false;
  bool _step2Submitted = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.customer.name ?? '');
    _mobileController = TextEditingController(
      text: widget.customer.contactNo ?? '',
    );
    _emailController = TextEditingController(text: widget.customer.email ?? '');
    _salesStaffController = TextEditingController();
    _staffCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _staffCtrl.dispose();
    _salesStaffController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  // ── Mappers ───────────────────────────────────────────────────────────────
  String _mapSource(String ui) => switch (ui) {
    'Social Media' => 'social_media',
    'Friends And Family' => 'friends_family',
    'Radio Or Cinema' => 'radio_cinema',
    'Banners, Posters Or Newspaper' => 'banners_posters_newspaper',
    'Salesman' => 'salesman',
    _ => 'other',
  };

  String _mapCustomerType(String ui) => switch (ui) {
    'Repeat Divine Customer' => 'repeat_divine',
    'Repeat Store Customer (buying divine first time)' =>
      'repeat_store_first_divine',
    'First Time Customer (For store and Divine)' => 'first_time',
    _ => 'unknown',
  };

  String _mapOccasion(String ui) => switch (ui) {
    'Birthday or celebration gift' => 'birthday',
    'Engagement or wedding' => 'engagement_wedding',
    'Gift to family' => 'gift_family',
    'Self gift / self-purchase' => 'self_purchase',
    'Other' => 'other',
    _ => 'other',
  };

  // ── Step 1 validation ─────────────────────────────────────────────────────
  bool get _step1Valid =>
      // _experienceRating > 0 &&
      // _selectedSource != null &&
      // _customerType != null &&
      // _occasion != null &&
      _nameController.text.trim().isNotEmpty &&
      _mobileController.text.trim().isNotEmpty;
  // && _emailController.text.trim().isNotEmpty;

  void _handleNext() {
    setState(() => _step1Submitted = true);
    if (!_step1Valid) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _currentStep = 2);
  }

  // ── Step 2 submit ─────────────────────────────────────────────────────────
  Future<void> _submit() async {
    setState(() => _step2Submitted = true);
    if (_staffCtrl.text.trim().isEmpty) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final feedback = DivineFeedbackModel(
      orderno: widget.orderNo,
      customer_type: _mapCustomerType(_customerType ?? ''),
      customer_name: _nameController.text.trim(),
      contact_no: _mobileController.text.trim(),
      email: _emailController.text.trim(),
      experience_rating: _experienceRating.toInt(),
      discovery_source: _mapSource(_selectedSource ?? ''),
      occasion: _mapOccasion(_occasion ?? ''),
      sales_by: _staffCtrl.text.trim(),
    );

    final notifier = ref.read(feedbackProvider.notifier);
    await notifier.createOrderFeedback(feedback);

    final feedbackState = ref.read(feedbackProvider);
    feedbackState.when(
      data: (_) => _showSuccessDialog(context, ScaleSize.aspectRatio),
      error: (err, _) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit feedback: $err')),
      ),
      loading: () {},
    );
  }

  // ── Error helpers ─────────────────────────────────────────────────────────
  String? _fieldError(String value, String message) =>
      _step1Submitted && value.trim().isEmpty ? message : null;

  @override
  Widget build(BuildContext context) {
    final fem = ScaleSize.aspectRatio;
    final feedbackState = ref.watch(feedbackProvider);
    final isSubmitting = feedbackState.isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      appBar: MyAppBar(appBarLeading: AppBarLeading.back, showLogo: false),
      body: SafeArea(
        child: Column(
          children: [
            feedbackHeader(fem, widget.customer.name ?? ''),
            SizedBox(height: 20 * fem),
            stepHeader(
              fem,
              currentStep: _currentStep,
              onStepChanged: (step) => setState(() => _currentStep = step),
            ),
            SizedBox(height: 25 * fem),
            Expanded(
              child: Form(
                key: _formKey,
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: fem * 100),
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(color: Color(0xFFBEE4DD)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 233 * fem),
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 24 * fem),
                        MyText(
                          'Form to be filled by Sales Executive',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: const Color(0xFF3F3F3F),
                            fontSize: 16 * fem,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w400,
                            height: 2.25,
                          ),
                        ),
                        SizedBox(height: 30 * fem),
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                            24 * fem,
                            24 * fem,
                            24 * fem,
                            24 * fem,
                          ),
                          child: _currentStep == 1
                              ? _buildStep1(fem)
                              : _buildStep2(fem, isSubmitting),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep1(double fem) {
    final ratingError = _step1Submitted && _experienceRating == 0;
    final sourceError = _step1Submitted && _selectedSource == null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Q1 Rating
        QuestionSection(
          index: 1,
          fem: fem,
          title: 'How Was Your Experience With Divine Solitaires? *',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RatingBar.builder(
                initialRating: _experienceRating,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: false,
                itemPadding: const EdgeInsets.symmetric(horizontal: 4),
                itemCount: 5,
                itemBuilder: (context, _) =>
                    const Icon(Icons.star, color: Color(0xFF90DCD0)),
                onRatingUpdate: (rating) =>
                    setState(() => _experienceRating = rating),
              ),
              //if (ratingError) _errorText('Please select a rating'),
            ],
          ),
        ),

        // Q2 Discovery source
        QuestionSection(
          index: 2,
          fem: fem,
          title: 'How did you know about Divine Solitaires? *',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _sources.map((s) {
                  final selected = _selectedSource == s;
                  return ChoiceChip(
                    label: MyText(
                      s,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: selected
                            ? Colors.black
                            : const Color(0xFF595959),
                        fontSize: 14 * fem,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    showCheckmark: false,
                    selected: selected,
                    onSelected: (_) => setState(() => _selectedSource = s),
                    selectedColor: const Color(0xFF90DCD0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    backgroundColor: const Color(0xFFBEE4DD),
                  );
                }).toList(),
              ),
              // if (sourceError)
              //   _errorText('Please select how you heard about us'),
            ],
          ),
        ),

        // Q3 Customer type
        QuestionSection(
          index: 3,
          fem: fem,
          title: 'Please select the option that best describes you *',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8 * fem),
              _radioTile(
                value: 'Repeat Divine Customer',
                groupValue: _customerType,
                onChanged: (v) => setState(() => _customerType = v!),
                fem: fem,
              ),
              _radioTile(
                value: 'Repeat Store Customer (buying divine first time)',
                groupValue: _customerType,
                onChanged: (v) => setState(() => _customerType = v!),
                fem: fem,
              ),
              _radioTile(
                value: 'First Time Customer (For store and Divine)',
                groupValue: _customerType,
                onChanged: (v) => setState(() => _customerType = v!),
                fem: fem,
              ),
              // if (_step1Submitted && _customerType == null)
              //   _errorText('Please select an option'),
            ],
          ),
        ),

        // Q4 Occasion
        QuestionSection(
          index: 4,
          fem: fem,
          title: "What's the special occasion you're buying for today? *",
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8 * fem),
              _radioTile(
                value: 'Birthday or celebration gift',
                groupValue: _occasion,
                fem: fem,
                onChanged: (v) => setState(() => _occasion = v!),
              ),
              _radioTile(
                value: 'Engagement or wedding',
                groupValue: _occasion,
                fem: fem,
                onChanged: (v) => setState(() => _occasion = v!),
              ),
              _radioTile(
                value: 'Gift to family',
                groupValue: _occasion,
                fem: fem,
                onChanged: (v) => setState(() => _occasion = v!),
              ),
              _radioTile(
                value: 'Self gift / self-purchase',
                groupValue: _occasion,
                fem: fem,
                onChanged: (v) => setState(() => _occasion = v!),
              ),
              _radioTile(
                value: 'Other',
                groupValue: _occasion,
                fem: fem,
                onChanged: (v) => setState(() => _occasion = v!),
              ),
              // if (_step1Submitted && _occasion == null)
              //   _errorText('Please select an occasion'),
            ],
          ),
        ),

        // Q5 Name
        QuestionSection(
          index: 5,
          fem: fem,
          title: 'Name *',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8 * fem),
              _inputField(
                controller: _nameController,
                hint: 'Customer Name',
                fem: fem,
                errorText: _fieldError(
                  _nameController.text,
                  'Please enter name',
                ),
                onChanged: (_) => setState(() {}),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Please enter name'
                    : null,
              ),
            ],
          ),
        ),

        // Q6 Mobile
        QuestionSection(
          index: 6,
          fem: fem,
          title: 'Mobile Number *',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8 * fem),
              _inputField(
                controller: _mobileController,
                hint: 'Enter your mobile number',
                fem: fem,
                keyboardType: TextInputType.phone,
                errorText: _fieldError(
                  _mobileController.text,
                  'Please enter mobile number',
                ),
                onChanged: (_) => setState(() {}),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Please enter mobile number'
                    : null,
              ),
            ],
          ),
        ),

        // Q7 Email
        QuestionSection(
          index: 7,
          fem: fem,
          title: 'Email ID *',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8 * fem),
              _inputField(
                controller: _emailController,
                hint: 'Enter your email id',
                fem: fem,
                keyboardType: TextInputType.emailAddress,
                // errorText: _fieldError(
                //   _emailController.text,
                //   'Please enter email',
                // ),
                onChanged: (_) => setState(() {}),
                validator: (v) {
                  final value = v?.trim() ?? '';
                  //if (value.isEmpty) return null; // optional
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Enter valid email';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),

        SizedBox(height: 30 * fem),
        Center(child: submitButton(fem, _handleNext, label: 'Next')),
        SizedBox(height: 43 * fem),
      ],
    );
  }

  Widget _buildStep2(double fem, bool isSubmitting) {
    final staffAsync = ref.watch(salesStaffProvider);
    final staffError = _step2Submitted && _staffCtrl.text.trim().isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FeedbackFormField(
          number: 8,
          label: 'Sales Staff',
          required: true,
          error: staffError ? 'Please select sales staff' : null,
          child: staffAsync.when(
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _inputField(
                  controller: _staffCtrl,
                  hint: 'Enter staff name',
                  fem: fem,
                  errorText: staffError
                      ? 'Please enter sales staff name'
                      : null,
                  onChanged: (_) => setState(() {}),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    'Could not load staff list — type manually',
                    style: TextStyle(fontSize: 12 * fem, color: Colors.orange),
                  ),
                ),
              ],
            ),
            data: (staffList) => Column(
              children: [
                _inputField(
                  controller: _staffCtrl,
                  hint: 'Search staff name',
                  fem: fem,
                  errorText: staffError ? 'Please select sales staff' : null,
                  onChanged: (v) =>
                      setState(() => _showSuggestions = v.isNotEmpty),
                ),
                if (_showSuggestions && _filteredStaff(staffList).isNotEmpty)
                  StaffDropdown(
                    items: _filteredStaff(staffList),
                    onSelect: (s) {
                      _staffCtrl.text = s;
                      setState(() => _showSuggestions = false);
                    },
                  ),
              ],
            ),
          ),
        ),
        SizedBox(height: 30 * fem),
        Center(
          child: submitButton(
            fem,
            isSubmitting ? () {} : _submit,
            label: isSubmitting ? 'Submitting...' : 'Submit',
          ),
        ),
        SizedBox(height: 43 * fem),
      ],
    );
  }

  // ── Reusable input with error border ──────────────────────────────────────
  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required double fem,
    TextInputType keyboardType = TextInputType.text,
    String? errorText,
    ValueChanged<String>? onChanged,
    FormFieldValidator<String>? validator,
  }) {
    final hasError = errorText != null;
    final borderColor = hasError ? Colors.red : const Color(0xFFBFBED0);

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      validator: validator,
      style: TextStyle(fontSize: 14 * fem, fontFamily: 'Montserrat'),
      decoration: InputDecoration(
        hintText: hint,
        errorText: errorText,
        filled: true,
        fillColor: hasError ? const Color(0xFFFFF0F0) : const Color(0xFFF9F9F9),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 15 * fem,
          vertical: 15 * fem,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15 * fem),
          borderSide: BorderSide(color: borderColor, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15 * fem),
          borderSide: BorderSide(
            color: borderColor,
            width: hasError ? 1.5 : 0.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15 * fem),
          borderSide: BorderSide(
            color: hasError ? Colors.red : const Color(0xFF8FBED0),
            width: 1,
          ),
        ),
        errorStyle: const TextStyle(fontSize: 12, color: Colors.red),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15 * fem),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15 * fem),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
      ),
    );
  }

  Widget _errorText(String message) => Padding(
    padding: const EdgeInsets.only(top: 6, left: 2),
    child: Text(
      message,
      style: const TextStyle(fontSize: 12, color: Colors.red),
    ),
  );
}

// ── Unchanged helpers below ───────────────────────────────────────────────────

Widget feedbackHeader(double fem, String customerName) {
  return Container(
    height: 103 * fem,
    color: const Color(0xFFF8F8F8),
    padding: EdgeInsets.symmetric(horizontal: 8 * fem),
    child: Row(
      children: [
        const SizedBox(width: 32),
        Expanded(
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/feedback_form/thanks.png',
                  width: 24 * fem,
                  height: 24 * fem,
                ),
                SizedBox(width: 8 * fem),
                MyText(
                  'Thank You for Placing Your Order!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFF0E162B),
                    fontSize: 22 * fem,
                    fontFamily: 'Arial',
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(0, 23 * fem, 17 * fem, 26 * fem),
          child: Container(
            width: 222 * fem,
            decoration: BoxDecoration(
              color: const Color(0xFFBEE4DD),
              borderRadius: BorderRadius.circular(15 * fem),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: 16 * fem,
              vertical: 6 * fem,
            ),
            child: Row(
              children: [
                Container(
                  width: 24 * fem,
                  height: 24 * fem,
                  decoration: const BoxDecoration(shape: BoxShape.circle),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(
                    'assets/feedback_form/cust.png',
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: 10 * fem),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        customerName,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: const Color(0xFF5E5E5E),
                          fontSize: 13 * fem,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      MyText(
                        "Visited on ${DateFormat('dd-MM-yyyy').format(DateTime.now())}",
                        style: TextStyle(
                          color: const Color(0xFF5E5E5E),
                          fontSize: 10 * fem,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w400,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

Widget stepHeader(
  double fem, {
  required int currentStep,
  required ValueChanged<int> onStepChanged,
}) {
  const activeColor = Color(0xFF7ED6C4);
  const inactiveCircle = Color(0xFFF5F5F5);
  const textColor = Color(0xFF222222);

  Widget step({required int step, required String label}) {
    final isActive = currentStep == step;
    return InkWell(
      onTap: () => onStepChanged(step),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28 * fem,
            height: 28 * fem,
            decoration: BoxDecoration(
              color: isActive ? activeColor : inactiveCircle,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '$step',
              style: TextStyle(
                color: isActive ? Colors.white : activeColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(width: 8 * fem),
          Text(
            label,
            style: const TextStyle(
              color: textColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  return Container(
    height: 56 * fem,
    padding: EdgeInsets.symmetric(horizontal: 24 * fem),
    decoration: ShapeDecoration(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(29433700),
      ),
      shadows: const [
        BoxShadow(
          color: Color(0x19000000),
          blurRadius: 2,
          offset: Offset(0, 1),
          spreadRadius: -1,
        ),
        BoxShadow(
          color: Color(0x19000000),
          blurRadius: 3,
          offset: Offset(0, 1),
          spreadRadius: 0,
        ),
      ],
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        step(step: 1, label: 'Customer'),
        SizedBox(width: 24 * fem),
        Container(width: 60 * fem, height: 2 * fem, color: activeColor),
        SizedBox(width: 24 * fem),
        step(step: 2, label: 'Sales Executive'),
      ],
    ),
  );
}

class QuestionSection extends StatelessWidget {
  final double fem;
  final int index;
  final String title;
  final Widget child;

  const QuestionSection({
    super.key,
    required this.index,
    required this.fem,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _questionTitle(index: index, text: title, fem: fem),
        SizedBox(height: 15 * fem),
        child,
        SizedBox(height: 23 * fem),
      ],
    );
  }
}

Widget _questionTitle({
  required int index,
  required String text,
  required double fem,
}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      CircleAvatar(
        radius: 14 * fem,
        backgroundColor: const Color(0xFFF4F4F4),
        child: MyText(
          '$index',
          style: TextStyle(color: const Color(0xFF525252), fontSize: 13 * fem),
        ),
      ),
      SizedBox(width: 8 * fem),
      Expanded(
        child: MyText(
          text,
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w400,
            fontSize: 14 * fem,
          ),
        ),
      ),
      const SizedBox(width: 8),
      const MyText('*', style: TextStyle(color: Colors.red)),
    ],
  );
}

Widget _radioTile({
  required String value,
  required String? groupValue,
  required ValueChanged<String?> onChanged,
  required double fem,
}) {
  final isSelected = value == groupValue;
  return RadioListTile<String>(
    contentPadding: EdgeInsets.zero,
    value: value,
    groupValue: groupValue,
    onChanged: onChanged,
    selected: isSelected,
    title: Text(
      value,
      style: TextStyle(
        color: isSelected ? Colors.black : const Color(0xFF595959),
        fontSize: 14 * fem,
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.w500,
        height: 1.71 * fem,
      ),
    ),
    activeColor: const Color(0xFF90DCD0),
  );
}

Widget submitButton(
  double fem,
  VoidCallback onPressed, {
  String label = 'Submit',
}) {
  return GestureDetector(
    onTap: onPressed,
    child: Container(
      width: 258 * fem,
      height: 52 * fem,
      padding: EdgeInsets.symmetric(horizontal: 30 * fem, vertical: 6 * fem),
      decoration: ShapeDecoration(
        gradient: const LinearGradient(
          begin: Alignment(0.0, 0.5),
          end: Alignment(0.96, 1.12),
          colors: [Color(0xFFBEE4DD), Color(0xA5D1B193)],
        ),
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0xFFACA584)),
          borderRadius: BorderRadius.circular(20),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x7C000000),
            blurRadius: 4,
            offset: Offset(2, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            color: Color(0xFF6C5022),
            fontSize: 20,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    ),
  );
}

void _showSuccessDialog(BuildContext context, double fem) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (_) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10 * fem),
        ),
        child: SizedBox(
          width: 425 * fem,
          child: Container(
            padding: EdgeInsets.fromLTRB(
              24 * fem,
              24 * fem,
              24 * fem,
              70 * fem,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10 * fem),
              border: Border.all(color: const Color(0xFFE5E5E5), width: 1),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 6,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(
                      Icons.close,
                      size: 18,
                      color: Color(0xFF707070),
                    ),
                  ),
                ),
                SizedBox(height: 12 * fem),
                Container(
                  width: 60 * fem,
                  height: 60 * fem,
                  decoration: const BoxDecoration(
                    color: Color(0xFFBEE4DD),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Image.asset(
                    'assets/feedback_form/thanks.png',
                    width: 32 * fem,
                    height: 32 * fem,
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: 24 * fem),
                Text(
                  'Thank you for sharing your feedback with us !!!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFF0E162B),
                    fontSize: 16 * fem,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 32 * fem),
                Center(
                  child: submitButton(fem, () {
                    //context.pushNamed(RoutePages.dashboard.routeName);
                    GoRouter.of(context).go(RoutePages.dashboard.routeName);
                  }, label: 'OK'),
                ),
                SizedBox(height: 32 * fem),
              ],
            ),
          ),
        ),
      );
    },
  );
}
