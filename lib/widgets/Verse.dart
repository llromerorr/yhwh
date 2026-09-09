import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_typedefs/rx_typedefs.dart';
import 'package:simple_html_css/simple_html_css.dart';
import 'package:yhwh/data/Define.dart';
import 'package:yhwh/classes/ColorPalette.dart';

class Verse extends StatelessWidget {
  final int verseNumber;

  final String title;
  final String text;

  final String fontFamily;
  final double fontSize;
  final double fontHeight;
  final double fontLetterSeparation;

  final Color colorText;
  final Color colorNumber;
  final Color colorHighlight;

  final bool highlight;
  final bool selected;
  final bool isJustified;

  final Callback? onTap;
  final Callback? onLongPress;
  final Function? onReferenceTap;
  final Function? onFootnoteTap;

  final bool isFirstVerseShowed;

  const Verse({
    Key? key,
    required this.verseNumber,
    required this.text,
    required this.title,
    required this.highlight,
    required this.fontFamily,
    required this.isFirstVerseShowed,
    this.isJustified = false,
    this.fontSize = 20.0,
    this.fontHeight = 1.8,
    this.fontLetterSeparation = 0,
    this.colorText = const Color(0xff263238),
    this.colorNumber = const Color(0xaf37474F),
    this.colorHighlight = Colors.pink,
    this.selected = false,
    this.onTap,
    this.onLongPress,
    this.onReferenceTap,
    this.onFootnoteTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<ColorPalette>();
    final resolvedColorText = this.colorText == Colors.transparent ? Colors.transparent : (palette?.verseText ?? this.colorText);
    final resolvedColorNumber = this.colorNumber == Colors.transparent ? Colors.transparent : (palette?.verseNumber ?? this.colorNumber);
    final resolvedColorHighlight = !this.highlight ? Colors.transparent : ColorPalette.getDynamicHighlightColor(context, this.colorHighlight.value);

    // 1. Preparamos el TextSpan
    final textSpan = HTML.toTextSpan(
      context,
      '<vn>$verseNumber&nbsp;</vn><ctn>${this.text.toString()}</ctn>'
          .replaceAll('<p style="text-align:center;">', '')
          .replaceAll('</p>', '')
          .replaceAll('<p style="text-align:right;">', '')
          .replaceAll('<br />', '')
          .replaceAll('*', '')
          .replaceAllMapped(RegExp(r'<f>(.*?)</f>'), (match) {
        final contenido =
            match.group(1); // El texto dentro de la etiqueta (ej: 1, a, nota)
        // Creamos una etiqueta 'a' donde el href es IGUAL al contenido
        return '<a href="$contenido">$contenido</a>';
      }),
      defaultTextStyle: TextStyle(
        fontSize: this.fontSize, 
        color: resolvedColorText,
        fontFamily: this.fontFamily,
        height: this.fontHeight,
        letterSpacing: this.fontLetterSeparation,
      ),
      overrideStyle: {
        'red': TextStyle(
          color: this.highlight
              ? (palette?.wordsOfJesusHighlighted ?? const Color.fromARGB(223, 156, 28, 32))
              : (palette?.wordsOfJesus ?? const Color.fromARGB(252, 136, 19, 23)),
        ),
        'vn': TextStyle(
          fontWeight: (this.selected || this.highlight)
              ? FontWeight.bold
              : FontWeight.normal,
          color: resolvedColorNumber,
          fontSize: (this.fontSize * 0.72).clamp(11.0, 24.0),
        ),
        'ctn': TextStyle(
          fontWeight: FontWeight.normal,
          backgroundColor: Colors.transparent,
          color: resolvedColorText,
        ),
        'i': TextStyle(
            fontWeight: FontWeight.normal,
            fontStyle: FontStyle.italic,
            fontSize: this.fontSize,
            backgroundColor: Colors.transparent,
            color: Theme.of(context).textTheme.bodyLarge!.color
            ),
        'a': TextStyle(
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.normal,
          fontSize: (this.fontSize * 0.68).clamp(11.0, 22.0),
          backgroundColor: Colors.transparent,
          decoration: TextDecoration.none,
          color: this.highlight
              ? (palette?.referenceTextHighlighted ?? const Color.fromARGB(202, 251, 84, 7))
              : (palette?.referenceText ?? const Color.fromARGB(209, 251, 84, 7)),
        ),
      },
      linksCallback: (link) {
        this.onFootnoteTap!('$link');
      },
    );

    return IntrinsicHeight(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          this.title == ""
              ? SizedBox()
              : textToTitle(
                  context: context,
                  fontSize: this.fontSize,
                  height: this.fontHeight,
                  letterSeparation: this.fontLetterSeparation,
                  text: this.title),
          IntrinsicHeight(
            child: Row(
              children: [
                AnimatedContainer(
                  color: Theme.of(context).indicatorColor,
                  height: double.infinity,
                  width: this.selected ? 5 : 0,
                  duration: Duration(milliseconds: 150),
                ),
                Flexible(
                  child: GestureDetector(
                    onTap: this.onTap,
                    onLongPress: this.onLongPress,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(12, 0, 12, 0.7),
                      child: this.highlight
                          ? CustomPaint(
                              painter: _ModernHighlightPainter(
                                textSpan: textSpan,
                                highlightColor: resolvedColorHighlight,
                                isJustified: this.isJustified,
                                radius: 7.0,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5.0, vertical: 0.5),
                              ),
                              child: RichText(
                                softWrap: true,
                                overflow: TextOverflow.visible,
                                textAlign: this.isJustified ? TextAlign.justify : TextAlign.start,
                                text: textSpan,
                              ),
                            )
                          : RichText(
                              softWrap: true,
                              overflow: TextOverflow.visible,
                              textAlign: this.isJustified ? TextAlign.justify : TextAlign.start,
                              text: textSpan,
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget textToTitle(
      {BuildContext? context,
      String? text,
      double? height,
      double? fontSize,
      double? letterSeparation}) {
      
    final palette = Theme.of(context!).extension<ColorPalette>();
    final resolvedColorText = palette?.verseText ?? this.colorText;

    // 1. Reemplazamos la etiqueta <f> en todo el texto del título.
    // Usamos el prefijo 'footnote_' para diferenciarlo de los enlaces de las referencias.
    String processedText = text!.replaceAllMapped(
      RegExp(r'<f>(.*?)</f>'),
      (match) {
        final contenido = match.group(1);
        return '<a href="footnote_$contenido">$contenido</a>';
      }
    );

    List<String> split = processedText.split('\n');
    List<Widget> widgets = [];

    // 2. Definimos el estilo del enlace <a> para reutilizarlo en todo el título
    final aStyle = Theme.of(context).textTheme.bodyLarge!.copyWith(
      fontFamily: this.fontFamily,
      fontWeight: FontWeight.bold,
      height: height,
      fontSize: (fontSize! * 0.68).clamp(11.0, 22.0),
      fontStyle: FontStyle.italic,
      decoration: TextDecoration.none,
      letterSpacing: letterSeparation,
      color: this.highlight
          ? (palette?.referenceTextHighlighted ?? const Color(0xffe36414))
          : (palette?.referenceText ?? const Color(0xffe36414)),
    );

    // 3. Centralizamos el callback de los links para manejar Notas al Pie vs Referencias
    void handleLinks(dynamic link) {
      if (link == null) return;
      String linkStr = link.toString();
      
      if (linkStr.startsWith('footnote_')) {
        // Es una nota al pie (<f>)
        this.onFootnoteTap!(linkStr.replaceAll('footnote_', ''));
      } else {
        // Es una referencia bíblica (<x>)
        List<String> splitRef = linkStr.split(':');
        if (splitRef.isNotEmpty) {
          int book = int.parse(splitRef[0]);
          int chapter = (splitRef.length >= 2) ? int.parse(splitRef[1]) : 0;
          int verse_from = (splitRef.length >= 3) ? int.parse(splitRef[2].split('-')[0]) : 0;
          int verse_to = (splitRef.length >= 3) && splitRef[2].contains('-') 
              ? int.parse(splitRef[2].split('-')[1]) 
              : 0;
          this.onReferenceTap!(book, chapter, verse_from, verse_to);
        }
      }
    }

    split.forEach((element) {
      if (element.split(' ')[0] == '#title_big') {
        widgets.add(
          Container(
            width: double.infinity,
            child: RichText(
              textAlign: TextAlign.center,
              // Cambiamos TextSpan por HTML.toTextSpan
              text: HTML.toTextSpan(
                context,
                element.replaceAll('#title_big ', ''),
                defaultTextStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    fontFamily: this.fontFamily,
                    fontWeight: FontWeight.bold,
                    height: height,
                    fontSize: (fontSize * 1.35).clamp(22.0, 42.0),
                    letterSpacing: letterSeparation,
                    color: resolvedColorText),
                overrideStyle: {'a': aStyle},
                linksCallback: handleLinks,
              ),
            ),
          ),
        );
      } else if (element.split(' ')[0] == '#subtitle') {
        widgets.add(
          Container(
            width: double.infinity,
            child: RichText(
              textAlign: TextAlign.left,
              text: HTML.toTextSpan(
                context,
                element.replaceAll('#subtitle ', ''),
                defaultTextStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    fontFamily: this.fontFamily,
                    fontStyle: FontStyle.italic,
                    height: height,
                    fontSize: fontSize,
                    letterSpacing: letterSeparation,
                    color: resolvedColorText),
                overrideStyle: {'a': aStyle},
                linksCallback: handleLinks,
              ),
            ),
          ),
        );
      } else if (element.split(' ')[0] == '#reference') {
        List<String> references = [];
        String temp = element;

        while (temp.contains('<x>')) {
          int start = temp.indexOf('<x>');
          int end = temp.indexOf('</x>');

          references.add(temp.substring(start + 3, end));
          temp = temp.substring(end + 1);
        }

        for (var ref in references) {
          List<String> split = ref.split(':');
          element = element.replaceFirst(
              '<x>$ref',
              '<x>${intToAbreviatura[int.parse(split[0])]} ${ref.substring(ref.indexOf(':') + 1)}');
        }

        for (var ref in references) {
          element = element.replaceFirst('<x>', '<a href="$ref">');
          element = element.replaceFirst('</x>', '</a>');
        }

        widgets.add(
          Container(
            width: double.infinity,
            child: RichText(
              textAlign: TextAlign.left,
              text: HTML.toTextSpan(
                context,
                element.replaceAll('#reference ', ''),
                defaultTextStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      fontFamily: this.fontFamily,
                      fontWeight: FontWeight.bold,
                      height: height,
                      fontSize: fontSize - 3,
                      fontStyle: FontStyle.italic,
                      letterSpacing: letterSeparation,
                      color: this.highlight
                        ? (palette?.referenceTextHighlighted ?? const Color(0xffe36414))
                        : (palette?.referenceText ?? const Color(0xffe36414)),
                    ),
                overrideStyle: {'a': aStyle},
                linksCallback: handleLinks,
              ),
            ),
          ),
        );
      } else if (element.split(' ')[0] == '#center') {
        widgets.add(Container(
            width: double.infinity,
            child: RichText(
              textAlign: TextAlign.left,
              text: HTML.toTextSpan(
                context,
                element.replaceAll('#center ', ''),
                defaultTextStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                    height: height,
                    fontSize: fontSize,
                    letterSpacing: letterSeparation,
                    color: resolvedColorText),
                overrideStyle: {'a': aStyle},
                linksCallback: handleLinks,
              ),
            )));
      } else {
        widgets.add(
          Container(
            width: double.infinity,
            child: RichText(
              textAlign: TextAlign.left,
              text: HTML.toTextSpan(
                context,
                element,
                defaultTextStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    fontFamily: this.fontFamily,
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                    height: height,
                    fontSize: fontSize,
                    letterSpacing: letterSeparation,
                    color: resolvedColorText),
                overrideStyle: {'a': aStyle},
                linksCallback: handleLinks,
              ),
            ),
          ),
        );
      }
    });

    return Padding(
      padding: EdgeInsets.fromLTRB(
          0,
          (this.isFirstVerseShowed == false)
              ? this.fontHeight + 30
              : this.fontHeight + 8,
          0,
          0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: widgets),
      ),
    );
  }
}

class _ModernHighlightPainter extends CustomPainter {
  final TextSpan textSpan;
  final Color highlightColor;
  final bool isJustified;
  final double radius;
  final EdgeInsets padding;

  _ModernHighlightPainter({
    required this.textSpan,
    required this.highlightColor,
    this.isJustified = false,
    this.radius = 7.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 5.0, vertical: 0.5),
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (highlightColor == Colors.transparent || highlightColor.a == 0.0) return;

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: isJustified ? TextAlign.justify : TextAlign.start,
    )..layout(minWidth: isJustified ? size.width : 0.0, maxWidth: size.width);

    final lines = textPainter.computeLineMetrics();
    if (lines.isEmpty) return;

    final paint = Paint()
      ..color = highlightColor
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final List<Rect> rects = [];
    final double left = -padding.left;
    final double maxHighlightWidth = size.width + padding.horizontal;

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (line.width <= 0) {
        rects.add(Rect.zero);
        continue;
      }

      // En modo justificado, toda línea intermedia se extiende exactamente de margen a margen.
      // La última línea del versículo concluye naturalmente donde termina el texto.
      final bool isFirst = i == 0;
      final bool isLastLine = i == lines.length - 1;
      final double targetWidth = (isJustified && !isLastLine)
          ? maxHighlightWidth
          : (line.width + padding.horizontal);

      final double width = targetWidth.clamp(0.0, maxHighlightWidth);

      // Límites verticales estrictamente acotados al espacio del versículo:
      // En la primera línea, el tope no debe invadir el versículo superior (top >= 0.0)
      final double lineTop = line.baseline - line.ascent;
      final double top = isFirst ? (lineTop < 0.0 ? 0.0 : lineTop) : (lineTop - 0.5);

      // En la última línea, el fondo no debe invadir el versículo inferior (bottom <= size.height)
      final double lineBottom = line.baseline + line.descent;
      final double bottom = isLastLine ? (lineBottom > size.height ? size.height : lineBottom) : (lineBottom + 0.5);

      final double height = (bottom - top).clamp(0.0, size.height);

      rects.add(Rect.fromLTWH(left, top, width, height));
    }

    // Construcción del Path continuo sin muescas dentadas en bordes compartidos
    final Path fullPath = Path();

    for (int i = 0; i < rects.length; i++) {
      final Rect rect = rects[i];
      if (rect == Rect.zero) continue;

      final bool isFirst = i == 0;
      final bool isLast = i == rects.length - 1;

      final double right = rect.right;
      final double prevRight = i > 0 ? rects[i - 1].right : right;
      final double nextRight = i < rects.length - 1 ? rects[i + 1].right : right;

      // Esquinas izquierdas: rectas en uniones interiores, redondeadas en extremos superior e inferior
      final Radius topLeft = isFirst ? Radius.circular(radius) : Radius.zero;
      final Radius bottomLeft = isLast ? Radius.circular(radius) : Radius.zero;

      // Esquinas derechas: se redondean en extremos o si sobresalen significativamente (> 2.0px)
      // Evita muescas ("scallops") entre líneas adyacentes de ancho idéntico en texto justificado
      final Radius topRight = (isFirst || right > prevRight + 2.0)
          ? Radius.circular(radius)
          : Radius.zero;

      final Radius bottomRight = (isLast || right > nextRight + 2.0)
          ? Radius.circular(radius)
          : Radius.zero;

      fullPath.addRRect(
        RRect.fromRectAndCorners(
          rect,
          topLeft: topLeft,
          topRight: topRight,
          bottomLeft: bottomLeft,
          bottomRight: bottomRight,
        ),
      );
    }

    // Dibujado unificado del Path completo en un solo pase homogéneo
    canvas.drawPath(fullPath, paint);
  }

  @override
  bool shouldRepaint(covariant _ModernHighlightPainter oldDelegate) {
    return oldDelegate.textSpan != textSpan ||
        oldDelegate.highlightColor != highlightColor ||
        oldDelegate.isJustified != isJustified ||
        oldDelegate.radius != radius ||
        oldDelegate.padding != padding;
  }
}
