import 'package:flutter/material.dart';

class FilterTagsRow extends StatelessWidget {
  final List<String> selectedFilters;
  final VoidCallback onClearAll;
  final Function(String) onRemoveTag;

  const FilterTagsRow({
    super.key,
    required this.selectedFilters,
    required this.onClearAll,
    required this.onRemoveTag,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedFilters.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      // ✅ FORCE FULL WIDTH
      width: MediaQuery.of(context).size.width,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        alignment: Alignment.centerLeft, // ✅ HARD LEFT ANCHOR
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min, // ✅ Content expands right
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Filtered By:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(width: 12),

              // Clear All pill
              _pill(label: 'Clear All', showClose: false, onTap: onClearAll),
              const SizedBox(width: 8),

              // Filter Pills
              ...selectedFilters.map((tag) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _pill(
                    label: tag,
                    showClose: true,
                    onTap: () => onRemoveTag(tag),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pill({
    required String label,
    required bool showClose,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE2D4BF), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
            if (showClose) ...[
              const SizedBox(width: 8),
              const Icon(Icons.close, size: 16, color: Colors.grey),
            ],
          ],
        ),
      ),
    );
  }
}
