import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final double r;
  const CustomCard(this.r, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16 * r),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12 * r),
      ),
      child: Column(
        children: [
          SliderField("Carat", 0.30, r),
          SizedBox(height: 12 * r),
          SliderField("Color", 5, r),
          SizedBox(height: 12 * r),
          SliderField("Clarity", 3, r),
        ],
      ),
    );
  }
}

class SliderField extends StatelessWidget {
  final String title;
  final double value;
  final double r;

  const SliderField(this.title, this.value, this.r, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 12 * r)),
        Slider(value: value, min: 0, max: 10, onChanged: (_) {}),
      ],
    );
  }
}
