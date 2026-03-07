import 'package:divine_pos/shared/utils/scale_size.dart';
import 'package:divine_pos/shared/widgets/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme.dart';

final fem = ScaleSize.aspectRatio;

// ─── Form Field wrapper (number + label + required star) ─────────────────────

class FeedbackFormField extends StatelessWidget {
  final int number;
  final String label;
  final bool required;
  final Widget child;
  final String? error; //for error siapley

  const FeedbackFormField({
    super.key,
    required this.number,
    required this.label,
    this.required = false,
    required this.child,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MyText(
              '$number  ',
              style: TextStyle(
                fontSize: 14 * fem,
                color: FeedbackTheme.textGrey,
                fontWeight: FontWeight.w400,
              ),
            ),
            Expanded(
              child: RichText(
                text: TextSpan(
                  text: label,
                  style: TextStyle(
                    fontSize: 14 * fem,
                    color: FeedbackTheme.textDark,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Montserrat',
                  ),
                  children: required
                      ? [
                          const TextSpan(
                            text: ' *',
                            style: TextStyle(color: Colors.red),
                          ),
                        ]
                      : [],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 10 * fem),
        child,
        // ── inline error message ──────────────────────────────────────────
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 2),
            child: Text(
              error!,
              style: const TextStyle(fontSize: 12, color: Colors.red),
            ),
          ),
      ],
    );
  }
}

// ─── Text Input ───────────────────────────────────────────────────────────────

class FeedbackInput extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final bool readOnly;
  final Color? fillColor;
  final bool hasError;

  const FeedbackInput({
    super.key,
    required this.controller,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.onChanged,
    this.readOnly = false,
    this.fillColor,
    this.hasError = false,
  });

  @override
  Widget build(BuildContext context) {
    final errorColor = hasError ? Colors.red : FeedbackTheme.borderColor;

    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      readOnly: readOnly,
      style: TextStyle(
        fontSize: 14 * fem,
        color: FeedbackTheme.textDark,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: FeedbackTheme.textGrey, fontSize: 14 * fem),
        filled: fillColor != null || hasError,
        fillColor: hasError ? const Color(0xFFFFF0F0) : fillColor,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 14 * fem,
          vertical: 12 * fem,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: errorColor), // ← remove const
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: errorColor), // ← remove const
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: hasError ? Colors.red : FeedbackTheme.teal,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}

// ─── Star Rating ──────────────────────────────────────────────────────────────

class StarRating extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const StarRating({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (i) {
        final filled = i < value;
        return GestureDetector(
          onTap: () => onChanged(i + 1),
          child: Padding(
            padding: EdgeInsets.only(right: 8 * fem),
            child: Icon(
              filled ? Icons.star : Icons.star_border,
              color: filled ? FeedbackTheme.teal : const Color(0xFFCCCCCC),
              size: 36 * fem,
            ),
          ),
        );
      }),
    );
  }
}

// ─── Wrap Chips (single select) ───────────────────────────────────────────────

class WrapChips extends StatelessWidget {
  final List<String> options;
  final String? selected;
  final ValueChanged<String> onSelect;

  const WrapChips({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: options
          .map(
            (opt) => ChipButton(
              label: opt,
              selected: selected == opt,
              onTap: () => onSelect(opt),
            ),
          )
          .toList(),
    );
  }
}

class ChipButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const ChipButton({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 18 * fem, vertical: 10 * fem),
        decoration: BoxDecoration(
          color: selected ? FeedbackTheme.tealSelected : FeedbackTheme.tealBg,
          borderRadius: BorderRadius.circular(24 * fem),
          border: Border.all(
            color: selected
                ? FeedbackTheme.tealSelected
                : FeedbackTheme.tealLight,
            width: 1.5,
          ),
        ),
        child: MyText(
          label,
          style: TextStyle(
            fontSize: 13 * fem,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected ? Colors.white : FeedbackTheme.textDark,
          ),
        ),
      ),
    );
  }
}

// ─── Radio Group ──────────────────────────────────────────────────────────────
// Named FeedbackRadioGroup to avoid conflict with Flutter's material.dart RadioGroup

class FeedbackRadioGroup extends StatelessWidget {
  final List<String> options;
  final String? selected;
  final ValueChanged<String> onSelect;

  const FeedbackRadioGroup({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: options.map((opt) {
        final isSelected = selected == opt;
        return GestureDetector(
          onTap: () => onSelect(opt),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(
              children: [
                Container(
                  width: 22 * fem,
                  height: 22 * fem,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? FeedbackTheme.teal
                          : FeedbackTheme.borderColor,
                      width: 1.8,
                    ),
                  ),
                  child: isSelected
                      ? Center(
                          child: Container(
                            width: 12 * fem,
                            height: 12 * fem,
                            decoration: const BoxDecoration(
                              color: FeedbackTheme.teal,
                              shape: BoxShape.circle,
                            ),
                          ),
                        )
                      : null,
                ),
                SizedBox(width: 12 * fem),
                Expanded(
                  child: MyText(
                    opt,
                    style: TextStyle(
                      fontSize: 14 * fem,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: FeedbackTheme.textDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─── Category Button ──────────────────────────────────────────────────────────

class CategoryButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const CategoryButton({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: selected
                ? const Color(0xFF00C2A8)
                : FeedbackTheme.borderColor,
          ),
          backgroundColor: selected
              ? const Color(0xFFE8FFFA)
              : Colors.transparent,
          foregroundColor: selected
              ? const Color(0xFF00A18C)
              : const Color(0xFF4F4F4F),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
        onPressed: onTap,
        child: Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}

// ─── Submit Button ────────────────────────────────────────────────────────────

class SubmitButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const SubmitButton({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 258 * fem,
          height: 52 * fem,
          padding: EdgeInsets.symmetric(
            horizontal: 30 * fem,
            vertical: 6 * fem,
          ),
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
      ),
    );
  }
}

// ─── Staff Autocomplete Dropdown ──────────────────────────────────────────────

class StaffDropdown extends StatelessWidget {
  final List<String> items;
  final ValueChanged<String> onSelect;

  const StaffDropdown({super.key, required this.items, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: FeedbackTheme.borderColor),
        borderRadius: BorderRadius.circular(8 * fem),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8),
        ],
      ),
      child: Column(
        children: items
            .map(
              (s) => InkWell(
                onTap: () => onSelect(s),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: 16 * fem,
                    vertical: 12 * fem,
                  ),
                  child: MyText(s, style: TextStyle(fontSize: 14 * fem)),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
