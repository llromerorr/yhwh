import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:yhwh/controllers/BiblePageController.dart';
import 'package:yhwh/controllers/MainPageController.dart';
import 'package:yhwh/controllers/ReadPreferencesController.dart';
import 'package:yhwh/pages/BiblePage.dart';
import 'package:animate_do/animate_do.dart' as animateDo;
import 'package:yhwh/pages/ContactPage.dart'; // Import original recuperado
import 'package:yhwh/widgets/GlassContainer.dart';

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    Get.lazyPut(() => BiblePageController());

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: Theme.of(context).canvasColor,

      body: GetBuilder<MainPageController>(
        init: MainPageController(),
        builder: (controller) {
          switch (controller.mainPagetabIndex) {
            case 0:
              return BiblePage();
            case 1:
              return const ContactPage(); // Regresamos al ContactPage
            default:
              return animateDo.FadeIn(child: const Center(child: Text("En desarrollo")), duration: const Duration(milliseconds: 150));
          }        
        },
      ),

      bottomNavigationBar: GetBuilder<MainPageController>(
        init: MainPageController(),
        builder: (_){
          return GetBuilder<ReadPreferencesController>(
            init: ReadPreferencesController(),
            builder: (readPrefs) {
              final isDark = Theme.of(context).brightness == Brightness.dark;
              final topBorderColor = Theme.of(context).indicatorColor.withValues(alpha: isDark ? 0.45 : 0.22);

              Widget navBar = BottomNavigationBar(
                currentIndex: _.mainPagetabIndex,
                elevation: 0,
                type: BottomNavigationBarType.fixed,
                backgroundColor: Colors.transparent,
                selectedItemColor: Theme.of(context).indicatorColor.withValues(alpha: 0.9),
                unselectedItemColor: Theme.of(context).indicatorColor.withValues(alpha: 0.6),
                          
                items: [
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.book),
                    label: 'Biblia',
                  ),
                          
                  BottomNavigationBarItem(
                    icon: Badge(
                      isLabelVisible: _.isDownloadCompleted, 
                      backgroundColor: Colors.red,
                      label: const Text('1', style: TextStyle(color: Colors.white, fontSize: 10)), 
                      child: const Icon(Icons.alternate_email_rounded),
                    ),
                    label: 'Contacto',
                  ),
                ],
                          
                onTap: _.bottomNavigationBarOnTap
              );

              return GlassContainer(
                enableAcrylic: readPrefs.enableAcrylicEffect,
                blur: isDark ? 23.0 : 19.0,
                border: Border(
                  top: BorderSide(
                    color: topBorderColor,
                    width: 1.5,
                  ),
                ),
                gradient: readPrefs.enableAcrylicEffect
                    ? (isDark
                        ? LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Theme.of(context).canvasColor.withValues(alpha: 0.45),
                              Theme.of(context).canvasColor.withValues(alpha: 0.25),
                            ],
                          )
                        : LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.white.withValues(alpha: 0.70),
                              Colors.white.withValues(alpha: 0.40),
                            ],
                          ))
                    : null,
                color: readPrefs.enableAcrylicEffect ? null : Theme.of(context).canvasColor,
                child: navBar,
              );
            }
          );
        },
      )
    );
  }
}