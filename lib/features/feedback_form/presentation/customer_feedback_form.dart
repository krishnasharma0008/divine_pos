import 'package:divine_pos/features/feedback_form/data/feedback_model.dart';
import 'package:divine_pos/shared/utils/scale_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../presentation/widget/shared_widgets.dart';
import '../theme.dart';

final fem = ScaleSize.aspectRatio;

class CustomerFeedbackForm extends StatefulWidget {
  final ValueChanged<CustomerFeedbackData> onNext;
  const CustomerFeedbackForm({super.key, required this.onNext});

  @override
  State<CustomerFeedbackForm> createState() => _CustomerFeedbackFormState();
}

class _CustomerFeedbackFormState extends State<CustomerFeedbackForm> {
  final _nameCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  int _rating = 4;
  String? _heardFrom;
  String? _customerType;
  String? _occasion;

  final _heardOptions = const [
    'Social Media',
    'Friends And Family',
    'Radio Or Cinema',
    'Banners, Posters Or Newspaper',
    'Salesman',
  ];

  final _customerTypes = const [
    'Repeat Divine Customer',
    'Repeat Store Customer (buying divine first time)',
    'First Time Customer (For store and Divine)',
  ];

  final _occasions = const [
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

  void _handleSubmit() {
    if (_nameCtrl.text.trim().isEmpty ||
        _mobileCtrl.text.trim().isEmpty ||
        _emailCtrl.text.trim().isEmpty ||
        _rating == 0 ||
        _heardFrom == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields.')),
      );
      return;
    }

    widget.onNext(
      CustomerFeedbackData(
        name: _nameCtrl.text.trim(),
        mobile: _mobileCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        rating: _rating,
        heardFrom: _heardFrom,
        customerType: _customerType,
        occasion: _occasion,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: FeedbackTheme.cardBg,
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
            // Q1 Name
            FeedbackFormField(
              number: 1,
              label: 'Name',
              required: true,
              child: FeedbackInput(
                controller: _nameCtrl,
                hint: 'Sukanya Naiknaware',
              ),
            ),
            SizedBox(height: 28 * fem),

            // Q2 Mobile
            FeedbackFormField(
              number: 2,
              label: 'Mobile Number',
              required: true,
              child: FeedbackInput(
                controller: _mobileCtrl,
                hint: 'Enter your mobile number',
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ),
            SizedBox(height: 28 * fem),

            // Q3 Email
            FeedbackFormField(
              number: 3,
              label: 'Email ID',
              required: true,
              child: FeedbackInput(
                controller: _emailCtrl,
                hint: 'Enter your email id',
                keyboardType: TextInputType.emailAddress,
              ),
            ),
            SizedBox(height: 28 * fem),

            // Q4 Rating
            FeedbackFormField(
              number: 4,
              label: 'How Was Your Experience With Divine Solitaires?',
              required: true,
              child: StarRating(
                value: _rating,
                onChanged: (v) => setState(() => _rating = v),
              ),
            ),
            SizedBox(height: 28 * fem),

            // Q5 Heard from
            FeedbackFormField(
              number: 5,
              label: 'How did you know about Divine Solitaires?',
              required: true,
              child: WrapChips(
                options: _heardOptions,
                selected: _heardFrom,
                onSelect: (v) => setState(() => _heardFrom = v),
              ),
            ),
            SizedBox(height: 28 * fem),

            // Q6 Customer type
            FeedbackFormField(
              number: 6,
              label: 'Please select the option that best describes you',
              child: FeedbackRadioGroup(
                options: _customerTypes,
                selected: _customerType,
                onSelect: (v) => setState(() => _customerType = v),
              ),
            ),
            SizedBox(height: 28 * fem),

            // Q7 Occasion
            FeedbackFormField(
              number: 7,
              label: "What's the special occasion you're buying for today?",
              child: FeedbackRadioGroup(
                options: _occasions,
                selected: _occasion,
                onSelect: (v) => setState(() => _occasion = v),
              ),
            ),
            SizedBox(height: 36 * fem),

            SubmitButton(label: 'Submit', onTap: _handleSubmit),
            SizedBox(height: 8 * fem),
          ],
        ),
      ),
    );
  }
}
