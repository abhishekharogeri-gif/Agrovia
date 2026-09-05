import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/agrovia_theme.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? surfaceColor;
  final Color? borderColor;

  const GlassContainer({
    super.key,
    required this.child,
    this.blur = 18.0,
    this.borderRadius = 16.0,
    this.padding,
    this.margin,
    this.surfaceColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = surfaceColor ?? (isDark ? AgroviaColors.glassSurfaceDark : AgroviaColors.glassSurface);
    final border = borderColor ?? (isDark ? AgroviaColors.glassBorderDark : AgroviaColors.glassBorder);

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding ?? const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(color: border, width: 1.5),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
