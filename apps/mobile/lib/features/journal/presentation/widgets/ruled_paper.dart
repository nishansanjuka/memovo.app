import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_theme.dart';

class RuledPaper extends StatelessWidget {
  final Widget child;
  final double horizontalPadding;
  final double verticalPadding;
  final bool showDateLine;
  final String? date;

  const RuledPaper({
    super.key,
    required this.child,
    this.horizontalPadding = 40.0,
    this.verticalPadding = 60.0,
    this.showDateLine = true,
    this.date,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final paperColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final lineColor = isDark
        ? Colors.white.withOpacity(0.05)
        : AppTheme.primary(context).withOpacity(0.1);
    final marginColor = isDark
        ? AppTheme.primary(context).withOpacity(0.1)
        : AppTheme.primary(context).withOpacity(0.15);
    final textColor = AppTheme.text(context).withOpacity(0.7);

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(color: paperColor),
      child: CustomPaint(
        painter: _RuledLinePainter(
          lineColor: lineColor,
          marginColor: marginColor,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showDateLine && date != null)
                Container(
                  width: double.infinity,
                  alignment: Alignment.topRight,
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Text(
                    date!,
                    style: TextStyle(
                      fontFamily: 'Serif',
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                      color: textColor,
                    ),
                  ),
                ),
              Expanded(child: child),
            ],
          ),
        ),
      ),
    );
  }
}

class _RuledLinePainter extends CustomPainter {
  final Color lineColor;
  final Color marginColor;

  _RuledLinePainter({required this.lineColor, required this.marginColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 1.0;

    // Draw horizontal lines
    const double lineSpacing = 28.0;
    const double startY = 100.0;

    for (double y = startY; y < size.height; y += lineSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Draw vertical margin line
    final marginPaint = Paint()
      ..color = marginColor
      ..strokeWidth = 1.5;

    canvas.drawLine(const Offset(60, 0), Offset(60, size.height), marginPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
