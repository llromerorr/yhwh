import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yhwh/controllers/FloatingBibleController.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:yhwh/data/Define.dart';
import 'package:yhwh/pages/HighlighterCreate.dart';
import 'package:yhwh/widgets/FloatingWidget.dart';
import 'package:yhwh/widgets/Verse.dart';
import 'package:animate_do/animate_do.dart' as animateDo;

class FloatingBible extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    bool showGoToBotton = Get.arguments?['showGoToBotton'] ?? true;

    return FloatingWidget(
      child: GetBuilder<FloatingBibleController>(
        init: FloatingBibleController(),
        builder: (floatingBibleController) =>  OrientationBuilder(
          builder: (context, orientation) => Container(
            color: Theme.of(context).canvasColor,
            child: Container( //BackdropFilter(
              // filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8, tileMode: TileMode.clamp),
              child: Scaffold( 
                backgroundColor: Theme.of(context).canvasColor,
      
                floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
                
                floatingActionButton: GetBuilder<FloatingBibleController>(
                  id: 'floatingActionButton2',
                  init: FloatingBibleController(),
                  builder: (FloatingBibleController) => Padding(
                  padding: EdgeInsets.fromLTRB(12, 0, 12, MediaQuery.of(context).viewPadding.bottom + MediaQuery.of(context).padding.bottom),
                  child: animateDo.ZoomIn(
                    duration: Duration(milliseconds: 150),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      
                      children: <Widget>[
                        //Genera efecto de movimiento en el Floating Button                        
                        AnimatedPadding(
                          padding: EdgeInsets.symmetric(horizontal: (FloatingBibleController.bookNumber == 1 && FloatingBibleController.chapterNumber == 1) ? 2 : 0),
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        ),
                          
                        AnimatedSwitcher(
                          duration: Duration(milliseconds: 300),
                          switchInCurve: Curves.easeInOut,
                          switchOutCurve: Curves.easeInOut,
                          child: (FloatingBibleController.bookNumber == 1 && FloatingBibleController.chapterNumber == 1) ? SizedBox() : Container(
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
                                    onPressed: FloatingBibleController.previusChapter,
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
                          child: (FloatingBibleController.bookNumber == 66 && FloatingBibleController.chapterNumber == 22) ? SizedBox() : Container(
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
                                    onPressed: FloatingBibleController.nextChapter,
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
                          padding: EdgeInsets.symmetric(horizontal: (FloatingBibleController.bookNumber == 66 && FloatingBibleController.chapterNumber == 22) ? 2 : 0),
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
                
                body: GetBuilder<FloatingBibleController>(
                  init: FloatingBibleController(),
                  builder: (floatingBibleController) => NotificationListener<ScrollNotification>(
                    onNotification: floatingBibleController.scrollNotification,
                    child: RawScrollbar(
                      controller: floatingBibleController.autoScrollController,
                      radius: Radius.circular(30),
                      thumbColor: Theme.of(context).indicatorColor.withValues(alpha: 0.4),
                      child: CustomScrollView(
                        controller: floatingBibleController.autoScrollController,
                        slivers: [
                          // AppBar
                          SliverAppBar(
                            backgroundColor: Theme.of(context).canvasColor,
                            primary: true,
                            floating: false,
                            automaticallyImplyLeading: false,
                            scrolledUnderElevation: 0,
                            // snap: false,
                            // primary: true,
                            pinned: true,
                            elevation: 0,
                            titleSpacing: 0,
                            bottom: PreferredSize(
                              child: Container(
                                color: Theme.of(context).indicatorColor.withValues(alpha: 0.7),
                                height: 1.5
                              ),
                              
                              preferredSize: Size.fromHeight(0)
                            ),
                            
                            title: AnimatedCrossFade(
                              sizeCurve: Curves.easeInOut,
                              duration: Duration(milliseconds: 300),
                              crossFadeState: floatingBibleController.selectionMode == false ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                              firstChild: Container(
                                height: 65,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Tooltip(
                                        message: 'Referencia',
                                        child: InkWell(
                                          // borderRadius: BorderRadius.only(topRight: Radius.circular(30), bottomRight: Radius.circular(30)),
                                          child: Container(
                                            height: 55,
                                            alignment: Alignment.centerLeft,
                                            child: Padding(
                                              padding: EdgeInsets.fromLTRB(17, 0, 0, 0),
                                              child: RichText(
                                                textAlign: TextAlign.left,
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                                text: TextSpan(
                                                  text: '${intToBook[floatingBibleController.bookNumber]} ${floatingBibleController.chapterNumber}',
                                                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                                    fontFamily: 'Roboto-Medium',
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                    color: Theme.of(context).indicatorColor
                                                  ),
                                                )
                                              ),
                                            ),
                                          ),
                              
                                          onTap: floatingBibleController.onReferenceButtonTap,
                                          
                                        ),
                                      ),
                                    ),
                              
                                    (showGoToBotton == false) ? Container() : IconButton(
                                      tooltip: 'Abrir en la biblia',
                                      color: Theme.of(context).indicatorColor,
                                      onPressed: (){
                                        floatingBibleController.cancelSelectionModeOnTap();
                                        floatingBibleController.ShowInBiblePage();
                                        Get.back();
                                      },
                                      icon: Icon(Icons.open_in_new_rounded),
                                      // iconSize: 25,
                                    ),
                              
                                    Container(width: 5),
                    
                                    IconButton(
                                      tooltip: 'Cerrar',
                                      color: Theme.of(context).indicatorColor,
                                      onPressed: (){
                                        floatingBibleController.cancelSelectionModeOnTap();
                                        Get.back();
                                        // Get.to(()=> ReadPreferences());
                                        /*
                                          Recuerda agregar floatingBibleController.cancelSelectionModeOnTap(),
                                          para evitar un posible bug al momento de entrar en modo
                                          seleccion y presionar alguna otra funccion en pantalla.
                                        */
                                      },
                                      icon: Icon(Icons.close_rounded),
                                      iconSize: 27,
                                    ),
                              
                                    Container(width: 5,)
                                  ],
                                )
                              ),
                      
                              secondChild: Container(
                                height: 90,
                                child: Row(
                                  children: [
                                    IconButton(
                                      tooltip: 'Cancelar',
                                      icon: Icon(Icons.arrow_back),
                                      iconSize: 30,
                                      onPressed: floatingBibleController.cancelSelectionModeOnTap,
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
                                  controller: floatingBibleController.autoScrollController!,
                                  index: index,
                      
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 15),
                                    child: Verse(
                                      highlight: floatingBibleController.versesRawList[index].highlight!,
                                      selected: floatingBibleController.versesSelected.contains(index + 1),
                                      verseNumber: floatingBibleController.versesRawList[index].verseNumber!,
                                      title: floatingBibleController.versesRawList[index].title!,
                                      text: floatingBibleController.versesRawList[index].text!,
                                      colorHighlight: floatingBibleController.versesRawList[index].colorHighlight!,
                                      colorNumber: Theme.of(context).indicatorColor.withAlpha(145),
                                      colorText: Theme.of(context).indicatorColor,
                                      fontSize: floatingBibleController.fontSize,
                                      fontHeight: floatingBibleController.fontHeight,
                                      fontLetterSeparation: floatingBibleController.fontLetterSeparation,
                                      fontFamily: floatingBibleController.fontFamily,
                                      isJustified: floatingBibleController.isJustified,
                                      isFirstVerseShowed: (index == 0) ? true : false,
                                      onReferenceTap: (int book, int chapter, int verse_from, int verse_to){
                                        floatingBibleController.setReference(book, chapter, verse_from, verse_to);
                                      },
                                    ),
                                  )
                                );
                              },
                      
                              childCount: floatingBibleController.versesRawList.length,
                            ),
                          ),
                  
                          SliverToBoxAdapter(
                            child: Container(height: Get.size.height * 0.05),
                          )
                      
                          // Chapter footer
                          // ChapterFooter(
                          //   bibleVersion: floatingBibleController.bibleVersion,
                          // )
                      
                        ],
                      ),
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