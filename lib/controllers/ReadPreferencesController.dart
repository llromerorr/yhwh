import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  static const List<double> fontLevels = [
    16.0, // 0: Compacto
    18.0, // 1: Pequeño
    20.0, // 2: Estándar
    22.0, // 3: Confort
    25.0, // 4: Grande
    28.0, // 5: Muy Grande
    32.0, // 6: Accesibilidad
    36.0, // 7: Accesibilidad Máx
  ];

  static const List<String> fontLevelLabels = [
    'Compacto',
    'Pequeño',
    'Estándar',
    'Confort',
    'Grande',
    'Muy Grande',
    'Accesibilidad',
    'Accesibilidad Máx',
  ];

  int get currentFontLevelIndex {
    int closestIndex = 0;
    double minDiff = (currentFontSize - fontLevels[0]).abs();
    for (int i = 1; i < fontLevels.length; i++) {
      double diff = (currentFontSize - fontLevels[i]).abs();
      if (diff < minDiff) {
        minDiff = diff;
        closestIndex = i;
      }
    }
    return closestIndex;
  }

  double get fontScaleFactor => currentFontSize / 20.0;

  String get currentFontLabel {
    int idx = currentFontLevelIndex;
    if (idx >= 0 && idx < fontLevelLabels.length) {
      return fontLevelLabels[idx];
    }
    return '${currentFontSize.round()} pt';
  }

  bool get isVisualImpaired => currentFontSize >= 28.0;

  // Sistema de notificación HUD estilo cápsula iOS / Dynamic Island
  String? toastMessage;
  IconData? toastIcon;
  Timer? _toastTimer;

  @override
  void onInit() {
    super.onInit();
    currentThemeName = getStorage.read('currentTheme') ?? 'Blanco'; 
    currentFontFamily = getStorage.read('fontFamily') ?? 'Roboto';
    enableAcrylicEffect = getStorage.read('enableAcrylicEffect') ?? false;
    
    currentFontSize = getStorage.read('fontSize') ?? 20.0;
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

  void showToast(String message, IconData icon) {
    _toastTimer?.cancel();
    toastMessage = message;
    toastIcon = icon;
    update();

    _toastTimer = Timer(const Duration(milliseconds: 1800), () {
      toastMessage = null;
      toastIcon = null;
      update();
    });
  }

  void dismissToast() {
    _toastTimer?.cancel();
    if (toastMessage != null || toastIcon != null) {
      toastMessage = null;
      toastIcon = null;
      update();
    }
  }

  @override
  void onClose() {
    _toastTimer?.cancel();
    super.onClose();
  }

  void toggleAcrylicEffect(bool value) {
    enableAcrylicEffect = value;
    getStorage.write('enableAcrylicEffect', value);
    update();
  }

  void setTheme(String themeName) {
    currentThemeName = themeName;
    getStorage.write('currentTheme', themeName);
    final theme = AppTheme.getTheme(themeName);
    SystemChrome.setSystemUIOverlayStyle(
      AppTheme.getOverlayStyle(theme.brightness),
    );
    Get.changeTheme(theme);
    update();
  }

  void setFontSize(double size) {
    currentFontSize = size;
    getStorage.write('fontSize', size);

    // Ajustamos la altura y separación dinámicamente según la escala
    double newFontHeight = 1.55;
    double newLetterSeparation = 0.0;

    if (size >= 32.0) {
      newFontHeight = 1.6;
      newLetterSeparation = 0.6;
    } else if (size >= 25.0) {
      newFontHeight = 1.5; 
      newLetterSeparation = 0.3;
    } else if (size <= 18.0) {
      newFontHeight = 1.6;
      newLetterSeparation = 0.1;
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

  void setFontSizeByIndex(int index) {
    int clampedIndex = index.clamp(0, fontLevels.length - 1);
    double targetSize = fontLevels[clampedIndex];
    setFontSize(targetSize);
    String label = fontLevelLabels[clampedIndex];
    showToast("${targetSize.round()} pt • $label", Icons.format_size_rounded);
  }

  void stepUpFontSize() {
    int nextIndex = (currentFontLevelIndex + 1).clamp(0, fontLevels.length - 1);
    setFontSizeByIndex(nextIndex);
  }

  void stepDownFontSize() {
    int nextIndex = (currentFontLevelIndex - 1).clamp(0, fontLevels.length - 1);
    setFontSizeByIndex(nextIndex);
  }

  void setJustified(bool value) {
    isJustified = value;
    getStorage.write('isJustified', value);

    _biblePageController.isJustified = value;

    for (var verseRaw in _biblePageController.versesRawList) {
      verseRaw.isJustified = value;
    }

    _biblePageController.update();
    showToast(
      value ? "Texto justificado" : "Texto a la izquierda",
      value ? Icons.format_align_justify_rounded : Icons.format_align_left_rounded,
    );
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

  void cycleTheme() {
    const themeList = ['Blanco', 'Negro', 'OLED'];
    int currentIndex = themeList.indexOf(currentThemeName);
    if (currentIndex == -1) currentIndex = 0;
    int nextIndex = (currentIndex + 1) % themeList.length;
    String nextTheme = themeList[nextIndex];
    setTheme(nextTheme);

    switch (nextTheme) {
      case 'Blanco':
        showToast("Tema Claro", Icons.wb_sunny_rounded);
        break;
      case 'Negro':
        showToast("Tema Oscuro", Icons.wb_twilight_rounded);
        break;
      case 'OLED':
      default:
        showToast("Tema Negro OLED", Icons.dark_mode_rounded);
        break;
    }
  }

  void cycleFontFamily() {
    const fontList = ['Roboto', 'Lato', 'Crimson Text', 'Atkinson Hyperlegible'];
    int currentIndex = fontList.indexOf(currentFontFamily);
    if (currentIndex == -1) currentIndex = 0;
    int nextIndex = (currentIndex + 1) % fontList.length;
    String nextFont = fontList[nextIndex];
    setFontFamily(nextFont);
    showToast("Fuente: $nextFont", Icons.text_fields_rounded);
  }

  void toggleJustified() {
    setJustified(!isJustified);
    showToast(
      isJustified ? "Texto justificado" : "Texto a la izquierda",
      isJustified ? Icons.format_align_justify_rounded : Icons.format_align_left_rounded,
    );
  }

  void toggleKeepScreenOn() {
    setKeepScreenOn(!keepScreenOn);
    showToast(
      keepScreenOn ? "Pantalla siempre activa" : "Pantalla: apagado automático",
      Icons.smartphone_rounded,
    );
  }

  void toggleAcrylic() {
    toggleAcrylicEffect(!enableAcrylicEffect);
    showToast(
      enableAcrylicEffect ? "Efecto cristal activado" : "Efecto cristal desactivado",
      enableAcrylicEffect ? Icons.blur_on_rounded : Icons.blur_off_rounded,
    );
  }

  void resetToDefaults() {
    setTheme('Blanco');
    setFontFamily('Roboto');
    setFontSize(22.0);
    setJustified(false);
    toggleAcrylicEffect(false);
    setKeepScreenOn(false);
    showToast("Ajustes restablecidos", Icons.restart_alt_rounded);
  }
}
