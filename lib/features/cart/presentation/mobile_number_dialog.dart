import 'package:divine_pos/shared/utils/scale_size.dart';
import 'package:divine_pos/shared/widgets/text.dart';
import 'package:flutter/material.dart';

class MobileNumberDialog extends StatefulWidget {
  final Function(String)? onSubmit;

  const MobileNumberDialog({Key? key, this.onSubmit}) : super(key: key);

  @override
  State<MobileNumberDialog> createState() => _MobileNumberDialogState();
}

class _MobileNumberDialogState extends State<MobileNumberDialog> {
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fem = ScaleSize.aspectRatio;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        width: 425 * fem,
        height: 276 * fem,
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: BorderSide(width: 1.75 * fem, color: Color(0xFFBEE4DD)),
            borderRadius: BorderRadius.circular(10),
          ),
          shadows: [
            BoxShadow(
              color: Color(0x19000000),
              blurRadius: 6 * fem,
              offset: Offset(0, 4),
              spreadRadius: -4,
            ),
            BoxShadow(
              color: Color(0x19000000),
              blurRadius: 15 * fem,
              offset: Offset(0, 10),
              spreadRadius: -3,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Header Section
            Positioned(
              left: 26 * fem,
              top: 25.57 * fem,
              child: SizedBox(
                width: 355 * fem,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyText(
                      'Enter Your Mobile Number',
                      style: TextStyle(
                        color: Color(0xFF2C3E50),
                        fontSize: 18 * fem,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
                        height: 1,
                      ),
                    ),
                    SizedBox(height: 7.99 * fem),
                    MyText(
                      'Please provide your mobile number to continue',
                      style: TextStyle(
                        color: Color(0xFF717182),
                        fontSize: 14 * fem,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w400,
                        height: 1.43,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Input and Button Section
            Positioned(
              left: 26 * fem,
              top: 98.57 * fem,
              child: SizedBox(
                width: 373 * fem,
                child: Padding(
                  padding: EdgeInsets.only(top: 16 * fem),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Input Field
                      TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          hintText: 'Enter your mobile number',
                          hintStyle: TextStyle(
                            color: const Color(0xFF717182),
                            fontSize: 14 * fem,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w400,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 10 * fem,
                            vertical: 14 * fem,
                          ),
                          filled: true,
                          fillColor: Color(0xFFF3F3F5),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10 * fem),
                            borderSide: const BorderSide(
                              color: Color(0xFFBEE4DD),
                              width: 0.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10 * fem),
                            borderSide: const BorderSide(
                              color: Color(0xFFBEE4DD),
                              width: 0.5,
                            ),
                          ),
                          isDense: true,
                        ),
                      ),

                      SizedBox(height: 24 * fem),

                      // Submit Button
                      GestureDetector(
                        onTap: () {
                          if (_phoneController.text.isNotEmpty) {
                            widget.onSubmit?.call(_phoneController.text);
                            Navigator.of(context).pop(_phoneController.text);
                          }
                        },
                        child: Container(
                          width: 213 * fem,
                          height: 42 * fem,
                          padding: EdgeInsets.symmetric(
                            horizontal: 30 * fem,
                            vertical: 6 * fem,
                          ),
                          decoration: ShapeDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment(-0.00, 0.50),
                              end: Alignment(0.96, 1.12),
                              colors: [Color(0xFFBEE4DD), Color(0xA5D1B193)],
                            ),
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(
                                width: 1,
                                color: Color(0xFFACA584),
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            shadows: [
                              BoxShadow(
                                color: Color(0x7C000000),
                                blurRadius: 4 * fem,
                                offset: Offset(2, 2),
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: Center(
                            child: MyText(
                              'Submit',
                              style: TextStyle(
                                color: Color(0xFF6C5022),
                                fontSize: 14 * fem,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Close Button
            Positioned(
              right: 18 * fem,
              top: 9.57 * fem,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Opacity(
                  opacity: 0.70,
                  child: Container(
                    width: 16 * fem,
                    height: 16 * fem,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2C3E50),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      size: 12 * fem,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
