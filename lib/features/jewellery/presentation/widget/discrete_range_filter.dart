import 'package:divine_pos/shared/widgets/text.dart';
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
          MyText(
            widget.title,
            style: TextStyle(fontSize: 16 * fem, fontWeight: FontWeight.w400),
          ),
          //SizedBox(height: 12 * fem),
        ],

        /// SELECTED VALUES
        Padding(
          padding: EdgeInsets.only(left: 5 * fem),
          child: Row(
            //mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _valueBox(widget.options[startIndex], fem),

              SizedBox(width: 12 * fem),

              Text(
                "-",
                style: TextStyle(
                  fontSize: 12 * fem,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF4B4B4B),
                ),
              ),

              SizedBox(width: 12 * fem),

              _valueBox(widget.options[endIndex], fem),
            ],
          ),
        ),

        SizedBox(height: 8 * fem),

        /// CLICKABLE SCALE
        Padding(
          padding: EdgeInsets.only(right: 30 * fem),
          child: SizedBox(
            height: 40 * fem,
            //width: 257 * fem,
            child: Stack(
              alignment: Alignment.center,
              children: [
                /// BASE LINE
                Positioned(
                  left: 8 * fem,
                  right: 8 * fem,
                  top: 13 * fem,
                  child: Container(
                    height: fem * 6,
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
                      SizedBox(height: 11 * fem),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6 * fem,
                          ), // 👈 inset ticks
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: List.generate(widget.options.length, (
                              index,
                            ) {
                              final bool selected =
                                  index >= startIndex && index <= endIndex;

                              return Expanded(
                                child: GestureDetector(
                                  //behavior: HitTestBehavior.translucent,
                                  behavior: HitTestBehavior
                                      .opaque, // 👈 VERY IMPORTANT
                                  onTap: () {
                                    setState(() {
                                      final s = startIndex;
                                      final e = endIndex;

                                      if (index <= s) {
                                        startIndex = index;
                                      } else if (index >= e) {
                                        endIndex = index;
                                      } else {
                                        final closerToStart =
                                            (index - s).abs() <=
                                            (index - e).abs();
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
                                      Center(
                                        child: Container(
                                          width: fem * 4,
                                          height: 10 * fem,
                                          decoration: BoxDecoration(
                                            color: selected
                                                ? const Color(0xFF90DCD0)
                                                : const Color(
                                                    0xFF90DCD0,
                                                  ).withValues(alpha: 0.4),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 2 * fem),

                                      /// ONLY FROM & TO LABELS
                                      if (index == startIndex ||
                                          index == endIndex)
                                        MyText(
                                          widget.options[index],
                                          style: TextStyle(
                                            fontSize: 10 * fem,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        )
                                      else
                                        SizedBox(height: 14 * fem),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ),
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
    return SizedBox(
      width: 114 * fem,
      child: Container(
        //padding: EdgeInsets.symmetric(horizontal: 16 * fem, vertical: 12 * fem),
        padding: EdgeInsets.all(10 * fem),
        decoration: BoxDecoration(
          color: const Color(0xFFF3FBFA),
          borderRadius: BorderRadius.circular(15 * fem),
          border: Border.all(color: const Color(0xFFE5C289), width: 1 * fem),
        ),
        alignment: Alignment.center,
        child: MyText(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14 * fem, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
