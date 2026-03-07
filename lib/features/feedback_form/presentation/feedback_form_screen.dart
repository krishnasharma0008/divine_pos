import 'package:divine_pos/features/feedback_form/data/feedback_model.dart';
import 'package:divine_pos/features/feedback_form/provider/feedback_form_notifier.dart';
import 'package:divine_pos/shared/app_bar.dart';
import 'package:divine_pos/shared/routes/route_pages.dart';
import 'package:divine_pos/shared/utils/enums.dart';
import 'package:divine_pos/shared/utils/scale_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'customer_feedback_form.dart';
import 'sales_executive_form.dart';
import 'step_indicator.dart';
import '../theme.dart';

class FeedbackFormScreen extends ConsumerStatefulWidget {
  const FeedbackFormScreen({super.key});

  @override
  ConsumerState<FeedbackFormScreen> createState() => _FeedbackFormScreenState();
}

class _FeedbackFormScreenState extends ConsumerState<FeedbackFormScreen> {
  int _currentStep = 0;
  CustomerFeedbackData? _customerData;

  void _goToStep2(CustomerFeedbackData data) {
    _customerData = data;
    setState(() => _currentStep = 1);
  }

  Future<void> _submitAll(SalesExecutiveData salesData) async {
    if (_customerData == null) return;

    final feedback = FeedbackFormData(
      customer: _customerData!,
      sales: salesData,
    );

    debugPrint('FULL JSON: ${feedback.toJson()}');

    final notifier = ref.read(feedbackFormProvider.notifier);
    final ok = await notifier.submit(feedback);

    if (!ok) {
      final err = ref.read(feedbackFormProvider).errorMsg ?? 'Unknown error';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit feedback: $err')),
      );
      return;
    }

    _showSuccessDialog(context, ScaleSize.aspectRatio);
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(feedbackFormProvider);

    return Stack(
      children: [
        Scaffold(
          backgroundColor: FeedbackTheme.pageBg,
          appBar: MyAppBar(appBarLeading: AppBarLeading.back, showLogo: false),
          body: SafeArea(
            child: Column(
              children: [
                StepIndicator(currentStep: _currentStep),
                Expanded(
                  child: _currentStep == 0
                      ? CustomerFeedbackForm(onNext: _goToStep2)
                      : SalesExecutiveForm(onSubmit: _submitAll),
                ),
              ],
            ),
          ),
        ),
        if (formState.isLoading)
          const ColoredBox(
            color: Colors.black26,
            child: Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: FeedbackTheme.pageBg,
//       appBar: MyAppBar(appBarLeading: AppBarLeading.back, showLogo: false),
//       body: Column(
//         children: [
//           StepIndicator(currentStep: _currentStep),
//           Expanded(
//             child: _currentStep == 0
//                 ? CustomerFeedbackForm(onNext: _goToStep2)
//                 : SalesExecutiveForm(onSubmit: _submitAll),
//           ),
//         ],
//       ),
//     );
//   }
// }

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
                    context.pushNamed(RoutePages.dashboard.routeName);
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
