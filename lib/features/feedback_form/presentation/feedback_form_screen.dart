import 'package:divine_pos/features/feedback_form/data/feedback_model.dart';
import 'package:divine_pos/shared/app_bar.dart';
import 'package:divine_pos/shared/utils/enums.dart';
import 'package:flutter/material.dart';

import 'customer_feedback_form.dart';
import 'sales_executive_form.dart';
import 'step_indicator.dart';
import '../theme.dart';

class FeedbackFormScreen extends StatefulWidget {
  const FeedbackFormScreen({super.key});

  @override
  State<FeedbackFormScreen> createState() => _FeedbackFormScreenState();
}

class _FeedbackFormScreenState extends State<FeedbackFormScreen> {
  int _currentStep = 0;
  CustomerFeedbackData? _customerData;

  void _goToStep2(CustomerFeedbackData data) {
    _customerData = data;
    setState(() => _currentStep = 1);
  }

  void _submitAll(SalesExecutiveData salesData) {
    if (_customerData == null) return;

    final feedback = FeedbackFormData(
      customer: _customerData!,
      sales: salesData,
    );

    debugPrint('FULL JSON: ${feedback.toJson()}');
    // TODO: send feedback.toJson() to API
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FeedbackTheme.pageBg,
      appBar: MyAppBar(appBarLeading: AppBarLeading.back, showLogo: false),
      body: Column(
        children: [
          StepIndicator(currentStep: _currentStep),
          Expanded(
            child: _currentStep == 0
                ? CustomerFeedbackForm(onNext: _goToStep2)
                : SalesExecutiveForm(onSubmit: _submitAll),
          ),
        ],
      ),
    );
  }
}
