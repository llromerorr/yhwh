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

  // sirver para gestionar el padding del titulo
  // cuando es el primer vesiculo mostrado en pantalla
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
    this.fontHeight  = 1.8,
    this.fontLetterSeparation = 0,

    this.colorText = const Color(0xff263238),
    this.colorNumber = const Color(0xaf37474F),
    this.colorHighlight = Colors.pink,
    this.selected = false,

    this.onTap,
    this.onLongPress,
    this.onReferenceTap
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    
    return IntrinsicHeight(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        
        children: [
          this.title == "" ? SizedBox() : textToTitle(
            context: context,
            fontSize: this.fontSize,
            height: this.fontHeight,
            letterSeparation: this.fontLetterSeparation,
            text: this.title
          ),

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
                      padding: EdgeInsets.fromLTRB(12, 0, 12, 0),
                      
                      child: RichText(
                        softWrap: true,
                        overflow: TextOverflow.visible,
                        textAlign: TextAlign.start,

                        text: HTML.toTextSpan(
                          context,
                          '<vn>$verseNumber&nbsp;</vn><ctn>${this.text.toString()}</ctn>'.replaceAll('<p style="text-align:center;">', '').replaceAll('</p>', '').replaceAll('<p style="text-align:right;">', '').replaceAll('<br />', '').replaceAll('*', ''),//.replaceAll('Jehová', 'Yahweh'),
                          defaultTextStyle: TextStyle(
                            fontSize: this.fontSize,
                            color: this.colorText,
                            fontFamily: this.fontFamily,
                            height: this.fontHeight,
                            letterSpacing: this.fontLetterSeparation,
                          ),

                          overrideStyle: {

                            'red' : TextStyle(
                              color: (this.highlight)
                                ? Theme.of(context).brightness == Brightness.light
                                  ? Theme.of(context).textTheme.bodyLarge!.color
                                  : Theme.of(context).canvasColor
                                : Theme.of(context).brightness == Brightness.light ? Color(0xffe75649) : Color(0xffe06c75)
                            ),

                            'vn' : TextStyle(
                              fontWeight: (this.selected) ? FontWeight.bold : FontWeight.normal,
                              color: this.colorNumber,
                              fontSize: this.fontSize - 7.0,
                            ),

                            'ctn' : TextStyle(
                              fontWeight: FontWeight.normal,
                              backgroundColor: (this.highlight)
                                ? colorHighlight
                                : Colors.transparent,
                              color: (this.highlight)
                                ? Theme.of(context).brightness == Brightness.light
                                  ? this.colorText
                                  : Theme.of(context).canvasColor
                                : this.colorText
                            ),

                            'i' : TextStyle(
                              fontWeight: FontWeight.normal,
                              fontStyle: FontStyle.italic,
                              fontSize: this.fontSize,
                              backgroundColor: (this.highlight)
                                ? colorHighlight
                                : Colors.transparent,
                              color: (this.highlight)
                                ? Theme.of(context).brightness == Brightness.light
                                  ? Theme.of(context).textTheme.bodyLarge!.color
                                  : Theme.of(context).canvasColor
                                : Theme.of(context).brightness == Brightness.light ? Color(0xffae7123) : Color(0xffe5c064)
                            ),

                            'f' : TextStyle(
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.normal,
                              fontSize: this.fontSize - 7.0,
                              backgroundColor: (this.highlight)
                                ? colorHighlight
                                : Colors.transparent,
                              color: (this.highlight)
                                ? Theme.of(context).brightness == Brightness.light
                                  ? Theme.of(context).textTheme.bodyLarge!.color
                                  : Theme.of(context).canvasColor
                                : Theme.of(context).brightness == Brightness.light ? Color(0xffae7123) : Color(0xffe5c064)
                            )
                          }
                        )
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

  Widget textToTitle({BuildContext? context, String? text, double? height, double? fontSize, double? letterSeparation}){
    List<String> split = text!.split('\n');
    List<Widget> widgets = [];


    split.forEach((element)
    {
      if(element.split(' ')[0] == '#title_big') 
      {
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
                  color: this.colorText
                ),
              ),
            ),
          ),
        );
      }

      else if(element.split(' ')[0] == '#subtitle')
      {
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
                  color: this.colorText
                ),
              ),
            ),
          ),
        );

        // widgets.add(
        //   Container(height: height * 10)
        // );
      }

      else if(element.split(' ')[0] == '#reference')
      {
        List<String> references = [];
        String temp = element;

        // encontrar referencias y guardar en una lista
        while(temp.contains('<x>')){
          int start = temp.indexOf('<x>');
          int end = temp.indexOf('</x>');

          references.add(temp.substring(start + 3, end));
          temp = temp.substring(end + 1);
        }

        // remplazar numero por nombre del libro
        for(var ref in references){
          List<String> split = ref.split(':');
          element = element.replaceFirst('<x>$ref', '<x>${intToAbreviatura[int.parse(split[0])]} ${ref.substring(ref.indexOf(':') + 1)}');
        }

        // remplazar etiquetas <x> por <a> que son links html
        for(var ref in references){
          element = element.replaceFirst('<x>', '<a href="$ref">');
          element = element.replaceFirst('</x>', '</a>');
        }


        // agregar el widget
        widgets.add(
          Container(
            width: double.infinity,
            child: RichText(
              textAlign: TextAlign.left,
              text: HTML.toTextSpan(
                context!,
                element.replaceAll('#reference ', ''),
                defaultTextStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  fontFamily: this.fontFamily,
                  fontWeight: FontWeight.normal,
                  height: height,
                  fontSize: fontSize! - 3,
                  fontStyle: FontStyle.italic,
                  letterSpacing: letterSeparation,
                  color: this.colorText
                ),

                overrideStyle: {
                  'a' : Theme.of(context).textTheme.bodyLarge!.copyWith(
                    fontFamily: this.fontFamily,
                    fontWeight: FontWeight.bold,
                    height: height,
                    fontSize: fontSize - 3,
                    fontStyle: FontStyle.italic,
                    letterSpacing: letterSeparation,
                    color: this.colorText
                  ),
                },

                // CUANDO SE HACE CLICK EN LA REFERENCIA DE LOS SUBTITULOS
                linksCallback: (link) {

                  List<String> split = link.toString().split(':');
                  int book = int.parse(split[0]);
                  int chapter = (split.length >= 2) ? int.parse(split[1]) : 0;
                  int verse_from = (split.length >= 3) ? int.parse(split[2].split('-')[0]) : 0;
                  int verse_to = (split.length >= 3) ? int.parse(split[2].split('-')[1]) : 0;

                  // BiblePageController _biblePageController = Get.find();
                  // _biblePageController.onReferenceTap(book: book, chapter: chapter, verse_from: verse_from, verse_to: verse_to);

                  this.onReferenceTap!(book, chapter, verse_from, verse_to);

                  // Get.dialog(FloatingBible(), barrierColor: Colors.transparent);
                },
              ),
            ),
          ),
        );

        // widgets.add(
        //   Container(height: height * 10)
        // );
      }

      else if(element.split(' ')[0] == '#center')
      {
        widgets.add(
          Container(
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
                  color: this.colorText
                ),
              ),
            ),
          )
        );
      }

      else{
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
                  color: this.colorText
                ),
              ),
            ),
          ),
        );
      }
    });

    return Padding(
      padding: EdgeInsets.fromLTRB(0, (this.isFirstVerseShowed == false) ? this.fontHeight + 30 : this.fontHeight + 8, 0, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: widgets
        ),
      ),
    );
  }
}