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
/// - Iconografía táctil y universal con respuesta háptica.
/// - Paginación visual con Dots animados para notas con múltiples pasajes.
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
  late final PageController _pageController;
  final Map<int, List<Widget>> _cachedVerses = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    if (widget.references.isNotEmpty) {
      _loadCurrentIndex(0);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
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

  void _onPillTap(int index) {
    if (_activeIndex == index) return;
    HapticFeedback.lightImpact();
    setState(() => _activeIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
    _loadCurrentIndex(index);
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

        // Escalabilidad tipográfica calculada de forma armónica
        final baseFontSize = readPrefs.currentFontSize;
        final headerFontSize = (baseFontSize * 0.90).clamp(16.0, 24.0);
        final badgeFontSize = (baseFontSize * 0.72).clamp(11.0, 18.0);
        final contentFontSize = (baseFontSize - 2).clamp(13.0, 30.0);

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
                // 1. Tirador táctil superior estilo Apple
                Center(
                  child: Container(
                    width: 38,
                    height: 4.5,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: indicatorColor.withValues(
                        alpha: isDark ? 0.30 : 0.20,
                      ),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),

                // 2. Barra de Encabezado: [Icono Contexto + Cita] <----> [Botón Icónico de Acción]
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

                // 3. Selector de Múltiples Citas (Píldoras táctiles horizontales + Dots)
                if (hasMultipleReferences) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      // Píldoras horizontales con scroll elástico
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            children: widget.references.asMap().entries.map((entry) {
                              final idx = entry.key;
                              final item = entry.value;
                              final isSelected = _activeIndex == idx;
                              return _ReferencePill(
                                label: item.label,
                                isSelected: isSelected,
                                activeGradient: activeGradient,
                                neutralGradient: neutralGradient,
                                borderColor: borderColor,
                                indicatorColor: indicatorColor,
                                canvasColor: canvasColor,
                                isDark: isDark,
                                onTap: () => _onPillTap(idx),
                              );
                            }).toList(),
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Dots de paginación visual estilo iOS
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(widget.references.length, (dotIdx) {
                          final isCurrent = _activeIndex == dotIdx;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOutCubic,
                            margin: const EdgeInsets.symmetric(horizontal: 2.5),
                            width: isCurrent ? 14.0 : 5.0,
                            height: 5.0,
                            decoration: BoxDecoration(
                              color: isCurrent
                                  ? indicatorColor
                                  : indicatorColor.withValues(alpha: 0.22),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 12),

                // 4. Contenido del Panel (Adaptable y con altura intrínseca elástica)
                if (hasReferences)
                  _buildReferencesContent(
                    context: context,
                    screenHeight: screenHeight,
                    indicatorColor: indicatorColor,
                    hasMultiple: hasMultipleReferences,
                  )
                else if (isHtmlNote)
                  _buildHtmlNoteContent(
                    context: context,
                    screenHeight: screenHeight,
                    readPrefs: readPrefs,
                    indicatorColor: indicatorColor,
                    contentFontSize: contentFontSize,
                  ),
              ],
            ),
          ),
        );

        return GlassContainer(
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
          color: readPrefs.enableAcrylicEffect ? null : canvasColor,
          child: sheetContent,
        );
      },
    );
  }

  /// Construye el visor de versículos para referencias bíblicas
  Widget _buildReferencesContent({
    required BuildContext context,
    required double screenHeight,
    required Color indicatorColor,
    required bool hasMultiple,
  }) {
    final maxContentHeight = (screenHeight * 0.48).clamp(200.0, 480.0);

    // Caso 1 cita: Render directo sin la sobrecarga del PageView
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
      return ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxContentHeight),
        child: SingleChildScrollView(
          primary: false,
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: currentVerses,
          ),
        ),
      );
    }

    // Caso múltiples citas: PageView horizontal suave sincronizado con las píldoras
    return SizedBox(
      height: maxContentHeight,
      child: PageView.builder(
        controller: _pageController,
        physics: const BouncingScrollPhysics(),
        itemCount: widget.references.length,
        onPageChanged: (idx) {
          HapticFeedback.selectionClick();
          setState(() => _activeIndex = idx);
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
          return SingleChildScrollView(
            primary: false,
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: currentVerses,
            ),
          );
        },
      ),
    );
  }

  /// Construye la nota lingüística / explicativa en formato HTML limpio
  Widget _buildHtmlNoteContent({
    required BuildContext context,
    required double screenHeight,
    required ReadPreferencesController readPrefs,
    required Color indicatorColor,
    required double contentFontSize,
  }) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: (screenHeight * 0.40).clamp(160.0, 380.0),
      ),
      child: SingleChildScrollView(
        primary: false,
        physics: const BouncingScrollPhysics(),
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

/// Píldora de Selección Táctil para Múltiples Citas
class _ReferencePill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Gradient activeGradient;
  final Gradient neutralGradient;
  final Color borderColor;
  final Color indicatorColor;
  final Color canvasColor;
  final bool isDark;
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
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textColor = isSelected
        ? (isDark ? canvasColor : Colors.white)
        : indicatorColor.withValues(alpha: 0.80);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedScale(
          scale: isSelected ? 1.03 : 0.97,
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6.5),
            decoration: BoxDecoration(
              gradient: isSelected ? activeGradient : neutralGradient,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? (isDark ? indicatorColor.withValues(alpha: 0.6) : Colors.transparent)
                    : borderColor,
                width: 1.0,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.10),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
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
