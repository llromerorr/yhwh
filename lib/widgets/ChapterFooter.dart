import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yhwh/controllers/ReadPreferencesController.dart';
import 'package:yhwh/data/Define.dart';

class ChapterFooter extends StatefulWidget {
  ChapterFooter({
    Key? key,
    required this.bibleVersion
  }) : super(key: key);

  final String bibleVersion;

  @override
  _ChapterFooterState createState() => _ChapterFooterState();
}

class _ChapterFooterState extends State<ChapterFooter> {

  @override
  Widget build(BuildContext context) {

    return GetBuilder<ReadPreferencesController>(
      init: ReadPreferencesController(),
      builder: (readPrefs) {
        final scale = readPrefs.fontScaleFactor;
        final infoFontSize = (15.0 * scale).clamp(13.0, 22.0);
        final copyrightFontSize = (14.0 * scale).clamp(12.0, 20.0);

        return SliverToBoxAdapter(
          child: Column(
            children: <Widget>[
              const Divider(height: 25, color: Color(0x00)),
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: RichText(
                    text: TextSpan(
                      text: 'Antiguo y Nuevo Testamento\nAntigua Versión de Casiodoro de Reina (1569)\nRevisada por Cipriano de Valera (1602)\nOtra revisiones: 1862, 1909 y 1960',
                      style: TextStyle(
                          fontSize: infoFontSize,
                          fontFamily: 'Baloo',
                          color: Theme.of(context).indicatorColor.withValues(alpha: 0.7),
                          height: 1.3
                      )
                    ),
                    textAlign: TextAlign.center,
                  )
              ),

              TextButton(
                child: Text('${versionToName[widget.bibleVersion]} ©',
                  style: TextStyle(
                    fontSize: copyrightFontSize,
                    fontFamily: 'Baloo',
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).indicatorColor.withValues(alpha: 0.9),
                  )
                ),
                onPressed: null,
              ),

              Container(
                height: MediaQuery.of(context).size.height / 5
              )
            ],
          ),
        );
      },
    );
  }
}