// ignore_for_file: deprecated_member_use

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:synqer_io/core/app_injector.dart'; // adjust path if needed
import 'package:synqer_io/core/theme/theme_scope.dart';
import 'package:synqer_io/core/token_storage.dart';
import 'package:synqer_io/core/utils/app_images.dart';
import 'package:synqer_io/core/widgets/app_snackbar.dart';
import 'package:synqer_io/core/widgets/custom_text_fields.dart';
import 'package:synqer_io/features/dashboard/dashboard.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  NEUTRAL TOKENS (background / surface / text only — accents come from AppColors)
// ─────────────────────────────────────────────────────────────────────────────

// ─────────────────────────────────────────────────────────────────────────────
//  LOGIN SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final ValueNotifier<bool> _obscurePassword = ValueNotifier(true);
  final ValueNotifier<bool> _isLoading = ValueNotifier(false);
  final ValueNotifier<bool> _agreedToTerms = ValueNotifier(false);

  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _obscurePassword.dispose();
    _isLoading.dispose();
    _agreedToTerms.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  //Login Fun
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_agreedToTerms.value) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      _isLoading.value = true;

      final response = await AppInjector.loginRepo.login(
        email: email,
        password: password,
      );

      // CHECK SUCCESS FIRST
      if (response["success"] == false) {
        if (!mounted) return;

        AppSnackbar.show(
          context,
          message: response["message"] ?? "Login failed",
          type: SnackbarType.error,
        );

        return;
      }

      final token = response["userToken"];

      await TokenStorage.saveToken(token);

      // Update Dio auth token
      AppInjector.dio.updateToken(token);

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MainScreen()),
      );

      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;

        AppSnackbar.show(
          context,
          message: response['message'] ?? "Login successful",
          type: SnackbarType.success,
        );
      });
    } catch (e) {
      if (!mounted) return;

      AppSnackbar.show(
        context,
        message: e.toString().replaceFirst('Exception: ', ''),
        type: SnackbarType.error,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Scaffold(
      backgroundColor: c.bg,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Background grid
          const Positioned.fill(child: _GridBackground()),

          // Glow orbs (derived from context.colors.primary)
          Positioned(
            left: -80,
            top: -60,
            child: _GlowOrb(size: 280, color: c.primary.withOpacity(0.20)),
          ),
          Positioned(
            right: -60,
            bottom: MediaQuery.of(context).size.height * 0.35,
            child: _GlowOrb(size: 200, color: c.secondary.withOpacity(0.15)),
          ),

          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final width = MediaQuery.of(context).size.width;
                    final scale = (width / 375).clamp(0.85, 1.15);

                    final keyboardOpen =
                        MediaQuery.of(context).viewInsets.bottom > 0;

                    final headerHeight = keyboardOpen
                        ? 90.0
                        : (constraints.maxHeight * 0.28).clamp(140.0, 220.0);

                    return SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: IntrinsicHeight(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SizedBox(
                                height: headerHeight,
                                child: _buildHeader(scale),
                              ),
                              _buildCard(scale),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(double scale) {
    final c = context.colors;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Logo mark
          Container(
            width: 60 * scale,
            height: 60 * scale,
            padding: EdgeInsets.all(5 * scale),
            decoration: BoxDecoration(
              // color: context.colors.primary.withOpacity(0.20),
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: c.primary.withOpacity(0.5), width: 1),
            ),

            // child: Icon(
            //   Icons.hub_rounded,
            //   color: context.colors.primary,
            //   size: 26 * scale,
            // ),
            child: Image.asset(AppImages.logo, scale: scale),
          ),
          SizedBox(height: 18 * scale),
          Text(
            'SYNQER',
            style: TextStyle(
              fontSize: 32 * scale,
              fontFamily: 'Audiowide',
              color: c.textPrimary,
              letterSpacing: 7,
            ),
          ),
          SizedBox(height: 8 * scale),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _dash(),
                  const SizedBox(width: 8),
                  Text(
                    'PROFESSIONAL NETWORK',
                    style: TextStyle(
                      fontSize: 9 * scale,
                      color: c.textSecondary,
                      letterSpacing: 3,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _dash(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dash() =>
      Container(width: 20, height: 1, color: context.colors.textMuted);

  // ── Card ──────────────────────────────────────────────────────────────────

  Widget _buildCard(double scale) {
    final c = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(
          top: BorderSide(color: c.border, width: 1),
          left: BorderSide(color: c.border, width: 1),
          right: BorderSide(color: c.border, width: 1),
        ),
      ),
      padding: EdgeInsets.fromLTRB(28 * scale, 36 * scale, 28 * scale, 24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Heading ──
            Text(
              "Sign In",
              style: TextStyle(
                fontSize: 26 * scale,
                fontWeight: FontWeight.w700,
                color: c.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            SizedBox(height: 6 * scale),
            Text(
              "Access your professional workspace",
              style: TextStyle(fontSize: 13 * scale, color: c.textSecondary),
            ),

            SizedBox(height: 28 * scale),

            // ── Email ──
            _FieldLabel(label: "Email Address", scale: scale),
            SizedBox(height: 8 * scale),
            CustomTextFormField(
              controller: _emailController,
              hint_text: 'you@company.com',
              fieldIcon: Icons.mail_outline_rounded,
              keyboardType: TextInputType.emailAddress,
              // themeMode: TextFieldTheme.dark,
              validator: (v) {
                if (v == null || v.isEmpty) return "Email is required";
                if (!v.contains("@")) return "Enter a valid email";
                return null;
              },
            ),

            SizedBox(height: 18 * scale),

            // ── Password ──
            _FieldLabel(label: "Password", scale: scale),
            SizedBox(height: 8 * scale),
            ValueListenableBuilder<bool>(
              valueListenable: _obscurePassword,
              builder: (_, obscure, __) => CustomTextFormField(
                controller: _passwordController,
                hint_text: '••••••••',
                fieldIcon: Icons.lock_outline_rounded,
                isPassword: true,
                obscureText: obscure,
                // themeMode: TextFieldTheme.dark,
                validator: (v) =>
                    v == null || v.length < 6 ? "Minimum 6 characters" : null,
                suffixIcon: GestureDetector(
                  onTap: () => _obscurePassword.value = !obscure,
                  child: Icon(
                    obscure
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 18,
                    color: c.inputIcon,
                  ),
                ),
              ),
            ),

            SizedBox(height: 8 * scale),

            // ── Forgot password ──
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () {}, // TODO: forgot password
                child: Text(
                  "Forgot password?",
                  style: TextStyle(
                    fontSize: 12 * scale,
                    color: c.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            SizedBox(height: 22 * scale),

            // ── Terms & Conditions ──
            ValueListenableBuilder<bool>(
              valueListenable: _agreedToTerms,
              builder: (_, agreed, __) {
                return GestureDetector(
                  onTap: () => _agreedToTerms.value = !agreed,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Custom checkbox
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: agreed ? c.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: agreed ? c.primary : c.border,
                            width: 1.5,
                          ),
                        ),
                        child: agreed
                            ? Icon(
                                Icons.check_rounded,
                                size: 13,
                                color: c.onBrand,
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 13 * scale,
                              color: c.textSecondary,
                              height: 1.5,
                            ),
                            children: [
                              const TextSpan(text: "I agree to the "),
                              TextSpan(
                                text: "Terms of Service",
                                style: TextStyle(
                                  color: c.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    // TODO: open terms
                                  },
                              ),
                              const TextSpan(text: " and "),
                              TextSpan(
                                text: "Privacy Policy",
                                style: TextStyle(
                                  color: c.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    // TODO: open privacy policy
                                  },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            SizedBox(height: 24 * scale),

            // ── Sign In Button ──
            // Listens to BOTH loading and terms-agreed so the button rebuilds
            // whenever either changes. Disabled until user agrees to terms.
            AnimatedBuilder(
              animation: Listenable.merge([_isLoading, _agreedToTerms]),
              builder: (_, __) {
                final loading = _isLoading.value;
                final agreed = _agreedToTerms.value;
                final enabled = agreed && !loading;

                return SizedBox(
                  width: double.infinity,
                  height: 52 * scale,
                  child: _SignInButton(
                    loading: loading,
                    enabled: enabled,
                    onTap: enabled ? _handleLogin : null,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  COMPONENTS
// ─────────────────────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String label;
  final double scale;
  const _FieldLabel({required this.label, this.scale = 1.0});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 12 * scale,
        fontWeight: FontWeight.w600,
        color: context.colors.textSecondary,
        letterSpacing: 0.3,
      ),
    );
  }
}

class _SignInButton extends StatefulWidget {
  final bool loading;
  final bool enabled;
  final VoidCallback? onTap;

  const _SignInButton({
    required this.loading,
    required this.enabled,
    this.onTap,
  });

  @override
  State<_SignInButton> createState() => _SignInButtonState();
}

class _SignInButtonState extends State<_SignInButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isInteractive = widget.enabled && !widget.loading;
    final c = context.colors;

    return GestureDetector(
      onTapDown: isInteractive ? (_) => setState(() => _pressed = true) : null,
      onTapUp: isInteractive
          ? (_) {
              setState(() => _pressed = false);
              widget.onTap?.call();
            }
          : null,
      onTapCancel: isInteractive
          ? () => setState(() => _pressed = false)
          : null,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          decoration: BoxDecoration(
            // Active: gradient. Loading or disabled: solid muted color.
            gradient: isInteractive
                ? LinearGradient(
                    colors: [c.primary, c.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isInteractive
                ? null
                : (widget.loading ? c.border : c.surfaceHigh),
            borderRadius: BorderRadius.circular(14),
            border: !widget.enabled && !widget.loading
                ? Border.all(color: c.border, width: 1)
                : null,
          ),
          alignment: Alignment.center,
          child: widget.loading
              ? SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: c.textSecondary,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Sign In",
                      style: TextStyle(
                        color: widget.enabled ? c.onBrand : c.textMuted,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: widget.enabled ? c.onBrand : c.textMuted,
                      size: 17,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  BACKGROUND EFFECTS
// ─────────────────────────────────────────────────────────────────────────────

class _GridBackground extends StatelessWidget {
  const _GridBackground();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GridPainter(
        dotColor: context.colors.textPrimary.withOpacity(
          context.isDark ? 0.04 : 0.05,
        ),
        lineColor: context.colors.textPrimary.withOpacity(
          context.isDark ? 0.025 : 0.035,
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  final Color dotColor;
  final Color lineColor;

  const _GridPainter({required this.dotColor, required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    final dotPaint = Paint()..color = dotColor;
    const spacing = 28.0;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1, dotPaint);
      }
    }

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 0.5;

    for (double y = 0; y < size.height; y += 80) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) =>
      oldDelegate.dotColor != dotColor || oldDelegate.lineColor != lineColor;
}

class _GlowOrb extends StatelessWidget {
  final double size;
  final Color color;

  const _GlowOrb({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, Colors.transparent],
          stops: const [0.0, 1.0],
        ),
      ),
    );
  }
}
