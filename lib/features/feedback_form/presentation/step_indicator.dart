import 'package:divine_pos/shared/utils/scale_size.dart';
import 'package:divine_pos/shared/widgets/text.dart';
import 'package:flutter/material.dart';

import '../theme.dart';

final fem = ScaleSize.aspectRatio;

class StepIndicator extends StatelessWidget {
  final int currentStep;
  const StepIndicator({super.key, required this.currentStep});

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
              color: FeedbackTheme.pageBg,
              borderRadius: BorderRadius.circular(24 * fem),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                StepBubble(
                  number: '1',
                  label: 'Customer feedback',
                  active: currentStep == 0,
                  done: currentStep > 0,
                ),
                StepLine(done: currentStep > 0),
                StepBubble(
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

class StepBubble extends StatelessWidget {
  final String number;
  final String label;
  final bool active;
  final bool done;

  const StepBubble({
    super.key,
    required this.number,
    required this.label,
    required this.active,
    required this.done,
  });

  @override
  Widget build(BuildContext context) {
    final bg = (active || done) ? FeedbackTheme.teal : Colors.transparent;
    final textColor = (active || done) ? Colors.white : FeedbackTheme.textGrey;
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
                : Border.all(color: FeedbackTheme.textGrey, width: 1.5),
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
            color: (active || done)
                ? FeedbackTheme.textDark
                : FeedbackTheme.textGrey,
          ),
        ),
      ],
    );
  }
}

class StepLine extends StatelessWidget {
  final bool done;
  const StepLine({super.key, required this.done});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40 * fem,
      height: 2 * fem,
      margin: EdgeInsets.symmetric(horizontal: 10 * fem),
      color: done ? FeedbackTheme.teal : FeedbackTheme.borderColor,
    );
  }
}
