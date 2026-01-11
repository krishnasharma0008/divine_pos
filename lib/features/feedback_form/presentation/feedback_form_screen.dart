import 'package:divine_pos/shared/widgets/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../../../shared/app_bar.dart';
import '../../../shared/utils/enums.dart';
import '../../../shared/utils/scale_size.dart';

class DivineFeedbackScreen extends StatefulWidget {
  const DivineFeedbackScreen({Key? key}) : super(key: key);

  @override
  State<DivineFeedbackScreen> createState() => _DivineFeedbackScreenState();
}

class _DivineFeedbackScreenState extends State<DivineFeedbackScreen> {
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
      // TODO: send data to API
      debugPrint('Rating: $_experienceRating');
      debugPrint('Source: $_selectedSource');
      debugPrint('CustomerType: $_customerType');
      debugPrint('Occasion: $_occasion');
      debugPrint('Name: ${_nameController.text}');
      debugPrint('Mobile: ${_mobileController.text}');
      debugPrint('Email: ${_emailController.text}');
      debugPrint('Sales Staff: ${_salesStaffController.text}');
      // ScaffoldMessenger.of(
      //   context,
      // ).showSnackBar(const SnackBar(content: Text('Feedback submitted')));
      _showSuccessDialog(context, ScaleSize.aspectRatio);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final fem = ScaleSize.aspectRatio;

    return Scaffold(
      backgroundColor: Color(0xFFFDFDFD),
      appBar: MyAppBar(appBarLeading: AppBarLeading.back, showLogo: false),
      body: SafeArea(
        // child: Center(
        //   child: ConstrainedBox(
        //     constraints: const BoxConstraints(),
        //     child: Padding(
        //       padding: const EdgeInsets.all(0),
        child: Column(
          children: [
            feedbackHeader(fem),
            SizedBox(height: 30 * fem),
            stepHeader(fem),
            SizedBox(height: 50 * fem),

            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Form(
                  key: _formKey,
                  child: Container(
                    width: 1089 * fem,
                    decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(color: Color(0xFFBEE4DD)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 233 * fem),
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              QuestionSection(
                                index: 1,
                                fem: fem,
                                title:
                                    'How Was Your Experience With Divine Solitaires? *',
                                child: RatingBar.builder(
                                  initialRating: _experienceRating,
                                  minRating: 1,
                                  direction: Axis.horizontal,
                                  allowHalfRating: false,
                                  itemPadding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  itemCount: 5,
                                  itemBuilder: (context, _) => const Icon(
                                    Icons.star,
                                    color: Color(0xFF90DCD0),
                                  ),
                                  onRatingUpdate: (rating) {
                                    setState(() => _experienceRating = rating);
                                  },
                                ),
                              ),
                              SizedBox(height: 23 * fem),
                              QuestionSection(
                                index: 2,
                                fem: fem,
                                title:
                                    'How did you know about Divine Solitaires? *',
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
                                          color: selected
                                              ? Colors.black
                                              : const Color(0xFF595959),
                                          fontSize: 14 * fem,
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      showCheckmark: false, // <- hides the tick
                                      selected: selected,
                                      // no avatar: this keeps it as plain text, no check icon
                                      onSelected: (_) {
                                        setState(() => _selectedSource = s);
                                      },
                                      selectedColor: const Color(0xFF90DCD0),
                                      labelStyle: TextStyle(
                                        color: selected
                                            ? Colors.black87
                                            : const Color(0xFF595959),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      backgroundColor: const Color(0xFFBEE4DD),
                                    );
                                  }).toList(),
                                ),
                              ),

                              SizedBox(height: 23 * fem),
                              QuestionSection(
                                index: 3,
                                fem: fem,
                                title:
                                    'Please select the option that best describes you *',
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 8 * fem),
                                    _radioTile(
                                      value: 'Repeat Divine Customer',
                                      groupValue: _customerType,
                                      onChanged: (v) =>
                                          setState(() => _customerType = v!),
                                      fem: fem,
                                    ),
                                    _radioTile(
                                      value:
                                          'Repeat Store Customer (buying divine first time)',
                                      groupValue: _customerType,
                                      onChanged: (v) =>
                                          setState(() => _customerType = v!),
                                      fem: fem,
                                    ),
                                    _radioTile(
                                      value:
                                          'First Time Customer (For store and Divine)',
                                      groupValue: _customerType,
                                      onChanged: (v) =>
                                          setState(() => _customerType = v!),
                                      fem: fem,
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: 23 * fem),

                              QuestionSection(
                                index: 4,
                                fem: fem,
                                title:
                                    'What\'s the special occasion you\'re buying for today? *',
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 8 * fem),
                                    _radioTile(
                                      value: 'Birthday or celebration gift',
                                      groupValue: _occasion,
                                      fem: fem,
                                      onChanged: (v) =>
                                          setState(() => _occasion = v!),
                                    ),
                                    _radioTile(
                                      value: 'Engagement or wedding',
                                      groupValue: _occasion,
                                      fem: fem,
                                      onChanged: (v) =>
                                          setState(() => _occasion = v!),
                                    ),
                                    _radioTile(
                                      value: 'Gift to family',
                                      groupValue: _occasion,
                                      fem: fem,
                                      onChanged: (v) =>
                                          setState(() => _occasion = v!),
                                    ),
                                    _radioTile(
                                      value: 'Self gift / self-purchase',
                                      groupValue: _occasion,
                                      fem: fem,
                                      onChanged: (v) =>
                                          setState(() => _occasion = v!),
                                    ),
                                    _radioTile(
                                      value: 'Other',
                                      groupValue: _occasion,
                                      fem: fem,
                                      onChanged: (v) =>
                                          setState(() => _occasion = v!),
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: 23 * fem),

                              // Q5: Name
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
                                      style: TextStyle(
                                        fontSize: 14 * fem,
                                        fontFamily: 'Montserrat',
                                      ),
                                      decoration: InputDecoration(
                                        hintText: 'Sukanya Naiknaware',
                                        filled: true,
                                        fillColor: const Color(0xFFF9F9F9),
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 15 * fem,
                                          vertical: 15 * fem,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            15 * fem,
                                          ),
                                          borderSide: const BorderSide(
                                            color: Color(
                                              0xFFBFBED0,
                                            ), // match figma border
                                            width: 0.5,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            15 * fem,
                                          ),
                                          borderSide: const BorderSide(
                                            color: Color(0xFFBFBED0),
                                            width: 0.5,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            15 * fem,
                                          ),
                                          borderSide: const BorderSide(
                                            color: Color(0xFF8FBED0),
                                            width: 0.5,
                                          ),
                                        ),
                                      ),
                                      validator: (v) =>
                                          (v == null || v.trim().isEmpty)
                                          ? 'Please enter name'
                                          : null,
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: 30 * fem),

                              // Q6: Mobile Number
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
                                      style: TextStyle(
                                        fontSize: 14 * fem,
                                        fontFamily: 'Montserrat',
                                      ),
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
                                          borderRadius: BorderRadius.circular(
                                            15 * fem,
                                          ),
                                          borderSide: const BorderSide(
                                            color: Color(0xFFBFBED0),
                                            width: 0.5,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            15 * fem,
                                          ),
                                          borderSide: const BorderSide(
                                            color: Color(0xFFBFBED0),
                                            width: 0.5,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            15 * fem,
                                          ),
                                          borderSide: const BorderSide(
                                            color: Color(0xFF8FBED0),
                                            width: 0.5,
                                          ),
                                        ),
                                      ),
                                      validator: (v) =>
                                          (v == null || v.trim().isEmpty)
                                          ? 'Please enter mobile number'
                                          : null,
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: 30 * fem),

                              // Q7: Email ID
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
                                      style: TextStyle(
                                        fontSize: 14 * fem,
                                        fontFamily: 'Montserrat',
                                      ),
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
                                          borderRadius: BorderRadius.circular(
                                            15 * fem,
                                          ),
                                          borderSide: const BorderSide(
                                            color: Color(0xFFBFBED0),
                                            width: 0.5,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            15 * fem,
                                          ),
                                          borderSide: const BorderSide(
                                            color: Color(0xFFBFBED0),
                                            width: 0.5,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            15 * fem,
                                          ),
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
                                        final regex = RegExp(
                                          r'^[^@]+@[^@]+\.[^@]+',
                                        );
                                        if (!regex.hasMatch(v.trim()))
                                          return 'Enter valid email';
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 30 * fem),

                              // Q8: Sales Staff
                              QuestionSection(
                                index: 8,
                                fem: fem,
                                title: 'Sales Staff',
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 8 * fem),
                                    TextFormField(
                                      controller:
                                          _salesStaffController, // new controller
                                      style: TextStyle(
                                        fontSize: 14 * fem,
                                        fontFamily: 'Montserrat',
                                      ),
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
                                          borderRadius: BorderRadius.circular(
                                            15 * fem,
                                          ),
                                          borderSide: const BorderSide(
                                            color: Color(0xFFBFBED0),
                                            width: 0.5,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            15 * fem,
                                          ),
                                          borderSide: const BorderSide(
                                            color: Color(0xFFBFBED0),
                                            width: 0.5,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            15 * fem,
                                          ),
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

                              //Center(child: submitButton(fem, _submit)),
                              Center(child: submitButton(fem, _submit)),
                              SizedBox(height: 43 * fem),
                              //SizedBox(
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                //),
              ),
            ),
            //SizedBox(height: 43 * fem),
          ],
        ),
      ),
      //     ),
      //   ),
      // ),
    );
  }

  // header with thanks + cust icon
  Widget feedbackHeader(double fem) {
    return Container(
      height: 103 * fem,
      color: const Color(0xFFF8F8F8),
      padding: EdgeInsets.symmetric(horizontal: 8 * fem),
      child: Row(
        children: [
          const SizedBox(width: 32),

          // center title with icon
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
                  Text(
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

          // right user chip
          Padding(
            padding: EdgeInsets.fromLTRB(0, 23 * fem, 17 * fem, 26 * fem),
            child: Container(
              width: 222 * fem,
              height: 54 * fem,
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
                          'Sukanya Naiknaware',
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
                          'Visited on 04-11-2025',
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
}

// step header using fem
Widget stepHeader(double fem) {
  const activeColor = Color(0xFF7ED6C4); // mint circle + line
  const inactiveCircle = Color(0xFFF5F5F5); // light grey circle
  const textColor = Color(0xFF222222);

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
        // Step 1
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28 * fem,
              height: 28 * fem,
              decoration: const BoxDecoration(
                color: activeColor,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Text(
                '1',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(width: 8 * fem),
            const Text(
              'Customer',
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),

        // Connector line
        SizedBox(width: 24 * fem),
        Container(width: 60 * fem, height: 2 * fem, color: activeColor),
        SizedBox(width: 24 * fem),

        // Step 2
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28 * fem,
              height: 28 * fem,
              decoration: const BoxDecoration(
                color: inactiveCircle,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Text(
                '2',
                style: TextStyle(
                  color: activeColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(width: 8 * fem),
            const Text(
              'Sales Executive',
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class QuestionSection extends StatelessWidget {
  final double fem;
  final int index;
  final String title;
  final Widget child; // e.g. RatingBar, chips, radios

  const QuestionSection({
    Key? key,
    required this.index,
    required this.fem,
    required this.title,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _questionTitle(
          index: index, // or pass index too if needed
          text: title,
          fem: fem,
        ),
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
          style: TextStyle(color: Color(0xFF525252), fontSize: 13 * fem),
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

Widget submitButton(double fem, VoidCallback onPressed) {
  return GestureDetector(
    onTap: onPressed,
    child: Container(
      width: 258 * fem,
      height: 52 * fem,
      padding: EdgeInsets.symmetric(horizontal: 30 * fem, vertical: 6 * fem),
      decoration: ShapeDecoration(
        gradient: const LinearGradient(
          begin: Alignment(-0.00, 0.50),
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
      child: const Center(
        child: Text(
          'Submit',
          style: TextStyle(
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
        //insetPadding: EdgeInsets.symmetric(horizontal: 16 * fem),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10 * fem),
        ),
        child: SizedBox(
          width: 425 * fem, // ✅ ADDED WIDTH
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
              border: Border.all(
                width: 0.88 * fem,
                color: Colors.black.withOpacity(0.10),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0x19000000),
                  blurRadius: 6 * fem,
                  offset: Offset(0, 4 * fem),
                  spreadRadius: -4 * fem,
                ),
                BoxShadow(
                  color: const Color(0x19000000),
                  blurRadius: 15 * fem,
                  offset: Offset(0, 10 * fem),
                  spreadRadius: -3 * fem,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// Close button
                Align(
                  alignment: Alignment.topRight,
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.close,
                      size: 18 * fem,
                      color: const Color(0xFF0A0A0A),
                    ),
                  ),
                ),

                //SizedBox(height: 12 * fem),

                /// Success image (Figma circle + asset)
                Container(
                  width: 56 * fem,
                  height: 56 * fem,
                  decoration: const BoxDecoration(
                    color: Color(0xFF90DCD0),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Image.asset(
                    'assets/feedback_form/App.png',
                    width: 56 * fem,
                    height: 56 * fem,
                    fit: BoxFit.contain,
                  ),
                ),

                SizedBox(height: 20 * fem),

                /// Message
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8 * fem),
                  child: Text(
                    'Thank you for sharing your feedback with us !!!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFF0A0A0A),
                      fontSize: 24 * fem,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w500,
                      height: 1.33,
                    ),
                  ),
                ),

                SizedBox(height: 24 * fem),

                /// Bottom indicator
                Opacity(
                  opacity: 0.30,
                  child: Container(
                    width: 134 * fem,
                    height: 4 * fem,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6DD3C0),
                      borderRadius: BorderRadius.circular(999 * fem),
                    ),
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
