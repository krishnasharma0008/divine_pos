import 'package:flutter/material.dart';

/// Carat filter widget based on your Figma layout.
class CaratSelector extends StatelessWidget {
  final List<double> values; // e.g. [0.10, 0.14, 0.18, ...]
  final int startIndex; // selected range start index
  final int endIndex; // selected range end index (inclusive)

  const CaratSelector({
    super.key,
    required this.values,
    required this.startIndex,
    required this.endIndex,
  });

  @override
  Widget build(BuildContext context) {
    assert(values.length >= 2, 'values must contain at least 2 items');
    assert(startIndex >= 0 && startIndex < values.length);
    assert(endIndex >= 0 && endIndex < values.length);
    assert(startIndex <= endIndex);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // "Carat" label
        const Text(
          'Carat',
          style: TextStyle(
            color: Color(0xFF303030),
            fontSize: 14,
            fontFamily: 'Rushter Glory',
            fontWeight: FontWeight.w400,
          ),
        ),

        const SizedBox(height: 12),

        // Values row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(values.length, (i) {
            final value = values[i];
            final isActive = i >= startIndex && i <= endIndex;

            return Text(
              value.toStringAsFixed(2),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isActive ? Colors.black : const Color(0xFFD9D9D9),
                fontSize: 11,
                fontFamily: 'Montserrat',
                fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
              ),
            );
          }),
        ),

        const SizedBox(height: 8),

        // Tick marks
        SizedBox(
          height: 14,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(values.length, (i) {
              return Container(
                width: 3,
                height: 10.8,
                decoration: BoxDecoration(
                  color: const Color(0xFFBEE4DD),
                  borderRadius: BorderRadius.circular(1.5),
                ),
              );
            }),
          ),
        ),

        const SizedBox(height: 6),

        // Track + selected range
        SizedBox(
          height: 6,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final totalSteps = (values.length - 1).clamp(1, 999);
              final step = constraints.maxWidth / totalSteps;
              final left = step * startIndex;
              final right = step * (values.length - 1 - endIndex);

              return Stack(
                children: [
                  // full track
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(3),
                      border: Border.all(
                        color: const Color(0xFFBEE4DD),
                        width: 1,
                      ),
                    ),
                  ),
                  // selected range
                  Positioned(
                    left: left,
                    right: right,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFCFF4EE),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFF8EE1D4),
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
