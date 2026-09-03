
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
import 'package:yhwh/pages/ReadPreferences.dart';
import 'package:yhwh/pages/ReferencesPage.dart';
import 'package:yhwh/widgets/FloatingBible.dart';
import 'package:yhwh/widgets/FloatingWidget.dart';
import 'package:yhwh/widgets/GlassContainer.dart';
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
    isJustified = getStorage.read("isJustified") ?? false;

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
          colorHighlight: highlightVerses.containsKey(index + 1) ? Color(highlightVerses[index + 1]!.color) : Colors.transparent,
          isJustified: isJustified,
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
    // VARIABLES DE ESTADO AFUERA DEL BUILDER
    List<Widget> previewVerses = [];
    String previewTitle = "";
    bool initialLoadTriggered = false; 

    setBottomSheetState(true);
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
                      isJustified: isJustified,
                      onFootnoteTap: (String footnote) {},
                      onReferenceTap: (int b, int c, int vf, int vt) {},
                    )
                  );
                }
              }

              setModalState(() {
                final readPreferencesController = Get.find<ReadPreferencesController>();
                bool isVisualImpaired = readPreferencesController.isVisualImpaired;

                previewTitle = isVisualImpaired
                    ? '${intToAbreviatura[book]} $chapter:$verse_from${(verse_to != null && verse_to > verse_from) ? '-$verse_to' : ''}'
                    : '${intToBook[book]} $chapter:$verse_from${(verse_to != null && verse_to > verse_from) ? '-$verse_to' : ''}';
                previewVerses = tempVerses;
              });
            }

            // --- AUTO-CARGA INICIAL ---
            if (!initialLoadTriggered) {
              initialLoadTriggered = true;
              loadReferenceText();
            }

            return GetBuilder<ReadPreferencesController>(
              init: ReadPreferencesController(),
              builder: (readPrefs) {
                final isDark = Theme.of(context).brightness == Brightness.dark;
                final indicatorColor = Theme.of(context).indicatorColor;
                final canvasColor = Theme.of(context).canvasColor;
                final topBorderColor = indicatorColor.withValues(
                  alpha: isDark ? 0.45 : 0.22,
                );
                final borderColor = indicatorColor.withValues(
                  alpha: isDark ? 0.18 : 0.14,
                );

                final activeGradient = isDark
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          indicatorColor,
                          indicatorColor.withValues(alpha: 0.85),
                        ],
                      )
                    : const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF2E2E34),
                          Color(0xFF111114),
                        ],
                      );

                Widget sheetContent = SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tirador de arrastre superior
                        Center(
                          child: Container(
                            width: 42,
                            height: 5,
                            margin: const EdgeInsets.only(bottom: 14),
                            decoration: BoxDecoration(
                              color: indicatorColor.withValues(
                                alpha: isDark ? 0.30 : 0.20,
                              ),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),

                        // Nivel 1: Insignia + Botón de Acción Compacto con Icono
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? indicatorColor.withValues(alpha: 0.12)
                                    : indicatorColor.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: borderColor,
                                  width: 1.0,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.auto_stories_rounded,
                                    size: 14,
                                    color: indicatorColor,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    "Pasaje Relacionado",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: indicatorColor,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            _ReferenceMiniActionBtn(
                              label: "Abrir",
                              icon: Icon(
                                Icons.arrow_forward_rounded,
                                size: 16,
                                color: isDark ? canvasColor : Colors.white,
                              ),
                              gradient: activeGradient,
                              borderColor: borderColor,
                              textColor: isDark ? canvasColor : Colors.white,
                              onTap: () {
                                Navigator.pop(context);
                                setReferenceSafeScroll(book!, chapter!, verse_from!);
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // Nivel 2: Título en grande con FittedBox (Cero desborde)
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            previewTitle,
                            style: TextStyle(
                              fontFamily: fontFamily,
                              fontWeight: FontWeight.bold,
                              fontSize: fontSize,
                              color: indicatorColor,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Contenido del versículo directamente sobre el cristal con scroll elástico
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (child, animation) {
                            return FadeTransition(opacity: animation, child: child);
                          },
                          child: previewVerses.isNotEmpty
                              ? ConstrainedBox(
                                  key: ValueKey('cross_ref_${book ?? 0}_${chapter ?? 0}_${verse_from ?? 0}'),
                                  constraints: BoxConstraints(
                                    maxHeight: MediaQuery.of(context).size.height * 0.48,
                                  ),
                                  child: RawScrollbar(
                                    radius: const Radius.circular(8),
                                    thumbColor: indicatorColor.withValues(alpha: 0.30),
                                    child: SingleChildScrollView(
                                      primary: false,
                                      physics: const BouncingScrollPhysics(),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: previewVerses,
                                      ),
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(key: Key('shrink')),
                        ),
                      ],
                    ),
                  ),
                );

                return GlassContainer(
                  enableAcrylic: readPrefs.enableAcrylicEffect,
                  blur: isDark
                      ? ControlCenterVisualConfig.darkBlurSigma
                      : ControlCenterVisualConfig.lightBlurSigma,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
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
                                canvasColor.withValues(alpha: ControlCenterVisualConfig.darkPanelTopAlpha),
                                canvasColor.withValues(alpha: ControlCenterVisualConfig.darkPanelBottomAlpha),
                              ],
                            )
                          : LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white.withValues(alpha: ControlCenterVisualConfig.lightPanelTopAlpha),
                                Colors.white.withValues(alpha: ControlCenterVisualConfig.lightPanelBottomAlpha),
                              ],
                            ))
                      : null,
                  color: readPrefs.enableAcrylicEffect ? null : canvasColor,
                  child: sheetContent,
                );
              },
            );
          },
        );
      },
    ).then((_) {
      setBottomSheetState(false);
    });
  }

  void onFootnoteTap({int? book, int? chapter, int? verse, String? footnote, required BuildContext context}){
    String textoNotaParaMostrar = rvr60_commentaries['$book:$chapter:$verse:$footnote'].toString();

    // 1. Parseamos todas las citas bíblicas de la nota
    List<_ParsedReference> parsedList = _parseFootnoteLinks(textoNotaParaMostrar);

    // 2. Estado
    int activeIndex = 0;
    PageController pageController = PageController();
    Map<int, List<Widget>> cachedVerses = {};
    bool initialLoadTriggered = false;

    setBottomSheetState(true);
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

            // Cargar versículos del índice activo
            Future<void> loadIndex(int idx) async {
              if (idx < 0 || idx >= parsedList.length) return;
              if (cachedVerses.containsKey(idx)) return;

              final target = parsedList[idx];
              List<String> chapterVerses = await BibleManager().getChapter(book: target.book, chapter: target.chapter);
              
              List<Widget> tempVerses = [];
              int endVerse = (target.verseTo != null && target.verseTo! > 0 && target.verseTo! >= target.verseFrom) ? target.verseTo! : target.verseFrom;
              
              for (int i = target.verseFrom; i <= endVerse; i++) {
                if (i > 0 && i <= chapterVerses.length) {
                  tempVerses.add(
                    Verse(
                      verseNumber: i,
                      text: chapterVerses[i-1],
                      title: rvr60_titles.containsKey('${target.book}:${target.chapter}:$i') == true ? rvr60_titles['${target.book}:${target.chapter}:$i'].toString() : "",
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
                      isJustified: isJustified,
                      onFootnoteTap: (String footnote) {},
                      onReferenceTap: (int b, int c, int vf, int vt) {},
                    )
                  );
                }
              }

              setModalState(() {
                cachedVerses[idx] = tempVerses;
              });
            }

            // Auto-carga del primer elemento si hay citas bíblicas
            if (parsedList.isNotEmpty && !initialLoadTriggered) {
              initialLoadTriggered = true;
              loadIndex(0);
            }

            return GetBuilder<ReadPreferencesController>(
              init: ReadPreferencesController(),
              builder: (readPrefs) {
                final isDark = Theme.of(context).brightness == Brightness.dark;
                final indicatorColor = Theme.of(context).indicatorColor;
                final canvasColor = Theme.of(context).canvasColor;
                final topBorderColor = indicatorColor.withValues(
                  alpha: isDark ? 0.45 : 0.22,
                );
                final borderColor = indicatorColor.withValues(
                  alpha: isDark ? 0.18 : 0.14,
                );

                final neutralGradient = isDark
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          indicatorColor.withValues(
                            alpha: readPrefs.enableAcrylicEffect
                                ? ControlCenterVisualConfig.darkButtonTopAlpha
                                : 0.15,
                          ),
                          indicatorColor.withValues(
                            alpha: readPrefs.enableAcrylicEffect
                                ? ControlCenterVisualConfig.darkButtonBottomAlpha
                                : 0.05,
                          ),
                        ],
                      )
                    : LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          readPrefs.enableAcrylicEffect
                              ? Colors.white.withValues(
                                  alpha: ControlCenterVisualConfig.lightButtonTopAlpha,
                                )
                              : const Color(0xFFFFFFFF),
                          readPrefs.enableAcrylicEffect
                              ? Colors.white.withValues(
                                  alpha: ControlCenterVisualConfig.lightButtonBottomAlpha,
                                )
                              : const Color(0xFFE2E4EA),
                        ],
                      );

                final activeGradient = isDark
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          indicatorColor,
                          indicatorColor.withValues(alpha: 0.85),
                        ],
                      )
                    : const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF2E2E34),
                          Color(0xFF111114),
                        ],
                      );

                final bool isVisualImpaired = readPrefs.isVisualImpaired;
                final String sourceBookTitle = (book != null)
                    ? (isVisualImpaired ? intToAbreviatura[book] ?? '' : intToBook[book] ?? '')
                    : '';
                final cleanFootnote = (footnote ?? '').replaceAll('[', '').replaceAll(']', '').trim();

                Widget sheetContent = SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tirador de arrastre superior
                        Center(
                          child: Container(
                            width: 42,
                            height: 5,
                            margin: const EdgeInsets.only(bottom: 14),
                            decoration: BoxDecoration(
                              color: indicatorColor.withValues(
                                alpha: isDark ? 0.30 : 0.20,
                              ),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),

                        // Nivel 1: Insignia + Botón de Acción Compacto con Icono
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xffe5c064).withValues(alpha: 0.15)
                                    : const Color(0xffe36414).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isDark
                                      ? const Color(0xffe5c064).withValues(alpha: 0.35)
                                      : const Color(0xffe36414).withValues(alpha: 0.25),
                                  width: 1.0,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    parsedList.isNotEmpty
                                        ? Icons.auto_stories_rounded
                                        : Icons.lightbulb_rounded,
                                    size: 14,
                                    color: isDark ? const Color(0xffe5c064) : const Color(0xffe36414),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    parsedList.isNotEmpty
                                        ? '${parsedList.length} ${parsedList.length == 1 ? 'Pasaje' : 'Pasajes'} (${activeIndex + 1}/${parsedList.length})'
                                        : "Nota Lingüística",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? const Color(0xffe5c064) : const Color(0xffe36414),
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            if (parsedList.isNotEmpty)
                              _ReferenceMiniActionBtn(
                                label: "Abrir",
                                icon: Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 16,
                                  color: isDark ? canvasColor : Colors.white,
                                ),
                                gradient: activeGradient,
                                borderColor: borderColor,
                                textColor: isDark ? canvasColor : Colors.white,
                                onTap: () {
                                  Navigator.pop(context);
                                  final currentTarget = parsedList[activeIndex];
                                  setReferenceSafeScroll(
                                    currentTarget.book,
                                    currentTarget.chapter,
                                    currentTarget.verseFrom,
                                  );
                                },
                              )
                            else
                              _ReferenceMiniActionBtn(
                                label: "Cerrar",
                                icon: Icon(
                                  Icons.close_rounded,
                                  size: 16,
                                  color: indicatorColor,
                                ),
                                gradient: neutralGradient,
                                borderColor: borderColor,
                                textColor: indicatorColor,
                                onTap: () => Navigator.pop(context),
                              ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // Nivel 2: Título de origen en grande con FittedBox (Cero desborde)
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: RichText(
                            text: TextSpan(
                              text: '$sourceBookTitle $chapter:$verse ',
                              style: TextStyle(
                                fontFamily: fontFamily,
                                fontWeight: FontWeight.bold,
                                fontSize: fontSize,
                                color: indicatorColor,
                                letterSpacing: -0.3,
                              ),
                              children: [
                                if (cleanFootnote.isNotEmpty)
                                  TextSpan(
                                    text: "[$cleanFootnote]",
                                    style: TextStyle(
                                      fontFamily: fontFamily,
                                      fontWeight: FontWeight.bold,
                                      fontSize: (fontSize - 4).clamp(12.0, 26.0),
                                      color: isDark ? const Color(0xffe5c064) : const Color(0xffe36414),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),

                        // --- CASO 1: NOTA CON PASAJES BÍBLICOS (CARRUSEL SWIPEABLE) ---
                        if (parsedList.isNotEmpty) ...[
                          const SizedBox(height: 12),

                          // Pestañas / Píldoras horizontales de selección rápida
                          if (parsedList.length > 1)
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              child: Row(
                                children: parsedList.asMap().entries.map((entry) {
                                  final idx = entry.key;
                                  final item = entry.value;
                                  final isSelected = activeIndex == idx;
                                  return _BouncyChip(
                                    label: item.label,
                                    isSelected: isSelected,
                                    activeGradient: activeGradient,
                                    neutralGradient: neutralGradient,
                                    borderColor: borderColor,
                                    indicatorColor: indicatorColor,
                                    onTap: () {
                                      setModalState(() => activeIndex = idx);
                                      pageController.animateToPage(
                                        idx,
                                        duration: const Duration(milliseconds: 260),
                                        curve: Curves.easeOutCubic,
                                      );
                                      loadIndex(idx);
                                    },
                                  );
                                }).toList(),
                              ),
                            ),

                          const SizedBox(height: 14),

                          // PageView Deslizable (Carrusel 100% fluido con el dedo)
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.38,
                            child: PageView.builder(
                              controller: pageController,
                              physics: const BouncingScrollPhysics(),
                              itemCount: parsedList.length,
                              onPageChanged: (idx) {
                                setModalState(() => activeIndex = idx);
                                loadIndex(idx);
                                HapticFeedback.selectionClick();
                              },
                              itemBuilder: (ctx, idx) {
                                final currentVerses = cachedVerses[idx] ?? [];
                                if (currentVerses.isEmpty) {
                                  return const Center(
                                    child: SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(strokeWidth: 2.5),
                                    ),
                                  );
                                }
                                return SingleChildScrollView(
                                  primary: false,
                                  physics: const BouncingScrollPhysics(),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: currentVerses,
                                  ),
                                );
                              },
                            ),
                          ),
                        ]
                        // --- CASO 2: NOTA LINGÜÍSTICA / EXPLICATIVA (TEXTO DIRECTO) ---
                        else ...[
                          const SizedBox(height: 14),
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight: MediaQuery.of(context).size.height * 0.35,
                            ),
                            child: SingleChildScrollView(
                              primary: false,
                              physics: const BouncingScrollPhysics(),
                              child: RichText(
                                textAlign: TextAlign.left,
                                text: HTML.toTextSpan(
                                  context,
                                  textoNotaParaMostrar,
                                  defaultTextStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                        fontFamily: fontFamily,
                                        fontWeight: FontWeight.normal,
                                        height: 1.45,
                                        fontSize: fontSize - 1,
                                        fontStyle: FontStyle.normal,
                                        letterSpacing: fontLetterSeparation,
                                        color: indicatorColor.withValues(alpha: 0.90),
                                      ),
                                  overrideStyle: {
                                    'em': Theme.of(context).textTheme.bodyLarge!.copyWith(
                                          fontFamily: fontFamily,
                                          fontWeight: FontWeight.bold,
                                          fontStyle: FontStyle.italic,
                                          fontSize: fontSize - 1,
                                          color: indicatorColor,
                                        ),
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );

                return GlassContainer(
                  enableAcrylic: readPrefs.enableAcrylicEffect,
                  blur: isDark
                      ? ControlCenterVisualConfig.darkBlurSigma
                      : ControlCenterVisualConfig.lightBlurSigma,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
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
                                canvasColor.withValues(alpha: ControlCenterVisualConfig.darkPanelTopAlpha),
                                canvasColor.withValues(alpha: ControlCenterVisualConfig.darkPanelBottomAlpha),
                              ],
                            )
                          : LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white.withValues(alpha: ControlCenterVisualConfig.lightPanelTopAlpha),
                                Colors.white.withValues(alpha: ControlCenterVisualConfig.lightPanelBottomAlpha),
                              ],
                            ))
                      : null,
                  color: readPrefs.enableAcrylicEffect ? null : canvasColor,
                  child: sheetContent,
                );
              },
            );
          }
        );
      },
    ).then((_) {
      setBottomSheetState(false);
    });
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

/// Botón Compacto con Icono y Rebote Háptico para Encabezados
class _ReferenceMiniActionBtn extends StatefulWidget {
  final VoidCallback onTap;
  final Widget? icon;
  final String? label;
  final Gradient? gradient;
  final Color borderColor;
  final Color? textColor;

  const _ReferenceMiniActionBtn({
    Key? key,
    required this.onTap,
    this.icon,
    this.label,
    this.gradient,
    required this.borderColor,
    this.textColor,
  }) : super(key: key);

  @override
  State<_ReferenceMiniActionBtn> createState() => _ReferenceMiniActionBtnState();
}

class _ReferenceMiniActionBtnState extends State<_ReferenceMiniActionBtn> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        HapticFeedback.lightImpact();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutBack,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: widget.gradient,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.borderColor,
              width: 1.0,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) widget.icon!,
              if (widget.icon != null && widget.label != null) const SizedBox(width: 5),
              if (widget.label != null)
                Text(
                  widget.label!,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: widget.textColor ?? Colors.white,
                    letterSpacing: -0.2,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Chip / Píldora Interactiva con Rebote Háptico para citas bíblicas
class _BouncyChip extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Gradient? activeGradient;
  final Gradient? neutralGradient;
  final Color borderColor;
  final Color indicatorColor;

  const _BouncyChip({
    Key? key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.activeGradient,
    this.neutralGradient,
    required this.borderColor,
    required this.indicatorColor,
  }) : super(key: key);

  @override
  State<_BouncyChip> createState() => _BouncyChipState();
}

class _BouncyChipState extends State<_BouncyChip> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canvasColor = Theme.of(context).canvasColor;

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        HapticFeedback.lightImpact();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutBack,
        child: Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            gradient: widget.isSelected ? widget.activeGradient : widget.neutralGradient,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.isSelected ? Colors.transparent : widget.borderColor,
              width: 1.0,
            ),
            boxShadow: [
              if (widget.isSelected)
                BoxShadow(
                  color: isDark ? Colors.white.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.auto_stories_rounded,
                size: 13,
                color: widget.isSelected
                    ? (isDark ? canvasColor : Colors.white)
                    : widget.indicatorColor.withValues(alpha: 0.75),
              ),
              const SizedBox(width: 5),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: widget.isSelected
                      ? (isDark ? canvasColor : Colors.white)
                      : widget.indicatorColor,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}