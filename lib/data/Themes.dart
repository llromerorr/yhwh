import 'package:flutter/material.dart';
import 'package:yhwh/classes/ColorPalette.dart';

Map<String, ColorPalette> themes = {
  "Blanco": ColorPalette(
    brightness: Brightness.light,
    background: const Color(0xffffffff), // Blanco puro
    foreground: const Color(0xff2c2c2c), 
  ),
  "Negro": ColorPalette(
    brightness: Brightness.dark,
    background: const Color(0xff1e1e1e),
    foreground: const Color(0xffe0e0e0),
  ),
  "OLED": ColorPalette(
    brightness: Brightness.dark,
    background: const Color(0xff000000), // Negro puro para ahorrar batería
    foreground: const Color(0xffcccccc),
  )
};