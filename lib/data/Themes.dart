import 'package:flutter/material.dart';
import 'package:yhwh/classes/ColorPalette.dart';

Map<String, ColorPalette> themes = {
  "Blanco": ColorPalette(
    brightness: Brightness.light,
    background: const Color(0xffffffff), // Blanco puro
    foreground: const Color(0xff2c2c2c),
    verseText: const Color.fromARGB(255, 56, 56, 56),
    verseNumber: const Color(0xaf37474F),
    wordsOfJesus: const Color.fromARGB(249, 163, 33, 38),
    wordsOfJesusHighlighted: const Color.fromARGB(223, 156, 28, 32),
    referenceText: const Color(0xffF28A2E),
    referenceTextHighlighted: const Color(0xffF28A2E),
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