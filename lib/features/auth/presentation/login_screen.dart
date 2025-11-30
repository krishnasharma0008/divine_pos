import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../data/providers.dart'; // import your provider file!
//import '../presentation/otp_screen.dart';
import 'package:go_router/go_router.dart';

//import '../../../shared/routes/route_pages.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

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
              child: _RightCard(isCompact: true),
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
                child: _RightCard(isCompact: false),
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
  const _RightCard({required this.isCompact});

  @override
  ConsumerState<_RightCard> createState() => _RightCardState();
}

class _RightCardState extends ConsumerState<_RightCard> {
  final _phoneController = TextEditingController();
  String? _mobileError; // holds error text

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _onGetOtpPressed() async {
    final mobile = _phoneController.text.trim();
    if (mobile.isEmpty) {
      setState(() => _mobileError = "Mobile number cannot be blank");
      return;
    } else if (!RegExp(r'^\d{10}$').hasMatch(mobile)) {
      setState(() => _mobileError = "Enter a valid 10 digit mobile number");
      return;
    }
    setState(() => _mobileError = null);

    bool sent = await ref
        .read(loginRepoProvider.notifier)
        .sendOtp(mobile: mobile);

    if (sent) {
      print("Navigating to OTP Screen with mobile: $mobile");
      //Navigator.of(context).pushNamed('/otp_screen', arguments: mobile);
      //context.go(RoutePages.otp.routePath, extra: mobile);
      context.go('/otp', extra: mobile);
      // Or, context.go('/otp', extra: mobile);
    } else {
      final state = ref.read(loginRepoProvider);
      setState(() {
        _mobileError = state.errorMessage ?? "Failed to send OTP";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
            Center(
              child: SizedBox(
                width: 420,
                child: Text(
                  "Welcome to Divine Solitaires",
                  style: TextStyle(
                    fontSize: widget.isCompact ? 30 : 30,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF2C2C2C),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: SizedBox(
                width: 420,
                child: Text(
                  "Enter your mobile number to access your account",
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF666666),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 22),
            Center(
              child: SizedBox(
                width: 420,
                child: Text(
                  "Mobile Number",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF2C2C2C),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),

            Center(
              child: SizedBox(
                width: 420,
                child: TextField(
                  controller: _phoneController,
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
                    errorText: _mobileError,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 22),
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
                    onPressed: _onGetOtpPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Get OTP",
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
            const SizedBox(height: 38),
            Center(
              child: Container(width: 332, height: 3, color: Colors.white),
            ),
            const SizedBox(height: 38),
            Center(
              child: Text(
                "By logging in, you agree to our Terms of Service and Privacy Policy",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                  color: const Color(0xFF3A3A3A),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
