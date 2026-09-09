import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:yhwh/controllers/BiblePageController.dart';
import 'package:yhwh/controllers/MainPageController.dart';
import 'package:yhwh/controllers/ReadPreferencesController.dart';
import 'package:yhwh/pages/BiblePage.dart';
import 'package:yhwh/pages/ContactPage.dart'; // Import original recuperado
import 'package:yhwh/pages/ReadPreferences.dart';
import 'package:yhwh/widgets/BibleNavigationFloatingButtons.dart';
import 'package:yhwh/widgets/GlassContainer.dart';

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    Get.lazyPut(() => BiblePageController());

    return BackdropGroup(
      child: GetBuilder<MainPageController>(
        init: MainPageController(),
        builder: (controller) {
          return Scaffold(
            extendBody: true,
            extendBodyBehindAppBar: true,
            backgroundColor: Theme.of(context).canvasColor,

            body: IndexedStack(
              index: controller.mainPagetabIndex,
              children: [
                BiblePage(),
                const ContactPage(),
              ],
            ),

            floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
            floatingActionButton: const BibleNavigationFloatingButtons(),

            bottomNavigationBar: GetBuilder<ReadPreferencesController>(
              init: ReadPreferencesController(),
              builder: (readPrefs) {
                final isDark = Theme.of(context).brightness == Brightness.dark;
                final topBorderColor = Theme.of(context).indicatorColor.withValues(alpha: isDark ? 0.45 : 0.22);

                Widget navBar = BottomNavigationBar(
                  currentIndex: controller.mainPagetabIndex,
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
                        isLabelVisible: controller.isDownloadCompleted, 
                        backgroundColor: Colors.red,
                        label: const Text('1', style: TextStyle(color: Colors.white, fontSize: 10)), 
                        child: const Icon(Icons.alternate_email_rounded),
                      ),
                      label: 'Contacto',
                    ),
                  ],
                            
                  onTap: (index) {
                    HapticFeedback.selectionClick();
                    controller.bottomNavigationBarOnTap(index);
                  },
                );

                return GlassContainer(
                  enableAcrylic: readPrefs.enableAcrylicEffect,
                  blur: isDark ? ControlCenterVisualConfig.darkBlurSigma : ControlCenterVisualConfig.lightBlurSigma,
                  border: Border(
                    top: BorderSide(
                      color: topBorderColor,
                      width: 1.5,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                      blurRadius: 28,
                      offset: const Offset(0, -6),
                    ),
                  ],
                  gradient: readPrefs.enableAcrylicEffect
                      ? (isDark
                          ? LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Theme.of(context).canvasColor.withValues(
                                      alpha: ControlCenterVisualConfig.darkPanelTopAlpha,
                                    ),
                                Theme.of(context).canvasColor.withValues(
                                      alpha: ControlCenterVisualConfig.darkPanelBottomAlpha,
                                    ),
                              ],
                            )
                          : LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white.withValues(
                                      alpha: ControlCenterVisualConfig.lightPanelTopAlpha,
                                    ),
                                Colors.white.withValues(
                                      alpha: ControlCenterVisualConfig.lightPanelBottomAlpha,
                                    ),
                              ],
                            ))
                      : null,
                  color: readPrefs.enableAcrylicEffect ? null : Theme.of(context).canvasColor,
                  child: navBar,
                );
              },
            ),
          );
        },
      ),
    );
  }
}