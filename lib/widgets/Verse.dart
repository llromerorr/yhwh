import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_typedefs/rx_typedefs.dart';
import 'package:simple_html_css/simple_html_css.dart';
import 'package:yhwh/data/Define.dart';

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

  final Callback? onTap;
  final Callback? onLongPress;
  final Function? onReferenceTap;

  final bool isFirstVerseShowed;

  const Verse({
    Key? key,
    required this.verseNumber,
    required this.text,
    required this.title,
    required this.highlight,
    required this.fontFamily,
    required this.isFirstVerseShowed,
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
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 1. Preparamos el TextSpan
    final textSpan = HTML.toTextSpan(
      context,
      '<vn>$verseNumber&nbsp;</vn><ctn>${this.text.toString()}</ctn>'
          .replaceAll('<p style="text-align:center;">', '')
          .replaceAll('</p>', '')
          .replaceAll('<p style="text-align:right;">', '')
          .replaceAll('<br />', '')
          .replaceAll('*', ''),
      defaultTextStyle: TextStyle(
        fontSize: this.fontSize,
        color: this.colorText,
        fontFamily: this.fontFamily,
        height: this.fontHeight,
        letterSpacing: this.fontLetterSeparation,
      ),
      overrideStyle: {
        'red': TextStyle(
          color: (this.highlight)
              ? Theme.of(context).brightness == Brightness.light
                  ? Color(0xffe75649)
                  : Color(0xffe06c75)
              : Theme.of(context).brightness == Brightness.light
                  ? Color(0xffe75649)
                  : Color(0xffe06c75),
        ),
        'vn': TextStyle(
          fontWeight: (this.selected || this.highlight) ? FontWeight.bold : FontWeight.normal,
          color: this.colorNumber,
          // color:  (this.highlight || this.selected)
          //   ? Theme.of(context).brightness == Brightness.light
          //     ? this.colorNumber
          //     : Theme.of(context).canvasColor
          //   : this.colorNumber,
          fontSize: this.fontSize - 7.0,
        ),
        'ctn': TextStyle(
          fontWeight: FontWeight.normal,
          backgroundColor: Colors.transparent, // Transparente para usar CustomPainter
          color: this.colorText,
          // color: (this.highlight)
          //     ? Theme.of(context).brightness == Brightness.light
          //         ? this.colorText
          //         : Theme.of(context).canvasColor
          //     : this.colorText,
        ),
        'i': TextStyle(
          fontWeight: FontWeight.normal,
          fontStyle: FontStyle.italic,
          fontSize: this.fontSize,
          backgroundColor: Colors.transparent,
          color: Theme.of(context).textTheme.bodyLarge!.color
          // color: (this.highlight)
          //     ? Theme.of(context).brightness == Brightness.light
          //         ? Theme.of(context).textTheme.bodyLarge!.color
          //         : Theme.of(context).canvasColor
          //     : Theme.of(context).brightness == Brightness.light
          //         ? Color(0xffae7123)
          //         : Color(0xffe5c064),
        ),
        
        'f': TextStyle(
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.normal,
          fontSize: this.fontSize - 7.0,
          backgroundColor: Colors.transparent,
          color: (this.highlight)
              ? Theme.of(context).brightness == Brightness.light
                  ? Color(0xffe36414)
                  : Color(0xffe5c064)
              : Theme.of(context).brightness == Brightness.light
                  ? Color(0xffe36414)
                  : Color(0xffe5c064),
        )
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
                      // --- CORRECCIÓN AQUÍ: Eliminado LayoutBuilder ---
                      child: this.highlight
                          ? CustomPaint(
                              painter: _ModernHighlightPainter(
                                textSpan: textSpan,
                                highlightColor: Theme.of(context).brightness == Brightness.light
                                  ? this.colorHighlight.withAlpha(80)
                                  : this.colorHighlight.withAlpha(70),
                                // highlightColor: this.colorHighlight.withAlpha(50),

                                radius: 8.0,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 4.0, vertical: 0.0),
                              ),
                              child: RichText(
                                softWrap: true,
                                overflow: TextOverflow.visible,
                                textAlign: TextAlign.start,
                                text: textSpan,
                              ),
                            )
                          : RichText(
                              softWrap: true,
                              overflow: TextOverflow.visible,
                              textAlign: TextAlign.start,
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
    List<String> split = text!.split('\n');
    List<Widget> widgets = [];

    split.forEach((element) {
      if (element.split(' ')[0] == '#title_big') {
        widgets.add(
          Container(
            width: double.infinity,
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: element.replaceAll('#title_big ', ''),
                style: Theme.of(context!).textTheme.bodyLarge!.copyWith(
                    fontFamily: this.fontFamily,
                    fontWeight: FontWeight.bold,
                    height: height,
                    fontSize: fontSize! + 10,
                    letterSpacing: letterSeparation,
                    color: this.colorText),
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
              text: TextSpan(
                text: element.replaceAll('#subtitle ', ''),
                style: Theme.of(context!).textTheme.bodyLarge!.copyWith(
                    fontFamily: this.fontFamily,
                    fontStyle: FontStyle.italic,
                    height: height,
                    fontSize: fontSize,
                    letterSpacing: letterSeparation,
                    color: this.colorText),
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
                context!,
                element.replaceAll('#reference ', ''),
                defaultTextStyle:
                    Theme.of(context).textTheme.bodyLarge!.copyWith(
                          fontFamily: this.fontFamily,
                          fontWeight: FontWeight.normal,
                          height: height,
                          fontSize: fontSize! - 3,
                          fontStyle: FontStyle.italic,
                          letterSpacing: letterSeparation,
                          color: this.colorText,
                        ),
                overrideStyle: {
                  'a': Theme.of(context).textTheme.bodyLarge!.copyWith(
                      fontFamily: this.fontFamily,
                      fontWeight: FontWeight.bold,
                      height: height,
                      fontSize: fontSize - 3,
                      fontStyle: FontStyle.italic,
                      letterSpacing: letterSeparation,
                      color: this.colorText),
                },
                linksCallback: (link) {
                  List<String> split = link.toString().split(':');
                  int book = int.parse(split[0]);
                  int chapter = (split.length >= 2) ? int.parse(split[1]) : 0;
                  int verse_from = (split.length >= 3)
                      ? int.parse(split[2].split('-')[0])
                      : 0;
                  int verse_to = (split.length >= 3)
                      ? int.parse(split[2].split('-')[1])
                      : 0;
                  this.onReferenceTap!(book, chapter, verse_from, verse_to);
                },
              ),
            ),
          ),
        );
      } else if (element.split(' ')[0] == '#center') {
        widgets.add(Container(
            width: double.infinity,
            child: RichText(
              textAlign: TextAlign.left,
              text: TextSpan(
                text: element.replaceAll('#center ', ''),
                style: Theme.of(context!).textTheme.bodyLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                    height: height,
                    fontSize: fontSize,
                    letterSpacing: letterSeparation,
                    color: this.colorText),
              ),
            )));
      } else {
        widgets.add(
          Container(
            width: double.infinity,
            child: RichText(
              textAlign: TextAlign.left,
              text: TextSpan(
                text: element,
                style: Theme.of(context!).textTheme.bodyLarge!.copyWith(
                    fontFamily: this.fontFamily,
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                    height: height,
                    fontSize: fontSize,
                    letterSpacing: letterSeparation,
                    color: this.colorText),
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
  final Color highlightColor; // Pásale aquí el color con .withOpacity(0.5)
  final double radius;
  final EdgeInsets padding;

  _ModernHighlightPainter({
    required this.textSpan,
    required this.highlightColor,
    this.radius = 8.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.start,
    )..layout(minWidth: 0, maxWidth: size.width);

    // Configura el Paint. 
    // IMPORTANTE: El color ya debe venir con la transparencia deseada 
    // o se la aplicas aquí: highlightColor.withOpacity(0.3)
    final paint = Paint()
      ..color = highlightColor
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final lines = textPainter.computeLineMetrics();
    if (lines.isEmpty) return;

    final List<Rect> rects = [];
    final double left = -padding.left;

    // 1) Calculamos los rectángulos (igual que antes)
    for (final line in lines) {
      if (line.width <= 0) {
        rects.add(Rect.zero);
        continue;
      }

      final double targetWidth = line.width + padding.horizontal;
      final double maxWidthAllowed = size.width - left;
      final double width = targetWidth.clamp(0.0, maxWidthAllowed);

      // TRUCO PRO: Agregamos un pequeñísimo overlap (0.5) vertical 
      // para asegurar que el Path se fusione y no queden líneas finas blancas 
      // por el anti-aliasing entre renglones.
      final double trueTextHeight = line.ascent + line.descent;
      final double top = line.baseline - line.ascent - padding.top;
      final double height = trueTextHeight + padding.vertical + 0.5; 

      rects.add(Rect.fromLTWH(left, top, width, height));
    }

    // 2) Creamos un ÚNICO Path
    final Path fullPath = Path();

    for (int i = 0; i < lines.length; i++) {
      final Rect rect = rects[i];
      if (rect == Rect.zero) continue;

      final bool isFirst = i == 0;
      final bool isLast  = i == lines.length - 1;

      final double right = rect.right;
      final double prevRight = i > 0 ? rects[i - 1].right : right;
      final double nextRight = i < lines.length - 1 ? rects[i + 1].right : right;

      final Radius topLeft     = isFirst ? Radius.circular(radius) : Radius.zero;
      final Radius bottomLeft  = isLast  ? Radius.circular(radius) : Radius.zero;
      
      Radius topRight = Radius.zero;
      Radius bottomRight = Radius.zero;

      if (isFirst || right >= prevRight) {
        topRight = Radius.circular(radius);
      }
      if (isLast || right >= nextRight) {
        bottomRight = Radius.circular(radius);
      }

      // EN LUGAR DE DIBUJAR, AGREGAMOS AL PATH
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

    // 3) Dibujamos el Path completo UNA SOLA VEZ
    // Esto hace que la opacidad sea uniforme en toda la figura
    canvas.drawPath(fullPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}