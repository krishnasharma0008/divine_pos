import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OtpScreen extends StatelessWidget {
  // final String phoneNumber;
  // const OtpScreen({super.key, required this.phoneNumber});
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
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
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
      children: [
        const SizedBox(height: 16),
        Image.asset('assets/Login/logo.png', width: 140, height: 80),
        //const SizedBox(height: 12),
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
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
            padding: const EdgeInsets.only(left: 38),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
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
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 48),
                child: _RightCard(isCompact: false, phoneNumber: phoneNumber),
              ),
            ],
          ),
        ),
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
  String? _otpError;
  int resendTimer = 30;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() async {
    while (resendTimer > 0) {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      setState(() {
        resendTimer--;
      });
    }
  }

  Future<void> _verifyOtp() async {
    final otp = otpController.text.trim();

    if (otp.isEmpty) {
      setState(() => _otpError = "OTP cannot be blank");
      return;
    } else if (!RegExp(r'^\d{10}$').hasMatch(otp)) {
      setState(() => _otpError = "Enter a valid 4-digit OTP");
      return;
    }

    setState(() => _otpError = null);

    bool sent = await ref
        .read(loginRepoProvider.notifier)
        .login(username: widget.phoneNumber, password: widget.phoneNumber);

    if (sent) {
      print("OTP Verified: $otp");
      //context.go('/home');
      context.go('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9F7F2),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.fromLTRB(28, 30, 28, 20),
                decoration: BoxDecoration(
                  color: const Color(0x5CFFFFFF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Image.asset(
                    //   'assets/Login/logo.png',
                    //   width: 140,
                    //   height: 80,
                    // ),
                    const SizedBox(height: 14),

                    SizedBox(
                      width: 420,
                      child: Text(
                        "Verification Code",
                        textAlign: TextAlign.left,
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF2C2C2C),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    SizedBox(
                      width: 420,
                      child: Text(
                        "We've sent a 4-digit code to ${widget.phoneNumber}",
                        textAlign: TextAlign.left,
                        style: const TextStyle(
                          fontFamily: "Montserrat",
                          fontSize: 15,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ),

                    const SizedBox(height: 26),

                    // OTP TEXT FIELD
                    // SizedBox(
                    //   width: 420,
                    //   child: TextField(
                    //     controller: otpController,
                    //     keyboardType: TextInputType.number,
                    //     maxLength: 4,
                    //     textAlign: TextAlign.left,
                    //     style: const TextStyle(
                    //       fontSize: 28,
                    //       fontWeight: FontWeight.w700,
                    //     ),
                    //     decoration: InputDecoration(
                    //       counterText: "",
                    //       filled: true,
                    //       fillColor: Colors.white,
                    //       hintText: "Enter 4-digit code",
                    //       hintStyle: const TextStyle(
                    //         color: Colors.grey,
                    //         fontSize: 18,
                    //       ),
                    //       contentPadding: const EdgeInsets.symmetric(
                    //         vertical: 14,
                    //       ),
                    //       border: OutlineInputBorder(
                    //         borderRadius: BorderRadius.circular(12),
                    //         borderSide: BorderSide.none,
                    //       ),
                    //     ),
                    //     onChanged: (value) {
                    //       if (value.length == 4) {
                    //         FocusScope.of(context).unfocus();
                    //       }
                    //     },
                    //   ),
                    // ),
                    Center(
                      child: SizedBox(
                        width: 420,
                        child: TextField(
                          controller: otpController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            hintText: "Enter 10 digit mobile number",
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

                    const SizedBox(height: 28),

                    // VERIFY BUTTON
                    SizedBox(
                      width: 420,
                      height: 52,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFD0B48E), Color(0xFF86C2B6)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ElevatedButton(
                          onPressed: _verifyOtp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Verify",
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: "Montserrat",
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF063A38),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // RESEND OTP (Below Verify)
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: resendTimer == 0
                            ? () {
                                setState(() {
                                  resendTimer = 30;
                                });
                                _startTimer();
                              }
                            : null,
                        child: Text(
                          resendTimer == 0
                              ? "Resend OTP"
                              : "Resend OTP in $resendTimer sec",
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 12,
                            color: resendTimer == 0
                                ? const Color(0xFF063A38)
                                : Colors.grey[700],
                            fontWeight: resendTimer == 0
                                ? FontWeight.w700
                                : FontWeight.w400,
                            decoration: resendTimer == 0
                                ? TextDecoration.underline
                                : TextDecoration.none,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
