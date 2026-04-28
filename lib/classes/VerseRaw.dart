import 'package:flutter/material.dart';

class VerseRaw {
  int? verseNumber;
  
  String? title;
  String? text;  

  String? fontFamily;
  double? fontSize;
  double? fontHeight;
  double? fontLetterSeparation;

  Color? colorText;
  Color? colorNumber;
  Color? colorHighlight;

  bool? highlight;
  bool? selected;
  bool? isJustified;

  VerseRaw({
    required this.verseNumber,
    required this.title,
    required this.text,
    required this.fontFamily,
    required this.fontSize,
    required this.fontHeight,
    required this.fontLetterSeparation,
    required this.colorText,
    required this.colorNumber,
    required this.colorHighlight,
    required this.highlight,
    required this.selected,
    this.isJustified = false,
  });
}