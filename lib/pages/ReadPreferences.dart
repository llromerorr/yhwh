import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:yhwh/controllers/BiblePageController.dart';
import 'package:yhwh/controllers/ReadPreferencesController.dart';
import 'package:yhwh/widgets/GlassContainer.dart';

// =============================================================================
// 🎛️ PANEL DE CONTROL VISUAL (Modifica estos valores para ajustar la estética)
// =============================================================================
abstract class ControlCenterVisualConfig {
  // --- 1. BANDEJA DEL PANEL (FONDO PRINCIPAL) ---
  /// Opacidad superior del fondo en Modo Claro (0.0 = 100% transparente, 1.0 = sólido)
  static const double lightPanelTopAlpha = 0.9;
  /// Opacidad inferior del fondo en Modo Claro
  static const double lightPanelBottomAlpha = 0;

  /// Opacidad superior del fondo en Modo Oscuro / OLED
  static const double darkPanelTopAlpha = 0;
  /// Opacidad inferior del fondo en Modo Oscuro / OLED
  static const double darkPanelBottomAlpha = 0;

  // --- 2. BOTONES Y MÓDULOS EN REPOSO ---
  /// Opacidad superior de los botones en Modo Claro
  static const double lightButtonTopAlpha = 0.5;
  /// Opacidad inferior de los botones en Modo Claro
  static const double lightButtonBottomAlpha = 0.5;

  /// Opacidad de los botones en Modo Oscuro
  static const double darkButtonTopAlpha = 0.05;
  static const double darkButtonBottomAlpha = 0.05;

  // --- 3. DESENFOQUE GAUSSIANO (BLUR) ---
  /// Intensidad del desenfoque en Modo Claro (16px difumina el texto pero deja ver los colores)
  static const double lightBlurSigma = 19.0;
  /// Intensidad del desenfoque en Modo Oscuro (18px)
  static const double darkBlurSigma = 23.0;
}

/// Centro de Control de Lectura Flotante (Diseño iOS 18 Liquid Glass & Neumorfismo Gradiente 3D)
class ReadPreferencesControlCenter extends StatelessWidget {
  const ReadPreferencesControlCenter({Key? key}) : super(key: key);

  /// Abre el Centro de Control directamente sobre la lectura
  static Future<void> show(BuildContext context) {
    if (Get.isRegistered<BiblePageController>()) {
      Get.find<BiblePageController>().setBottomSheetState(true);
    }
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      isDismissible: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.transparent, // Fondo cristalino sin velo gris
      builder: (context) => const ReadPreferencesControlCenter(),
    ).then((_) {
      if (Get.isRegistered<ReadPreferencesController>()) {
        Get.find<ReadPreferencesController>().dismissToast();
      }
      if (Get.isRegistered<BiblePageController>()) {
        Get.find<BiblePageController>().setBottomSheetState(false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BiblePageController>(
      init: BiblePageController(),
      builder: (biblePageController) => GetBuilder<ReadPreferencesController>(
        init: ReadPreferencesController(),
        builder: (controller) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final indicatorColor = Theme.of(context).indicatorColor;
          final canvasColor = Theme.of(context).canvasColor;

          // Gradiente 3D para módulos en reposo
          final neutralGradient = isDark
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    indicatorColor.withValues(
                      alpha: controller.enableAcrylicEffect
                          ? ControlCenterVisualConfig.darkButtonTopAlpha
                          : 0.15,
                    ),
                    indicatorColor.withValues(
                      alpha: controller.enableAcrylicEffect
                          ? ControlCenterVisualConfig.darkButtonBottomAlpha
                          : 0.05,
                    ),
                  ],
                )
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    controller.enableAcrylicEffect
                        ? Colors.white.withValues(alpha: ControlCenterVisualConfig.lightButtonTopAlpha)
                        : const Color(0xFFFFFFFF),
                    controller.enableAcrylicEffect
                        ? Colors.white.withValues(alpha: ControlCenterVisualConfig.lightButtonBottomAlpha)
                        : const Color(0xFFE2E4EA),
                  ],
                );

          // Gradiente 3D para módulos activos (Negro azabache profundo con reflejo o Platino en oscuro)
          final activeGradient = isDark
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    indicatorColor,
                    indicatorColor.withValues(alpha: 0.85),
                  ],
                )
              : const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF2E2E34),
                    Color(0xFF111114),
                  ],
                );

          final borderColor = isDark
              ? indicatorColor.withValues(alpha: 0.18)
              : indicatorColor.withValues(alpha: 0.14);
          final topBorderColor = isDark
              ? indicatorColor.withValues(alpha: 0.45)
              : indicatorColor.withValues(alpha: 0.22);
          final inactiveIconColor = isDark
              ? indicatorColor.withValues(alpha: 0.70)
              : const Color(0xff27272A);
          final activeIconColor = isDark ? canvasColor : Colors.white;

          // Estilo 3D Apple Segmented Control para Alineación
          final segmentActiveGradient = isDark
              ? activeGradient
              : neutralGradient;
          final segmentActiveIconColor = isDark ? canvasColor : inactiveIconColor;
          final segmentInactiveIconColor = isDark
              ? indicatorColor.withValues(alpha: 0.70)
              : indicatorColor.withValues(alpha: 0.38);

          // CONTENIDO INTERNO DEL PANEL
          Widget panelContent = Container(
            constraints: const BoxConstraints(maxWidth: 480),
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
            decoration: BoxDecoration(
              gradient: controller.enableAcrylicEffect
                  ? (isDark
                      ? LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            canvasColor.withValues(alpha: ControlCenterVisualConfig.darkPanelTopAlpha),
                            canvasColor.withValues(alpha: ControlCenterVisualConfig.darkPanelBottomAlpha),
                          ],
                        )
                      : LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withValues(alpha: ControlCenterVisualConfig.lightPanelTopAlpha),
                            Colors.white.withValues(alpha: ControlCenterVisualConfig.lightPanelBottomAlpha),
                          ],
                        ))
                  : null,
              color: controller.enableAcrylicEffect ? null : canvasColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              border: Border(
                top: BorderSide(
                  color: topBorderColor,
                  width: 1.5,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                  blurRadius: 28,
                  offset: const Offset(0, -6),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Tirador de arrastre superior (Drag Handle estilo iOS)
                  Container(
                    width: 42,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 18),
                    decoration: BoxDecoration(
                      color: indicatorColor.withValues(alpha: isDark ? 0.30 : 0.20),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),

                  // BLOQUE 1: CONTROLES DE APARIENCIA Y FORMATO (Altura emparejada: 140px)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Cápsula vertical deslizante para el tamaño de letra (Apple iOS 18 Slider)
                      Expanded(
                        flex: 5,
                        child: _FontSizeCapsuleSlider(
                          controller: controller,
                          neutralGradient: neutralGradient,
                          activeGradient: activeGradient,
                          indicatorColor: indicatorColor,
                          canvasColor: canvasColor,
                          borderColor: borderColor,
                          enableLiquidGlass: controller.enableAcrylicEffect,
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Columna derecha: Selectores y Alineación (64px + 12px + 64px = 140px)
                      Expanded(
                        flex: 7,
                        child: Column(
                          children: [
                            // FILA 1: Tema (☀️/🌅/🌙) y Tipografía (A)
                            Row(
                              children: [
                                // Botón 1: Tema visual cíclico con morphing animado
                                Expanded(
                                  child: _BouncyControlModule(
                                    height: 64,
                                    onTap: controller.cycleTheme,
                                    gradient: neutralGradient,
                                    borderColor: borderColor,
                                    enableLiquidGlass: controller.enableAcrylicEffect,
                                    child: AnimatedSwitcher(
                                      duration: const Duration(milliseconds: 250),
                                      transitionBuilder: (child, anim) => ScaleTransition(
                                        scale: anim,
                                        child: RotationTransition(
                                          turns: Tween<double>(begin: 0.85, end: 1.0).animate(anim),
                                          child: child,
                                        ),
                                      ),
                                      child: _buildThemeIcon(
                                        controller.currentThemeName,
                                        inactiveIconColor,
                                        key: ValueKey(controller.currentThemeName),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // Botón 2: Tipografía cíclica con morphing animado de la letra 'A'
                                Expanded(
                                  child: _BouncyControlModule(
                                    height: 64,
                                    onTap: controller.cycleFontFamily,
                                    gradient: neutralGradient,
                                    borderColor: borderColor,
                                    enableLiquidGlass: controller.enableAcrylicEffect,
                                    child: AnimatedSwitcher(
                                      duration: const Duration(milliseconds: 250),
                                      transitionBuilder: (child, anim) => ScaleTransition(
                                        scale: anim,
                                        child: FadeTransition(opacity: anim, child: child),
                                      ),
                                      child: Text(
                                        "A",
                                        key: ValueKey(controller.currentFontFamily),
                                        style: TextStyle(
                                          fontFamily: controller.currentFontFamily,
                                          fontSize: 30,
                                          fontWeight: FontWeight.bold,
                                          color: inactiveIconColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // FILA 2: Segmento de Alineación 3D (Izquierda | Justificado)
                            Container(
                              height: 64,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? (controller.enableAcrylicEffect
                                        ? indicatorColor.withValues(alpha: 0.08)
                                        : null)
                                    : (controller.enableAcrylicEffect
                                        ? indicatorColor.withValues(alpha: 0.04)
                                        : indicatorColor.withValues(alpha: 0.06)),
                                gradient: isDark
                                    ? (controller.enableAcrylicEffect ? null : neutralGradient)
                                    : null,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isDark ? borderColor : indicatorColor.withValues(alpha: 0.10),
                                  width: 1.2,
                                ),
                                boxShadow: [
                                  if (isDark && !controller.enableAcrylicEffect)
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.40),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  // Alineación Izquierda
                                  Expanded(
                                    child: _BouncyControlModule(
                                      height: 56,
                                      margin: const EdgeInsets.all(4),
                                      enableLiquidGlass: controller.enableAcrylicEffect,
                                      onTap: () {
                                        if (controller.isJustified) {
                                          HapticFeedback.mediumImpact();
                                          controller.setJustified(false);
                                        }
                                      },
                                      gradient: !controller.isJustified ? segmentActiveGradient : null,
                                      isActive: !controller.isJustified,
                                      borderColor: isDark
                                          ? Colors.transparent
                                          : (!controller.isJustified
                                              ? borderColor
                                              : Colors.transparent),
                                      child: AnimatedScale(
                                        scale: !controller.isJustified ? 1.08 : 0.92,
                                        duration: const Duration(milliseconds: 200),
                                        curve: Curves.easeOutBack,
                                        child: Icon(
                                          Icons.format_align_left_rounded,
                                          size: 24,
                                          color: !controller.isJustified ? segmentActiveIconColor : segmentInactiveIconColor,
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Alineación Justificada
                                  Expanded(
                                    child: _BouncyControlModule(
                                      height: 56,
                                      margin: const EdgeInsets.all(4),
                                      enableLiquidGlass: controller.enableAcrylicEffect,
                                      onTap: () {
                                        if (!controller.isJustified) {
                                          HapticFeedback.mediumImpact();
                                          controller.setJustified(true);
                                        }
                                      },
                                      gradient: controller.isJustified ? segmentActiveGradient : null,
                                      isActive: controller.isJustified,
                                      borderColor: isDark
                                          ? Colors.transparent
                                          : (controller.isJustified
                                              ? borderColor
                                              : Colors.transparent),
                                      child: AnimatedScale(
                                        scale: controller.isJustified ? 1.08 : 0.92,
                                        duration: const Duration(milliseconds: 200),
                                        curve: Curves.easeOutBack,
                                        child: Icon(
                                          Icons.format_align_justify_rounded,
                                          size: 24,
                                          color: controller.isJustified ? segmentActiveIconColor : segmentInactiveIconColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // BLOQUE 2: TOGGLES DE ACTIVACIÓN AGRUPADOS + RESET (Gradientes 3D iOS 18)
                  Row(
                    children: [
                      // TOGGLE 1: Pantalla Siempre Activa (Ícono de teléfono despierto)
                      Expanded(
                        child: _BouncyControlModule(
                          height: 56,
                          onTap: controller.toggleKeepScreenOn,
                          gradient: controller.keepScreenOn ? activeGradient : neutralGradient,
                          isActive: controller.keepScreenOn,
                          borderColor: controller.keepScreenOn ? Colors.transparent : borderColor,
                          enableLiquidGlass: controller.enableAcrylicEffect,
                          child: AnimatedScale(
                            scale: controller.keepScreenOn ? 1.08 : 1.0,
                            duration: const Duration(milliseconds: 180),
                            child: Icon(
                              Icons.smartphone_rounded,
                              size: 26,
                              color: controller.keepScreenOn ? activeIconColor : inactiveIconColor,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // TOGGLE 2: Efecto Cristal / Acrílico (Ícono de desenfoque / blur)
                      Expanded(
                        child: _BouncyControlModule(
                          height: 56,
                          onTap: controller.toggleAcrylic,
                          gradient: controller.enableAcrylicEffect ? activeGradient : neutralGradient,
                          isActive: controller.enableAcrylicEffect,
                          borderColor: controller.enableAcrylicEffect ? Colors.transparent : borderColor,
                          enableLiquidGlass: controller.enableAcrylicEffect,
                          child: AnimatedScale(
                            scale: controller.enableAcrylicEffect ? 1.08 : 1.0,
                            duration: const Duration(milliseconds: 180),
                            child: Icon(
                              controller.enableAcrylicEffect
                                  ? Icons.blur_on_rounded
                                  : Icons.blur_off_rounded,
                              size: 26,
                              color: controller.enableAcrylicEffect ? activeIconColor : inactiveIconColor,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // BOTÓN 3: Restablecer valores iniciales
                      Expanded(
                        child: _BouncyControlModule(
                          height: 56,
                          onTap: controller.resetToDefaults,
                          gradient: neutralGradient,
                          borderColor: borderColor,
                          enableLiquidGlass: controller.enableAcrylicEffect,
                          child: Icon(
                            Icons.restart_alt_rounded,
                            size: 26,
                            color: inactiveIconColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );

          // EFECTO DE CRISTAL ACRÍLICO UNIFICADO (GlassContainer Nativo con aceleración en GPU)
          Widget finalPanel = GlassContainer(
            enableAcrylic: controller.enableAcrylicEffect,
            blur: isDark
                ? ControlCenterVisualConfig.darkBlurSigma
                : ControlCenterVisualConfig.lightBlurSigma,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            child: panelContent,
          );

          // ESTRUCTURA CON AVISO FLOTANDO POR ENCIMA DEL PANEL (Control Center)
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ZONA HUD FLOTANTE CON ALTURA ESTABLE (Mantiene la altura del modal 100% constante evitando saltos al desaparecer)
              IgnorePointer(
                ignoring: controller.toastMessage == null,
                child: SizedBox(
                  height: 52,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      switchInCurve: Curves.easeOutBack,
                      switchOutCurve: Curves.easeIn,
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: ScaleTransition(
                            scale: Tween<double>(begin: 0.85, end: 1.0).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: controller.toastMessage != null
                          ? GestureDetector(
                              key: ValueKey(controller.toastMessage),
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                HapticFeedback.selectionClick();
                                controller.dismissToast();
                              },
                              onVerticalDragEnd: (_) {
                                HapticFeedback.selectionClick();
                                controller.dismissToast();
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(300.0),
                                  child: controller.enableAcrylicEffect
                                      ? BackdropFilter(
                                          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12, tileMode: TileMode.mirror),
                                          child: _buildToastCard(context, controller, indicatorColor, isDark),
                                        )
                                      : _buildToastCard(context, controller, indicatorColor, isDark),
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),
                ),
              ),

              // EL PANEL DEL CENTRO DE CONTROL
              finalPanel,
            ],
          );
        },
      ),
    );
  }

  Widget _buildToastCard(BuildContext context, ReadPreferencesController controller, Color indicatorColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        color: controller.enableAcrylicEffect
            ? Theme.of(context).canvasColor.withValues(alpha: isDark ? 0.20 : 0.85)
            : Theme.of(context).canvasColor,
        borderRadius: BorderRadius.circular(300.0),
        border: Border.all(
          color: indicatorColor.withValues(alpha: isDark ? 0.50 : 0.20),
          width: 1.5,
        ),
        boxShadow: [
          if (!isDark) ...[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ] else ...[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.50),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ],
      ),
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.noScaling,
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (controller.toastIcon != null) ...[
                Icon(
                  controller.toastIcon,
                  size: 16,
                  color: indicatorColor,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                controller.toastMessage!,
                maxLines: 1,
                style: TextStyle(
                  color: indicatorColor,
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeIcon(String themeName, Color iconColor, {Key? key}) {
    switch (themeName) {
      case 'Blanco':
        return Icon(
          Icons.wb_sunny_rounded,
          key: key,
          size: 28,
          color: iconColor,
        );
      case 'Negro':
        return Icon(
          Icons.wb_twilight_rounded,
          key: key,
          size: 28,
          color: iconColor,
        );
      case 'OLED':
      default:
        return Icon(
          Icons.dark_mode_rounded,
          key: key,
          size: 26,
          color: iconColor,
        );
    }
  }
}

/// Cápsula Vertical Táctil con Máscara de Recorte Dual Apple y Gradientes 3D iOS 18
class _FontSizeCapsuleSlider extends StatefulWidget {
  final ReadPreferencesController controller;
  final Gradient neutralGradient;
  final Gradient activeGradient;
  final Color indicatorColor;
  final Color canvasColor;
  final Color borderColor;
  final bool enableLiquidGlass;

  const _FontSizeCapsuleSlider({
    Key? key,
    required this.controller,
    required this.neutralGradient,
    required this.activeGradient,
    required this.indicatorColor,
    required this.canvasColor,
    required this.borderColor,
    this.enableLiquidGlass = false,
  }) : super(key: key);

  @override
  State<_FontSizeCapsuleSlider> createState() => _FontSizeCapsuleSliderState();
}

class _FontSizeCapsuleSliderState extends State<_FontSizeCapsuleSlider> {
  static const double sliderHeight = 140.0;
  bool _isPressed = false;

  double _dragStartY = 0.0;
  int _dragStartIndex = 2;
  bool _hasMoved = false;

  // 18 píxeles de desplazamiento vertical por cada nivel
  static const double pixelsPerStep = 18.0;

  void _handleDragStart(DragStartDetails details) {
    setState(() {
      _isPressed = true;
      _hasMoved = false;
    });
    _dragStartY = details.globalPosition.dy;
    _dragStartIndex = widget.controller.currentFontLevelIndex;
    HapticFeedback.lightImpact();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    double totalDeltaY = _dragStartY - details.globalPosition.dy; // Desplazar hacia arriba suma niveles
    if (totalDeltaY.abs() > 4) {
      _hasMoved = true;
    }

    int stepOffset = (totalDeltaY / pixelsPerStep).round();
    int targetIndex = (_dragStartIndex + stepOffset).clamp(0, ReadPreferencesController.fontLevels.length - 1);

    if (targetIndex != widget.controller.currentFontLevelIndex) {
      // Vibración háptica real y nítida
      if (targetIndex == 0 || targetIndex == ReadPreferencesController.fontLevels.length - 1) {
        HapticFeedback.mediumImpact(); // Tope mínimo o máximo
      } else {
        HapticFeedback.lightImpact(); // Salto de nivel
      }
      widget.controller.setFontSizeByIndex(targetIndex);
    }
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    if (!_hasMoved) {
      HapticFeedback.lightImpact();
      // Toque en mitad superior: +1 nivel; toque en mitad inferior: -1 nivel
      if (details.localPosition.dy < sliderHeight / 2) {
        widget.controller.stepUpFontSize();
      } else {
        widget.controller.stepDownFontSize();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Mapeo calibrado estilo iOS: en nivel 0 (16 pt) el relleno es del 30% (cubre el icono completo), y sube de 10% en 10% hasta el 100%
    int levelIndex = widget.controller.currentFontLevelIndex;
    int totalLevels = ReadPreferencesController.fontLevels.length;
    double targetFill = (levelIndex / (totalLevels - 1)) * 0.70 + 0.30;

    Widget sliderBody = Container(
      height: sliderHeight,
      decoration: BoxDecoration(
        gradient: widget.neutralGradient,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: widget.borderColor,
          width: 1.2,
        ),
        boxShadow: [
          if (!isDark) ...[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.white.withValues(alpha: widget.enableLiquidGlass ? 0.35 : 0.95),
              blurRadius: 2,
              offset: const Offset(0, -1),
            ),
          ] else ...[
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.06),
              blurRadius: 1,
              offset: const Offset(0, -1),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.45),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22.8),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // BARRA DE LLENADO ACTIVA CON SPRING PHYSICS ANIMADO
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: targetFill, end: targetFill),
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              builder: (context, animatedFill, child) {
                return Align(
                  alignment: Alignment.bottomCenter,
                  child: FractionallySizedBox(
                    heightFactor: animatedFill,
                    widthFactor: 1.0,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: widget.activeGradient,
                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(22.8)),
                      ),
                    ),
                  ),
                );
              },
            ),

            // ICONO Y TEXTO CON EFECTO DE COLOR INVERSO DINÁMICO
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Indicador de nivel superior en escala de puntos
                    Text(
                      '${widget.controller.currentFontSize.toInt()}',
                      style: TextStyle(
                        fontFamily: 'SF Pro Display',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                        color: targetFill >= 0.85 
                            ? (isDark ? widget.canvasColor : Colors.white) 
                            : (isDark ? widget.indicatorColor.withValues(alpha: 0.85) : const Color(0xff27272A)),
                      ),
                    ),

                    // Icono Tt inferior
                    AnimatedScale(
                      scale: _isPressed ? 1.08 : 1.0,
                      duration: const Duration(milliseconds: 140),
                      curve: Curves.easeOutBack,
                      child: Icon(
                        Icons.text_fields_rounded,
                        size: 26,
                        color: targetFill >= 0.30
                            ? (isDark ? widget.canvasColor : Colors.white)
                            : (isDark ? widget.indicatorColor : const Color(0xff27272A)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return GestureDetector(
      onVerticalDragStart: _handleDragStart,
      onVerticalDragUpdate: _handleDragUpdate,
      onVerticalDragEnd: (_) => setState(() => _isPressed = false),
      onVerticalDragCancel: () => setState(() => _isPressed = false),
      onTapDown: (_) {
        setState(() => _isPressed = true);
        HapticFeedback.lightImpact();
      },
      onTapUp: _handleTapUp,
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutBack,
        child: sliderBody,
      ),
    );
  }
}

/// Módulo Táctil con Animación de Rebote Elástico y Sombra Neumórfica 3D con Gradientes iOS 18
class _BouncyControlModule extends StatefulWidget {
  final VoidCallback onTap;
  final Widget child;
  final Gradient? gradient;
  final Color? backgroundColor;
  final bool isActive;
  final Color borderColor;
  final double height;
  final EdgeInsetsGeometry? margin;
  final bool enableLiquidGlass;

  const _BouncyControlModule({
    Key? key,
    required this.onTap,
    required this.child,
    this.gradient,
    this.backgroundColor,
    this.isActive = false,
    required this.borderColor,
    this.height = 64.0,
    this.margin,
    this.enableLiquidGlass = false,
  }) : super(key: key);

  @override
  State<_BouncyControlModule> createState() => _BouncyControlModuleState();
}

class _BouncyControlModuleState extends State<_BouncyControlModule> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isTransparent = widget.gradient == null && (widget.backgroundColor == null || widget.backgroundColor == Colors.transparent);

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        HapticFeedback.lightImpact();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutBack,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeInOut,
          height: widget.height,
          margin: widget.margin,
          decoration: BoxDecoration(
            gradient: widget.gradient,
            color: widget.gradient == null ? widget.backgroundColor : null,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.borderColor,
              width: 1.2,
            ),
            boxShadow: [
              if (!isTransparent) ...[
                if (widget.isActive) ...[
                  // Botón Activo: Sombra profunda y relieve 3D táctil
                  BoxShadow(
                    color: isDark
                        ? widget.borderColor.withValues(alpha: 0.25)
                        : Colors.black.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                  if (!isDark) ...[
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 1,
                      offset: const Offset(0, 1),
                    ),
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.70),
                      blurRadius: 1,
                      offset: const Offset(0, -1),
                    ),
                  ],
                ] else ...[
                  if (!isDark) ...[
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: Colors.white.withValues(alpha: widget.enableLiquidGlass ? 0.35 : 0.95),
                      blurRadius: 2,
                      offset: const Offset(0, -1),
                    ),
                  ] else ...[
                    // Modo Oscuro / OLED: Bisel de cristal superior + sombra de oclusión
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.06),
                      blurRadius: 1,
                      offset: const Offset(0, -1),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.40),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ],
              ],
            ],
          ),
          child: Center(child: widget.child),
        ),
      ),
    );
  }
}

/// Envoltorio de compatibilidad para navegación directa
class ReadPreferences extends StatelessWidget {
  const ReadPreferences({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).canvasColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: Theme.of(context).indicatorColor,
      ),
      body: const Center(
        child: ReadPreferencesControlCenter(),
      ),
    );
  }
}
