import 'dart:ui';
import 'package:flutter/material.dart';

/// Contenedor de Cristal Acrílico Esmerilado Universal (Estilo iOS 18 / macOS Sonoma / Fluent 2)
/// Ofrece un desenfoque gaussiano nativo acelerado en GPU, tinte translúcido equilibrado
/// y soporte para biseles ópticos perimetrales sin sobrecarga de shaders.
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final BorderRadius? borderRadius;
  final Gradient? gradient;
  final Color? color;
  final Border? border;
  final List<BoxShadow>? boxShadow;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final BoxConstraints? constraints;
  final bool enableAcrylic;

  const GlassContainer({
    Key? key,
    required this.child,
    this.blur = 16.0,
    this.borderRadius,
    this.gradient,
    this.color,
    this.border,
    this.boxShadow,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.constraints,
    this.enableAcrylic = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = borderRadius ?? BorderRadius.zero;

    Widget content = Container(
      width: width,
      height: height,
      constraints: constraints,
      padding: padding,
      decoration: BoxDecoration(
        gradient: gradient,
        color: gradient == null ? color : null,
        borderRadius: effectiveRadius,
        border: border,
        boxShadow: boxShadow,
      ),
      child: child,
    );

    if (!enableAcrylic || blur <= 0) {
      return Container(
        margin: margin,
        child: content,
      );
    }

    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: effectiveRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: blur,
            sigmaY: blur,
            tileMode: TileMode.mirror,
          ),
          child: content,
        ),
      ),
    );
  }
}
