import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hive/hive.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:uuid/uuid.dart';
import 'package:yhwh/bibles/RVR60/rvr60_commentaries.dart';
import 'package:yhwh/bibles/RVR60/rvr60_titles.dart';
import 'package:yhwh/classes/BibleManager.dart';
import 'package:yhwh/classes/VerseRaw.dart';
import 'package:yhwh/classes/hiveManagers/HighlighterManager.dart';
import 'package:yhwh/controllers/ReadPreferencesController.dart';
import 'package:yhwh/data/Define.dart';
import 'package:yhwh/data/valuesOfBooks.dart';
import 'package:yhwh/models/highlighterItem.dart';
import 'package:yhwh/pages/ReferencesPage.dart';
import 'package:yhwh/widgets/Verse.dart';
import 'package:yhwh/widgets/ReferenceBottomSheet.dart';


class BiblePageController extends GetxController {
  AutoScrollController? autoScrollController;
  GetStorage getStorage = GetStorage();
  LazyBox? highlighterBox;
  LazyBox? highlighterOrderBox;
  bool isScreenReady = false;

  int bookNumber = 1;
  int chapterNumber = 1;
  int verseNumber = 1;
  bool selectionMode = false;
  double scrollOffset = 0;

  String bibleVersion = "RVR60";
  List<VerseRaw> versesRawList = [];
  List<int> versesSelected = [];

  double fontSize = 22.0;
  double fontHeight = 1.55;
  double fontLetterSeparation = 0.0;
  String fontFamily = "Crimson Text";
  bool isJustified = false;
  bool isBottomSheetOpen = false;

  void setBottomSheetState(bool isOpen) {
    if (isBottomSheetOpen != isOpen) {
      isBottomSheetOpen = isOpen;
      update(['floatingActionButton']);
    }
  }

  @override
  void onInit() {
    super.onInit();
    bookNumber = getStorage.read("bookNumber") ?? 1;
    chapterNumber = getStorage.read("chapterNumber") ?? 1;
    verseNumber = getStorage.read("verseNumber") ?? 1;
    
    fontSize = getStorage.read("fontSize") ?? 22.0;
    fontHeight = getStorage.read("fontHeight") ?? 1.55;
    fontLetterSeparation = getStorage.read("fontLetterSeparation") ?? 0;
    fontFamily = getStorage.read("fontFamily") ?? "Crimson Text";
    isJustified = getStorage.read("isJustified") ?? false;
  }

  @override
  void onReady() async {
    final savedOffset = getStorage.read('scrollOffset');
    scrollOffset = (savedOffset is num) ? savedOffset.toDouble() : 0.0;
    autoScrollController = AutoScrollController();

    await updateVerseList();
    isScreenReady = true;
    update();
    update(['floatingActionButton']);

    // Restauramos el scroll una vez que los versículos están listos en pantalla
    if (scrollOffset > 0) {
      Future.delayed(const Duration(milliseconds: 60), () {
        if (autoScrollController != null && autoScrollController!.hasClients) {
          autoScrollController!.jumpTo(scrollOffset);
        }
      });
    }

    super.onReady();
  }

  bool scrollNotification(ScrollNotification notification) {
    // Exactamente como querías: cuando se detiene el scroll, se guarda
    if (notification is ScrollEndNotification) {
      if (autoScrollController != null && autoScrollController!.hasClients) {
        scrollOffset = autoScrollController!.offset;
        getStorage.write('scrollOffset', scrollOffset);
      }
    }

    return false;
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
    HapticFeedback.vibrate();
    
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
      versesRawList.add(
        VerseRaw(
          verseNumber: index + 1,
          selected: false,
          colorNumber: Colors.transparent,
          colorText: Colors.transparent,
          fontFamily: "",
          text: verses[index],
          // se debe cambiar la forma en la que se obotiene el titulo para solo usar un mapa con el formato '[book]:[chapter]:[verse]' como un id de tipo string
          title: rvr60_titles.containsKey('$bookNumber:$chapterNumber:${index + 1}') == true ? rvr60_titles['$bookNumber:$chapterNumber:${index + 1}'] : "",
          fontSize: fontSize,
          fontHeight: fontHeight,
          fontLetterSeparation: fontLetterSeparation,
          highlight: highlightVerses.containsKey(index + 1) ? true : false,
          colorHighlight: highlightVerses.containsKey(index + 1) ? Color(highlightVerses[index + 1]!.color) : Colors.transparent,
          isJustified: isJustified,
        )
      );
    }

    return;
  }


  void nextChapter() async {
    scrollOffset = 0.0;
    getStorage.write('scrollOffset', 0.0);
    autoScrollController!.animateTo(0, duration: Duration(milliseconds: 500), curve: Curves.easeOut);

    if (chapterNumber < namesAndChapters[bookNumber - 1][1]) {
      chapterNumber++;
      verseNumber = 1;
      getStorage.write("chapterNumber", chapterNumber);
      getStorage.write("verseNumber", verseNumber);
    }

    else if (chapterNumber == namesAndChapters[bookNumber - 1][1]) {
      if (bookNumber < 66) {
        bookNumber += 1;
        chapterNumber = 1;
        verseNumber = 1;
        getStorage.write("bookNumber", bookNumber);
        getStorage.write("chapterNumber", chapterNumber);
        getStorage.write("verseNumber", verseNumber);
      }
    }

    versesSelected = [];
    selectionMode = false;
    await updateVerseList();
    update();
    update(['floatingActionButton']);
  }

  void previusChapter() async {
    scrollOffset = 0.0;
    getStorage.write('scrollOffset', 0.0);
    autoScrollController!.animateTo(0, duration: Duration(milliseconds: 500), curve: Curves.easeOut);
    
    if (chapterNumber > 1) {
      chapterNumber--;
      verseNumber = 1;
      getStorage.write("chapterNumber", chapterNumber);
      getStorage.write("verseNumber", verseNumber);
    }

    else if (chapterNumber == 1)
    {
      if(bookNumber > 1)
      {
        bookNumber -= 1;
        chapterNumber = namesAndChapters[bookNumber - 1][1];
        verseNumber = 1;
        getStorage.write("bookNumber", bookNumber);
        getStorage.write("chapterNumber", chapterNumber);
        getStorage.write("verseNumber", verseNumber);
      }
    }

    versesSelected = [];
    selectionMode = false;
    await updateVerseList();
    update();
    update(['floatingActionButton']);
  }

  void referenceButtonOnTap(){
    cancelSelectionModeOnTap();
    Get.to(()=> ReferencesPage());
  }

  void setReference(int bookNumber, int chapterNumber, int verseNumber) async {
    scrollOffset = 0.0;
    getStorage.write('scrollOffset', 0.0);
    this.bookNumber = bookNumber;
    this.chapterNumber = chapterNumber;
    this.verseNumber = verseNumber;
    getStorage.write("bookNumber", bookNumber);
    getStorage.write("chapterNumber", chapterNumber);
    getStorage.write("verseNumber", verseNumber);

    versesSelected = [];
    await updateVerseList();
    update();
    update(['floatingActionButton']);
    
    autoScrollController!.scrollToIndex(verseNumber - 1, duration: Duration(milliseconds: 500), preferPosition: AutoScrollPosition.begin);
  }

  void setReferenceSafeScroll(int bookNumber, int chapterNumber, int verseNumber) async{
    scrollOffset = 0.0;
    getStorage.write('scrollOffset', 0.0);
    this.bookNumber = bookNumber;
    this.chapterNumber = chapterNumber;
    this.verseNumber = verseNumber;
    getStorage.write("bookNumber", bookNumber);
    getStorage.write("chapterNumber", chapterNumber);
    getStorage.write("verseNumber", verseNumber);

    versesSelected = [];
    await updateVerseList();
    update();
    update(['floatingActionButton']);
    
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
      // Guardamos directamente el índice. El widget Verse se encargará de decodificarlo.
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

  void copyVersesToClipboard() {
    if (versesSelected.isEmpty) return;

    // 1. Ordenamos los versículos de menor a mayor por si el usuario los seleccionó en desorden
    versesSelected.sort();
    String copiedText = "";

    // 2. Extraemos el texto de cada versículo y lo limpiamos
    for (int verseIndex in versesSelected) {
      String rawText = versesRawList[verseIndex - 1].text ?? "";
      
      // Utilizamos una Expresión Regular (RegExp) para eliminar cualquier etiqueta HTML 
      // como <red>, <f>, <i>, etc. y dejar solo el texto puro.
      // 1. Elimina las etiquetas <f> completas junto con su contenido interno (ej: <f>[5†]</f> desaparece)
      // 2. Elimina cualquier otra etiqueta HTML restante (ej: <red> o </red>) dejando el texto intacto
      String cleanText = rawText
          .replaceAll(RegExp(r'<f>.*?</f>'), '') 
          .replaceAll(RegExp(r'<[^>]*>'), '');
          
      // (Opcional) Limpia posibles dobles espacios que queden al borrar la nota
      cleanText = cleanText.replaceAll('  ', ' ').trim();
      
      copiedText += "$verseIndex $cleanText\n";
    }

    // 3. Armamos la referencia final (Ej: "Juan 3:16" o "Juan 3:16-18")
    String bookName = intToBook[bookNumber] ?? "";
    String reference = "$bookName $chapterNumber:${versesSelected.first}";
    if (versesSelected.length > 1) {
      reference += "-${versesSelected.last}"; 
    }

    copiedText += "\n$reference";

    // 4. Guardamos en el portapapeles
    Clipboard.setData(ClipboardData(text: copiedText));
    
    // 5. Salimos del modo selección
    cancelSelectionModeOnTap();
    
    // 6. (Opcional) Mostramos un pequeño aviso de éxito
    // Get.snackbar(
    //   '¡Copiado!',
    //   'Versículos copiados al portapapeles.',
    //   snackPosition: SnackPosition.BOTTOM,
    //   backgroundColor: Get.theme.indicatorColor.withValues(alpha: 0.9),
    //   colorText: Get.theme.canvasColor,
    //   margin: const EdgeInsets.all(16),
    //   borderRadius: 12,
    //   duration: const Duration(seconds: 2),
    // );
  }

  void onReferenceTap({int? book, int? chapter, int? verse_from, int? verse_to, required BuildContext context}) {
    if (book == null || chapter == null || verse_from == null) return;

    final readPrefs = Get.find<ReadPreferencesController>();
    final isVisualImpaired = readPrefs.isVisualImpaired;
    final bookName = isVisualImpaired
        ? (intToAbreviatura[book] ?? '')
        : (intToBook[book] ?? '');
    final title = '$bookName $chapter:$verse_from${(verse_to != null && verse_to > verse_from) ? '-$verse_to' : ''}';

    final reference = ReferenceItem(
      book: book,
      chapter: chapter,
      verseFrom: verse_from,
      verseTo: verse_to,
      label: title,
    );

    setBottomSheetState(true);
    ReferenceBottomSheet.show(
      context: context,
      title: title,
      references: [reference],
      loadVerses: (b, c, vf, vt) => _loadVersesForReference(b, c, vf, vt, context),
      onNavigate: (b, c, v) => setReferenceSafeScroll(b, c, v),
      onDismissed: () => setBottomSheetState(false),
    );
  }

  Future<List<Widget>> _loadVersesForReference(
      int book, int chapter, int verseFrom, int? verseTo, BuildContext context) async {
    List<String> chapterVerses = await BibleManager().getChapter(book: book, chapter: chapter);
    List<Widget> tempVerses = [];
    int endVerse = (verseTo != null && verseTo > 0 && verseTo >= verseFrom) ? verseTo : verseFrom;

    for (int i = verseFrom; i <= endVerse; i++) {
      if (i > 0 && i <= chapterVerses.length) {
        tempVerses.add(
          Verse(
            verseNumber: i,
            text: chapterVerses[i - 1],
            title: rvr60_titles['$book:$chapter:$i']?.toString() ?? "",
            highlight: false,
            selected: false,
            colorHighlight: Colors.transparent,
            colorNumber: Theme.of(context).indicatorColor.withAlpha(145),
            colorText: Theme.of(context).indicatorColor,
            fontSize: (fontSize - 2).clamp(13.0, 32.0),
            fontHeight: fontHeight,
            fontLetterSeparation: fontLetterSeparation,
            fontFamily: fontFamily,
            isFirstVerseShowed: true,
            isJustified: isJustified,
            onFootnoteTap: (String footnote) {},
            onReferenceTap: (int b, int c, int vf, int vt) {},
          ),
        );
      }
    }
    return tempVerses;
  }

  void onFootnoteTap({int? book, int? chapter, int? verse, String? footnote, required BuildContext context}) {
    String textoNotaParaMostrar = rvr60_commentaries['$book:$chapter:$verse:$footnote']?.toString() ?? '';

    final readPrefs = Get.find<ReadPreferencesController>();
    final isVisualImpaired = readPrefs.isVisualImpaired;
    final sourceBookTitle = (book != null)
        ? (isVisualImpaired ? intToAbreviatura[book] ?? '' : intToBook[book] ?? '')
        : '';
    final title = '$sourceBookTitle $chapter:$verse';

    // 1. Parseamos todas las citas bíblicas de la nota
    List<_ParsedReference> parsedList = _parseFootnoteLinks(textoNotaParaMostrar);
    List<ReferenceItem> referenceItems = parsedList.map((p) => ReferenceItem(
      book: p.book,
      chapter: p.chapter,
      verseFrom: p.verseFrom,
      verseTo: p.verseTo,
      label: p.label,
    )).toList();

    setBottomSheetState(true);
    ReferenceBottomSheet.show(
      context: context,
      title: title,
      footnoteBadge: footnote,
      references: referenceItems,
      rawHtmlContent: referenceItems.isEmpty ? textoNotaParaMostrar : null,
      loadVerses: (b, c, vf, vt) => _loadVersesForReference(b, c, vf, vt, context),
      onNavigate: (b, c, v) => setReferenceSafeScroll(b, c, v),
      onDismissed: () => setBottomSheetState(false),
    );
  }

  void onReferenceButtonLongPress(){
    // Get.to(() => FloatingBible());
  }

  void TESTER(){
    // nothing
  }

}

/// Estructura de Referencia parseada para el Carrusel
class _ParsedReference {
  final int book;
  final int chapter;
  final int verseFrom;
  final int? verseTo;
  final String label;
  final String linkStr;

  _ParsedReference({
    required this.book,
    required this.chapter,
    required this.verseFrom,
    this.verseTo,
    required this.label,
    required this.linkStr,
  });
}

/// Helper para parsear todas las citas bíblicas de una nota
List<_ParsedReference> _parseFootnoteLinks(String text) {
  List<_ParsedReference> list = [];
  RegExp linkExp = RegExp(r"<a\s+href=['\x22](.*?)['\x22]>(.*?)<\/a>");
  for (var m in linkExp.allMatches(text)) {
    String linkStr = m.group(1)!;
    String label = m.group(2)!.replaceAll(RegExp(r'<[^>]*>'), '').trim();

    int? refBook;
    int? refChapter;
    int? refVerseFrom;
    int? refVerseTo;

    if (linkStr.startsWith('B:')) {
      String cleanLink = linkStr.substring(2);
      List<String> parts = cleanLink.split(' ');
      if (parts.isNotEmpty) {
        int? internalId = int.tryParse(parts[0]);
        if (internalId != null && linkIdToBook.containsKey(internalId)) {
          refBook = linkIdToBook[internalId];
        }
      }
      if (parts.length > 1) {
        List<String> cv = parts[1].split(':');
        if (cv.isNotEmpty) refChapter = int.tryParse(cv[0]);
        if (cv.length > 1) {
          List<String> verses = cv[1].split('-');
          refVerseFrom = int.tryParse(verses[0]);
          refVerseTo = verses.length > 1 ? int.tryParse(verses[1]) : refVerseFrom;
        }
      }
    } else {
      List<String> split = linkStr.split(':');
      if (split.isNotEmpty) refBook = int.tryParse(split[0]);
      if (split.length >= 2) refChapter = int.tryParse(split[1]);
      if (split.length >= 3) {
        List<String> verses = split[2].split('-');
        refVerseFrom = int.tryParse(verses[0]);
        refVerseTo = verses.length > 1 ? int.tryParse(verses[1]) : refVerseFrom;
      }
    }

    if (refBook != null && refChapter != null && refVerseFrom != null) {
      list.add(_ParsedReference(
        book: refBook,
        chapter: refChapter,
        verseFrom: refVerseFrom,
        verseTo: refVerseTo,
        label: label,
        linkStr: linkStr,
      ));
    }
  }
  return list;
}