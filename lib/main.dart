import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:yhwh/classes/AppTheme.dart';
import 'package:yhwh/models/highlighterItem.dart';
import 'package:yhwh/models/highlighterOrderItem.dart';
import 'package:yhwh/pages/MainPage.dart';
import 'package:get_storage/get_storage.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Init GetStorage
  await GetStorage.init();

  // Init Hive
  final appDocumentDir = await getApplicationDocumentsDirectory();
  Hive..init(appDocumentDir.path)
      .. registerAdapter(HighlighterItemAdapter())
      .. registerAdapter(HighlighterOrderItemAdapter());

  // evitar el cambio de orientacion de la aplicacion
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Cargar tema persistido para sincronizar barra de sistema desde el primer frame
  final savedThemeName = GetStorage().read('currentTheme') ?? 'Blanco';
  final initialTheme = AppTheme.getTheme(savedThemeName);

  SystemChrome.setSystemUIOverlayStyle(
    AppTheme.getOverlayStyle(initialTheme.brightness),
  );

  // Run Application
  runApp(GetMaterialApp(
    debugShowCheckedModeBanner: false,
    home: Builder(
      builder: (context) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: AppTheme.getOverlayStyle(Theme.of(context).brightness),
          child: MainPage(),
        );
      },
    ),
    themeMode: ThemeMode.light,
    theme: initialTheme,
    darkTheme: AppTheme.dark,
    builder: (context, child) => ScrollConfiguration(behavior: MyBehavior(), child: child!), // remove the glow effect.
  ));
}

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}
