import 'package:flutter/material.dart';

class ColorPalette extends ThemeExtension<ColorPalette> {
  final Brightness brightness;
  final Color background;
  final Color foreground;
  final Color verseText;
  final Color verseNumber;
  final Color wordsOfJesus;
  final Color wordsOfJesusHighlighted;
  final Color referenceText;
  final Color referenceTextHighlighted;
  final List<Color> highlights;

  ColorPalette({
    required this.brightness,
    required this.background,
    required this.foreground,
    required this.verseText,
    required this.verseNumber,
    required this.wordsOfJesus,
    required this.wordsOfJesusHighlighted,
    required this.referenceText,
    required this.referenceTextHighlighted,
    required this.highlights,
  });

  static int getHighlightIndex(int savedColor) {
    // Si el valor guardado es pequeño (0 a 20), asumimos que ya es un índice directo.
    if (savedColor >= 0 && savedColor <= 20) {
      return savedColor;
    }
    
    final lightColors = [
      0xff8ab4f8, 0xfff28b82, 0xfffdd663, 0xff81c995, 0xffff8bcb, 0xffd7aefb, 0xff78d9ec
    ];
    final darkColors = [
      0xff4a7dc0, 0xffb74b46, 0xffae7123, 0xff4c8c5a, 0xffa84c7d, 0xff865ea3, 0xff3f8997
    ];
    int index = lightColors.indexOf(savedColor);
    if (index == -1) index = darkColors.indexOf(savedColor);
    return index;
  }

  static Color getDynamicHighlightColor(BuildContext context, int savedColor) {
    final palette = Theme.of(context).extension<ColorPalette>();
    if (palette != null) {
      int index = getHighlightIndex(savedColor);
      if (index != -1 && index < palette.highlights.length) {
        return palette.highlights[index];
      }
    }
    // Fallback: si por alguna razón no se encuentra el tema, y el color guardado
    // es un índice, devolvemos un color transparente o uno por defecto.
    if (savedColor >= 0 && savedColor <= 20) {
      return Colors.transparent; 
    }
    return Color(savedColor);
  }

  @override
  ThemeExtension<ColorPalette> copyWith({
    Brightness? brightness,
    Color? background,
    Color? foreground,
    Color? verseText,
    Color? verseNumber,
    Color? wordsOfJesus,
    Color? wordsOfJesusHighlighted,
    Color? referenceText,
    Color? referenceTextHighlighted,
    List<Color>? highlights,
  }) {
    return ColorPalette(
      brightness: brightness ?? this.brightness,
      background: background ?? this.background,
      foreground: foreground ?? this.foreground,
      verseText: verseText ?? this.verseText,
      verseNumber: verseNumber ?? this.verseNumber,
      wordsOfJesus: wordsOfJesus ?? this.wordsOfJesus,
      wordsOfJesusHighlighted: wordsOfJesusHighlighted ?? this.wordsOfJesusHighlighted,
      referenceText: referenceText ?? this.referenceText,
      referenceTextHighlighted: referenceTextHighlighted ?? this.referenceTextHighlighted,
      highlights: highlights ?? this.highlights,
    );
  }

  @override
  ThemeExtension<ColorPalette> lerp(ThemeExtension<ColorPalette>? other, double t) {
    if (other is! ColorPalette) {
      return this;
    }
    return ColorPalette(
      brightness: other.brightness,
      background: Color.lerp(background, other.background, t)!,
      foreground: Color.lerp(foreground, other.foreground, t)!,
      verseText: Color.lerp(verseText, other.verseText, t)!,
      verseNumber: Color.lerp(verseNumber, other.verseNumber, t)!,
      wordsOfJesus: Color.lerp(wordsOfJesus, other.wordsOfJesus, t)!,
      wordsOfJesusHighlighted: Color.lerp(wordsOfJesusHighlighted, other.wordsOfJesusHighlighted, t)!,
      referenceText: Color.lerp(referenceText, other.referenceText, t)!,
      referenceTextHighlighted: Color.lerp(referenceTextHighlighted, other.referenceTextHighlighted, t)!,
      highlights: [
        for (int i = 0; i < highlights.length; i++)
          Color.lerp(highlights[i], other.highlights.length > i ? other.highlights[i] : highlights[i], t)!
      ],
    );
  }
}