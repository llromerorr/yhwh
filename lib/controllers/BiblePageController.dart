
import 'dart:ui';

import 'package:animate_do/animate_do.dart' as animateDo;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hive/hive.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:simple_html_css/simple_html_css.dart';
import 'package:uuid/uuid.dart';
import 'package:yhwh/bibles/RVR60/rvr60_commentaries.dart';
import 'package:yhwh/bibles/RVR60/rvr60_titles.dart';
import 'package:yhwh/classes/BibleManager.dart';
import 'package:yhwh/classes/VerseRaw.dart';
import 'package:yhwh/classes/hiveManagers/HighlighterManager.dart';
import 'package:yhwh/controllers/FloatingBibleController.dart';
import 'package:yhwh/controllers/ReadPreferencesController.dart';
import 'package:yhwh/data/Define.dart';
import 'package:yhwh/data/valuesOfBooks.dart';
import 'package:yhwh/models/highlighterItem.dart';
import 'package:yhwh/pages/FloatingReferencesPage.dart';
import 'package:yhwh/pages/ReferencesPage.dart';
import 'package:yhwh/widgets/FloatingBible.dart';
import 'package:yhwh/widgets/FloatingWidget.dart';
import 'package:yhwh/widgets/Verse.dart';


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

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() async {
    scrollOffset = await getStorage.read('scrollOffset') ?? 0;
    autoScrollController = AutoScrollController(initialScrollOffset: scrollOffset);

    bookNumber = getStorage.read("bookNumber") ?? 1;
    chapterNumber = getStorage.read("chapterNumber") ?? 1;
    verseNumber = getStorage.read("verseNumber") ?? 1;
    
    fontSize = getStorage.read("fontSize") ?? 22.0;
    fontHeight = getStorage.read("fontHeight") ?? 1.55;
    fontLetterSeparation = getStorage.read("fontLetterSeparation") ?? 0;
    fontFamily = getStorage.read("fontFamily") ?? "Crimson Text";

    await updateVerseList();
    isScreenReady = true;
    update();
    super.onReady();
  }

  bool scrollNotification(notification) {
    if(notification is ScrollEndNotification){
      // Save scroll offset
      scrollOffset = autoScrollController!.offset;
      getStorage.write('scrollOffset', scrollOffset);
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
          colorHighlight: highlightVerses.containsKey(index + 1) ? Color(highlightVerses[index + 1]!.color) : Colors.transparent
        )
      );
    }

    return;
  }


  void nextChapter() async {
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
  }

  void previusChapter() async {
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
  }

  void referenceButtonOnTap(){
    cancelSelectionModeOnTap();
    Get.to(()=> ReferencesPage());
  }

  void setReference(int bookNumber, int chapterNumber, int verseNumber) async {
    this.bookNumber = bookNumber;
    this.chapterNumber = chapterNumber;
    this.verseNumber = verseNumber;
    getStorage.write("bookNumber", bookNumber);
    getStorage.write("chapterNumber", chapterNumber);
    getStorage.write("verseNumber", verseNumber);

    versesSelected = [];
    await updateVerseList();
    update();
    
    autoScrollController!.scrollToIndex(verseNumber - 1, duration: Duration(milliseconds: 500), preferPosition: AutoScrollPosition.begin);
  }

  void setReferenceSafeScroll(int bookNumber, int chapterNumber, int verseNumber) async{
    this.bookNumber = bookNumber;
    this.chapterNumber = chapterNumber;
    this.verseNumber = verseNumber;
    getStorage.write("bookNumber", bookNumber);
    getStorage.write("chapterNumber", chapterNumber);
    getStorage.write("verseNumber", verseNumber);

    versesSelected = [];
    await updateVerseList();
    update();
    
    autoScrollController!.scrollToIndex(verseNumber - 1, duration: Duration(milliseconds: 500), preferPosition: AutoScrollPosition.begin);
    autoScrollController!.scrollToIndex(verseNumber - 1, duration: Duration(milliseconds: 500), preferPosition: AutoScrollPosition.begin);
  }

  void addToHighlighter(Color color) async {
    var newHighlighterItem = HighlighterItem(
      book: bookNumber,
      chapter: chapterNumber,
      id: Uuid().v1(),
      color: color.value,
      verses: versesSelected,
      dateTime: DateTime.now()
    );

    // add to database
    HighlighterManager.add(newHighlighterItem);

    // update RawVerses
    for(int verse in versesSelected){
      versesRawList[verse - 1].highlight = true;
      versesRawList[verse - 1].colorHighlight = Color(newHighlighterItem.color);
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
    
    // VARIABLES DE ESTADO AFUERA DEL BUILDER
    List<Widget> previewVerses = []; // Ahora es una lista de widgets Verse
    String previewTitle = "";
    bool initialLoadTriggered = false; 

    showModalBottomSheet(
      context: context,
      isDismissible: true, 
      enableDrag: true,    
      isScrollControlled: true, 
      backgroundColor: Colors.transparent,
      barrierColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {

            // --- FUNCIÓN CENTRAL PARA CARGAR TEXTO BÍBLICO ---
            Future<void> loadReferenceText() async {
              if (book == null || chapter == null || verse_from == null) return;

              List<String> chapterVerses = await BibleManager().getChapter(book: book, chapter: chapter);
              
              List<Widget> tempVerses = [];
              int endVerse = (verse_to != null && verse_to > 0 && verse_to >= verse_from) ? verse_to : verse_from;
              
              for (int i = verse_from; i <= endVerse; i++) {
                if (i > 0 && i <= chapterVerses.length) {
                  // AÑADIMOS TU WIDGET VERSE
                  tempVerses.add(
                    Verse(
                      verseNumber: i,
                      text: chapterVerses[i-1],
                      title: rvr60_titles.containsKey('$book:$chapter:$i') == true ? rvr60_titles['$book:$chapter:$i'].toString() : "",
                      highlight: false, 
                      selected: false,
                      colorHighlight: Colors.transparent,
                      colorNumber: Theme.of(context).indicatorColor.withAlpha(145),
                      colorText: Theme.of(context).indicatorColor,
                      fontSize: fontSize - 2,
                      fontHeight: fontHeight,
                      fontLetterSeparation: fontLetterSeparation,
                      fontFamily: fontFamily,
                      isFirstVerseShowed: true, 
                      
                      onFootnoteTap: (String footnote) {
                        // this.onFootnoteTap(book: book, chapter: chapter, verse: i, footnote: footnote, context: context);
                      },
                      onReferenceTap: (int b, int c, int vf, int vt) {
                        // this.onReferenceTap(book: b, chapter: c, verse_from: vf, verse_to: vt, context: context);
                      },
                    )
                  );
                }
              }

              setModalState(() {
                previewTitle = '${intToBook[book]} $chapter:$verse_from${(verse_to != null && verse_to > verse_from) ? '-$verse_to' : ''}';
                previewVerses = tempVerses;
              });
            }

            // --- AUTO-CARGA INICIAL ---
            if (!initialLoadTriggered) {
              initialLoadTriggered = true;
              loadReferenceText();
            }

            return ClipRect(

              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18, tileMode: TileMode.clamp),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).canvasColor.withValues(alpha: 0.4),
                    border: Border(
                      top: BorderSide(
                        color: Theme.of(context).indicatorColor.withValues(alpha: 0.1), 
                        width: 1.5
                      ),
                    )
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min, 
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Theme.of(context).indicatorColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10), 
                
                      // --- SECCIÓN DE PREVISUALIZACIÓN DINÁMICA ---
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) {
                          return FadeTransition(opacity: animation, child: child);
                        },
                        child: previewVerses.isNotEmpty 
                          ? KeyedSubtree(
                              key: ValueKey('cross_ref_${book ?? 0}_${chapter ?? 0}_${verse_from ?? 0}'),
                              child: animateDo.FadeIn(
                                duration: const Duration(milliseconds: 400),
                                child: Container(
                                  margin: const EdgeInsets.only(top: 10), 
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).indicatorColor.withValues(alpha: 0.05), 
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(
                                      color: Theme.of(context).indicatorColor.withValues(alpha: 0.1), 
                                      width: 1
                                    )
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        previewTitle,
                                        style: TextStyle(
                                          fontFamily: this.fontFamily,
                                          fontWeight: FontWeight.bold,
                                          fontSize: fontSize, 
                                          color: Theme.of(context).indicatorColor,
                                        )
                                      ),
                                      const SizedBox(height: 10),
                
                                      ConstrainedBox(
                                        constraints: BoxConstraints(
                                          maxHeight: MediaQuery.of(context).size.height * 0.4,
                                        ),
                                        child: Scrollbar(
                                          radius: const Radius.circular(8),
                                          child: SingleChildScrollView(
                                            physics: const BouncingScrollPhysics(), 
                                            // AHORA IMPRIMIMOS TUS WIDGETS VERSE
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: previewVerses,
                                            )
                                          ),
                                        ),
                                      ),
                
                                      const SizedBox(height: 15),
                                      
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: TextButton.icon(
                                          onPressed: () {
                                            Navigator.pop(context); 
                                            this.setReferenceSafeScroll(book!, chapter!, verse_from!);
                                          },
                                          icon: Icon(Icons.menu_book_rounded, size: 20, color: Theme.of(context).indicatorColor),
                                          label: Text(
                                            "Ir a la referencia", 
                                            style: TextStyle(
                                              color: Theme.of(context).indicatorColor, 
                                              fontFamily: this.fontFamily, 
                                              fontWeight: FontWeight.bold,
                                              fontSize: fontSize - 7,
                                            )
                                          ),
                                          style: TextButton.styleFrom(
                                            backgroundColor: Theme.of(context).indicatorColor.withValues(alpha: 0.1),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12)
                                            )
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            )
                          : const SizedBox.shrink(key: Key('shrink')), 
                      ),
                
                      Container( 
                        height: MediaQuery.of(context).viewPadding.bottom,
                      )
                    ],
                  ),
                ),
              ),
            );
          }
        );
      },
    );
  }

  void onFootnoteTap({int? book, int? chapter, int? verse, String? footnote, required BuildContext context}){
    String textoNotaParaMostrar = rvr60_commentaries['$book:$chapter:$verse:$footnote'].toString();

    // 1. BUSCAMOS EL PRIMER ENLACE AUTOMÁTICAMENTE
    RegExp exp = RegExp(r"<a\s+href=['\x22](.*?)['\x22]>");
    var match = exp.firstMatch(textoNotaParaMostrar);
    String? firstLink = match?.group(1);

    // 2. VARIABLES DE ESTADO AFUERA DEL BUILDER
    List<Widget> previewVerses = []; // Ahora es una lista de widgets Verse
    String previewTitle = "";
    bool initialLoadTriggered = false; 
    
    int? targetBook;
    int? targetChapter;
    int? targetVerseFrom;
    int? targetVerseTo;

    final ScrollController _versePreviewScrollController = ScrollController();

    showModalBottomSheet(
      context: context,
      isDismissible: true, 
      enableDrag: true,    
      isScrollControlled: true, 
      backgroundColor: Colors.transparent,
      barrierColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {

            // --- FUNCIÓN CENTRAL PARA CARGAR TEXTO BÍBLICO ---
            Future<void> loadReferenceText(String linkStr) async {
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

              if (refBook == null || refChapter == null || refVerseFrom == null) {
                return; 
              }

              List<String> chapterVerses = await BibleManager().getChapter(book: refBook, chapter: refChapter);
              
              List<Widget> tempVerses = [];
              int endVerse = (refVerseTo != null && refVerseTo > 0 && refVerseTo >= refVerseFrom) ? refVerseTo : refVerseFrom;
              
              for (int i = refVerseFrom; i <= endVerse; i++) {
                if (i > 0 && i <= chapterVerses.length) {
                  // AÑADIMOS TU WIDGET VERSE
                  tempVerses.add(
                    Verse(
                      verseNumber: i,
                      text: chapterVerses[i-1],
                      title: rvr60_titles.containsKey('$refBook:$refChapter:$i') == true ? rvr60_titles['$refBook:$refChapter:$i'].toString() : "",
                      highlight: false, // Sin resaltado en la previsualización
                      selected: false,
                      colorHighlight: Colors.transparent,
                      colorNumber: Theme.of(context).indicatorColor.withAlpha(145),
                      colorText: Theme.of(context).indicatorColor,
                      fontSize: fontSize - 2,
                      fontHeight: fontHeight,
                      fontLetterSeparation: fontLetterSeparation,
                      fontFamily: fontFamily,
                      isFirstVerseShowed: true, // Evita espacios grandes arriba
                      
                      // Si tocan una nota o referencia dentro de la previsualización, pueden seguir navegando
                      onFootnoteTap: (String footnote) {
                        // this.onFootnoteTap(book: refBook, chapter: refChapter, verse: i, footnote: footnote, context: context);
                      },
                      onReferenceTap: (int b, int c, int vf, int vt) {
                        // this.onReferenceTap(book: b, chapter: c, verse_from: vf, verse_to: vt, context: context);
                      },
                    )
                  );
                }
              }

              setModalState(() {
                targetBook = refBook;
                targetChapter = refChapter;
                targetVerseFrom = refVerseFrom;
                targetVerseTo = refVerseTo;
                
                // 1. Buscamos el controlador de preferencias con GetX
                final readPreferencesController = Get.find<ReadPreferencesController>();

                // 2. Evaluamos la condición (asumo que la parte cortada de tu imagen era 'presbyopia')
                bool isVisualImpaired = readPreferencesController.activeTypographyPreset == 'visual_impairment' || 
                                        readPreferencesController.activeTypographyPreset == 'presbyopia';

                // 3. Asignamos el título dinámicamente
                previewTitle = isVisualImpaired
                    ? '${intToAbreviatura[refBook]} $refChapter:$refVerseFrom${refVerseTo != refVerseFrom ? '-$refVerseTo' : ''}'
                    : '${intToBook[refBook]} $refChapter:$refVerseFrom${refVerseTo != refVerseFrom ? '-$refVerseTo' : ''}';
                
                previewVerses = tempVerses;
              });
            }

            // --- AUTO-CARGA INICIAL ---
            if (firstLink != null && !initialLoadTriggered) {
              initialLoadTriggered = true;
              loadReferenceText(firstLink);
            }

            return ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18, tileMode: TileMode.clamp),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).canvasColor.withValues(alpha: 0.4),
                    border: Border(
                      top: BorderSide(
                        color: Theme.of(context).indicatorColor.withValues(alpha: 0.4),
                        width: 1.5
                      ),
                    )
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min, 
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Theme.of(context).indicatorColor.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                
                      RichText(
                        text: TextSpan(
                          text: '${intToBook[book]} $chapter:$verse ',
                          style: TextStyle(
                            fontFamily: this.fontFamily,
                            fontWeight: FontWeight.bold,
                            fontSize: fontSize,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                          children: [
                            TextSpan(
                              text: footnote,
                              style: TextStyle(
                                fontFamily: this.fontFamily,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.normal,
                                fontSize: this.fontSize - 7.0,
                                backgroundColor: Colors.transparent,
                                decoration: TextDecoration.none,
                                color: Theme.of(context).brightness == Brightness.light
                                  ? Color(0xffe36414)
                                  : Color(0xffe5c064),
                              ),
                            ),
                          ],
                        ),
                      ),
                
                      // const SizedBox(height: 10),
                      
                      RichText(
                        textAlign: TextAlign.left,
                        text: HTML.toTextSpan(
                          context,
                          textoNotaParaMostrar,
                          defaultTextStyle:
                            Theme.of(context).textTheme.bodyLarge!.copyWith(
                              fontFamily: this.fontFamily,
                              fontWeight: FontWeight.normal,
                              height: fontHeight,
                              fontSize: fontSize,
                              fontStyle: FontStyle.normal,
                              letterSpacing: fontLetterSeparation,
                              color: Theme.of(context).indicatorColor
                            ),
                          overrideStyle: {
                            'a': Theme.of(context).textTheme.bodyLarge!.copyWith(
                              fontFamily: this.fontFamily,
                              fontWeight: FontWeight.bold,
                              height: this.fontHeight,
                              fontSize: fontSize - 1,
                              fontStyle: FontStyle.italic,
                              letterSpacing: this.fontLetterSeparation,
                              color: Theme.of(context).brightness == Brightness.light
                                ? Color(0xffe36414)
                                : Color(0xffe5c064),
                            ),
                            'em': Theme.of(context).textTheme.bodyLarge!.copyWith(
                              fontFamily: this.fontFamily,
                              fontWeight: FontWeight.bold,
                              height: this.fontHeight,
                              fontSize: fontSize,
                              fontStyle: FontStyle.italic,
                              letterSpacing: this.fontLetterSeparation,
                              color: Theme.of(context).indicatorColor),
                          },
                          linksCallback: (link) {
                            loadReferenceText(link.toString());
                          },
                        ),
                      ),
                
                      // --- SECCIÓN DE PREVISUALIZACIÓN DINÁMICA ---
                      AnimatedSize(
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeOutCubic,
                        alignment: Alignment.topCenter,
                        child: Container(
                          width: double.infinity,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder: (child, animation) {
                              return FadeTransition(opacity: animation, child: child);
                            },
                            child: previewVerses.isNotEmpty 
                              ? KeyedSubtree(
                                  key: ValueKey('verse_${targetBook ?? 0}_${targetChapter ?? 0}_${targetVerseFrom ?? 0}'),
                                  child: animateDo.FadeIn(
                                    duration: const Duration(milliseconds: 400),
                                    child: Container(
                                      margin: const EdgeInsets.only(top: 20),
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.transparent,
                                        borderRadius: BorderRadius.circular(15),
                                        border: Border.all(
                                          color: Theme.of(context).indicatorColor.withValues(alpha: 0.2),
                                          width: 2
                                        )
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          AppBar(
                                            title: Text(previewTitle,
                                              style: TextStyle(
                                                fontFamily: this.fontFamily,
                                                fontWeight: FontWeight.bold,
                                                fontSize: fontSize - 2,
                                                color: Theme.of(context).indicatorColor,
                                              )
                                            ),
                                            backgroundColor: Theme.of(context).indicatorColor.withValues(alpha: 0.1),
                                            automaticallyImplyLeading: false,
                                            centerTitle: true,
                                            titleSpacing: 10,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            
                                          ),
                
                                          // Text(
                                          //   previewTitle,
                                          //   style: TextStyle(
                                          //     fontFamily: this.fontFamily,
                                          //     fontWeight: FontWeight.bold,
                                          //     fontSize: fontSize - 1,
                                          //     color: Theme.of(context).indicatorColor,
                                          //   )
                                          // ),
                
                                          // Divider(
                                          //   color: Theme.of(context).indicatorColor.withValues(alpha: 0.3),
                                          //   thickness: 2,
                                          //   height: 20,
                                          // ),
                                          const SizedBox(height: 10),
                
                                          ConstrainedBox(
                                            constraints: BoxConstraints(
                                              maxHeight: MediaQuery.of(context).size.height * 0.3,
                                            ),
                                            child: Scrollbar(
                                              radius: const Radius.circular(8),
                                              // interactive: false,
                                              // thumbVisibility: true,
                                              child: SingleChildScrollView(
                                                physics: const BouncingScrollPhysics(),
                                                // AHORA IMPRIMIMOS TUS WIDGETS VERSE
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: previewVerses,
                                                )
                                              ),
                                            ),
                                          ),
                
                                          const SizedBox(height: 12),
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: TextButton.icon(
                                              onPressed: () {
                                                Navigator.pop(context); 
                                                this.setReferenceSafeScroll(targetBook!, targetChapter!, targetVerseFrom!);
                                              },
                                              icon: Icon(Icons.menu_book_rounded, size: 20, color: Theme.of(context).indicatorColor),
                                              label: Text(
                                                "Ir a la referencia", 
                                                style: TextStyle(
                                                  color: Theme.of(context).indicatorColor, 
                                                  fontFamily: this.fontFamily, 
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: fontSize - 7,
                                                )
                                              ),
                                              style: TextButton.styleFrom(
                                                backgroundColor: Theme.of(context).indicatorColor.withValues(alpha: 0.1),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(12)
                                                )
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(key: Key('shrink')), 
                          ),
                        ),
                      ),
                
                      Container( 
                        height: MediaQuery.of(context).viewPadding.bottom,
                      )
                    ],
                  ),
                ),
              ),
            );
          }
        );
      },
    );
  }

  void onReferenceButtonLongPress(){
    // Get.to(() => FloatingBible());
  }

  void TESTER(){
    // nothing
  }

}