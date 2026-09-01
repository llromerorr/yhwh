import 'package:flutter/material.dart';
import 'package:yhwh/classes/ColorPalette.dart';

Map<String, ColorPalette> themes = {
  "Blanco": ColorPalette(
    brightness: Brightness.light,
    background: const Color(0xffFBFBFD), // Blanco porcelana cálida (Apple editorial / cero deslumbramiento)
    foreground: const Color(0xff18181B), // Negro tinta azabache profundo
    verseText: const Color(0xff27272A),   // Zinc 800 alta legibilidad
    verseNumber: const Color(0xff71717A), // Zinc 500 elegante
    wordsOfJesus: const Color(0xffB91C1C), // Rubí refinado
    wordsOfJesusHighlighted: const Color(0xffDC2626),
    referenceText: const Color(0xffD97706), // Ámbar dorado cálido
    referenceTextHighlighted: const Color(0xffD97706),
    highlights: [
      const Color(0x25D9320D),
      const Color(0x25F28A2E),
      const Color(0x251BCBF2),
      const Color(0x25154EBF),
      const Color(0x25D94389),
    ],
  ),
  "Negro": ColorPalette(
    brightness: Brightness.dark,
    background: const Color(0xff212529),
    foreground: const Color(0xffdee2e6),
    verseText: const Color(0xffdee2e6),
    verseNumber: const Color.fromARGB(255, 152, 154, 156),
    wordsOfJesus: const Color.fromARGB(255, 248, 147, 156),
    wordsOfJesusHighlighted: const Color.fromARGB(255, 248, 189, 193),
    referenceText: const Color(0xffe5c064),
    referenceTextHighlighted: const Color.fromARGB(255, 221, 196, 131),
    highlights: [
      const Color(0x20D9320D),
      const Color(0x20F28A2E),
      const Color(0x201BCBF2),
      const Color(0x20154EBF),
      const Color(0x20D94389),
    ],
  ),
  "OLED": ColorPalette(
    brightness: Brightness.dark,
    background: const Color(0xff000000), // Negro puro para ahorrar batería
    foreground: const Color(0xffcccccc),
    verseText: const Color(0xffcccccc),
    verseNumber: const Color.fromARGB(255, 145, 145, 145),
    wordsOfJesus: const Color(0xFFF8939C),
    wordsOfJesusHighlighted: const Color(0xFFF7ABB0),
    referenceText: const Color(0xffe5c064),
    referenceTextHighlighted: const Color(0xffe5c064),
    highlights: [
      const Color.fromARGB(53, 216, 30, 30),
      const Color(0x35F28A2E),
      const Color(0x351BCBF2),
      const Color(0x35154EBF),
      const Color(0x35D94389),
    ],
  )
};