import 'package:flutter/material.dart';
import '../../../../shared/utils/scale_size.dart';

class DiscreteClickRange extends StatefulWidget {
  final String title;
  final List<String> options;
  final int initialStartIndex;
  final int initialEndIndex;
  final ValueChanged<RangeValues>? onChanged;

  const DiscreteClickRange({
    super.key,
    required this.title,
    required this.options,
    this.initialStartIndex = 0,
    required this.initialEndIndex,
    this.onChanged,
  });

  @override
  State<DiscreteClickRange> createState() => _DiscreteClickRangeState();
}

class _DiscreteClickRangeState extends State<DiscreteClickRange> {
  late int startIndex;
  late int endIndex;

  @override
  void initState() {
    super.initState();
    startIndex = widget.initialStartIndex;
    endIndex = widget.initialEndIndex;
  }

  @override
  Widget build(BuildContext context) {
    final fem = ScaleSize.aspectRatio.clamp(0.7, 1.3);
    final bool hasTitle = widget.title.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// TITLE
        if (hasTitle) ...[
          Text(
            widget.title,
            style: TextStyle(fontSize: 18 * fem, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 12 * fem),
        ],

        /// SELECTED VALUES
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(child: _valueBox(widget.options[startIndex], fem)),

            SizedBox(width: 12 * fem),

            Text(
              '–',
              style: TextStyle(fontSize: 20 * fem, fontWeight: FontWeight.w500),
            ),

            SizedBox(width: 12 * fem),

            Expanded(child: _valueBox(widget.options[endIndex], fem)),
          ],
        ),

        SizedBox(height: 20 * fem),

        /// CLICKABLE SCALE
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24 * fem),
          child: SizedBox(
            height: 55 * fem,
            child: Stack(
              alignment: Alignment.center,
              children: [
                /// BASE LINE
                Positioned(
                  left: 8 * fem,
                  right: 8 * fem,
                  top: 18 * fem,
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDEDED),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),

                /// TICKS + LABELS
                Positioned.fill(
                  child: Column(
                    children: [
                      SizedBox(height: 10 * fem),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(widget.options.length, (
                            index,
                          ) {
                            final bool selected =
                                index >= startIndex && index <= endIndex;

                            return GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () {
                                setState(() {
                                  final s = startIndex;
                                  final e = endIndex;

                                  if (index <= s) {
                                    startIndex = index;
                                  } else if (index >= e) {
                                    endIndex = index;
                                  } else {
                                    final bool closerToStart =
                                        (index - s).abs() <= (index - e).abs();
                                    closerToStart
                                        ? startIndex = index
                                        : endIndex = index;
                                  }

                                  if (endIndex < startIndex) {
                                    final t = startIndex;
                                    startIndex = endIndex;
                                    endIndex = t;
                                  }

                                  widget.onChanged?.call(
                                    RangeValues(
                                      startIndex.toDouble(),
                                      endIndex.toDouble(),
                                    ),
                                  );
                                });
                              },
                              child: Column(
                                children: [
                                  Container(
                                    width: 6,
                                    height: selected ? 18 * fem : 12 * fem,
                                    decoration: BoxDecoration(
                                      color: selected
                                          ? const Color(0xFF90DCD0)
                                          : const Color(
                                              0xFF90DCD0,
                                            ).withOpacity(0.4),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  SizedBox(height: 6 * fem),
                                  Text(
                                    widget.options[index],
                                    style: TextStyle(
                                      fontSize: 12 * fem,
                                      fontFamily: 'Montserrat',
                                      fontWeight: selected
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// VALUE BOX
  Widget _valueBox(String text, double fem) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16 * fem, vertical: 12 * fem),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF8F7),
        borderRadius: BorderRadius.circular(15 * fem),
        border: Border.all(color: const Color(0xFFE5C289), width: 1 * fem),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14 * fem,
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
