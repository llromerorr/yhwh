import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yhwh/controllers/ReadPreferencesController.dart';
import 'package:yhwh/widgets/GlassContainer.dart';

class FloatingWidget extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const FloatingWidget({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.all(24.0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GetBuilder<ReadPreferencesController>(
      init: ReadPreferencesController(),
      builder: (readPrefs) {
        return Container(
          color: Colors.transparent,
          child: Padding(
            padding: padding,
            child: SafeArea(
              child: GlassContainer(
                enableAcrylic: readPrefs.enableAcrylicEffect,
                blur: isDark ? 23.0 : 19.0,
                borderRadius: BorderRadius.circular(24.0),
                border: Border.all(
                  color: Theme.of(context).indicatorColor.withValues(
                        alpha: isDark ? 0.45 : 0.22,
                      ),
                  width: 1.2,
                ),
                gradient: readPrefs.enableAcrylicEffect
                    ? (isDark
                        ? LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Theme.of(context).canvasColor.withValues(alpha: 0.55),
                              Theme.of(context).canvasColor.withValues(alpha: 0.35),
                            ],
                          )
                        : LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.white.withValues(alpha: 0.75),
                              Colors.white.withValues(alpha: 0.45),
                            ],
                          ))
                    : null,
                color: readPrefs.enableAcrylicEffect ? null : Theme.of(context).canvasColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.40 : 0.12),
                    blurRadius: 24.0,
                    offset: const Offset(0, 8),
                  ),
                ],
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }
}