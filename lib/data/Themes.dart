import 'package:flutter/material.dart';
import 'package:yhwh/classes/ColorPalette.dart';

Map<String, ColorPalette> themes = {
  "Negro Claro": ColorPalette(
    brightness: Brightness.light,
    background: const Color(0xffffffff),
    foreground: const Color(0xff242424),
  ),
  
  "Negro Oscuro": ColorPalette( // 1
    brightness: Brightness.dark,
    background: const Color(0xff000000),
    foreground: const Color(0xffbbbbbb),
  ),

  // "Jean Claro": ColorPalette(
  //   brightness: Brightness.light,
  //   background: const Color(0xfff3efca),
  //   foreground: const Color(0xff1c2c58),
  // ),

  // "Jean Oscuro": ColorPalette(
  //   brightness: Brightness.dark,
  //   background: const Color(0xff101628),
  //   foreground: const Color(0xfff6f6f6),
  // ),

  "Azul Claro": ColorPalette(
    brightness: Brightness.light,
    background: const Color.fromARGB(255, 200, 220, 255),
    foreground: const Color.fromARGB(255, 25, 34, 51),
  ),

  "Azul Oscuro": ColorPalette( // 2
    brightness: Brightness.dark,
    background: const Color.fromARGB(255, 25, 34, 51),
    foreground: const Color.fromARGB(255, 218, 232, 255),
  ),

  "Rojo Claro": ColorPalette(
    brightness: Brightness.light,
    background: const Color(0xffeddec9),
    foreground: const Color(0xff331922)
  ),
  
  "Rojo Oscuro": ColorPalette( // 4
    brightness: Brightness.dark,
    background: const Color(0xff331922),
    foreground: const Color(0xffeddec9),
  ),
  
  "Verde Claro": ColorPalette( // 3
    brightness: Brightness.light,
    background: const Color.fromARGB(255, 193, 254, 181),
    foreground: const Color.fromARGB(255, 25, 51, 31)
  ),

  "Verde Oscuro": ColorPalette( // 5
    brightness: Brightness.dark,
    background: const Color.fromARGB(255, 25, 51, 31),
    foreground: const Color.fromARGB(255, 237, 255, 192),
  ),

  "Rosa claro": ColorPalette( // 3
    brightness: Brightness.light,
    background: const Color.fromARGB(255, 255, 182, 221),
    foreground: const Color.fromARGB(255, 56, 0, 28),
  ),

  "Rosa oscuro": ColorPalette( // 5
    brightness: Brightness.dark,
    background: const Color.fromARGB(255, 41, 6, 23),
    foreground: const Color.fromARGB(255, 247, 228, 238),
  ),

  "Amarillo claro": ColorPalette( // 3
    brightness: Brightness.light,
    background: const Color.fromARGB(255, 253, 252, 201),
    foreground: const Color.fromARGB(255, 51, 48, 25),
  ),

  "Amarillo oscuro": ColorPalette( // 5
    brightness: Brightness.dark,
    background: const Color.fromARGB(255, 51, 48, 25),
    foreground: const Color.fromARGB(255, 255, 254, 209),
  ),

  "Morado claro": ColorPalette( // 3
    brightness: Brightness.light,
    background: const Color.fromARGB(255, 221, 201, 253),
    foreground: const Color.fromARGB(255, 33, 25, 51),
  ),

  "Morado oscuro": ColorPalette( // 5
    brightness: Brightness.dark,
    background: const Color.fromARGB(255, 33, 25, 51),
    foreground: const Color.fromARGB(255, 232, 217, 255),
  )
  
};