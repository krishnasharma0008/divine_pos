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
    final fem = ScaleSize.aspectRatio;
    final bool hasTitle = widget.title.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title Row
        if (hasTitle) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
        // Selected start & end boxes
        Row(
          children: [
            _valueBox(widget.options[startIndex]),
            const SizedBox(width: 12),
            const Text("-", style: TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            _valueBox(widget.options[endIndex]),
          ],
        ),
        const SizedBox(height: 20),

        // Clickable scale
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SizedBox(
            height: 55 * fem,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Grey base line
                Positioned(
                  left: 8,
                  right: 8,
                  top: 18,
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDEDED),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),

                // Ticks + labels
                Positioned.fill(
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(widget.options.length, (
                            index,
                          ) {
                            final bool selected =
                                index >= startIndex && index <= endIndex;

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  final int s = startIndex;
                                  final int e = endIndex;

                                  if (index <= s) {
                                    // click on/left of start → move start
                                    startIndex = index;
                                  } else if (index >= e) {
                                    // click on/right of end → move end
                                    endIndex = index;
                                  } else {
                                    // between → move nearer handle
                                    final bool closerToStart =
                                        (index - s).abs() <= (index - e).abs();
                                    if (closerToStart) {
                                      startIndex = index;
                                    } else {
                                      endIndex = index;
                                    }
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
                                    height: selected ? 18 : 12,
                                    decoration: BoxDecoration(
                                      color: selected
                                          ? const Color(0xFF90DCD0)
                                          : const Color(
                                              0xFF90DCD0,
                                            ).withOpacity(0.4),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    widget.options[index],
                                    style: TextStyle(
                                      fontSize: 12, //10 in fig
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

  Widget _valueBox(String text) {
    return SizedBox(
      width: 135,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF8F7),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xFFE5C289), width: 1),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
