import 'package:flutter/material.dart';

Widget withLines(Widget child) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      const SizedBox(
        width: 297,
        height: 1,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Color(0xFFE0E0E0), // line color
          ),
        ),
      ),
      child,
      const SizedBox(
        width: 297,
        height: 1,
        child: DecoratedBox(
          decoration: BoxDecoration(color: Color(0xFFE0E0E0)),
        ),
      ),
    ],
  );
}
