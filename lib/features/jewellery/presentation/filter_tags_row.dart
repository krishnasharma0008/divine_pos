import 'package:flutter/material.dart';

class FilterTagsRow extends StatelessWidget {
  const FilterTagsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 10,
        children: const [
          // Add selected filter chips here later
        ],
      ),
    );
  }
}
