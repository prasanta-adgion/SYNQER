import 'package:flutter/material.dart';
import 'package:synqer_io/core/theme/theme_scope.dart';

class FullScreenLoader extends StatelessWidget {
  final String message;
  final Color color;

  const FullScreenLoader({
    super.key,
    this.message = "Loading...",
    this.color = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // SizedBox(
            //   width: 50,
            //   height: 50,
            //   child: Lottie.asset(AppGifAnimation.loadingGif),
            // ),
            GradientLoader(size: 20, strokeWidth: 2.5),
            const SizedBox(width: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: context.colors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GradientLoader extends StatefulWidget {
  final double size;
  final double strokeWidth;

  const GradientLoader({super.key, this.size = 30, this.strokeWidth = 3});

  @override
  State<GradientLoader> createState() => _GradientLoaderState();
}

class _GradientLoaderState extends State<GradientLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _AnimatedGradientPainter(
            progress: _controller.value,
            strokeWidth: widget.strokeWidth,
          ),
        );
      },
    );
  }
}

class _AnimatedGradientPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;

  _AnimatedGradientPainter({required this.progress, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    final gradient = SweepGradient(
      colors: [Color(0xFF12DDF0), Color(0xFF301BF3), Color(0xFF9128C3)],
      transform: GradientRotation(progress * 6.28), // animate colors
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final radius = size.width / 2 - strokeWidth / 2;

    canvas.drawCircle(size.center(Offset.zero), radius, paint);
  }

  @override
  bool shouldRepaint(covariant _AnimatedGradientPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
