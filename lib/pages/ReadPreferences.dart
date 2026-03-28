import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:yhwh/classes/AppTheme.dart';
import 'package:yhwh/controllers/BiblePageController.dart';
import 'package:yhwh/controllers/ReadPreferencesController.dart';
import 'package:yhwh/data/Themes.dart';

class ReadPreferences extends StatelessWidget {
  const ReadPreferences({Key? key}) : super(key: key);

  final List<String> availableFonts = const [
    'Lato',
    'Crimson Text',
    'Atkinson Hyperlegible'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).canvasColor,
      appBar: AppBar(
        title: Text("Preferencias de lectura", style: Theme.of(context).textTheme.bodyLarge!.copyWith(
          fontSize: 21,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).indicatorColor
        )),
        backgroundColor: Theme.of(context).canvasColor,
        scrolledUnderElevation: 0,
        elevation: 0,
        foregroundColor: Theme.of(context).indicatorColor,
      ),
      body: GetBuilder<BiblePageController>(
        init: BiblePageController(),
        builder: (biblePageController) => GetBuilder<ReadPreferencesController>(
          init: ReadPreferencesController(),
          builder: (controller) => SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 24),
            
                // --- 1. Selector de Temas (Minimalista) ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    "Tema visual",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).indicatorColor.withValues(alpha: 0.7),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: themes.keys.map((themeKey) {
                      // Nombres más limpios para la UI
                      String displayName = themeKey;
                      IconData icon = FontAwesomeIcons.sun;

                      if (themeKey == 'Blanco') { displayName = 'Claro'; icon = FontAwesomeIcons.sun; }
                      if (themeKey == 'Negro') { displayName = 'Oscuro'; icon = FontAwesomeIcons.moon; }
                      if (themeKey == 'OLED') { displayName = 'Negro'; icon = FontAwesomeIcons.solidMoon; }

                      return Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: _buildThemeSimpleButton(context, controller, themeKey, displayName, icon),
                      );
                    }).toList(),
                  ),
                ),
            
                const SizedBox(height: 32),

                // --- 2. Selector de Tipografía ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    "Tipografía",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).indicatorColor.withValues(alpha: 0.7),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: availableFonts.map((fontName) {
                      bool isActive = controller.currentFontFamily == fontName;
                      return Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: InkWell(
                          onTap: () => controller.setFontFamily(fontName),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: isActive ? Theme.of(context).indicatorColor.withValues(alpha: 0.15) : Colors.transparent,
                              border: Border.all(
                                color: isActive ? Theme.of(context).indicatorColor : Theme.of(context).indicatorColor.withValues(alpha: 0.2),
                                width: isActive ? 1.5 : 1.5,
                              ),
                            ),
                            child: Text(
                              fontName == 'Atkinson Hyperlegible' ? 'Atkinson' : fontName,
                              style: TextStyle(
                                fontFamily: fontName,
                                fontSize: 16,
                                color: isActive ? Theme.of(context).indicatorColor : Theme.of(context).indicatorColor.withValues(alpha: 0.8),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 32),
            
                // --- 3. Selector de Tamaño de Letra ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    "Tamaño de letra",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).indicatorColor.withValues(alpha: 0.7),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Expanded(child: _buildPresetButton(context, controller, 'small', 'Pequeña', FontAwesomeIcons.font, 18)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildPresetButton(context, controller, 'normal', 'Normal', FontAwesomeIcons.font, 22)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildPresetButton(context, controller, 'large', 'Grande', FontAwesomeIcons.font, 26)),
                    ],
                  ),
                ),
            
                // const SizedBox(height: 32),
            
                // --- 4. Accesibilidad ---
                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
                //   child: Row(
                //     children: [
                //       Icon(FontAwesomeIcons.glasses, size: 16, color: Theme.of(context).indicatorColor.withValues(alpha: 0.5)),
                //       const SizedBox(width: 8),
                //       Text(
                //         "Accesibilidad",
                //         style: TextStyle(
                //           fontWeight: FontWeight.bold,
                //           color: Theme.of(context).indicatorColor.withValues(alpha: 0.5),
                //         ),
                //       ),
                //       const SizedBox(width: 12),
                //       Expanded(
                //         child: Divider(color: Theme.of(context).indicatorColor.withValues(alpha: 0.2), thickness: 1),
                //       ),
                //     ],
                //   ),
                // ),
                const SizedBox(height: 10),
            
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      _buildAccessibilityButton(
                        context,
                        controller,
                        'presbyopia', 
                        'Extra Grande',
                        'Ideal para descansar la vista en lecturas largas o para quienes usan lentes de lectura.',
                      ),
                      const SizedBox(height: 12),
                      _buildAccessibilityButton(
                        context,
                        controller,
                        'visual_impairment', 
                        'Gigante',
                        'Recomendado para personas con dificultades visuales severas que necesitan el texto al tamaño máximo.',
                      ),
                    ],
                  ),
                ),
            
                Container(
                  height: MediaQuery.of(context).viewPadding.bottom + 20,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Nuevo widget de botón simple para los temas
  Widget _buildThemeSimpleButton(BuildContext context, ReadPreferencesController controller, String themeId, String label, IconData icon) {
    bool isActive = controller.currentThemeName == themeId;
    return InkWell(
      onTap: () => controller.setTheme(themeId),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isActive ? Theme.of(context).indicatorColor.withValues(alpha: 0.15) : Colors.transparent,
          border: Border.all(
            color: isActive ? Theme.of(context).indicatorColor : Theme.of(context).indicatorColor.withValues(alpha: 0.2),
            width: isActive ? 1.5 : 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isActive ? Theme.of(context).indicatorColor : Theme.of(context).indicatorColor.withValues(alpha: 0.6)),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive ? Theme.of(context).indicatorColor : Theme.of(context).indicatorColor.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetButton(BuildContext context, ReadPreferencesController controller, String presetId, String label, IconData icon, double iconSize) {
    bool isActive = controller.activeTypographyPreset == presetId;
    return InkWell(
      onTap: () => controller.setTypographyPreset(presetId),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 75,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isActive ? Theme.of(context).indicatorColor.withValues(alpha: 0.15) : Colors.transparent,
          border: Border.all(
            color: isActive ? Theme.of(context).indicatorColor : Theme.of(context).indicatorColor.withValues(alpha: 0.2),
            width: isActive ? 1.5 : 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: iconSize, color: isActive ? Theme.of(context).indicatorColor : Theme.of(context).indicatorColor.withValues(alpha: 0.6)),
            const SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive ? Theme.of(context).indicatorColor : Theme.of(context).indicatorColor.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccessibilityButton(BuildContext context, ReadPreferencesController controller, String presetId, String title, String subtitle) {
    bool isActive = controller.activeTypographyPreset == presetId;
    return InkWell(
      onTap: () => controller.setTypographyPreset(presetId),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 100,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isActive ? Theme.of(context).indicatorColor.withValues(alpha: 0.15) : Colors.transparent,
          border: Border.all(
            color: isActive ? Theme.of(context).indicatorColor : Theme.of(context).indicatorColor.withValues(alpha: 0.2),
            width: isActive ? 1.5 : 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isActive ? FontAwesomeIcons.solidCircleCheck : FontAwesomeIcons.circle,
              color: isActive ? Theme.of(context).indicatorColor : Theme.of(context).indicatorColor.withValues(alpha: 0.3),
              size: 20,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Theme.of(context).indicatorColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).indicatorColor.withValues(alpha: 0.7),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}