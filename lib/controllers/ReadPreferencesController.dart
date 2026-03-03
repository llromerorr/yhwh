import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:yhwh/classes/AppTheme.dart';
import 'package:yhwh/controllers/BiblePageController.dart';

class ReadPreferencesController extends GetxController {
  BiblePageController _biblePageController = Get.find();
  GetStorage getStorage = GetStorage();

  String activeTypographyPreset = 'normal';
  String currentThemeName = 'Blanco'; // <-- NUEVO: Sabe qué tema está activo

  @override
  void onInit() {
    super.onInit();
    activeTypographyPreset = getStorage.read('typographyPreset') ?? 'normal';
    currentThemeName = getStorage.read('currentTheme') ?? 'Blanco'; // <-- NUEVO
  }

  void setTheme(String themeName) {
    currentThemeName = themeName; // <-- NUEVO
    getStorage.write('currentTheme', themeName);
    Get.changeTheme(AppTheme.getTheme(themeName));
    update(); // <-- NUEVO: Le avisa a la UI que redibuje el checkmark (✓)
  }

  void setTypographyPreset(String preset) {
    activeTypographyPreset = preset;
    getStorage.write('typographyPreset', preset);

    double newFontSize = 20.0;
    double newFontHeight = 1.8;
    double newLetterSeparation = 0.0;

    switch (preset) {
      case 'small':
        newFontSize = 16.0;
        newFontHeight = 1.5;
        newLetterSeparation = 0.0;
        break;
      case 'normal':
        newFontSize = 20.0;
        newFontHeight = 1.8;
        newLetterSeparation = 0.0;
        break;
      case 'large':
        newFontSize = 24.0;
        newFontHeight = 2.0;
        newLetterSeparation = 0.0;
        break;
      case 'presbyopia':
        newFontSize = 22.0;
        newFontHeight = 2.2;
        newLetterSeparation = 0.5;
        break;
      case 'visual_impairment':
        newFontSize = 30.0;
        newFontHeight = 2.5;
        newLetterSeparation = 1.0;
        break;
    }

    _biblePageController.fontSize = newFontSize;
    _biblePageController.fontHeight = newFontHeight;
    _biblePageController.fontLetterSeparation = newLetterSeparation;

    for (var verseRaw in _biblePageController.versesRawList) {
      verseRaw.fontSize = newFontSize;
      verseRaw.fontHeight = newFontHeight;
      verseRaw.fontLetterSeparation = newLetterSeparation;
    }

    getStorage.write("fontSize", newFontSize);
    getStorage.write("fontHeight", newFontHeight);
    getStorage.write("fontLetterSeparation", newLetterSeparation);

    _biblePageController.update();
    update(); 
  }
}