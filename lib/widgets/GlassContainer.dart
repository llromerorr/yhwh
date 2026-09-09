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
  final bool enableShadows;
  final bool useGrouped;

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
    this.enableShadows = true,
    this.useGrouped = true,
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
      ),
      child: child,
    );

    Widget inner;
    if (!enableAcrylic || blur <= 0) {
      inner = effectiveRadius == BorderRadius.zero
          ? content
          : ClipRRect(
              borderRadius: effectiveRadius,
              child: content,
            );
    } else {
      final imageFilter = ImageFilter.blur(
        sigmaX: blur,
        sigmaY: blur,
        tileMode: TileMode.mirror,
      );

      final filterWidget = BackdropFilter.grouped(
        filter: imageFilter,
        child: content,
      );

      inner = ClipRRect(
        borderRadius: effectiveRadius,
        child: filterWidget,
      );
    }

    final effectiveShadows = enableShadows ? boxShadow : null;
    if (effectiveShadows != null && effectiveShadows.isNotEmpty) {
      return Container(
        margin: margin,
        decoration: BoxDecoration(
          borderRadius: effectiveRadius,
          boxShadow: effectiveShadows,
        ),
        child: inner,
      );
    }

    return Container(
      margin: margin,
      child: inner,
    );
  }
}
