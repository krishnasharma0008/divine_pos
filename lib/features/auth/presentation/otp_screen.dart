import 'dart:async'; // ✅ REQUIRED FOR TIMER

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OtpScreen extends StatelessWidget {
  final String phoneNumber;
  const OtpScreen({Key? key, required this.phoneNumber}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final isNarrow = mq.size.width < 800;

    return Scaffold(
      backgroundColor: const Color(0xFFD9F7F2),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 18.0,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: isNarrow ? _buildColumn(context) : _buildRow(context),
            ),
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

  Widget _buildRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: Padding(
            padding: const EdgeInsets.only(left: 38.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30.0),
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/Login/login_side_image.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.centerLeft,
                  height: 605,
                  width: 404,
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
                top: -76,
                left: 0,
                right: 0,
                child: Image.asset(
                  'assets/Login/logo.png',
                  width: 129,
                  height: 99,
                  fit: BoxFit.contain,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 0.0, top: 48.0),
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

  Future<void> _verifyOtp() async {
    final otp = otpController.text.trim();

    if (otp.isEmpty) {
      if (!mounted) return;
      setState(() => _otpError = "OTP cannot be blank");
      return;
    } else if (!RegExp(r'^\d{10}$').hasMatch(otp)) {
      if (!mounted) return;
      setState(() => _otpError = "Enter a valid OTP");
      return;
    }

    if (!mounted) return;
    setState(() => _otpError = null);

    final sent = await ref
        .read(loginRepoProvider.notifier)
        .login(username: widget.phoneNumber, password: widget.phoneNumber);

    if (!mounted) return; // widget might have been popped while waiting

    if (sent) {
      context.go('/dashboard');
    }
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
    final apiError = loginState.errorMessage;

    final cardRadius = 20.0;
    final cardPadding = const EdgeInsets.only(
      left: 28.0,
      right: 28.0,
      top: 36.0,
      bottom: 16.0,
    );

    return Container(
      margin: const EdgeInsets.only(right: 8.0),
      decoration: BoxDecoration(
        color: const Color(0x5CFFFFFF),
        borderRadius: BorderRadius.circular(cardRadius),
      ),
      child: Padding(
        padding: cardPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            /// TITLE
            Center(
              child: SizedBox(
                width: 420,
                child: Text(
                  "Verification Code",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF2C2C2C),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            /// SUBTITLE
            Center(
              child: SizedBox(
                width: 420,
                child: Text(
                  "We've sent a 4-digit code to ${widget.phoneNumber}",
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF666666),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 22),

            /// OTP FIELD
            Center(
              child: SizedBox(
                width: 420,
                child: TextField(
                  controller: otpController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: "Enter Your Code",
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    errorText: _otpError,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 22),

            /// LOGIN BUTTON
            Center(
              child: SizedBox(
                width: 420,
                height: 52,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFD0B48E), Color(0xFF86C2B6)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black12),
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
                    // child: const Text(
                    //   "Login",
                    //   style: TextStyle(
                    //     fontSize: 18,
                    //     color: Color(0xFF063A38),
                    //     fontWeight: FontWeight.w600,
                    //   ),
                    // ),
                    child: isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation(
                                Color(0xFF063A38),
                              ),
                            ),
                          )
                        : const Text(
                            "Login",
                            style: TextStyle(
                              fontSize: 18,
                              color: Color(0xFF063A38),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),
            ),

            if (apiError != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  apiError.replaceFirst("Exception: ", ""),
                  style: const TextStyle(color: Colors.red),
                ),
              ),

            const SizedBox(height: 38),

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
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}
