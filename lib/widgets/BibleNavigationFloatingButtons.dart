import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yhwh/controllers/BiblePageController.dart';
import 'package:yhwh/controllers/ReadPreferencesController.dart';
import 'package:yhwh/widgets/GlassContainer.dart';

/// Botones flotantes nativos para navegación de capítulos (Anterior / Siguiente)
class BibleNavigationFloatingButtons extends StatelessWidget {
  const BibleNavigationFloatingButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BiblePageController>(
      id: 'floatingActionButton',
      init: BiblePageController(),
      builder: (biblePageController) => GetBuilder<ReadPreferencesController>(
        init: ReadPreferencesController(),
        builder: (readPrefs) => AnimatedScale(
          scale: 1.0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          child: AnimatedOpacity(
            opacity: 1.0,
            duration: const Duration(milliseconds: 200),
            child: IgnorePointer(
              ignoring: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    // Genera efecto de movimiento en el botón flotante izquierdo
                    AnimatedPadding(
                      padding: EdgeInsets.symmetric(
                        horizontal: (biblePageController.bookNumber == 1 && biblePageController.chapterNumber == 1) ? 2 : 0,
                      ),
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    ),

                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      switchInCurve: Curves.easeInOut,
                      switchOutCurve: Curves.easeInOut,
                      child: (biblePageController.bookNumber == 1 && biblePageController.chapterNumber == 1)
                          ? const SizedBox()
                          : Tooltip(
                              message: 'Capitulo anterior',
                              child: GlassContainer(
                                enableAcrylic: readPrefs.enableAcrylicEffect,
                                blur: Theme.of(context).brightness == Brightness.dark ? 23.0 : 19.0,
                                width: 45.0,
                                height: 45.0,
                                borderRadius: BorderRadius.circular(30.0),
                                border: Border.all(
                                  color: Theme.of(context).indicatorColor.withValues(
                                        alpha: Theme.of(context).brightness == Brightness.dark ? 0.45 : 0.22,
                                      ),
                                  width: 1.2,
                                ),
                                gradient: readPrefs.enableAcrylicEffect
                                    ? (Theme.of(context).brightness == Brightness.dark
                                        ? LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Theme.of(context).canvasColor.withValues(alpha: 0.35),
                                              Theme.of(context).canvasColor.withValues(alpha: 0.15),
                                            ],
                                          )
                                        : LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Colors.white.withValues(alpha: 0.65),
                                              Colors.white.withValues(alpha: 0.25),
                                            ],
                                          ))
                                    : null,
                                color: readPrefs.enableAcrylicEffect ? null : Theme.of(context).canvasColor,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(
                                      alpha: Theme.of(context).brightness == Brightness.dark ? 0.35 : 0.08,
                                    ),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(30.0),
                                    onTap: biblePageController.previusChapter,
                                    child: Center(
                                      child: Icon(
                                        Icons.keyboard_arrow_left,
                                        color: Theme.of(context).indicatorColor,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                    ),

                    Expanded(child: SizedBox.fromSize()),

                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      switchInCurve: Curves.easeInOut,
                      switchOutCurve: Curves.easeInOut,
                      child: (biblePageController.bookNumber == 66 && biblePageController.chapterNumber == 22)
                          ? const SizedBox()
                          : Tooltip(
                              message: 'Capitulo siguiente',
                              child: GlassContainer(
                                enableAcrylic: readPrefs.enableAcrylicEffect,
                                blur: Theme.of(context).brightness == Brightness.dark ? 23.0 : 19.0,
                                width: 45.0,
                                height: 45.0,
                                borderRadius: BorderRadius.circular(30.0),
                                border: Border.all(
                                  color: Theme.of(context).indicatorColor.withValues(
                                        alpha: Theme.of(context).brightness == Brightness.dark ? 0.45 : 0.22,
                                      ),
                                  width: 1.2,
                                ),
                                gradient: readPrefs.enableAcrylicEffect
                                    ? (Theme.of(context).brightness == Brightness.dark
                                        ? LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Theme.of(context).canvasColor.withValues(alpha: 0.35),
                                              Theme.of(context).canvasColor.withValues(alpha: 0.15),
                                            ],
                                          )
                                        : LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Colors.white.withValues(alpha: 0.65),
                                              Colors.white.withValues(alpha: 0.25),
                                            ],
                                          ))
                                    : null,
                                color: readPrefs.enableAcrylicEffect ? null : Theme.of(context).canvasColor,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(
                                      alpha: Theme.of(context).brightness == Brightness.dark ? 0.35 : 0.08,
                                    ),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(30.0),
                                    onTap: biblePageController.nextChapter,
                                    child: Center(
                                      child: Icon(
                                        Icons.keyboard_arrow_right,
                                        color: Theme.of(context).indicatorColor,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                    ),

                    // Genera efecto de movimiento en el botón flotante derecho
                    AnimatedPadding(
                      padding: EdgeInsets.symmetric(
                        horizontal: (biblePageController.bookNumber == 66 && biblePageController.chapterNumber == 22) ? 2 : 0,
                      ),
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
