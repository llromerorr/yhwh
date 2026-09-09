import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:yhwh/controllers/BiblePageController.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:yhwh/controllers/MainPageController.dart';
import 'package:yhwh/controllers/ReadPreferencesController.dart';
import 'package:yhwh/data/Define.dart';
import 'package:yhwh/pages/HighlighterCreate.dart';
import 'package:yhwh/pages/HighlighterPage.dart';
import 'package:yhwh/pages/ReadPreferences.dart';
import 'package:yhwh/widgets/ChapterFooter.dart';
import 'package:yhwh/widgets/GlassContainer.dart';
import 'package:yhwh/widgets/Verse.dart';
import 'package:yhwh/widgets/VerseSkeleton.dart';

class BiblePage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    // 1. Obtenemos el ancho total de la pantalla
    double screenWidth = MediaQuery.of(context).size.width;
    
    // 2. Definimos el ancho máximo ideal para una lectura cómoda
    // Un valor entre 650.0 y 750.0 es perfecto para textos largos.
    double maxReadingWidth = 700.0;
    
    // 3. Calculamos el padding dinámico
    // Si la pantalla es más ancha que nuestro límite, centramos el texto
    // añadiendo padding sobrante a los lados. Si es móvil, usamos 24.0.
    double dynamicPadding = screenWidth > maxReadingWidth 
        ? (screenWidth - maxReadingWidth) / 2 
        : 24.0;

    return GetBuilder<BiblePageController>(
      init: BiblePageController(),
      builder: (mainController) => WillPopScope(
        onWillPop: () {
          BiblePageController onWillPopBiblePageController = Get.put(BiblePageController());
          MainPageController onWillPopMainPageController = Get.put(MainPageController());
          
          if(onWillPopBiblePageController.selectionMode){
            onWillPopBiblePageController.cancelSelectionModeOnTap();
          }
          
          else {
            onWillPopMainPageController.bottomNavigationBarOnTap(0);
          }

          return Future.value(true);
        },

        child: GetBuilder<ReadPreferencesController>(
          init: ReadPreferencesController(),
          builder: (readPrefs) => GetBuilder<BiblePageController>(
              init: BiblePageController(),
              builder: (biblePageController) => NotificationListener<ScrollNotification>(
                  onNotification: biblePageController.scrollNotification,
                  child: RawScrollbar(
                    interactive: true,
                    radius: const Radius.circular(30),
                    thumbColor: Theme.of(context).indicatorColor.withValues(alpha: 0.4),
                    controller: biblePageController.autoScrollController,
                    child: CustomScrollView(
                      controller: biblePageController.autoScrollController,
                      slivers: [
                        // AppBar
                        SliverAppBar(
                          backgroundColor: Colors.transparent,
                          primary: true,
                          floating: false,
                          pinned: true,
                          scrolledUnderElevation: 0,
                          elevation: 0,
                          titleSpacing: 0,
                          bottom: PreferredSize(
                            child: Container(
                              color: Theme.of(context).indicatorColor.withValues(
                                    alpha: Theme.of(context).brightness == Brightness.dark ? 0.45 : 0.22,
                                  ),
                              height: 1.5,
                            ),
                            preferredSize: const Size.fromHeight(0),
                          ),
                    
                          flexibleSpace: GlassContainer(
                            enableAcrylic: readPrefs.enableAcrylicEffect,
                            enableShadows: readPrefs.enableShadows,
                            blur: Theme.of(context).brightness == Brightness.dark
                                ? ControlCenterVisualConfig.darkBlurSigma
                                : ControlCenterVisualConfig.lightBlurSigma,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(
                                  alpha: Theme.of(context).brightness == Brightness.dark ? 0.35 : 0.08,
                                ),
                                blurRadius: 24,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            gradient: readPrefs.enableAcrylicEffect
                                ? (Theme.of(context).brightness == Brightness.dark
                                    ? LinearGradient(
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
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
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                        colors: [
                                          Colors.white.withValues(
                                                alpha: ControlCenterVisualConfig.lightPanelBottomAlpha,
                                              ),
                                          Colors.white.withValues(
                                                alpha: ControlCenterVisualConfig.lightPanelTopAlpha,
                                              ),
                                        ],
                                      ))
                                : null,
                            color: readPrefs.enableAcrylicEffect ? null : Theme.of(context).canvasColor,
                            child: const SizedBox.expand(),
                          ),
                          
                          title: AnimatedCrossFade(
                            sizeCurve: Curves.easeInOut,
                            duration: Duration(milliseconds: 300),
                            crossFadeState: biblePageController.selectionMode == false ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                            firstChild: Container(
                              height: 65,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [      
                                  Spacer(flex: 1),
                    
                                  IconButton(
                                    tooltip: 'Resaltados',
                                    onPressed: (){
                                      biblePageController.cancelSelectionModeOnTap();
                                      Get.to(()=> HighlighterPage());
                                      /*
                                        Recuerda agregar biblePageController.cancelSelectionModeOnTap(),
                                        para evitar un posible bug al momento de entrar en modo
                                        seleccion y presionar alguna otra funccion en pantalla.
                                      */
                                    },

                                    icon: Icon(Icons.bookmark_outline_rounded, color: Theme.of(context).indicatorColor),
                                    iconSize: 26,
                                  ),
                    
                                  Spacer(flex: 10),
                    
                                  GetBuilder<ReadPreferencesController>(
                                    init: ReadPreferencesController(),
                                    builder: (readPreferencesController) {
                                      return Tooltip(
                                        message: 'Referencias',
                                        child: InkWell(
                                          borderRadius: BorderRadius.all(Radius.circular(30)),
                                          child: Container(
                                            height: 55,
                                            alignment: Alignment.center,
                                            child: Padding(
                                              padding: EdgeInsets.fromLTRB(24, 0, 24, 0),
                                              child: RichText(
                                                textAlign: TextAlign.left,
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                                text: TextSpan(
                                                  text: (readPreferencesController.isVisualImpaired)
                                                  ? '${intToAbreviatura[biblePageController.bookNumber]} ${biblePageController.chapterNumber}'
                                                  : '${intToBook[biblePageController.bookNumber]} ${biblePageController.chapterNumber}',
                                                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                                    fontFamily: biblePageController.fontFamily,
                                                    letterSpacing: biblePageController.fontLetterSeparation,
                                                    fontWeight: FontWeight.bold,
                                                    height: biblePageController.fontHeight,
                                                    fontSize: biblePageController.fontSize,
                                                    color: Theme.of(context).indicatorColor
                                                  ),
                                                )
                                              ),
                                            ),
                                          ),
                                                                  
                                          onTap: biblePageController.referenceButtonOnTap,
                                          onLongPress: biblePageController.onReferenceButtonLongPress,
                                          
                                        ),
                                      );
                                    }
                                  ),
                    
                                  Spacer(flex: 10),
                            
                                  IconButton(
                                    tooltip: 'Ajustes visuales',
                                    onPressed: (){
                                      biblePageController.cancelSelectionModeOnTap();
                                      ReadPreferencesControlCenter.show(context);
                                    },
                                    icon: Icon(Icons.text_fields_rounded, color: Theme.of(context).indicatorColor),
                                    iconSize: 26,
                                  ),
                            
                                  Spacer(flex: 1),
                                ],
                              )
                            ),
                    
                            secondChild: Container(
                              height: 90,
                              child: Row(
                                children: [
                                  IconButton(
                                    tooltip: 'Cancelar',
                                    icon: Icon(Icons.arrow_back, color: Theme.of(context).indicatorColor),
                                    iconSize: 30,
                                    onPressed: biblePageController.cancelSelectionModeOnTap,
                                  ),
                            
                                  Expanded(
                                    child: HihglighterCreate()
                                  ),
                            
                                  // Container(width: 12,)
                                ],
                              )
                            ),
                          )
                        ),
                    
                        // Versículos o Skeleton durante la carga asíncrona
                        if (!biblePageController.isScreenReady || biblePageController.versesRawList.isEmpty)
                          SliverToBoxAdapter(
                            child: VerseSkeletonList(
                              horizontalPadding: dynamicPadding,
                            ),
                          )
                        else ...[
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (BuildContext buildContext, int index){
                                return AutoScrollTag(
                                  key: ValueKey(index),
                                  controller: biblePageController.autoScrollController!,
                                  index: index,
                      
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: dynamicPadding),
                                    child: Verse(
                                      highlight: biblePageController.versesRawList[index].highlight!,
                                      selected: biblePageController.versesSelected.contains(index + 1),
                                      verseNumber: index + 1,
                                      title: biblePageController.versesRawList[index].title!,
                                      text: biblePageController.versesRawList[index].text!,
                                      colorHighlight: biblePageController.versesRawList[index].colorHighlight!,
                                      colorNumber: Theme.of(context).indicatorColor.withAlpha(180),
                                      colorText: Theme.of(context).indicatorColor,
                                      fontSize: biblePageController.fontSize,
                                      fontHeight: biblePageController.fontHeight,
                                      fontLetterSeparation: biblePageController.fontLetterSeparation,
                                      fontFamily: biblePageController.fontFamily,
                                      isJustified: biblePageController.isJustified,
                                      isFirstVerseShowed: (index == 0) ? true : false,                    
                                      onTap: ( ) {
                                        biblePageController.onVerseTap(index + 1);
                                      },
                      
                                      onLongPress: (){
                                        biblePageController.onVerseLongPress(index + 1);
                                      },
  
                                      onFootnoteTap: (String footnote) {
                                        biblePageController.onFootnoteTap(book: biblePageController.bookNumber, chapter: biblePageController.chapterNumber, verse: index + 1, footnote: footnote, context: context);
                                      },
                      
                                      onReferenceTap: (int book, int chapter, int verse_from, int verse_to){
                                        biblePageController.onReferenceTap(
                                          book: book, 
                                          chapter: chapter, 
                                          verse_from: verse_from, 
                                          verse_to: verse_to, 
                                          context: context
                                        );
                                      },
                                    ),
                                  ),
                                );
                              },
                      
                              childCount: biblePageController.versesRawList.length,
                            ),
                          ),
                      
                          // Chapter footer
                          ChapterFooter(
                            bibleVersion: biblePageController.bibleVersion,
                          ),
                        ],
                    
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