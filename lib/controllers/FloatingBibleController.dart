import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hive/hive.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:uuid/uuid.dart';
import 'package:yhwh/bibles/RVR60/rvr60_titles.dart';
import 'package:yhwh/classes/BibleManager.dart';
import 'package:yhwh/classes/VerseRaw.dart';
import 'package:yhwh/classes/hiveManagers/HighlighterManager.dart';
import 'package:yhwh/controllers/BiblePageController.dart';
import 'package:yhwh/data/Define.dart';
import 'package:yhwh/data/valuesOfBooks.dart';
import 'package:yhwh/models/highlighterItem.dart';
import 'package:yhwh/pages/FloatingReferencesPage.dart';
import 'package:yhwh/pages/ReferencesPage.dart';
import 'package:yhwh/widgets/FloatingBible.dart';
import 'package:yhwh/widgets/FloatingWidget.dart';


class FloatingBibleController extends GetxController {
  AutoScrollController? autoScrollController;
  GetStorage getStorage = GetStorage();
  LazyBox? highlighterBox;
  LazyBox? highlighterOrderBox;
  bool isScreenReady = false;

  int bookNumber = 1;
  int chapterNumber = 1;
  int verseNumber = 1;
  int verseNumber_to = 1;
  bool selectionMode = false;
  double scrollOffset = 0;

  String bibleVersion = "RVR60";
  List<VerseRaw> versesRawList = [];
  List<int> versesSelected = [];

  double fontSize = 20.0;
  double fontHeight = 1.8;
  double fontLetterSeparation = 0.0;
  String fontFamily = "Nunito";

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() async {
    autoScrollController = AutoScrollController(initialScrollOffset: scrollOffset);

    scrollOffset = await getStorage.read('floatingScrollOffset') ?? 0;
    autoScrollController = AutoScrollController(initialScrollOffset: scrollOffset);

    bookNumber = getStorage.read("FloatingBibleBookNumber") ?? 1;
    chapterNumber = getStorage.read("FloatingBibleChapterNumber") ?? 1;
    verseNumber = getStorage.read("FloatingBibleVerseNumber") ?? 1;
    
    fontSize = getStorage.read("fontSize") ?? 20.0;
    fontHeight = getStorage.read("fontHeight") ?? 1.8;
    fontLetterSeparation = getStorage.read("fontLetterSeparation") ?? 0;

    if(chapterNumber == 0) chapterNumber = 1;
    if(verseNumber == 0) verseNumber = 1;
    if(verseNumber_to == 0) verseNumber_to = valuesOfBooks[bookNumber - 1][chapterNumber - 1];

    await updateVerseList();
    isScreenReady = true;
    update();
    super.onReady();
  }

  bool scrollNotification(notification) {
    if(notification is ScrollEndNotification){
      // Save scroll offset
      scrollOffset = autoScrollController!.offset;
      getStorage.write('floatingScrollOffset', scrollOffset);
    }

    return true;
  }

  void onVerseTap(int index){
    if(selectionMode){
      // Agregar o eliminar indices
      if(versesSelected.contains(index)){
        versesSelected.remove(index);
      } else {
        versesSelected.add(index);
      }

      // Activar o desactivar modo seleccion
      if(versesSelected.length != 0){
        selectionMode = true;
      } else {
        selectionMode = false;
      }
      
      versesSelected.sort();
      update();
    }

    else{
      // showVerseExplorer(book: bookNumber, chapter: chapterNumber, verse: index);
    }
  }

  void onVerseLongPress(int index){
    if(!selectionMode){
      selectionMode = true;
      onVerseTap(index);
    } else {
      onVerseTap(index);
    }
  }

  void cancelSelectionModeOnTap(){
    versesSelected = [];
    selectionMode = false;
    update();
  }

  Future<void> updateVerseList() async {
    List<String> verses = await BibleManager().getChapter(book: bookNumber, chapter: chapterNumber);
    Map<int, HighlighterItem> highlightVerses = await HighlighterManager.getHighlightVersesInChapterWithData(bookNumber, chapterNumber);
    versesRawList = [];

    // Crear versiculos
    for (int index = 0; index < valuesOfBooks[bookNumber -1][chapterNumber - 1]; index++) {
      // if(index + 1 >= verseNumber && index + 1 <= verseNumber_to){ // se supone que si quito esto muestra todo el capitulo
        versesRawList.add(
          VerseRaw(
            text: verses[index],
            verseNumber: index + 1,
            colorNumber: Colors.transparent,
            colorText: Colors.transparent,
            fontFamily: "",
            selected: false,
            // se debe cambiar la forma en la que se obotiene el titulo para solo usar un mapa con el formato '[book]:[chapter]:[verse]' como un id de tipo string
            title: rvr60_titles.containsKey('$bookNumber:$chapterNumber:${index + 1}') == true ? rvr60_titles['$bookNumber:$chapterNumber:${index + 1}'] : "",
            fontSize: fontSize,
            fontHeight: fontHeight,
            fontLetterSeparation: fontLetterSeparation,
            highlight: highlightVerses.containsKey(index + 1) ? true : false,
            colorHighlight: highlightVerses.containsKey(index + 1) ? Color(highlightVerses[index + 1]!.color) : Colors.transparent
          )
        );
      // }
    }

    return;
  }


  void nextChapter() async {
    autoScrollController!.animateTo(0, duration: Duration(milliseconds: 500), curve: Curves.easeOut);

    if (chapterNumber < namesAndChapters[bookNumber - 1][1]) {
      chapterNumber++;
      verseNumber = 1;
      verseNumber_to = valuesOfBooks[bookNumber - 1][chapterNumber - 1];
      getStorage.write("FloatingBibleChapterNumber", chapterNumber);
      getStorage.write("FloatingBibleVerseNumber", verseNumber);
      getStorage.write("FloatingBibleVerseNumberTo", verseNumber_to);
    }

    else if (chapterNumber == namesAndChapters[bookNumber - 1][1]) {
      if (bookNumber < 66) {
        bookNumber += 1;
        chapterNumber = 1;
        verseNumber = 1;
        verseNumber_to = valuesOfBooks[bookNumber - 1][chapterNumber - 1];
        getStorage.write("FloatingBibleBookNumber", bookNumber);
        getStorage.write("FloatingBibleChapterNumber", chapterNumber);
        getStorage.write("FloatingBibleVerseNumber", verseNumber);
        getStorage.write("FloatingBibleVerseNumberTo", verseNumber_to);
      }
    }

    versesSelected = [];
    selectionMode = false;
    await updateVerseList();
    update();
  }

  void previusChapter() async {
    autoScrollController!.animateTo(0, duration: Duration(milliseconds: 500), curve: Curves.easeOut);
    
    if (chapterNumber > 1) {
      chapterNumber--;
      verseNumber = 1;
      verseNumber_to = valuesOfBooks[bookNumber - 1][chapterNumber - 1];
      getStorage.write("FloatingBibleChapterNumber", chapterNumber);
      getStorage.write("FloatingBibleVerseNumber", verseNumber);
      getStorage.write("FloatingBibleVerseNumberTo", verseNumber_to);
    }

    else if (chapterNumber == 1)
    {
      if(bookNumber > 1)
      {
        bookNumber -= 1;
        chapterNumber = namesAndChapters[bookNumber - 1][1];
        verseNumber = 1;
        verseNumber_to = valuesOfBooks[bookNumber - 1][chapterNumber - 1];
        getStorage.write("FloatingBibleBookNumber", bookNumber);
        getStorage.write("FloatingBibleChapterNumber", chapterNumber);
        getStorage.write("FloatingBibleVerseNumber", verseNumber);
        getStorage.write("FloatingBibleVerseNumberTo", verseNumber_to);
      }
    }

    versesSelected = [];
    selectionMode = false;
    await updateVerseList();
    update();
  }

  void referenceButtonOnTap(){
    cancelSelectionModeOnTap();
    Get.to(()=> ReferencesPage());
  }

  void setReference(int bookNumber, int chapterNumber, int verseNumber, int verseNumber_to) async {
    this.bookNumber = bookNumber;
    this.chapterNumber = chapterNumber;
    this.verseNumber = verseNumber;
    this.verseNumber_to = verseNumber_to;

    getStorage.write("FloatingBibleBookNumber", bookNumber);
    getStorage.write("FloatingBibleChapterNumber", chapterNumber);
    getStorage.write("FloatingBibleVerseNumber", verseNumber);
    getStorage.write("FloatingBibleVerseNumberTo", verseNumber_to);

    versesSelected = [];
    await updateVerseList();
    update();
    
    autoScrollController!.scrollToIndex(0, duration: Duration(milliseconds: 500), preferPosition: AutoScrollPosition.begin);
  }

  void setReferenceSafeScroll(int bookNumber, int chapterNumber, int verseNumber) async{
    this.bookNumber = bookNumber;
    this.chapterNumber = chapterNumber;
    this.verseNumber = verseNumber;
    getStorage.write("FloatingBibleBookNumber", bookNumber);
    getStorage.write("FloatingBibleChapterNumber", chapterNumber);
    getStorage.write("FloatingBibleVerseNumber", verseNumber);

    versesSelected = [];
    await updateVerseList();
    update();
    
    autoScrollController!.scrollToIndex(verseNumber - 1, duration: Duration(milliseconds: 500), preferPosition: AutoScrollPosition.begin);
    autoScrollController!.scrollToIndex(verseNumber - 1, duration: Duration(milliseconds: 500), preferPosition: AutoScrollPosition.begin);
  }

  void addToHighlighter(int colorIndex) async {
    var newHighlighterItem = HighlighterItem(
      book: bookNumber,
      chapter: chapterNumber,
      id: Uuid().v1(),
      color: colorIndex,
      verses: versesSelected,
      dateTime: DateTime.now()
    );

    // add to database
    HighlighterManager.add(newHighlighterItem);

    // update RawVerses
    for(int verse in versesSelected){
      versesRawList[verse - 1].highlight = true;
      versesRawList[verse - 1].colorHighlight = Color(colorIndex);
    }

    update();
    cancelSelectionModeOnTap();
  }

  void removeFromHighlighter() {
    
    HighlighterManager.removeVersesInChapter(bookNumber, chapterNumber, versesSelected);

    // update RawVerses
    for(int verse in versesSelected){
      versesRawList[verse - 1].highlight = false;
      versesRawList[verse - 1].colorHighlight = Colors.transparent;
    }

    update();
    cancelSelectionModeOnTap();
  }

  void ShowInBiblePage(){
    BiblePageController _biblePageController = Get.find();
    _biblePageController.setReferenceSafeScroll(this.bookNumber, this.chapterNumber, this.verseNumber);
  }

  void onReferenceButtonTap(){
    Get.to(() => FloatingReferencesPage());
    print('Referencia');
  }

}