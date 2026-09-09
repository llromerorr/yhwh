import 'package:flutter/material.dart';
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
      enableDrag: true,
      isScrollControlled: true,
      elevation: 0,
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

class _ReferenceBottomSheetState extends State<ReferenceBottomSheet> {
  int _activeIndex = 0;
  late final DraggableScrollableController _sheetController;
  final Map<int, List<Widget>> _cachedVerses = {};
  late final List<GlobalKey> _pillKeys;
  bool _isLoading = false;
  double _slideDirection = 1.0;
  double _horizontalDragDelta = 0.0;
  ScrollController? _activeScrollController;

  @override
  void initState() {
    super.initState();
    _sheetController = DraggableScrollableController();
    _pillKeys = List.generate(widget.references.length, (_) => GlobalKey());
    if (widget.references.isNotEmpty) {
      _loadCurrentIndex(0);
    }
  }

  @override
  void dispose() {
    _sheetController.dispose();
    super.dispose();
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

  void _switchToReference(int index, {double direction = 1.0}) {
    if (_activeIndex == index) return;
    HapticFeedback.selectionClick();
    setState(() {
      _slideDirection = direction;
      _activeIndex = index;
    });
    if (_activeScrollController != null &&
        _activeScrollController!.hasClients &&
        _activeScrollController!.offset > 0) {
      _activeScrollController!.jumpTo(0.0);
    }
    _scrollToPill(index);
    _loadCurrentIndex(index);
  }

  void _onPillTap(int index) {
    if (_activeIndex == index) return;
    final double dir = index > _activeIndex ? 1.0 : -1.0;
    _switchToReference(index, direction: dir);
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

        final minRequiredHeight = hasReferences ? 175.0 : 125.0;
        final double minSize = (minRequiredHeight / screenHeight).clamp(0.20, 0.35);
        final double compactSize = 0.44.clamp(minSize + 0.05, 0.60);
        const double expandedSize = 0.85;

        return DraggableScrollableSheet(
          expand: false,
          controller: _sheetController,
          initialChildSize: compactSize,
          minChildSize: minSize,
          maxChildSize: expandedSize,
          snap: true,
          snapSizes: [compactSize],
          builder: (BuildContext sheetContext, ScrollController scrollController) {
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
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tirador visual superior + Encabezado interactivo con soporte de arrastre vertical
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onVerticalDragUpdate: (details) {
                        if (_sheetController.isAttached) {
                          final double delta = -details.delta.dy;
                          final double deltaSize = _sheetController.pixelsToSize(delta);
                          final double targetSize = (_sheetController.size + deltaSize).clamp(minSize, expandedSize);
                          _sheetController.jumpTo(targetSize);
                        }
                      },
                      onVerticalDragEnd: (details) {
                        if (_sheetController.isAttached) {
                          final double velocity = -(details.primaryVelocity ?? 0.0);
                          final double currentSize = _sheetController.size;

                          if (velocity > 350) {
                            // Fling hacia arriba -> expandir al máximo
                            _sheetController.animateTo(
                              expandedSize,
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOutCubic,
                            );
                          } else if (velocity < -350) {
                            // Fling hacia abajo
                            if (currentSize > compactSize + 0.08) {
                              _sheetController.animateTo(
                                compactSize,
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeOutCubic,
                              );
                            } else {
                              Navigator.of(context).pop();
                            }
                          } else {
                            // Arrastre suave: snap por umbral de posición
                            final double midPoint = (compactSize + expandedSize) / 2;
                            if (currentSize > midPoint) {
                              _sheetController.animateTo(
                                expandedSize,
                                duration: const Duration(milliseconds: 220),
                                curve: Curves.easeOutCubic,
                              );
                            } else if (currentSize < (compactSize + minSize) / 2) {
                              Navigator.of(context).pop();
                            } else {
                              _sheetController.animateTo(
                                compactSize,
                                duration: const Duration(milliseconds: 220),
                                curve: Curves.easeOutCubic,
                              );
                            }
                          }
                        }
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Tirador visual superior (drag handle)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 8),
                              child: Container(
                                width: 38,
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

                    // 3. Selector de Citas a ancho completo con auto-centrado
                    if (hasReferences) ...[
                      const SizedBox(height: 10),
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

                    const SizedBox(height: 10),

                    // 4. Contenido del Panel conectado al scrollController
                    if (hasReferences)
                      Expanded(
                        child: _buildReferencesContent(
                          context: context,
                          scrollController: scrollController,
                          indicatorColor: indicatorColor,
                          hasMultiple: hasMultipleReferences,
                        ),
                      )
                    else if (isHtmlNote)
                      Expanded(
                        child: _buildHtmlNoteContent(
                          context: context,
                          scrollController: scrollController,
                          readPrefs: readPrefs,
                          indicatorColor: indicatorColor,
                          contentFontSize: contentFontSize,
                        ),
                      ),
                  ],
                ),
              ),
            );

            return GlassContainer(
              enableAcrylic: readPrefs.enableAcrylicEffect,
              enableShadows: readPrefs.enableShadows,
              blur: isDark
                  ? ControlCenterVisualConfig.darkBlurSigma
                  : ControlCenterVisualConfig.lightBlurSigma,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              border: Border(
                top: BorderSide(
                  color: topBorderColor,
                  width: 1.5,
                ),
              ),
              boxShadow: [
                if (readPrefs.enableShadows)
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
              color: readPrefs.enableAcrylicEffect ? null : canvasColor,
              child: sheetContent,
            );
          },
        );
      },
    );
  }

  /// Construye el visor de versículos con física nativa de scroll
  Widget _buildReferencesContent({
    required BuildContext context,
    required ScrollController scrollController,
    required Color indicatorColor,
    required bool hasMultiple,
  }) {
    _activeScrollController = scrollController;

    if (!hasMultiple) {
      final currentVerses = _cachedVerses[0] ?? [];
      if (currentVerses.isEmpty && _isLoading) {
        return const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2.2),
          ),
        );
      }

      return SingleChildScrollView(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...currentVerses,
            const SizedBox(height: 16),
          ],
        ),
      );
    }

    // Caso múltiples citas: GestureDetector horizontal sin PageView bloqueante,
    // garantizando que el SingleChildScrollView y su ScrollPosition se mantengan 100% activos y fluidos.
    final currentVerses = _cachedVerses[_activeIndex] ?? [];

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragStart: (_) => _horizontalDragDelta = 0.0,
      onHorizontalDragUpdate: (details) => _horizontalDragDelta += details.delta.dx,
      onHorizontalDragEnd: (details) {
        final double vx = details.primaryVelocity ?? 0.0;
        if (vx < -220 || _horizontalDragDelta < -50) {
          if (_activeIndex < widget.references.length - 1) {
            _switchToReference(_activeIndex + 1, direction: 1.0);
          }
        } else if (vx > 220 || _horizontalDragDelta > 50) {
          if (_activeIndex > 0) {
            _switchToReference(_activeIndex - 1, direction: -1.0);
          }
        }
        _horizontalDragDelta = 0.0;
      },
      child: SingleChildScrollView(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
            return Stack(
              alignment: Alignment.topLeft,
              children: <Widget>[
                ...previousChildren,
                if (currentChild != null) currentChild,
              ],
            );
          },
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: Offset(_slideDirection * 0.12, 0.0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          ),
          child: KeyedSubtree(
            key: ValueKey('verse_content_$_activeIndex'),
            child: currentVerses.isEmpty && _isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 36),
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2.2),
                      ),
                    ),
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...currentVerses,
                      const SizedBox(height: 16),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  /// Construye la nota lingüística / explicativa en formato HTML limpio con física nativa
  Widget _buildHtmlNoteContent({
    required BuildContext context,
    required ScrollController scrollController,
    required ReadPreferencesController readPrefs,
    required Color indicatorColor,
    required double contentFontSize,
  }) {
    _activeScrollController = scrollController;
    return SingleChildScrollView(
      controller: scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
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
