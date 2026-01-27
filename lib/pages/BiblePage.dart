import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:yhwh/controllers/BiblePageController.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:yhwh/controllers/MainPageController.dart';
import 'package:yhwh/data/Define.dart';
import 'package:yhwh/pages/HighlighterCreate.dart';
import 'package:yhwh/pages/HighlighterPage.dart';
import 'package:yhwh/pages/ReadPreferences.dart';
import 'package:yhwh/widgets/ChapterFooter.dart';
import 'package:yhwh/widgets/Verse.dart';
import 'package:animate_do/animate_do.dart' as animateDo;

class BiblePage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BiblePageController>(
      init: BiblePageController(),
      builder: (mainController) => !mainController.isScreenReady ? Center(child: CircularProgressIndicator(color: Theme.of(context).indicatorColor)) : WillPopScope(
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

        child: animateDo.FadeIn(
          duration: Duration(milliseconds: 150),
          child: Container(
            child: Scaffold(
              backgroundColor: Theme.of(context).canvasColor,

              floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

              floatingActionButton: GetBuilder<BiblePageController>(
                id: 'floatingActionButton',
                init: BiblePageController(),
                builder: (biblePageController) => Padding(
                padding: EdgeInsets.fromLTRB(12, 0, 12, MediaQuery.of(context).viewPadding.bottom + MediaQuery.of(context).padding.bottom),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  
                  children: <Widget>[
                    //Genera efecto de movimiento en el Floating Button                        
                    AnimatedPadding(
                      padding: EdgeInsets.symmetric(horizontal: (biblePageController.bookNumber == 1 && biblePageController.chapterNumber == 1) ? 2 : 0),
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    ),

                    AnimatedSwitcher(
                      duration: Duration(milliseconds: 300),
                      switchInCurve: Curves.easeInOut,
                      switchOutCurve: Curves.easeInOut,
                      child: (biblePageController.bookNumber == 1 && biblePageController.chapterNumber == 1) ? SizedBox() : Container(
                        width: 45.0,
                        height: 45.0,
                        child: Tooltip(
                          message: 'Capitulo anterior',
                          child: Container( //ClipRRect(
                            // borderRadius: BorderRadius.circular(300.0),
                            child: Container( //BackdropFilter(
                              //filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8, tileMode: TileMode.mirror),
                              child: MaterialButton(
                                elevation: 0,
                                onPressed: biblePageController.previusChapter,
                                color: Theme.of(context).canvasColor, //.withValues(alpha: 0.5),
                            
                                child: Icon(
                                  Icons.keyboard_arrow_left,
                                  color: Theme.of(context).indicatorColor,
                                  size: 24,
                                ),
                                padding: EdgeInsets.all(0),
                                shape: CircleBorder(
                                  side: BorderSide(
                                    color: Theme.of(context).indicatorColor.withValues(alpha: 0.5),
                                    width: 1.5
                                  )
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    ),

                    Expanded(child: SizedBox.fromSize()),

                    AnimatedSwitcher(
                      duration: Duration(milliseconds: 300),
                      switchInCurve: Curves.easeInOut,
                      switchOutCurve: Curves.easeInOut,
                      child: (biblePageController.bookNumber == 66 && biblePageController.chapterNumber == 22) ? SizedBox() : Container(
                        width: 45.0,
                        height: 45.0,
                        child: Tooltip(
                          message: 'Capitulo siguiente',
                          child: Container( //ClipRRect(
                            // borderRadius: BorderRadius.circular(300.0),
                            child: Container( //BackdropFilter(
                              //filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8, tileMode: TileMode.mirror),
                              child: MaterialButton(
                                elevation: 0,
                                onPressed: biblePageController.nextChapter,
                                color: Theme.of(context).canvasColor, //.withValues(alpha: 0.5),
                                                          
                                child: Icon(
                                  Icons.keyboard_arrow_right,
                                  color: Theme.of(context).indicatorColor,
                                  size: 24,
                                ),
                                padding: EdgeInsets.all(0),
                                shape: CircleBorder(
                                  side: BorderSide(
                                    color: Theme.of(context).indicatorColor.withValues(alpha: 0.5),
                                    width: 1.5
                                  )
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    //Genera efecto de movimiento en el Floating Button
                    AnimatedPadding(
                      padding: EdgeInsets.symmetric(horizontal: (biblePageController.bookNumber == 66 && biblePageController.chapterNumber == 22) ? 2 : 0),
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    ),
                  ],
                ),
              ),
            ),

              body: GetBuilder<BiblePageController>(
                init: BiblePageController(),
                builder: (biblePageController) => NotificationListener<ScrollNotification>(
                  onNotification: biblePageController.scrollNotification,
                  child: RawScrollbar(
                    interactive: true,
                    radius: Radius.circular(30),
                    thumbColor: Theme.of(context).indicatorColor.withValues(alpha: 0.4),
                    controller: biblePageController.autoScrollController,
                    child: CustomScrollView(
                      controller: biblePageController.autoScrollController,
                      slivers: [
                        // AppBar
                        SliverAppBar(
                          backgroundColor: Theme.of(context).canvasColor, //.withValues(alpha: 0.8),
                          primary: true,
                          floating: false,
                          pinned: true,
                          scrolledUnderElevation: 0,
                          elevation: 0,
                          titleSpacing: 0,
                          bottom: PreferredSize(
                            child: Container(
                              color: Theme.of(context).indicatorColor.withValues(alpha: 0.5),
                              height: 1.5
                            ),
                            
                            preferredSize: Size.fromHeight(0)
                          ),
                    
                          flexibleSpace: Container( //ClipRRect(
                            child: Container( //BackdropFilter(
                              // filter: ImageFilter.blur(
                              //   sigmaX: 24,
                              //   sigmaY: 24,
                              //   tileMode: TileMode.mirror
                              // ),
                              // child: Container(
                              //   color: Colors.transparent,
                              // ),
                            ),
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
                    
                                  Tooltip(
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
                                              text: '${intToBook[biblePageController.bookNumber]} ${biblePageController.chapterNumber}',
                                              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                                fontFamily: biblePageController.fontFamily,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                                color: Theme.of(context).indicatorColor
                                              ),
                                            )
                                          ),
                                        ),
                                      ),
                            
                                      onTap: biblePageController.referenceButtonOnTap,
                                      onLongPress: biblePageController.onReferenceButtonLongPress,
                                      
                                    ),
                                  ),
                    
                                  Spacer(flex: 10),
                            
                                  IconButton(
                                    tooltip: 'Ajustes visuales',
                                    onPressed: (){
                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        backgroundColor: Colors.transparent,
                                        barrierColor: Colors.transparent,
                                        builder: (context) => StatefulBuilder(
                                          builder: (context, setState) => BottomSheet(
                                            backgroundColor: Colors.transparent,
                                            enableDrag: false,
                                            onClosing: (){},
                                            builder: (context) => ReadPreferences(),
                                          )
                                        ),
                                      );
                                    },
                                    icon: Icon(Icons.menu_rounded, color: Theme.of(context).indicatorColor),
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
                    
                        // Verses list
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (BuildContext buildContext, int index){
                              return AutoScrollTag(
                                key: ValueKey(index),
                                controller: biblePageController.autoScrollController!,
                                index: index,
                    
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 25),
                                  child: Verse(
                                    highlight: biblePageController.versesRawList[index].highlight!,
                                    selected: biblePageController.versesSelected.contains(index + 1),
                                    verseNumber: index + 1,
                                    title: biblePageController.versesRawList[index].title!,
                                    text: biblePageController.versesRawList[index].text!,
                                    colorHighlight: biblePageController.versesRawList[index].colorHighlight!,
                                    colorNumber: Theme.of(context).indicatorColor.withAlpha(145),
                                    colorText: Theme.of(context).indicatorColor,
                                    fontSize: biblePageController.fontSize,
                                    fontHeight: biblePageController.fontHeight,
                                    fontLetterSeparation: biblePageController.fontLetterSeparation,
                                    fontFamily: biblePageController.fontFamily,
                                    isFirstVerseShowed: (index == 0) ? true : false,
                    
                                    onTap: ( ) {
                                      biblePageController.onVerseTap(index + 1);
                                    },
                    
                                    onLongPress: (){
                                      biblePageController.onVerseLongPress(index + 1);
                                    },

                                    onFootnoteTap: (String footnote) {
                                      biblePageController.onFootnoteTap(verse: index + 1, footnote: footnote, context: context);
                                    },
                    
                                    onReferenceTap: (int book, int chapter, int verse_from, int verse_to){
                                      biblePageController.onReferenceTap(book: book, chapter: chapter, verse_from: verse_from, verse_to: verse_to);
                                    },
                                  ),
                                )
                              );
                            },
                    
                            childCount: biblePageController.versesRawList.length,
                          ),
                        ),
                    
                        // Chapter footer
                        ChapterFooter(
                          bibleVersion: biblePageController.bibleVersion,
                        )
                    
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}