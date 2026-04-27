// ignore_for_file: deprecated_member_use

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:synqer_io/core/app_injector.dart';
import 'package:synqer_io/core/widgets/app_snackbar.dart';
import 'package:synqer_io/core/widgets/custom_text_fields.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final ValueNotifier<bool> _rememberMe = ValueNotifier(false);
  final ValueNotifier<bool> _obscurePassword = ValueNotifier(true);
  final ValueNotifier<bool> _isLoading = ValueNotifier(false);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _rememberMe.dispose();
    _obscurePassword.dispose();
    _isLoading.dispose();
    super.dispose();
  }

  // ───────────────── LOGIN LOGIC ─────────────────

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    _isLoading.value = true;

    final response = await AppInjector.loginRepo.login(
      email: email,
      password: password,
    );

    _isLoading.value = false;

    if (!mounted) return;

    if (response["success"] == true) {
      final token = response["userToken"];

      AppInjector.dio.updateToken(token);

      AppSnackbar.show(
        context,
        message: response['message'],
        type: SnackbarType.success,
      );

      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(
      //     builder: (_) => const DashboardScreen(),
      //   ),
      // );
    } else {
      debugPrint(response['message']);
      AppSnackbar.show(
        context,
        message: 'Error in login.',
        type: SnackbarType.error,
      );
    }
  }

  // ───────────────── UI ─────────────────

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _DotGridPainter())),

          _buildXMark(left: size.width * 0.06, top: size.height * 0.05),
          _buildXMark(left: size.width * 0.82, top: size.height * 0.03),

          SafeArea(
            child: Column(
              children: [
                SizedBox(
                  height: size.height * 0.30,
                  child: Center(child: _buildBrand()),
                ),
                Expanded(child: _buildLoginCard()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrand() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: const [
        Text(
          'SYNQER',
          style: TextStyle(
            fontSize: 38,
            fontFamily: 'Audiowide',
            color: Colors.white,
            letterSpacing: 6,
          ),
        ),
        SizedBox(height: 10),
        Text(
          'PROFESSIONAL NETWORK',
          style: TextStyle(
            fontSize: 10,
            color: Color(0xFF777777),
            letterSpacing: 4.5,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginCard() {
    return Form(
      key: _formKey,
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Welcome Back",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            CustomTextFormField(
              controller: _emailController,
              hint_text: 'you@example.com',
              keyboardType: TextInputType.emailAddress,
              fieldIcon: Icons.mail_outline,
              validator: (v) {
                if (v == null || v.isEmpty) return "Enter email";
                if (!v.contains("@")) return "Invalid email";
                return null;
              },
            ),

            const SizedBox(height: 20),

            ValueListenableBuilder<bool>(
              valueListenable: _obscurePassword,
              builder: (_, obscure, __) {
                return CustomTextFormField(
                  controller: _passwordController,
                  hint_text: '••••••••',
                  isPassword: true,
                  obscureText: obscure,
                  fieldIcon: Icons.lock_outline,
                  validator: (v) =>
                      v == null || v.length < 6 ? "Min 6 characters" : null,
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscure ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () => _obscurePassword.value = !obscure,
                  ),
                );
              },
            ),

            const SizedBox(height: 30),

            ValueListenableBuilder<bool>(
              valueListenable: _isLoading,
              builder: (_, loading, __) {
                return SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: loading ? null : _handleLogin,
                    child: loading
                        ? const CircularProgressIndicator()
                        : const Text("Sign In"),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildXMark({required double left, required double top}) {
    return Positioned(
      left: left,
      top: top,
      child: const Icon(Icons.close, color: Colors.white24),
    );
  }
}

// Background painter (unchanged)
class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.05);

    for (double x = 0; x < size.width; x += 30) {
      for (double y = 0; y < size.height; y += 30) {
        canvas.drawCircle(Offset(x, y), 1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
