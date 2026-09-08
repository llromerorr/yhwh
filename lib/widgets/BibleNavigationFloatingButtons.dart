import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:yhwh/controllers/BiblePageController.dart';
import 'package:yhwh/controllers/ReadPreferencesController.dart';
import 'package:yhwh/pages/ReadPreferences.dart';
import 'package:yhwh/widgets/GlassContainer.dart';

/// Botones flotantes nativos para navegación de capítulos con estética iOS Liquid Glass y física elástica
class BibleNavigationFloatingButtons extends StatelessWidget {
  const BibleNavigationFloatingButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BiblePageController>(
      id: 'floatingActionButton',
      init: BiblePageController(),
      builder: (biblePageController) => GetBuilder<ReadPreferencesController>(
        init: ReadPreferencesController(),
        builder: (readPrefs) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final indicatorColor = Theme.of(context).indicatorColor;
          final canvasColor = Theme.of(context).canvasColor;
          final borderColor = indicatorColor.withValues(
            alpha: isDark ? 0.18 : 0.14,
          );
          final blur = isDark
              ? ControlCenterVisualConfig.darkBlurSigma
              : ControlCenterVisualConfig.lightBlurSigma;

          final neutralGradient = isDark
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    indicatorColor.withValues(
                      alpha: readPrefs.enableAcrylicEffect
                          ? ControlCenterVisualConfig.darkButtonTopAlpha
                          : 0.15,
                    ),
                    indicatorColor.withValues(
                      alpha: readPrefs.enableAcrylicEffect
                          ? ControlCenterVisualConfig.darkButtonBottomAlpha
                          : 0.05,
                    ),
                  ],
                )
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    readPrefs.enableAcrylicEffect
                        ? Colors.white.withValues(
                            alpha: ControlCenterVisualConfig.lightButtonTopAlpha,
                          )
                        : const Color(0xFFFFFFFF),
                    readPrefs.enableAcrylicEffect
                        ? Colors.white.withValues(
                            alpha: ControlCenterVisualConfig.lightButtonBottomAlpha,
                          )
                        : const Color(0xFFE2E4EA),
                  ],
                );

          return AnimatedScale(
            scale: 1.0,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: AnimatedOpacity(
              opacity: 1.0,
              duration: const Duration(milliseconds: 200),
              child: IgnorePointer(
                ignoring: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      // Genera efecto de movimiento en el botón flotante izquierdo
                      AnimatedPadding(
                        padding: EdgeInsets.symmetric(
                          horizontal: (biblePageController.bookNumber == 1 &&
                                  biblePageController.chapterNumber == 1)
                              ? 2
                              : 0,
                        ),
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      ),

                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        switchInCurve: Curves.easeInOut,
                        switchOutCurve: Curves.easeInOut,
                        child: (biblePageController.bookNumber == 1 &&
                                biblePageController.chapterNumber == 1)
                            ? const SizedBox()
                            : _BouncyNavigationButton(
                                tooltip: 'Capitulo anterior',
                                icon: Icons.keyboard_arrow_left,
                                onTap: biblePageController.previusChapter,
                                gradient: neutralGradient,
                                borderColor: borderColor,
                                indicatorColor: indicatorColor,
                                canvasColor: canvasColor,
                                enableAcrylic: readPrefs.enableAcrylicEffect,
                                blur: blur,
                                isDark: isDark,
                              ),
                      ),

                      Expanded(child: SizedBox.fromSize()),

                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        switchInCurve: Curves.easeInOut,
                        switchOutCurve: Curves.easeInOut,
                        child: (biblePageController.bookNumber == 66 &&
                                biblePageController.chapterNumber == 22)
                            ? const SizedBox()
                            : _BouncyNavigationButton(
                                tooltip: 'Capitulo siguiente',
                                icon: Icons.keyboard_arrow_right,
                                onTap: biblePageController.nextChapter,
                                gradient: neutralGradient,
                                borderColor: borderColor,
                                indicatorColor: indicatorColor,
                                canvasColor: canvasColor,
                                enableAcrylic: readPrefs.enableAcrylicEffect,
                                blur: blur,
                                isDark: isDark,
                              ),
                      ),

                      // Genera efecto de movimiento en el botón flotante derecho
                      AnimatedPadding(
                        padding: EdgeInsets.symmetric(
                          horizontal: (biblePageController.bookNumber == 66 &&
                                  biblePageController.chapterNumber == 22)
                              ? 2
                              : 0,
                        ),
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Botón elástico interactivo con háptica y estética de cristalería fina
class _BouncyNavigationButton extends StatefulWidget {
  final String tooltip;
  final IconData icon;
  final VoidCallback onTap;
  final Gradient? gradient;
  final Color borderColor;
  final Color indicatorColor;
  final Color canvasColor;
  final bool enableAcrylic;
  final double blur;
  final bool isDark;

  const _BouncyNavigationButton({
    Key? key,
    required this.tooltip,
    required this.icon,
    required this.onTap,
    required this.gradient,
    required this.borderColor,
    required this.indicatorColor,
    required this.canvasColor,
    required this.enableAcrylic,
    required this.blur,
    required this.isDark,
  }) : super(key: key);

  @override
  State<_BouncyNavigationButton> createState() => _BouncyNavigationButtonState();
}

class _BouncyNavigationButtonState extends State<_BouncyNavigationButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          HapticFeedback.lightImpact();
          widget.onTap();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: _isPressed ? 0.88 : 1.0,
          duration: const Duration(milliseconds: 130),
          curve: Curves.easeOutBack,
          child: GlassContainer(
            enableAcrylic: widget.enableAcrylic,
            blur: widget.blur,
            width: 45.0,
            height: 45.0,
            borderRadius: BorderRadius.circular(30.0),
            border: Border.all(
              color: widget.borderColor,
              width: 1.0,
            ),
            gradient: widget.gradient,
            color: widget.enableAcrylic ? null : widget.canvasColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: widget.isDark ? 0.30 : 0.08,
                ),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            child: Center(
              child: Icon(
                widget.icon,
                color: widget.indicatorColor,
                size: 24,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
