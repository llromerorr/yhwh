import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yhwh/controllers/ReadPreferencesController.dart';
import 'package:yhwh/data/Define.dart';

class ChapterFooter extends StatelessWidget {
  const ChapterFooter({
    Key? key,
    required this.bibleVersion,
  }) : super(key: key);

  final String bibleVersion;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ReadPreferencesController>(
      init: ReadPreferencesController(),
      builder: (readPrefs) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final indicatorColor = Theme.of(context).indicatorColor;
        final fontFamily = readPrefs.currentFontFamily;
        final scale = readPrefs.fontScaleFactor;

        final titleFontSize = (17.0 * scale).clamp(15.0, 22.0);
        final sectionFontSize = (11.0 * scale).clamp(10.0, 14.0);
        final infoFontSize = (13.5 * scale).clamp(12.0, 16.5);

        final versionName = versionToName[bibleVersion] ?? 'Reina Valera Revisada 1960';

        return SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const SizedBox(height: 36),

                // Separador ornamental elegante con micro-glifo central
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 48,
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            indicatorColor.withValues(alpha: isDark ? 0.35 : 0.20),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        '✦',
                        style: TextStyle(
                          fontSize: 10,
                          color: indicatorColor.withValues(alpha: isDark ? 0.40 : 0.25),
                        ),
                      ),
                    ),
                    Container(
                      width: 48,
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            indicatorColor.withValues(alpha: isDark ? 0.35 : 0.20),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Título de la Versión en 1 sola línea limpia
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '$versionName ©',
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: fontFamily,
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                      color: indicatorColor.withValues(alpha: isDark ? 0.88 : 0.80),
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                // Sección del Canon Bíblico en mayúsculas espaciadas
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'ANTIGUO Y NUEVO TESTAMENTO',
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: fontFamily,
                      fontSize: sectionFontSize,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2.0,
                      color: indicatorColor.withValues(alpha: isDark ? 0.45 : 0.35),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // Bloque histórico editorial: cada línea concisa y garantizada en un solo renglón
                if (bibleVersion == 'RVR60') ...[
                  _buildSingleLineText(
                    text: 'Traducción: Casiodoro de Reina (1569)',
                    fontFamily: fontFamily,
                    fontSize: infoFontSize,
                    color: indicatorColor.withValues(alpha: isDark ? 0.62 : 0.52),
                  ),
                  const SizedBox(height: 4),
                  _buildSingleLineText(
                    text: 'Revisión: Cipriano de Valera (1602)',
                    fontFamily: fontFamily,
                    fontSize: infoFontSize,
                    color: indicatorColor.withValues(alpha: isDark ? 0.62 : 0.52),
                  ),
                  const SizedBox(height: 4),
                  _buildSingleLineText(
                    text: 'Revisiones: 1862 · 1909 · 1960',
                    fontFamily: fontFamily,
                    fontSize: infoFontSize,
                    color: indicatorColor.withValues(alpha: isDark ? 0.55 : 0.45),
                  ),
                ],

                // Espacio inferior seguro: holgura para no solaparse con los botones flotantes de navegación
                const SizedBox(height: 130),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSingleLineText({
    required String text,
    required String fontFamily,
    required double fontSize,
    required Color color,
  }) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        text,
        maxLines: 1,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: fontFamily,
          fontSize: fontSize,
          fontWeight: FontWeight.normal,
          letterSpacing: 0.15,
          color: color,
        ),
      ),
    );
  }
}