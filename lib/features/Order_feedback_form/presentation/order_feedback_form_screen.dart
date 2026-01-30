import 'package:divine_pos/shared/widgets/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';

import '../../../shared/app_bar.dart';
import '../../../shared/utils/enums.dart';
import '../../../shared/utils/scale_size.dart';

class DivineFeedbackScreen extends StatefulWidget {
  const DivineFeedbackScreen({super.key});

  @override
  State<DivineFeedbackScreen> createState() => _DivineFeedbackScreenState();
}

class _DivineFeedbackScreenState extends State<DivineFeedbackScreen> {
  // STEP STATE
  int _currentStep = 1; // 1 = Customer, 2 = Sales Executive

  // Q1: rating
  double _experienceRating = 4;

  // Q2: discovery source (single choice chips)
  final List<String> _sources = const [
    'Social Media',
    'Friends And Family',
    'Radio Or Cinema',
    'Banners, Posters Or Newspaper',
    'Salesman',
  ];
  String _selectedSource = 'Social Media';

  // Q3: customer type (radio)
  String _customerType = 'Repeat Divine Customer';

  // Q4: occasion (radio)
  String _occasion = 'Engagement or wedding';

  // Text fields
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _salesStaffController = TextEditingController();

  @override
  void dispose() {
    _salesStaffController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      debugPrint('Rating: $_experienceRating');
      debugPrint('Source: $_selectedSource');
      debugPrint('CustomerType: $_customerType');
      debugPrint('Occasion: $_occasion');
      debugPrint('Name: ${_nameController.text}');
      debugPrint('Mobile: ${_mobileController.text}');
      debugPrint('Email: ${_emailController.text}');
      debugPrint('Sales Staff: ${_salesStaffController.text}');
      _showSuccessDialog(context, ScaleSize.aspectRatio);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fem = ScaleSize.aspectRatio;

    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      appBar: MyAppBar(appBarLeading: AppBarLeading.back, showLogo: false),
      body: SafeArea(
        child: Column(
          children: [
            feedbackHeader(fem),
            SizedBox(height: 20 * fem),
            stepHeader(
              fem,
              currentStep: _currentStep,
              onStepChanged: (step) {
                setState(() => _currentStep = step);
              },
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
                        SizedBox(
                          child: MyText(
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
                              : _buildStep2(fem),
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

  // STEP 1: Customer questions + Next
  Widget _buildStep1(double fem) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Q1
        QuestionSection(
          index: 1,
          fem: fem,
          title: 'How Was Your Experience With Divine Solitaires? *',
          child: RatingBar.builder(
            initialRating: _experienceRating,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: false,
            itemPadding: const EdgeInsets.symmetric(horizontal: 4),
            itemCount: 5,
            itemBuilder: (context, _) =>
                const Icon(Icons.star, color: Color(0xFF90DCD0)),
            onRatingUpdate: (rating) {
              setState(() => _experienceRating = rating);
            },
          ),
        ),

        // Q2
        QuestionSection(
          index: 2,
          fem: fem,
          title: 'How did you know about Divine Solitaires? *',
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _sources.map((s) {
              final selected = _selectedSource == s;
              return ChoiceChip(
                label: MyText(
                  s,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: selected ? Colors.black : const Color(0xFF595959),
                    fontSize: 14 * fem,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w400,
                  ),
                ),
                showCheckmark: false,
                selected: selected,
                onSelected: (_) {
                  setState(() => _selectedSource = s);
                },
                selectedColor: const Color(0xFF90DCD0),
                labelStyle: TextStyle(
                  color: selected ? Colors.black87 : const Color(0xFF595959),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                backgroundColor: const Color(0xFFBEE4DD),
              );
            }).toList(),
          ),
        ),

        // Q3
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
            ],
          ),
        ),

        // Q4
        QuestionSection(
          index: 4,
          fem: fem,
          title: 'What\'s the special occasion you\'re buying for today? *',
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
            ],
          ),
        ),

        // Q5
        QuestionSection(
          index: 5,
          fem: fem,
          title: 'Name *',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8 * fem),
              TextFormField(
                controller: _nameController,
                style: TextStyle(fontSize: 14 * fem, fontFamily: 'Montserrat'),
                decoration: InputDecoration(
                  hintText: 'Customer Name',
                  filled: true,
                  fillColor: const Color(0xFFF9F9F9),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 15 * fem,
                    vertical: 15 * fem,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15 * fem),
                    borderSide: const BorderSide(
                      color: Color(0xFFBFBED0),
                      width: 0.5,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15 * fem),
                    borderSide: const BorderSide(
                      color: Color(0xFFBFBED0),
                      width: 0.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15 * fem),
                    borderSide: const BorderSide(
                      color: Color(0xFF8FBED0),
                      width: 0.5,
                    ),
                  ),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Please enter name'
                    : null,
              ),
            ],
          ),
        ),

        // Q6
        QuestionSection(
          index: 6,
          fem: fem,
          title: 'Mobile Number *',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8 * fem),
              TextFormField(
                controller: _mobileController,
                style: TextStyle(fontSize: 14 * fem, fontFamily: 'Montserrat'),
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: 'Enter your mobile number',
                  filled: true,
                  fillColor: const Color(0xFFF9F9F9),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 15 * fem,
                    vertical: 15 * fem,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15 * fem),
                    borderSide: const BorderSide(
                      color: Color(0xFFBFBED0),
                      width: 0.5,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15 * fem),
                    borderSide: const BorderSide(
                      color: Color(0xFFBFBED0),
                      width: 0.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15 * fem),
                    borderSide: const BorderSide(
                      color: Color(0xFF8FBED0),
                      width: 0.5,
                    ),
                  ),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Please enter mobile number'
                    : null,
              ),
            ],
          ),
        ),

        // Q7
        QuestionSection(
          index: 7,
          fem: fem,
          title: 'Email ID *',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8 * fem),
              TextFormField(
                controller: _emailController,
                style: TextStyle(fontSize: 14 * fem, fontFamily: 'Montserrat'),
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Enter your email id',
                  filled: true,
                  fillColor: const Color(0xFFF9F9F9),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 15 * fem,
                    vertical: 15 * fem,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15 * fem),
                    borderSide: const BorderSide(
                      color: Color(0xFFBFBED0),
                      width: 0.5,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15 * fem),
                    borderSide: const BorderSide(
                      color: Color(0xFFBFBED0),
                      width: 0.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15 * fem),
                    borderSide: const BorderSide(
                      color: Color(0xFF8FBED0),
                      width: 0.5,
                    ),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Please enter email';
                  }
                  final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                  if (!regex.hasMatch(v.trim())) {
                    return 'Enter valid email';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),

        SizedBox(height: 30 * fem),
        Center(
          child: submitButton(fem, () {
            if (_formKey.currentState?.validate() ?? false) {
              setState(() => _currentStep = 2);
            }
          }, label: 'Next'),
        ),
        SizedBox(height: 43 * fem),
      ],
    );
  }

  // STEP 2: Sales staff + Submit
  Widget _buildStep2(double fem) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        QuestionSection(
          index: 8,
          fem: fem,
          title: 'Sales Staff',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8 * fem),
              TextFormField(
                controller: _salesStaffController,
                style: TextStyle(fontSize: 14 * fem, fontFamily: 'Montserrat'),
                keyboardType: TextInputType.name,
                decoration: InputDecoration(
                  hintText: 'Enter your full name',
                  filled: true,
                  fillColor: const Color(0xFFF9F9F9),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 15 * fem,
                    vertical: 15 * fem,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15 * fem),
                    borderSide: const BorderSide(
                      color: Color(0xFFBFBED0),
                      width: 0.5,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15 * fem),
                    borderSide: const BorderSide(
                      color: Color(0xFFBFBED0),
                      width: 0.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15 * fem),
                    borderSide: const BorderSide(
                      color: Color(0xFF8FBED0),
                      width: 0.5,
                    ),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Please enter your full name';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        SizedBox(height: 30 * fem),
        Center(child: submitButton(fem, _submit, label: 'Submit')),
        SizedBox(height: 43 * fem),
      ],
    );
  }
}

// header with thanks + customer chip
Widget feedbackHeader(double fem) {
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
                        'Customer Name',
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

// interactive 2-step header
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

// Question section wrapper
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
  required String groupValue,
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
                Container(
                  width: 80 * fem,
                  height: 4 * fem,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(2 * fem),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
