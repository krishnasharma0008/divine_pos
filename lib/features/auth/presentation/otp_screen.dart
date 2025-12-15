import 'dart:async'; // ✅ REQUIRED FOR TIMER

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/themes.dart';
import '../../../shared/utils/scale_size.dart';
import '../../../shared/widgets/text.dart';
import '../data/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OtpScreen extends StatelessWidget {
  final String phoneNumber;
  const OtpScreen({super.key, required this.phoneNumber});

  @override
  Widget build(BuildContext context) {
    //final mq = MediaQuery.of(context);
    //final isNarrow = mq.size.width < 800;
    final fem = ScaleSize.aspectRatio;

    return Scaffold(
      backgroundColor: const Color(0xFFBEE4DD),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: fem * 80, //24.0,
              vertical: fem * 0, //18.0,
            ),
            child: _buildRow(context, fem),
            // child: ConstrainedBox(
            //   constraints: const BoxConstraints(maxWidth: 1200),
            //   child: isNarrow ? _buildColumn(context) : _buildRow(context),
            // ),
          ),
        ),
      ),
    );
  }

  Widget _buildColumn(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 16),
        Image.asset(
          'assets/Login/logo.png',
          width: 140,
          height: 80,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 12),
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: _RightCard(isCompact: true, phoneNumber: phoneNumber),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRow(BuildContext context, double fem) {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: SingleChildScrollView(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(fem * 30.0),
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: fem * 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/Login/login_side_image.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.centerLeft,
                  height: fem * 605,
                  //width: 464,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 5,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: fem * -100,
                left: 0,
                right: 0,
                child: Image.asset(
                  'assets/Login/logo.png',
                  width: fem * 129,
                  height: fem * 99,
                  fit: BoxFit.contain,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: fem * 20.0, bottom: fem * 20.0),
                child: _RightCard(isCompact: false, phoneNumber: phoneNumber),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _RightCard extends ConsumerStatefulWidget {
  final bool isCompact;
  final String phoneNumber;

  const _RightCard({required this.isCompact, required this.phoneNumber});

  @override
  ConsumerState<_RightCard> createState() => _RightCardState();
}

class _RightCardState extends ConsumerState<_RightCard> {
  final TextEditingController otpController = TextEditingController();
  //final ValueNotifier<int> resendTimer = ValueNotifier<int>(30);

  String? _otpError;
  //Timer? _timer;

  @override
  void initState() {
    super.initState();
    //_startTimer();
  }

  // void _startTimer() {
  //   _timer?.cancel();
  //   resendTimer.value = 30;

  //   _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
  //     if (!mounted) {
  //       timer.cancel();
  //       return;
  //     }
  //     if (resendTimer.value > 0) {
  //       resendTimer.value--;
  //     } else {
  //       timer.cancel();
  //     }
  //   });
  // }

  void _verifyOtp() {
    final otp = otpController.text.trim();
    //print(otp);
    if (otp.isEmpty) {
      //if (!mounted) return;
      setState(() => _otpError = "OTP cannot be blank");
      return;
    } else if (!RegExp(r'(^\-?\d*\.?\d*)').hasMatch(otp)) {
      //if (!mounted) return;
      //!RegExp(r'^\d{10}$').hasMatch(otp)
      setState(() => _otpError = "Enter a valid OTP");
      return;
    }

    //if (!mounted) return;
    setState(() => _otpError = null);

    //final sent =
    ref
        .read(loginRepoProvider.notifier)
        .login(username: widget.phoneNumber, password: widget.phoneNumber)
        .then((val) {
          if (!val) {
            final state = ref.read(loginRepoProvider);
            setState(() => _otpError = state.errorMessage);
          }
        });

    // if (!mounted) return; // widget might have been popped while waiting

    // if (sent) {
    //   context.go('/dashboard');
    // }
  }

  @override
  void dispose() {
    //_timer?.cancel();
    //resendTimer.dispose();
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginRepoProvider);
    final isLoading = loginState.isLoading;
    //final apiError = loginState.errorMessage;

    final fem = ScaleSize.aspectRatio;

    final cardRadius = 20.0;
    final cardPadding = EdgeInsets.only(
      left: fem * 28.0,
      right: fem * 28.0,
      top: fem * 59,
      bottom: fem * 16.0,
    );

    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.only(right: fem * 8.0),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.35),
          borderRadius: BorderRadius.only(
            //topLeft: Radius.circular(cardRadius),
            topRight: Radius.circular(cardRadius),
            //bottomLeft: Radius.circular(cardRadius),
            bottomRight: Radius.circular(cardRadius),
          ),
        ),
        child: Padding(
          padding: cardPadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// TITLE
              Center(
                child: SizedBox(
                  width: fem * 420,
                  child: Text(
                    "Verification Code",
                    style: TextStyle(
                      fontFamily: "Rushter Glory",
                      fontSize: fem * 30,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF2C2C2C),
                    ),
                  ),
                ),
              ),

              SizedBox(height: fem * 12),

              /// SUBTITLE
              Center(
                child: SizedBox(
                  width: 420,
                  child: MyText(
                    "We've sent a 4-digit code to ${widget.phoneNumber}",
                    style: TextStyle(
                      fontSize: fem * 16,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF666666),
                    ),
                  ),
                ),
              ),

              SizedBox(height: fem * 49),

              /// OTP FIELD
              Center(
                child: SizedBox(
                  width: fem * 420,
                  child: TextField(
                    controller: otpController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(
                      fontFamily: MyThemes.inputFontFamily,
                      fontSize: fem * 14,
                      color: Colors.black,
                      letterSpacing: fem * 2,
                    ),

                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: fem * 14,
                        vertical: fem * 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      errorText: _otpError,
                      hintText: "Enter Your Code",
                      hintStyle: TextStyle(
                        fontFamily: MyThemes.inputFontFamily,
                        fontSize: fem * 12,
                        color: Color(0xFF717182),
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: fem * 56),

              /// LOGIN BUTTON
              Center(
                child: Container(
                  width: fem * 420,
                  height: fem * 52,

                  decoration: ShapeDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFC8AC7D), Color(0xFFBEE4DD)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 1,
                        color: const Color(0xFF9F8353),
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    shadows: [
                      BoxShadow(
                        color: Color(0x3F777777),
                        blurRadius: 4,
                        offset: Offset(3, 3),
                        spreadRadius: 0,
                      ),
                      BoxShadow(
                        color: Color(0xFFFFFFFF),
                        blurRadius: 4,
                        offset: Offset(0, 4),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    //onPressed: _verifyOtp,
                    onPressed: isLoading ? null : _verifyOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),

                    child: isLoading
                        ? SizedBox(
                            width: fem * 22,
                            height: fem * 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation(
                                Color(0xFF063A38),
                              ),
                            ),
                          )
                        : MyText(
                            "Login",
                            style: TextStyle(
                              fontSize: fem * 20,
                              color: Color(0xFF6C5022),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                  ),
                ),
              ),

              // if (apiError != null)
              //   Padding(
              //     padding: const EdgeInsets.only(top: 8),
              //     child: Text(
              //       apiError.replaceFirst("Exception: ", ""),
              //       style: const TextStyle(color: Colors.red),
              //     ),
              //   ),

              //const SizedBox(height: 38),

              /// ✅ SMOOTH RESEND OTP (NO FLICKER)
              // Align(
              //   alignment: Alignment.centerRight,
              //   child: ValueListenableBuilder<int>(
              //     valueListenable: resendTimer,
              //     builder: (_, value, __) {
              //       return GestureDetector(
              //         onTap: value == 0 ? _startTimer : null,
              //         child: Text(
              //           value == 0 ? "Resend OTP" : "Resend OTP in $value sec",
              //           style: TextStyle(
              //             fontFamily: 'Montserrat',
              //             fontSize: 12,
              //             color: value == 0
              //                 ? const Color(0xFF063A38)
              //                 : Colors.grey[700],
              //             fontWeight: value == 0
              //                 ? FontWeight.w700
              //                 : FontWeight.w400,
              //             decoration: value == 0
              //                 ? TextDecoration.underline
              //                 : TextDecoration.none,
              //           ),
              //         ),
              //       );
              //     },
              //   ),
              // ),
              SizedBox(height: fem * 120),
            ],
          ),
        ),
      ),
    );
  }
}
