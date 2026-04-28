import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:yhwh/classes/AppTheme.dart';
import 'package:yhwh/controllers/BiblePageController.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class ReadPreferencesController extends GetxController {
  BiblePageController _biblePageController = Get.find();
  GetStorage getStorage = GetStorage();

  String currentThemeName = 'Blanco';
  String currentFontFamily = 'Roboto';
  bool enableAcrylicEffect = false;
  
  double currentFontSize = 22.0;
  bool isJustified = false;
  bool keepScreenOn = false;

  bool get isVisualImpaired => currentFontSize >= 28.0;

  @override
  void onInit() {
    super.onInit();
    // Cargamos los valores guardados o usamos los "normales" por defecto
    currentThemeName = getStorage.read('currentTheme') ?? 'Blanco'; 
    currentFontFamily = getStorage.read('fontFamily') ?? 'Roboto';
    enableAcrylicEffect = getStorage.read('enableAcrylicEffect') ?? false;
    
    currentFontSize = getStorage.read('fontSize') ?? 22.0;
    isJustified = getStorage.read('isJustified') ?? false;
    keepScreenOn = getStorage.read('keepScreenOn') ?? false;

    _applyWakelock();
  }

  void _applyWakelock() {
    if (keepScreenOn) {
      WakelockPlus.enable();
    } else {
      WakelockPlus.disable();
    }
  }

  void toggleAcrylicEffect(bool value) {
    enableAcrylicEffect = value;
    getStorage.write('enableAcrylicEffect', value);
    update();
  }

  void setTheme(String themeName) {
    currentThemeName = themeName;
    getStorage.write('currentTheme', themeName);
    Get.changeTheme(AppTheme.getTheme(themeName));
    update();
  }

  void setFontSize(double size) {
    currentFontSize = size;
    getStorage.write('fontSize', size);

    // Ajustamos la altura y separación dinámicamente
    double newFontHeight = 1.55;
    double newLetterSeparation = 0.0;

    if (size >= 38.0) {
      newFontHeight = 1.6;
      newLetterSeparation = 1.0;
    } else if (size >= 30.0) {
      newFontHeight = 1.4; 
      newLetterSeparation = 0.5;
    } else if (size <= 18.0) {
      newFontHeight = 1.6;
      newLetterSeparation = 0.2;
    }

    getStorage.write('fontHeight', newFontHeight);
    getStorage.write('fontLetterSeparation', newLetterSeparation);

    _biblePageController.fontSize = currentFontSize;
    _biblePageController.fontHeight = newFontHeight;
    _biblePageController.fontLetterSeparation = newLetterSeparation;

    for (var verseRaw in _biblePageController.versesRawList) {
      verseRaw.fontSize = currentFontSize;
      verseRaw.fontHeight = newFontHeight;
      verseRaw.fontLetterSeparation = newLetterSeparation;
    }

    _biblePageController.update();
    update();
  }

  void setJustified(bool value) {
    isJustified = value;
    getStorage.write('isJustified', value);

    _biblePageController.isJustified = value;

    for (var verseRaw in _biblePageController.versesRawList) {
      verseRaw.isJustified = value;
    }

    _biblePageController.update();
    update();
  }

  void setKeepScreenOn(bool value) {
    keepScreenOn = value;
    getStorage.write('keepScreenOn', value);
    _applyWakelock();
    update();
  }

  void setFontFamily(String font) {
    currentFontFamily = font;
    getStorage.write('fontFamily', font);

    Get.changeTheme(AppTheme.getTheme(currentThemeName));

    _biblePageController.fontFamily = font;

    for (var verseRaw in _biblePageController.versesRawList) {
      verseRaw.fontFamily = font;
    }

    _biblePageController.update();
    update();
  }

  void resetToDefaults() {
    setTheme('Blanco');
    setFontFamily('Roboto');
    setFontSize(22.0);
    setJustified(false);
    toggleAcrylicEffect(false);
    setKeepScreenOn(false);
  }
}
