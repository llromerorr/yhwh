import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:yhwh/classes/AppTheme.dart';
import 'package:yhwh/controllers/BiblePageController.dart';

class ReadPreferencesController extends GetxController {
  BiblePageController _biblePageController = Get.find();
  GetStorage getStorage = GetStorage();

  String activeTypographyPreset = 'normal';
  String currentThemeName = 'Blanco';
  String currentFontFamily = 'Crimson Text';

  @override
  void onInit() {
    super.onInit();
    // Cargamos los valores guardados o usamos los "normales" por defecto
    activeTypographyPreset = getStorage.read('typographyPreset') ?? 'normal';
    currentThemeName = getStorage.read('currentTheme') ?? 'Blanco'; 
    currentFontFamily = getStorage.read('fontFamily') ?? 'Crimson Text';
  }

  void setTheme(String themeName) {
    currentThemeName = themeName;
    getStorage.write('currentTheme', themeName);
    Get.changeTheme(AppTheme.getTheme(themeName));
    update();
  }

  void setTypographyPreset(String preset) {
    activeTypographyPreset = preset;
    getStorage.write('typographyPreset', preset);

    double newFontSize;
    double newFontHeight;
    double newLetterSeparation;
    // Empezamos asumiendo que conservaremos la fuente que el usuario ya tiene seleccionada
    String newFontFamily = currentFontFamily; 

    switch (preset) {
      case 'small':
        newFontSize = 18.0;
        newFontHeight = 1.6;
        newLetterSeparation = 0.2;
        break;
      case 'normal':
        newFontSize = 22.0;
        newFontHeight = 1.55;
        newLetterSeparation = 0.0;
        break;
      case 'large':
        newFontSize = 26.0;
        newFontHeight = 1.45;
        newLetterSeparation = 0.0;
        break;
      case 'presbyopia':
        newFontSize = 30.0;
        newFontHeight = 1.4; 
        newLetterSeparation = 0.5;
        break;
      case 'visual_impairment':
        newFontSize = 38.0;
        newFontHeight = 1.6;
        newLetterSeparation = 1.0;
        break;
      default:
        newFontSize = 22.0;
        newFontHeight = 1.55;
        newLetterSeparation = 0.0;
    }

    // Si un preset de accesibilidad cambió la fuente, actualizamos la variable global
    if (currentFontFamily != newFontFamily) {
      currentFontFamily = newFontFamily;
      getStorage.write('fontFamily', newFontFamily);
    }

    _biblePageController.fontSize = newFontSize;
    _biblePageController.fontHeight = newFontHeight;
    _biblePageController.fontLetterSeparation = newLetterSeparation;
    _biblePageController.fontFamily = currentFontFamily;

    for (var verseRaw in _biblePageController.versesRawList) {
      verseRaw.fontSize = newFontSize;
      verseRaw.fontHeight = newFontHeight;
      verseRaw.fontLetterSeparation = newLetterSeparation;
      verseRaw.fontFamily = currentFontFamily;
    }

    getStorage.write("fontSize", newFontSize);
    getStorage.write("fontHeight", newFontHeight);
    getStorage.write("fontLetterSeparation", newLetterSeparation);

    _biblePageController.update();
    update(); 
  }

  void setFontFamily(String font) {
    currentFontFamily = font;
    getStorage.write('fontFamily', font);

    _biblePageController.fontFamily = font;

    for (var verseRaw in _biblePageController.versesRawList) {
      verseRaw.fontFamily = font;
    }

    _biblePageController.update();
    update();
  }
}