import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:yhwh/classes/AppTheme.dart';
import 'package:yhwh/controllers/BiblePageController.dart';
import 'package:yhwh/controllers/ReadPreferencesController.dart';
import 'package:yhwh/data/Themes.dart';

class ReadPreferences extends StatelessWidget {
  const ReadPreferences({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Preferencias de lectura", style: Theme.of(context).textTheme.bodyLarge!.copyWith(
          fontSize: 21,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).indicatorColor
        )),
        // centerTitle: true,
        backgroundColor: Theme.of(context).canvasColor,
        scrolledUnderElevation: 0,
        elevation: 0,
        foregroundColor: Theme.of(context).indicatorColor,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).canvasColor,
          border: Border(
            top: BorderSide(
              color: Theme.of(context).indicatorColor.withAlpha(120),
              width: 1.5,
            ),
          ),
        ),
        child: GetBuilder<BiblePageController>(
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
      
                  // Selector de Temas
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      "Tema de lectura",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).indicatorColor.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: themes.keys.map((themeName) {
                        bool isSelected = controller.currentThemeName == themeName;
                        
                        return Padding(
                          padding: const EdgeInsets.only(right: 20.0),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => controller.setTheme(themeName),
                            child: Column(
                              children: [
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Anillo exterior de selección
                                    Container(
                                      height: 58,
                                      width: 58,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isSelected ? Theme.of(context).indicatorColor : Colors.transparent,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                    // Color de fondo del tema
                                    Container(
                                      height: 48,
                                      width: 48,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppTheme.getTheme(themeName).canvasColor,
                                        border: Border.all(
                                          color: Theme.of(context).indicatorColor.withValues(alpha: 0.2),
                                          width: 1,
                                        )
                                      ),
                                    ),
                                    // Checkmark si está seleccionado, de lo contrario el color de texto del tema
                                    if (isSelected)
                                      Icon(FontAwesomeIcons.check, size: 20, color: AppTheme.getTheme(themeName).indicatorColor)
                                    else
                                      Container(
                                        height: 20,
                                        width: 20,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppTheme.getTheme(themeName).indicatorColor,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                // Etiqueta de texto debajo del círculo
                                Text(
                                  themeName,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    color: isSelected 
                                        ? Theme.of(context).indicatorColor 
                                        : Theme.of(context).indicatorColor.withValues(alpha: 0.6),
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
      
                  const SizedBox(height: 32),
      
                  // Selector de Tamaño de Letra
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
                        Expanded(child: _buildPresetButton(context, controller, 'small', 'Pequeña', FontAwesomeIcons.font, 14)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildPresetButton(context, controller, 'normal', 'Normal', FontAwesomeIcons.font, 18)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildPresetButton(context, controller, 'large', 'Grande', FontAwesomeIcons.font, 22)),
                      ],
                    ),
                  ),
      
                  const SizedBox(height: 32),
      
                  // Accesibilidad
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Icon(FontAwesomeIcons.glasses, size: 16, color: Theme.of(context).indicatorColor.withValues(alpha: 0.5)),
                        const SizedBox(width: 8),
                        Text(
                          "Accesibilidad",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).indicatorColor.withValues(alpha: 0.5),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Divider(color: Theme.of(context).indicatorColor.withValues(alpha: 0.2), thickness: 1),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
      
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        _buildAccessibilityButton(
                          context,
                          controller,
                          'presbyopia',
                          'Presbicia',
                          'Letra grande con mayor espacio entre líneas para no perder la lectura.',
                        ),
                        const SizedBox(height: 12),
                        _buildAccessibilityButton(
                          context,
                          controller,
                          'visual_impairment',
                          'Discapacidad Visual',
                          'Letra gigante y máxima separación. (Te recomendamos usar el tema "OLED" para maximizar el contraste).',
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
      ),
    );
  }

  Widget _buildPresetButton(BuildContext context, ReadPreferencesController controller, String presetId, String label, IconData icon, double iconSize) {
    bool isActive = controller.activeTypographyPreset == presetId;
    
    return InkWell(
      onTap: () => controller.setTypographyPreset(presetId),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isActive ? Theme.of(context).indicatorColor.withValues(alpha: 0.15) : Colors.transparent,
          border: Border.all(
            color: isActive ? Theme.of(context).indicatorColor : Theme.of(context).indicatorColor.withValues(alpha: 0.2),
            width: isActive ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: iconSize, color: isActive ? Theme.of(context).indicatorColor : Theme.of(context).indicatorColor.withValues(alpha: 0.6)),
            const SizedBox(height: 8),
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isActive ? Theme.of(context).indicatorColor.withValues(alpha: 0.15) : Colors.transparent,
          border: Border.all(
            color: isActive ? Theme.of(context).indicatorColor : Theme.of(context).indicatorColor.withValues(alpha: 0.2),
            width: isActive ? 1.5 : 1.0,
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