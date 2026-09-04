import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:simple_html_css/simple_html_css.dart';
import 'package:yhwh/controllers/ReadPreferencesController.dart';
import 'package:yhwh/pages/ReadPreferences.dart';
import 'package:yhwh/widgets/GlassContainer.dart';

/// Modelo de referencia bíblica estructurada para el panel
class ReferenceItem {
  final int book;
  final int chapter;
  final int verseFrom;
  final int? verseTo;
  final String label;

  const ReferenceItem({
    required this.book,
    required this.chapter,
    required this.verseFrom,
    this.verseTo,
    required this.label,
  });
}

/// Widget para medir el tamaño intrínseco posterior al layout
class _MeasureSize extends SingleChildRenderObjectWidget {
  final ValueChanged<Size> onChange;

  const _MeasureSize({
    Key? key,
    required this.onChange,
    required Widget child,
  }) : super(key: key, child: child);

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _MeasureSizeRenderObject(onChange);
}

class _MeasureSizeRenderObject extends RenderProxyBox {
  final ValueChanged<Size> onChange;
  Size? _prevSize;

  _MeasureSizeRenderObject(this.onChange);

  @override
  void performLayout() {
    super.performLayout();
    final newSize = child?.size ?? Size.zero;
    if (_prevSize != newSize) {
      _prevSize = newSize;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onChange(newSize);
      });
    }
  }
}

/// Panel Inferior de Referencias y Notas al Pie (Estilo Apple / Google Material 3)
///
/// Características clave:
/// - 100% Adaptable para fuentes desde 16 pt hasta 36 pt (modo accesibilidad).
/// - Altura intrínseca elástica: Abraza notas breves y limita pasajes largos con scroll suave.
/// - Cero texto redundante: Eliminadas etiquetas obvias ("Pasaje Relacionado", "Nota Lingüística", "Abrir").
/// - Píldoras táctiles con auto-centrado al deslizar y tamaño proporcional a la fuente.
/// - Cero aserciones de Scrollbar y cero espacio vacío inferior.
class ReferenceBottomSheet extends StatefulWidget {
  final String title;
  final String? footnoteBadge;
  final List<ReferenceItem> references;
  final String? rawHtmlContent;
  final Future<List<Widget>> Function(int book, int chapter, int verseFrom, int? verseTo) loadVerses;
  final void Function(int book, int chapter, int verse) onNavigate;

  const ReferenceBottomSheet({
    Key? key,
    required this.title,
    this.footnoteBadge,
    this.references = const [],
    this.rawHtmlContent,
    required this.loadVerses,
    required this.onNavigate,
  }) : super(key: key);

  /// Método de apertura unificado
  static Future<void> show({
    required BuildContext context,
    required String title,
    String? footnoteBadge,
    List<ReferenceItem> references = const [],
    String? rawHtmlContent,
    required Future<List<Widget>> Function(int book, int chapter, int verseFrom, int? verseTo) loadVerses,
    required void Function(int book, int chapter, int verse) onNavigate,
    required VoidCallback onDismissed,
  }) {
    return showModalBottomSheet(
      context: context,
      isDismissible: true,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.transparent,
      builder: (ctx) => ReferenceBottomSheet(
        title: title,
        footnoteBadge: footnoteBadge,
        references: references,
        rawHtmlContent: rawHtmlContent,
        loadVerses: loadVerses,
        onNavigate: onNavigate,
      ),
    ).then((_) => onDismissed());
  }

  @override
  State<ReferenceBottomSheet> createState() => _ReferenceBottomSheetState();
}

class _ReferenceBottomSheetState extends State<ReferenceBottomSheet>
    with SingleTickerProviderStateMixin {
  int _activeIndex = 0;
  late final PageController _pageController;
  final Map<int, List<Widget>> _cachedVerses = {};
  final Map<int, double> _pageHeights = {};
  double? _singleRefHeight;
  double? _htmlNoteHeight;
  bool _isExpanded = false;
  late final List<GlobalKey> _pillKeys;
  bool _isLoading = false;

  // Cinemática elástica (Rubber-Band Physics)
  late final AnimationController _springController;
  Animation<double>? _springAnimation;
  double _dragOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pillKeys = List.generate(widget.references.length, (_) => GlobalKey());
    _springController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    )..addListener(() {
        if (_springAnimation != null) {
          setState(() {
            _dragOffset = _springAnimation!.value;
          });
        }
      });
    if (widget.references.isNotEmpty) {
      _loadCurrentIndex(0);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _springController.dispose();
    super.dispose();
  }

  void _handleDragStart(DragStartDetails details) {
    _springController.stop();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    final dy = details.delta.dy;
    if (dy > 0) {
      // Arrastre hacia abajo con resistencia elástica progresiva (Rubber-band)
      setState(() {
        _dragOffset += dy * 0.55;
      });
    } else if (dy < 0) {
      // Arrastre hacia arriba: solo reduce el offset si ya estaba jalado hacia abajo
      if (_dragOffset > 0) {
        setState(() {
          _dragOffset = math.max(0.0, _dragOffset + dy * 0.6);
        });
      }
      // Desde el cuerpo del texto NUNCA se amplía el panel
    }
  }

  void _handleHeaderDragUpdate(DragUpdateDetails details) {
    final dy = details.delta.dy;
    if (dy > 0) {
      setState(() {
        _dragOffset += dy * 0.55;
      });
    } else if (dy < 0) {
      if (_dragOffset > 0) {
        setState(() {
          _dragOffset = math.max(0.0, _dragOffset + dy * 0.6);
        });
      } else if (!_isExpanded && dy < -5) {
        // En la parte superior del panel SÍ se permite elevar a pantalla amplia
        HapticFeedback.mediumImpact();
        setState(() {
          _isExpanded = true;
        });
      }
    }
  }

  void _finishDrag({double velocity = 0.0}) {
    // Cierre deliberado: arrastre amplio (> 100 px) o lanzamiento rápido hacia abajo (> 800 px/s)
    if (_dragOffset > 100 || velocity > 800) {
      _dismissSheet();
    } else if (_isExpanded && (velocity > 380 || _dragOffset > 45)) {
      // Si está expandido y tira hacia abajo, contraer al modo compacto
      HapticFeedback.lightImpact();
      setState(() {
        _isExpanded = false;
        _dragOffset = 0.0;
      });
    } else {
      // Rebote elástico de vuelta a la posición original
      _bounceBack();
    }
  }

  void _handleDragEnd(DragEndDetails details) {
    _finishDrag(velocity: details.primaryVelocity ?? 0.0);
  }

  void _bounceBack() {
    if (_dragOffset == 0.0) return;
    HapticFeedback.lightImpact();
    _springAnimation = Tween<double>(
      begin: _dragOffset,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _springController,
      curve: Curves.easeOutBack,
    ));
    _springController.duration = const Duration(milliseconds: 260);
    _springController.forward(from: 0.0);
  }

  void _dismissSheet() {
    final screenHeight = MediaQuery.of(context).size.height;
    _springAnimation = Tween<double>(
      begin: _dragOffset,
      end: screenHeight - _dragOffset + 150,
    ).animate(CurvedAnimation(
      parent: _springController,
      curve: Curves.easeInCubic,
    ));
    _springController.duration = const Duration(milliseconds: 180);
    _springController.forward(from: 0.0).then((_) {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }

  Future<void> _loadCurrentIndex(int index) async {
    if (index < 0 || index >= widget.references.length) return;
    if (_cachedVerses.containsKey(index)) return;

    setState(() => _isLoading = true);
    final ref = widget.references[index];
    final verses = await widget.loadVerses(ref.book, ref.chapter, ref.verseFrom, ref.verseTo);
    if (mounted) {
      setState(() {
        _cachedVerses[index] = verses;
        _isLoading = false;
      });
    }
  }

  void _onPageMeasured(int idx, double measuredHeight) {
    if (measuredHeight <= 0) return;
    if (_pageHeights[idx] != measuredHeight) {
      _pageHeights[idx] = measuredHeight;
    }
  }

  void _onPillTap(int index) {
    if (_activeIndex == index) return;
    HapticFeedback.lightImpact();
    setState(() => _activeIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
    _scrollToPill(index);
    _loadCurrentIndex(index);
  }

  void _scrollToPill(int index) {
    if (index < 0 || index >= _pillKeys.length) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final keyContext = _pillKeys[index].currentContext;
      if (keyContext != null) {
        Scrollable.ensureVisible(
          keyContext,
          alignment: 0.5,
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ReadPreferencesController>(
      builder: (readPrefs) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final indicatorColor = Theme.of(context).indicatorColor;
        final canvasColor = Theme.of(context).canvasColor;
        final screenHeight = MediaQuery.of(context).size.height;
        final screenWidth = MediaQuery.of(context).size.width;

        // Escalabilidad tipográfica calculada de forma armónica para todas las edades y modos visuales
        final baseFontSize = readPrefs.currentFontSize;
        final headerFontSize = (baseFontSize * 0.90).clamp(16.0, 24.0);
        final badgeFontSize = (baseFontSize * 0.72).clamp(11.0, 18.0);
        final contentFontSize = (baseFontSize - 2).clamp(13.0, 30.0);
        final pillFontSize = (baseFontSize * 0.68).clamp(13.5, 22.0);
        final pillHorizontalPadding = (baseFontSize * 0.50).clamp(11.0, 20.0);
        final pillVerticalPadding = (baseFontSize * 0.28).clamp(6.0, 12.0);

        final topBorderColor = indicatorColor.withValues(
          alpha: isDark ? 0.45 : 0.22,
        );
        final borderColor = indicatorColor.withValues(
          alpha: isDark ? 0.18 : 0.14,
        );

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

        final hasReferences = widget.references.isNotEmpty;
        final hasMultipleReferences = widget.references.length > 1;
        final isHtmlNote = !hasReferences && widget.rawHtmlContent != null;

        // Limpieza de corchetes del badge
        final cleanBadge = (widget.footnoteBadge ?? '')
            .replaceAll('[', '')
            .replaceAll(']', '')
            .trim();

        // Color temático para la insignia de notas
        final accentColor = isDark
            ? const Color(0xFFE5C064)
            : const Color(0xFFE36414);

        Widget sheetContent = SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              screenWidth < 360 ? 14 : 18,
              8,
              screenWidth < 360 ? 14 : 18,
              18,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1 y 2. Zona Superior Interactiva (Tirador + Header) con soporte de cinemática elástica
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onVerticalDragStart: _handleDragStart,
                  onVerticalDragUpdate: _handleHeaderDragUpdate,
                  onVerticalDragEnd: _handleDragEnd,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Tirador táctil superior estilo Apple con micro-animación de ancho y soporte para tap
                      Center(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            HapticFeedback.lightImpact();
                            setState(() => _isExpanded = !_isExpanded);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeOutCubic,
                              width: _isExpanded ? 52 : 38,
                              height: 4.5,
                              decoration: BoxDecoration(
                                color: indicatorColor.withValues(
                                  alpha: isDark ? 0.40 : 0.28,
                                ),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Barra de Encabezado: [Icono Contexto + Cita] <----> [Botón Icónico de Acción]
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Icono de contexto visual sutil
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: hasReferences
                                  ? indicatorColor.withValues(alpha: isDark ? 0.12 : 0.08)
                                  : accentColor.withValues(alpha: isDark ? 0.15 : 0.12),
                              border: Border.all(
                                color: hasReferences
                                    ? borderColor
                                    : accentColor.withValues(alpha: isDark ? 0.35 : 0.25),
                                width: 1.0,
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                hasReferences
                                    ? Icons.auto_stories_rounded
                                    : Icons.format_quote_rounded,
                                size: 18,
                                color: hasReferences ? indicatorColor : accentColor,
                              ),
                            ),
                          ),

                          const SizedBox(width: 10),

                          // Título principal con badge en negrita
                          Expanded(
                            child: RichText(
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              text: TextSpan(
                                text: widget.title,
                                style: TextStyle(
                                  fontFamily: readPrefs.currentFontFamily,
                                  fontWeight: FontWeight.bold,
                                  fontSize: headerFontSize,
                                  color: indicatorColor,
                                  letterSpacing: -0.3,
                                ),
                                children: [
                                  if (cleanBadge.isNotEmpty) ...[
                                    const TextSpan(text: ' '),
                                    TextSpan(
                                      text: '[$cleanBadge]',
                                      style: TextStyle(
                                        fontFamily: readPrefs.currentFontFamily,
                                        fontWeight: FontWeight.bold,
                                        fontSize: badgeFontSize,
                                        color: accentColor,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(width: 8),

                          // Botón de acción icónico flotante (Sin texto, 100% universal)
                          if (hasReferences)
                            _CircleIconButton(
                              tooltip: 'Ir al versículo',
                              icon: Icons.open_in_new_rounded,
                              iconColor: isDark ? canvasColor : Colors.white,
                              gradient: activeGradient,
                              borderColor: borderColor,
                              onTap: () {
                                HapticFeedback.mediumImpact();
                                Navigator.pop(context);
                                final currentRef = widget.references[_activeIndex];
                                widget.onNavigate(
                                  currentRef.book,
                                  currentRef.chapter,
                                  currentRef.verseFrom,
                                );
                              },
                            )
                          else
                            _CircleIconButton(
                              tooltip: 'Cerrar',
                              icon: Icons.close_rounded,
                              iconColor: indicatorColor,
                              gradient: neutralGradient,
                              borderColor: borderColor,
                              onTap: () {
                                HapticFeedback.lightImpact();
                                Navigator.pop(context);
                              },
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                // 3. Selector de Citas a ancho completo con auto-centrado (siempre visible si hay referencias para identificar qué cita se lee)
                if (hasReferences) ...[
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: widget.references.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final item = entry.value;
                        final isSelected = _activeIndex == idx;
                        return _ReferencePill(
                          key: _pillKeys[idx],
                          label: item.label,
                          isSelected: isSelected,
                          activeGradient: activeGradient,
                          neutralGradient: neutralGradient,
                          borderColor: borderColor,
                          indicatorColor: indicatorColor,
                          canvasColor: canvasColor,
                          isDark: isDark,
                          fontSize: pillFontSize,
                          horizontalPadding: pillHorizontalPadding,
                          verticalPadding: pillVerticalPadding,
                          onTap: () => _onPillTap(idx),
                        );
                      }).toList(),
                    ),
                  ),
                ],

                const SizedBox(height: 12),

                // 4. Contenido del Panel con Altura Intrínseca Dinámica (Cero hueco abajo y cero overflow)
                if (hasReferences)
                  Flexible(
                    fit: FlexFit.loose,
                    child: _buildReferencesContent(
                      context: context,
                      screenHeight: screenHeight,
                      indicatorColor: indicatorColor,
                      hasMultiple: hasMultipleReferences,
                    ),
                  )
                else if (isHtmlNote)
                  Flexible(
                    fit: FlexFit.loose,
                    child: _buildHtmlNoteContent(
                      context: context,
                      screenHeight: screenHeight,
                      readPrefs: readPrefs,
                      indicatorColor: indicatorColor,
                      contentFontSize: contentFontSize,
                    ),
                  ),
              ],
            ),
          ),
        );

        return AnimatedBuilder(
          animation: _springController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _dragOffset),
              child: child,
            );
          },
          child: GlassContainer(
            enableAcrylic: readPrefs.enableAcrylicEffect,
            blur: isDark
                ? ControlCenterVisualConfig.darkBlurSigma
                : ControlCenterVisualConfig.lightBlurSigma,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
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
            gradient: readPrefs.enableAcrylicEffect
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
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onVerticalDragStart: _handleDragStart,
              onVerticalDragUpdate: _handleDragUpdate,
              onVerticalDragEnd: _handleDragEnd,
              child: sheetContent,
            ),
          ),
        );
      },
    );
  }

  /// Envuelve el scroll con detector de sobre-desplazamiento en el tope (offset 0) para activar el cierre elástico
  Widget _buildScrollableWithOverscrollDismiss({
    required bool canScroll,
    required Widget child,
  }) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is OverscrollNotification && notification.overscroll < 0) {
          // El scroll ya está en el tope superior (offset 0) y el usuario vuelve a arrastrar hacia abajo
          _springController.stop();
          setState(() {
            _dragOffset += (-notification.overscroll) * 0.55;
          });
        } else if (notification is ScrollUpdateNotification) {
          // Si el panel ya se estaba desplazando hacia abajo y el usuario rectifica hacia arriba
          if (_dragOffset > 0 && notification.scrollDelta != null && notification.scrollDelta! > 0) {
            setState(() {
              _dragOffset = math.max(0.0, _dragOffset - notification.scrollDelta! * 0.6);
            });
          }
        } else if (notification is ScrollEndNotification) {
          if (_dragOffset > 0) {
            _finishDrag(velocity: notification.dragDetails?.primaryVelocity ?? 0.0);
          }
        }
        return false;
      },
      child: SingleChildScrollView(
        primary: false,
        physics: canScroll
            ? const ClampingScrollPhysics()
            : const NeverScrollableScrollPhysics(),
        child: child,
      ),
    );
  }

  /// Construye el visor de versículos con altura estable y elevación elástica
  Widget _buildReferencesContent({
    required BuildContext context,
    required double screenHeight,
    required Color indicatorColor,
    required bool hasMultiple,
  }) {
    final mediaQuery = MediaQuery.of(context);
    final safeScreenHeight = screenHeight - mediaQuery.padding.top - mediaQuery.padding.bottom;
    final compactMaxContentHeight = (safeScreenHeight * 0.42).clamp(200.0, 360.0);
    final expandedMaxContentHeight = (safeScreenHeight * 0.70).clamp(300.0, safeScreenHeight - 160.0);
    final maxContentHeight = _isExpanded ? expandedMaxContentHeight : compactMaxContentHeight;

    // Caso 1 cita: Render directo con auto-ajuste de altura y elevación al scrollear
    if (!hasMultiple) {
      final currentVerses = _cachedVerses[0] ?? [];
      if (currentVerses.isEmpty && _isLoading) {
        return const SizedBox(
          height: 90,
          child: Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.2),
            ),
          ),
        );
      }
      final canScroll = (_singleRefHeight ?? 0) > maxContentHeight;
      final targetHeight = (_singleRefHeight != null)
          ? _singleRefHeight!.clamp(70.0, maxContentHeight)
          : maxContentHeight;

      return AnimatedSize(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        alignment: Alignment.topCenter,
        child: SizedBox(
          height: targetHeight,
          child: _buildScrollableWithOverscrollDismiss(
            canScroll: canScroll,
            child: _MeasureSize(
              onChange: (size) {
                if (size.height > 0 && _singleRefHeight != size.height) {
                  if (mounted) {
                    setState(() => _singleRefHeight = size.height);
                  }
                }
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: currentVerses,
              ),
            ),
          ),
        ),
      );
    }

    // Caso múltiples citas: Altura 100% uniforme y estable en todo el carrusel (cero saltos visuales)
    final targetHeight = maxContentHeight;

    return AnimatedSize(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: SizedBox(
        height: targetHeight,
        child: PageView.builder(
          controller: _pageController,
          physics: const BouncingScrollPhysics(),
          itemCount: widget.references.length,
          onPageChanged: (idx) {
            HapticFeedback.selectionClick();
            setState(() => _activeIndex = idx);
            _scrollToPill(idx);
            _loadCurrentIndex(idx);
          },
          itemBuilder: (ctx, idx) {
            final currentVerses = _cachedVerses[idx] ?? [];
            if (currentVerses.isEmpty) {
              return const Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.2),
                ),
              );
            }
            final canScroll = (_pageHeights[idx] ?? 0) > maxContentHeight;
            return _buildScrollableWithOverscrollDismiss(
              canScroll: canScroll,
              child: _MeasureSize(
                onChange: (size) {
                  if (size.height > 0) {
                    _onPageMeasured(idx, size.height);
                  }
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: currentVerses,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Construye la nota lingüística / explicativa en formato HTML limpio con soporte de elevación
  Widget _buildHtmlNoteContent({
    required BuildContext context,
    required double screenHeight,
    required ReadPreferencesController readPrefs,
    required Color indicatorColor,
    required double contentFontSize,
  }) {
    final mediaQuery = MediaQuery.of(context);
    final safeScreenHeight = screenHeight - mediaQuery.padding.top - mediaQuery.padding.bottom;
    final compactMaxContentHeight = (safeScreenHeight * 0.38).clamp(160.0, 320.0);
    final expandedMaxContentHeight = (safeScreenHeight * 0.68).clamp(280.0, safeScreenHeight - 160.0);
    final maxContentHeight = _isExpanded ? expandedMaxContentHeight : compactMaxContentHeight;
    final canScroll = (_htmlNoteHeight ?? 0) > maxContentHeight;
    final targetHeight = (_htmlNoteHeight != null)
        ? _htmlNoteHeight!.clamp(70.0, maxContentHeight)
        : maxContentHeight;

    return AnimatedSize(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: SizedBox(
        height: targetHeight,
        child: _buildScrollableWithOverscrollDismiss(
          canScroll: canScroll,
          child: _MeasureSize(
            onChange: (size) {
              if (size.height > 0 && _htmlNoteHeight != size.height) {
                if (mounted) {
                  setState(() => _htmlNoteHeight = size.height);
                }
              }
            },
            child: RichText(
              textAlign: TextAlign.left,
              text: HTML.toTextSpan(
                context,
                widget.rawHtmlContent ?? '',
                defaultTextStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      fontFamily: readPrefs.currentFontFamily,
                      fontWeight: FontWeight.normal,
                      height: 1.5,
                      fontSize: contentFontSize,
                      color: indicatorColor.withValues(alpha: 0.92),
                    ),
                overrideStyle: {
                  'em': Theme.of(context).textTheme.bodyLarge!.copyWith(
                        fontFamily: readPrefs.currentFontFamily,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                        fontSize: contentFontSize,
                        color: indicatorColor,
                      ),
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Botón Circular Icónico con Micro-Rebote y Respuesta Háptica
class _CircleIconButton extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final Gradient? gradient;
  final Color borderColor;
  final String tooltip;
  final VoidCallback onTap;

  const _CircleIconButton({
    Key? key,
    required this.icon,
    required this.iconColor,
    this.gradient,
    required this.borderColor,
    required this.tooltip,
    required this.onTap,
  }) : super(key: key);

  @override
  State<_CircleIconButton> createState() => _CircleIconButtonState();
}

class _CircleIconButtonState extends State<_CircleIconButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: _isPressed ? 0.88 : 1.0,
          duration: const Duration(milliseconds: 130),
          curve: Curves.easeOutBack,
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: widget.gradient,
              border: Border.all(
                color: widget.borderColor,
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                widget.icon,
                size: 19,
                color: widget.iconColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Píldora de Selección Táctil para Múltiples Citas con Dimensiones Accesibles
class _ReferencePill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Gradient activeGradient;
  final Gradient neutralGradient;
  final Color borderColor;
  final Color indicatorColor;
  final Color canvasColor;
  final bool isDark;
  final double fontSize;
  final double horizontalPadding;
  final double verticalPadding;
  final VoidCallback onTap;

  const _ReferencePill({
    Key? key,
    required this.label,
    required this.isSelected,
    required this.activeGradient,
    required this.neutralGradient,
    required this.borderColor,
    required this.indicatorColor,
    required this.canvasColor,
    required this.isDark,
    required this.fontSize,
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textColor = isSelected
        ? (isDark ? canvasColor : Colors.white)
        : indicatorColor.withValues(alpha: 0.85);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedScale(
          scale: isSelected ? 1.02 : 0.98,
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: verticalPadding,
            ),
            decoration: BoxDecoration(
              gradient: isSelected ? activeGradient : neutralGradient,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isSelected
                    ? (isDark ? indicatorColor.withValues(alpha: 0.6) : Colors.transparent)
                    : borderColor,
                width: 1.0,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.30 : 0.12),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: textColor,
                letterSpacing: -0.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
