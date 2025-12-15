import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../../../shared/routes/route_pages.dart';
import '../../../shared/themes.dart';
import '../../../shared/utils/scale_size.dart';
import '../../../shared/widgets/text.dart';
import '../data/providers.dart'; // import your provider file!
//import '../presentation/otp_screen.dart';
import 'package:go_router/go_router.dart';

//import '../../../shared/routes/route_pages.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final fem = ScaleSize.aspectRatio;
    //print("fem:$fem");

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
            //   //child: isNarrow ? _buildColumn(context) : _buildRow(context),
            //   child: _buildRow(context),
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
              child: _RightCard(isCompact: true),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRow(BuildContext context, double fem) {
    //print("fem:$fem");
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
                child: _RightCard(isCompact: false),
              ),
              //_RightCard(isCompact: false),
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

  void _onGetOtpPressed() {
    final mobile = _phoneController.text.trim();

    if (mobile.isEmpty) {
      setState(() => _mobileError = "Mobile number cannot be blank");
      return;
    } else if (!RegExp(r'^\d{10}$').hasMatch(mobile)) {
      setState(() => _mobileError = "Enter a valid 10 digit mobile number");
      return;
    }
    setState(() => _mobileError = null);

    final ctx = context;
    ref.read(loginRepoProvider.notifier).sendOtp(mobile: mobile).then((val) {
      if (val) {
        //context.go('/otp', extra: mobile);
        if (!ctx.mounted) return;
        GoRouter.of(
          ctx,
        ).pushReplacement(RoutePages.otp.routePath, extra: mobile);
        // Or, context.go('/otp', extra: mobile);
      } else {
        final state = ref.read(loginRepoProvider);
        setState(() {
          _mobileError = state.errorMessage ?? "Failed to send OTP";
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // final isLoading = ref.watch(loginRepoProvider).isLoading;
    // final loginErrorMessage = ref.read(loginRepoProvider).errorMessage;
    final fem = ScaleSize.aspectRatio;

    final loginState = ref.watch(loginRepoProvider);
    final isLoading = loginState.isLoading;
    //final loginErrorMessage = loginState.errorMessage;

    final cardRadius = 20.0;
    final cardPadding = EdgeInsets.only(
      left: fem * 28.0,
      right: fem * 28.0,
      top: fem * 59.0,
      bottom: fem * 13.0,
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
              SizedBox(height: fem * 10),
              Center(
                child: SizedBox(
                  width: fem * 420,
                  child: Text(
                    "Welcome to Divine Solitaires",
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
              Center(
                child: SizedBox(
                  width: fem * 420,
                  child: MyText(
                    "Enter your mobile number to access your account",
                    style: TextStyle(
                      fontSize: fem * 16,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF666666),
                    ),
                  ),
                ),
              ),
              SizedBox(height: fem * 50),
              Center(
                child: SizedBox(
                  width: fem * 420,
                  child: MyText(
                    "Mobile Number",
                    style: TextStyle(
                      fontSize: fem * 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF2C2C2C),
                    ),
                  ),
                ),
              ),
              SizedBox(height: fem * 8),

              Center(
                child: SizedBox(
                  width: fem * 420,
                  child: TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
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
                      errorText: _mobileError,
                      hintText: "Enter 10 digit mobile number",
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
                    onPressed: isLoading ? null : _onGetOtpPressed,
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
                            "Get OTP",
                            style: TextStyle(
                              fontSize: fem * 20,
                              color: Color(0xFF6C5022),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                  ),
                ),
              ),

              SizedBox(height: fem * 45),
              Center(
                child: Container(
                  width: fem * 332,
                  height: fem * 1,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: fem * 27),
              Center(
                child: MyText(
                  "By logging in, you agree to our Terms of Service and Privacy Policy",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: fem * 12,
                    color: const Color(0xFF3A3A3A),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
