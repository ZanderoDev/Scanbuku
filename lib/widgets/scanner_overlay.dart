import 'package:flutter/material.dart';

/// Overlay visual di atas kamera scanner: area di luar kotak viewfinder
/// digelapin, kotak viewfinder dikasih sudut bracket, dan ada garis scan
/// yang gerak naik-turun buat kesan "modern scanning".
///
/// Widget ini murni dekoratif (nggak pengaruh ke logic scan barcode),
/// jadi aman ditumpuk di atas MobileScanner tanpa risiko ganggu deteksi.
class ScannerOverlay extends StatefulWidget {
  const ScannerOverlay({
    super.key,
    this.cutoutWidth = 280,
    this.cutoutHeight = 180,
    this.borderRadius = 24,
    this.accentColor = Colors.tealAccent,
  });

  final double cutoutWidth;
  final double cutoutHeight;
  final double borderRadius;
  final Color accentColor;

  @override
  State<ScannerOverlay> createState() => _ScannerOverlayState();
}

class _ScannerOverlayState extends State<ScannerOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.biggest;
          final cutout = Rect.fromCenter(
            center: size.center(Offset.zero),
            width: widget.cutoutWidth,
            height: widget.cutoutHeight,
          );

          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                size: size,
                painter: _ScannerOverlayPainter(
                  cutout: cutout,
                  borderRadius: widget.borderRadius,
                  accentColor: widget.accentColor,
                  lineProgress: _controller.value,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _ScannerOverlayPainter extends CustomPainter {
  _ScannerOverlayPainter({
    required this.cutout,
    required this.borderRadius,
    required this.accentColor,
    required this.lineProgress,
  });

  final Rect cutout;
  final double borderRadius;
  final Color accentColor;
  final double lineProgress;

  static const double _bracketLength = 26;
  static const double _bracketThickness = 4;

  @override
  void paint(Canvas canvas, Size size) {
    final cutoutRRect = RRect.fromRectAndRadius(
      cutout,
      Radius.circular(borderRadius),
    );

    // 1. Gelapin seluruh layar kecuali area cutout.
    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final cutoutPath = Path()..addRRect(cutoutRRect);
    final scrimPath = Path.combine(
      PathOperation.difference,
      backgroundPath,
      cutoutPath,
    );
    canvas.drawPath(scrimPath, Paint()..color = Colors.black.withOpacity(0.6));

    // 2. Border tipis di sekeliling cutout.
    canvas.drawRRect(
      cutoutRRect,
      Paint()
        ..color = Colors.white.withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // 3. Sudut bracket di 4 pojok (gaya modern kayak viewfinder kamera).
    final bracketPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = _bracketThickness
      ..strokeCap = StrokeCap.round;

    void drawCorner(Offset corner, Offset horizontalDir, Offset verticalDir) {
      canvas.drawLine(corner, corner + horizontalDir * _bracketLength, bracketPaint);
      canvas.drawLine(corner, corner + verticalDir * _bracketLength, bracketPaint);
    }

    drawCorner(cutout.topLeft, const Offset(1, 0), const Offset(0, 1));
    drawCorner(cutout.topRight, const Offset(-1, 0), const Offset(0, 1));
    drawCorner(cutout.bottomLeft, const Offset(1, 0), const Offset(0, -1));
    drawCorner(cutout.bottomRight, const Offset(-1, 0), const Offset(0, -1));

    // 4. Garis scan animasi, gerak naik-turun di dalam cutout.
    final lineY = cutout.top + cutout.height * lineProgress;
    final lineRect = Rect.fromLTWH(
      cutout.left + 8,
      lineY - 1,
      cutout.width - 16,
      2,
    );
    final linePaint = Paint()
      ..shader = LinearGradient(
        colors: [
          accentColor.withOpacity(0),
          accentColor.withOpacity(0.9),
          accentColor.withOpacity(0),
        ],
      ).createShader(lineRect);
    canvas.drawRect(lineRect, linePaint);
  }

  @override
  bool shouldRepaint(covariant _ScannerOverlayPainter oldDelegate) {
    return oldDelegate.lineProgress != lineProgress ||
        oldDelegate.cutout != cutout ||
        oldDelegate.accentColor != accentColor;
  }
}
