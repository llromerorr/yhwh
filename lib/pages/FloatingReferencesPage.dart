
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:yhwh/controllers/BiblePageController.dart';
import 'package:yhwh/controllers/FloatingBibleController.dart';
import 'package:yhwh/controllers/FloatingReferencesPageController.dart';
import 'package:yhwh/data/Define.dart';
import 'package:yhwh/data/valuesOfBooks.dart';
import 'package:yhwh/pages/BiblePage.dart';
import 'package:yhwh/widgets/FloatingWidget.dart';

class FloatingReferencesPage extends StatelessWidget {
  const FloatingReferencesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return FloatingWidget(
      child: GetBuilder<FloatingReferencesPageController>(
          init: FloatingReferencesPageController(),
          builder: (FloatingReferencesPageController floatingReferencesPageController) { 
            return GetBuilder<FloatingBibleController>(
              init: FloatingBibleController(),
              builder: (floatingBibleController) { 
                return Container(
                  color: Colors.transparent,
                  child: Stack(
                    children: [
                      // Referencias
                      Scaffold(
                        backgroundColor: Colors.transparent,
                        appBar: AppBar(
                          backgroundColor: Colors.transparent,
                          scrolledUnderElevation: 0,
                          elevation: 0,
                          title: Text("Referencias", style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).indicatorColor
                          )),
                      
                          leading: IconButton(
                            tooltip: 'Volver',
                            icon: Icon(Icons.arrow_back, color: Theme.of(context).indicatorColor),
                            onPressed: Get.back,
                          ), 
                      
                          actions: [
                            IconButton(
                                tooltip: 'Buscar referencias',
                                color: Theme.of(context).indicatorColor,
                                onPressed: (){
                                  Get.dialog(
                                     GetBuilder<FloatingReferencesPageController>(
                                      init: FloatingReferencesPageController(),
                                      builder: (FloatingReferencesPageController floatingReferencesPageController) {
                                        return FloatingWidget(
                                          child: Scaffold(
                                            backgroundColor: Colors.transparent,
                                            appBar: AppBar(
                                              backgroundColor: Colors.transparent,
                                              scrolledUnderElevation: 0,
                                              elevation: 0,
                                              title: TextField(
                                                style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 21, color: Theme.of(context).indicatorColor),
                                                decoration: InputDecoration(
                                                  border: InputBorder.none,
                                                  hintText: 'Buscar',
                                                  hintStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 21, color: Theme.of(context).indicatorColor.withValues(alpha: 0.5)),
                                                ),
                                                          
                                                cursorColor: Theme.of(context).indicatorColor,
                                                cursorRadius: Radius.circular(8),
                                                          
                                                autofocus: true,
                                                keyboardType: TextInputType.text,
                                                textInputAction: TextInputAction.search,
                                                autocorrect: false,
                                                onSubmitted: floatingReferencesPageController.searchTextFieldOnSubmitted,
                                                          
                                                          
                                                controller: floatingReferencesPageController.textEditingController,
                                                onChanged: floatingReferencesPageController.searchTextFieldOnChange,
                                              ),
                                                          
                                              leading: IconButton(
                                                tooltip: 'Volver',
                                                icon: Icon(Icons.arrow_back, color: Theme.of(context).indicatorColor),
                                                onPressed: Get.back
                                              ),
                                                          
                                              actions: [
                                                IconButton(
                                                  tooltip: 'Limpiar',
                                                  icon: Icon(Icons.clear, color: Theme.of(context).indicatorColor),
                                                  onPressed: floatingReferencesPageController.clearSearchTextField
                                                ),
                                              ],
                                                          
                                              bottom: PreferredSize(
                                                child: Container(
                                                  color: Theme.of(context).indicatorColor,
                                                  height: 1.5
                                                ),
                                                
                                                preferredSize: Size.fromHeight(0)
                                              ),
                                            ),
                                                          
                                            body: ListView.builder(
                                              controller: floatingReferencesPageController.searchListScrollController,
                                              itemBuilder: (context, index) => ListTile(
                                                title: Text(
                                                  '${intToBook[floatingReferencesPageController.searchList[index][0]]} ${floatingReferencesPageController.searchList[index][1]}:${floatingReferencesPageController.searchList[index][2]}', 
                                                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                                    fontSize: 18,
                                                    fontWeight: index == 0 ? FontWeight.bold : FontWeight.normal,
                                                    color: Theme.of(context).indicatorColor
                                                  )
                                                ),
                                                        
                                                onTap: (){
                                                  floatingReferencesPageController.searchListItemOnTap(index);
                                                },
                                                        
                                                leading: Icon(Icons.search, color: Theme.of(context).indicatorColor)
                                              ),
                                              
                                              itemCount: floatingReferencesPageController.searchList.length,
                                            )
                                          ),
                                        );
                                      }
                                    )
                                  );
                                },
                                icon: Icon(Icons.search),
                            )
                          ],
                      
                          bottom: PreferredSize(
                            preferredSize: Size.fromHeight(kToolbarHeight),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).canvasColor,
                                border: Border(
                                  bottom: BorderSide(
                                    width: 1.5,
                                    color: Theme.of(context).indicatorColor.withValues(alpha: 0.8)
                                  )
                                )
                              ),
                      
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Container(
                                      alignment: Alignment.centerLeft,
                                      height: kToolbarHeight,
                                      child: Padding(
                                        padding: EdgeInsets.only(left: 12),
                                        child: Text("Libro", style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontSize: 18, color: Theme.of(context).indicatorColor), textAlign: TextAlign.center),
                                      ),
                                    ),
                                  ),
                      
                                  Expanded(
                                    child: Container(
                                      alignment: Alignment.center,
                                      height: kToolbarHeight,
                                      // color: Color(0xffEA4335),
                                      child: Text("Capitulo", style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontSize: 18, color: Theme.of(context).indicatorColor), textAlign: TextAlign.center),
                                    ),
                                  ),
                      
                                  Expanded(
                                    child: Container(
                                      alignment: Alignment.center,
                                      height: kToolbarHeight,
                                      // color: Color(0xff34A853),
                                      child: Text("Verso", style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontSize: 18, color: Theme.of(context).indicatorColor), textAlign: TextAlign.center),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      
                        body: Container(
                          child: Row(
                            children: [
                              
                              // LIBRO
                              Expanded(
                                flex: 200,
                                child: RawScrollbar(
                                  controller: floatingReferencesPageController.bookAutoScrollController,
                                  thumbColor: Theme.of(context).indicatorColor.withValues(alpha: 0.4),
                                  radius: Radius.circular(30),
                                  child: ListView.builder(
                                    itemExtent: 60,
                                    controller: floatingReferencesPageController.bookAutoScrollController,
                                    padding: EdgeInsets.fromLTRB(6, 8, 0, 80),
                                    itemBuilder: (context, index) {
                                      return AutoScrollTag(
                                        key: ValueKey(index),
                                        controller: floatingReferencesPageController.bookAutoScrollController!,
                                        index: index,
                                                        
                                        child: InkWell(
                                          borderRadius: BorderRadius.only(topRight: Radius.circular(30), bottomRight: Radius.circular(30), bottomLeft: Radius.circular(6), topLeft: Radius.circular(6)),
                                          onTap: (){
                                            floatingBibleController.setReference(index + 1, 1, 1, valuesOfBooks[index][0]);
                                            floatingReferencesPageController.bookListOnSelect(index);
                                            floatingReferencesPageController.chapterListOnSelect(0);
                                            floatingReferencesPageController.verseListOnSelect(0);
                                          },
                                          child: Container(
                                            padding: EdgeInsets.only(left: 6),
                                            decoration: BoxDecoration(
                                              color: index == floatingBibleController.bookNumber - 1 ? Theme.of(context).indicatorColor: Colors.transparent,
                                              borderRadius: BorderRadius.only(topRight: Radius.circular(30), bottomRight: Radius.circular(30), bottomLeft: Radius.circular(6), topLeft: Radius.circular(6)),
                                            ),
                                            // padding: EdgeInsets.only(left: 15),
                                            alignment: Alignment.centerLeft,
                                            height: 60,
                                            child: Text(
                                              '${intToBook[index + 1]}',
                                              textAlign: TextAlign.center,
                                              maxLines: 1,
                                              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                                color: index == floatingBibleController.bookNumber - 1 ? Theme.of(context).canvasColor : Theme.of(context).indicatorColor,
                                                fontSize: 18,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            )
                                          ),
                                        ),
                                      );
                                    },
                                                        
                                    itemCount: 66,
                                  ),
                                ),
                              ),
                            
                              // CAPITULO
                              Expanded(
                                flex: 100,
                                child: RawScrollbar(
                                  controller: floatingReferencesPageController.chapterAutoScrollController,
                                  thumbColor: Theme.of(context).indicatorColor.withValues(alpha: 0.4),
                                  radius: Radius.circular(30),
                                  child: ListView.builder(
                                    itemExtent: 60,
                                    controller: floatingReferencesPageController.chapterAutoScrollController,
                                    padding: EdgeInsets.fromLTRB(0, 8, 0, 80),
                                    itemBuilder: (context, index) {
                                      return AutoScrollTag(
                                        key: ValueKey(index),
                                        controller: floatingReferencesPageController.chapterAutoScrollController!,
                                        index: index,
                                                        
                                        child: InkWell(
                                          customBorder: CircleBorder(),
                                          onTap: (){
                                            floatingBibleController.setReference(floatingBibleController.bookNumber, index + 1, 1, valuesOfBooks[floatingBibleController.bookNumber - 1][index]);
                                            floatingReferencesPageController.chapterListOnSelect(index);
                                            floatingReferencesPageController.verseListOnSelect(0);
                                          },
                            
                                          // onLongPress: (){
                                          //   // Get.back();
                                          //   floatingBibleController.onReferenceTap(showGoToBotton: false, book: floatingBibleController.bookNumber, chapter: index + 1, verse_from: 1, verse_to: valuesOfBooks[floatingBibleController.bookNumber - 1][index]);
                                          //   // floatingReferencesPageController.verseListOnSelect(index);
                                          // },
                            
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: index == floatingBibleController.chapterNumber - 1 ? Theme.of(context).indicatorColor : Colors.transparent,
                                              shape: BoxShape.circle,
                                            ),
                                            alignment: Alignment.center,
                                            height: 60,
                                            child: Text(
                                              '${index + 1}',
                                              textAlign: TextAlign.center,
                                              maxLines: 1,
                                              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                                color: index == floatingBibleController.chapterNumber - 1 ? Theme.of(context).canvasColor : Theme.of(context).indicatorColor,
                                                fontSize: 18,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            )
                                          ),
                                        ),
                                      );
                                    },
                                    itemCount: valuesOfBooks[floatingBibleController.bookNumber - 1].length,
                                  ),
                                ),
                              ),
                            
                              // VERSICULO
                              Expanded(
                                flex: 100,
                                child:RawScrollbar(
                                  controller: floatingReferencesPageController.verseAutoScrollController,
                                  thumbColor: Theme.of(context).indicatorColor.withValues(alpha: 0.4),
                                  radius: Radius.circular(30),
                                  child: ListView.builder(
                                    itemExtent: 60,
                                    controller: floatingReferencesPageController.verseAutoScrollController,
                                    padding: EdgeInsets.fromLTRB(0, 8, 0, 80),
                                    itemBuilder: (context, index) {
                                                        
                                      return AutoScrollTag(
                                        key: ValueKey(index),
                                        controller: floatingReferencesPageController.verseAutoScrollController!,
                                        index: index,
                                                        
                                        child: InkWell(
                                          customBorder: CircleBorder(),
                                          onTap: (){
                                            floatingBibleController.setReferenceSafeScroll(floatingBibleController.bookNumber, floatingBibleController.chapterNumber, index + 1);
                                            floatingReferencesPageController.verseListOnSelect(index);
                                            Get.back();
                                          },
                            
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: index == floatingBibleController.verseNumber - 1 ? Theme.of(context).indicatorColor: Colors.transparent,
                                              shape: BoxShape.circle,
                                            ),
                                            alignment: Alignment.center,
                                            height: 60,
                                            child: Text(
                                              '${index + 1}',
                                              textAlign: TextAlign.center,
                                              maxLines: 1,
                                              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                                color: index == floatingBibleController.verseNumber - 1 ? Theme.of(context).canvasColor : Theme.of(context).indicatorColor,
                                                fontSize: 18,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            )
                                          ),
                                        ),
                                      );
                                    },
                                    itemCount: valuesOfBooks[floatingBibleController.bookNumber - 1][floatingBibleController.chapterNumber - 1],
                                  ),
                                ),
                              ),
                            ]
                          ),
                        )
                        ),
                    ],
                  ),
                        );
              }
            );
        }
      ),
    );
  }
}
