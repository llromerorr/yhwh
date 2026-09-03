import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yhwh/data/Themes.dart';

class AppTheme
{
  static SystemUiOverlayStyle getOverlayStyle(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;
    return SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      systemStatusBarContrastEnforced: false,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      systemNavigationBarContrastEnforced: false,
    );
  }

  // estos son temas por defecto, solo sirven para que no se rompa la app
  static ThemeData light = ThemeData(
    brightness: Brightness.light,
    canvasColor: const Color(0xffffffff),
    indicatorColor: const Color(0xff242424),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      systemOverlayStyle: getOverlayStyle(Brightness.light),
    ),
  );

  static ThemeData dark = ThemeData(
    brightness: Brightness.dark,
    canvasColor: const Color(0xff000000),
    indicatorColor: const Color(0xffbbbbbb),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      systemOverlayStyle: getOverlayStyle(Brightness.dark),
    ),
  );

  
  static ThemeData getTheme(String themeName){
    // esto establece el tema blanco por defecto al iniciar la app por primera vez
    ThemeData theme = light;

    if(themes.containsKey(themeName))
    {
      final palette = themes[themeName]!;
      final overlay = getOverlayStyle(palette.brightness);

      // para temas claros
      if(palette.brightness == Brightness.light){
        theme = ThemeData.light().copyWith(
          canvasColor: palette.background,
          indicatorColor: palette.foreground,
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            systemOverlayStyle: overlay,
          ),
          extensions: <ThemeExtension<dynamic>>[
            palette,
          ],
        );
      }
      
      // para temas oscuros
      else {
        theme = ThemeData.dark().copyWith(
          canvasColor: palette.background,
          indicatorColor: palette.foreground,
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            systemOverlayStyle: overlay,
          ),
          extensions: <ThemeExtension<dynamic>>[
            palette,
          ],
        );
      }
    }

    return theme;
  }
}