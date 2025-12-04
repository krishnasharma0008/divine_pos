import 'package:flutter/material.dart';
import 'package:flutter_xlider/flutter_xlider.dart';

class CaratWeightSlider extends StatefulWidget {
  const CaratWeightSlider({super.key});

  @override
  State<CaratWeightSlider> createState() => _CaratWeightSliderState();
}

class _CaratWeightSliderState extends State<CaratWeightSlider> {
  double _lowerValue = 0.5;
  double _upperValue = 5.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Carat Weight",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),

        FlutterSlider(
          values: [_lowerValue, _upperValue],
          rangeSlider: true,
          max: 10,
          min: 0,
          step: const FlutterSliderStep(step: 0.1),

          trackBar: FlutterSliderTrackBar(
            activeTrackBarHeight: 5,
            inactiveTrackBarHeight: 5,
            activeTrackBar: BoxDecoration(color: Colors.teal),
            inactiveTrackBar: BoxDecoration(color: Colors.grey.shade300),
          ),

          handler: FlutterSliderHandler(
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(blurRadius: 3, color: Colors.black26)],
              ),
            ),
          ),

          rightHandler: FlutterSliderHandler(
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(blurRadius: 3, color: Colors.black26)],
              ),
            ),
          ),

          onDragging: (handlerIndex, lowerValue, upperValue) {
            setState(() {
              _lowerValue = lowerValue;
              _upperValue = upperValue;
            });
          },
        ),

        const SizedBox(height: 6),

        Text(
          "${_lowerValue.toStringAsFixed(1)} ct  -  ${_upperValue.toStringAsFixed(1)} ct",
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
