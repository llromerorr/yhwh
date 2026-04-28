import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:yhwh/controllers/BiblePageController.dart';
import 'package:yhwh/controllers/ReadPreferencesController.dart';
import 'package:yhwh/data/Themes.dart';

class ReadPreferences extends StatelessWidget {
  const ReadPreferences({Key? key}) : super(key: key);

  final List<String> availableFonts = const [
    'Roboto',
    'Lato',
    'Crimson Text',
    'Atkinson Hyperlegible'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).canvasColor,
      appBar: AppBar(
        title: Text("Preferencias visuales", style: Theme.of(context).textTheme.bodyLarge!.copyWith(
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
          builder: (controller) => Column(
            children: [
              // PREVISUALIZACIÓN FIJA ARRIBA
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).canvasColor,
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).indicatorColor.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    )
                  ],
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context).indicatorColor.withValues(alpha: 0.1),
                      width: 1,
                    )
                  )
                ),
                child: Column(
                  children: [
                    Text(
                      "Porque de tal manera amó Dios al mundo, que ha dado a su Hijo unigénito, para que todo aquel que en él cree, no se pierda, mas tenga vida eterna.",
                      textAlign: controller.isJustified ? TextAlign.justify : TextAlign.start,
                      style: TextStyle(
                        fontFamily: controller.currentFontFamily,
                        fontSize: controller.currentFontSize,
                        height: biblePageController.fontHeight,
                        letterSpacing: biblePageController.fontLetterSeparation,
                        color: Theme.of(context).indicatorColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "Juan 3:16",
                        style: TextStyle(
                          fontFamily: controller.currentFontFamily,
                          fontSize: controller.currentFontSize * 0.7,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).indicatorColor.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // CONTENIDO SCROLLABLE
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // SECCIÓN TIPOGRAFÍA
                      _buildSectionTitle(context, "Tipografía y Formato"),
                      const SizedBox(height: 16),
                      
                      // Slider de tamaño
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: [
                            Icon(Icons.text_fields, size: 18, color: Theme.of(context).indicatorColor.withValues(alpha: 0.5)),
                            Expanded(
                              child: Slider(
                                value: controller.currentFontSize,
                                min: 14.0,
                                max: 45.0,
                                activeColor: Theme.of(context).indicatorColor,
                                inactiveColor: Theme.of(context).indicatorColor.withValues(alpha: 0.2),
                                onChanged: (value) => controller.setFontSize(value),
                              ),
                            ),
                            Icon(Icons.text_fields, size: 28, color: Theme.of(context).indicatorColor),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Chips de Fuentes
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: availableFonts.map((font) {
                            bool isSelected = controller.currentFontFamily == font;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ChoiceChip(
                                label: Text(font, style: TextStyle(fontFamily: font, fontSize: 16, color: isSelected ? Theme.of(context).canvasColor : Theme.of(context).indicatorColor)),
                                selected: isSelected,
                                selectedColor: Theme.of(context).indicatorColor,
                                backgroundColor: Theme.of(context).indicatorColor.withValues(alpha: 0.05),
                                onSelected: (bool selected) {
                                  if (selected) controller.setFontFamily(font);
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      
                      const SizedBox(height: 24),

                      // Alineación
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).indicatorColor.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                                  onTap: () => controller.setJustified(false),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: !controller.isJustified ? Theme.of(context).indicatorColor.withValues(alpha: 0.1) : Colors.transparent,
                                      borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                                    ),
                                    child: Icon(Icons.format_align_left, color: Theme.of(context).indicatorColor),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: InkWell(
                                  borderRadius: const BorderRadius.horizontal(right: Radius.circular(12)),
                                  onTap: () => controller.setJustified(true),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: controller.isJustified ? Theme.of(context).indicatorColor.withValues(alpha: 0.1) : Colors.transparent,
                                      borderRadius: const BorderRadius.horizontal(right: Radius.circular(12)),
                                    ),
                                    child: Icon(Icons.format_align_justify, color: Theme.of(context).indicatorColor),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // SECCIÓN TEMAS
                      _buildSectionTitle(context, "Tema Visual"),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: themes.keys.map((themeKey) {
                            String displayName = themeKey;
                            IconData icon = FontAwesomeIcons.sun;

                            if (themeKey == 'Blanco') { displayName = 'Claro'; icon = FontAwesomeIcons.sun; }
                            if (themeKey == 'Negro') { displayName = 'Oscuro'; icon = FontAwesomeIcons.moon; }
                            if (themeKey == 'OLED') { displayName = 'Negro'; icon = FontAwesomeIcons.solidMoon; }

                            return Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(right: themeKey == 'OLED' ? 0 : 8.0),
                                child: _buildThemeSimpleButton(context, controller, themeKey, displayName, icon),
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // SECCIÓN AVANZADO
                      _buildSectionTitle(context, "Ajustes Avanzados"),
                      const SizedBox(height: 12),
                      
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Theme.of(context).indicatorColor.withValues(alpha: 0.05),
                            border: Border.all(
                              color: Theme.of(context).indicatorColor.withValues(alpha: 0.1),
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            children: [
                              _buildSwitchTile(
                                context: context,
                                title: "Efecto cristal (Acrílico)",
                                subtitle: "Transparencias en menús. Apágalo si hay lentitud.",
                                value: controller.enableAcrylicEffect,
                                onChanged: controller.toggleAcrylicEffect,
                              ),
                              Divider(height: 1, color: Theme.of(context).indicatorColor.withValues(alpha: 0.1)),
                              _buildSwitchTile(
                                context: context,
                                title: "Mantener pantalla encendida",
                                subtitle: "Evita que la pantalla se apague mientras lees.",
                                value: controller.keepScreenOn,
                                onChanged: controller.setKeepScreenOn,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 48),

                      // BOTÓN RESET
                      Center(
                        child: TextButton.icon(
                          onPressed: () {
                            controller.resetToDefaults();
                          },
                          icon: Icon(Icons.restore, color: Theme.of(context).indicatorColor.withValues(alpha: 0.6)),
                          label: Text("Restablecer ajustes", style: TextStyle(color: Theme.of(context).indicatorColor.withValues(alpha: 0.6))),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).indicatorColor.withValues(alpha: 0.7),
          fontSize: 14,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
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
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Theme.of(context).canvasColor,
            activeTrackColor: Theme.of(context).indicatorColor,
            inactiveThumbColor: Theme.of(context).indicatorColor.withValues(alpha: 0.5),
            inactiveTrackColor: Theme.of(context).indicatorColor.withValues(alpha: 0.1),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeSimpleButton(BuildContext context, ReadPreferencesController controller, String themeKey, String displayName, IconData icon) {
    bool isActive = controller.currentThemeName == themeKey;
    
    return InkWell(
      onTap: () => controller.setTheme(themeKey),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isActive 
              ? Theme.of(context).indicatorColor.withValues(alpha: 0.1)
              : Colors.transparent,
          border: Border.all(
            color: isActive ? Theme.of(context).indicatorColor : Theme.of(context).indicatorColor.withValues(alpha: 0.2),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon, 
              color: isActive ? Theme.of(context).indicatorColor : Theme.of(context).indicatorColor.withValues(alpha: 0.6),
              size: 20,
            ),
            const SizedBox(height: 6),
            Text(
              displayName,
              style: TextStyle(
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive ? Theme.of(context).indicatorColor : Theme.of(context).indicatorColor.withValues(alpha: 0.6),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
