import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:yhwh/classes/AppTheme.dart';
import 'package:yhwh/controllers/BiblePageController.dart';
import 'package:yhwh/controllers/ReadPreferencesController.dart';
import 'package:yhwh/data/Themes.dart';

class ReadPreferences extends StatelessWidget {
  const ReadPreferences({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height - 200
      ),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Theme.of(context).indicatorColor.withAlpha(120),
            width: 1.5
          ),
        )
      ),
      child: Container( //ClipRRect(
        child: Container( //BackdropFilter(
          //filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24, tileMode: TileMode.mirror),
          child: Container(
            color: Theme.of(context).canvasColor, //.withValues(alpha: 0.4),
            child: GetBuilder<BiblePageController>(
              init: BiblePageController(),
              builder: (biblePageController) => GetBuilder<ReadPreferencesController>(
                init: ReadPreferencesController(),
                builder: (readPreferencesController) => Wrap(
                  children: [
                    Container(
                      height: 30,
                      child: Center(
                        child: Container(
                          height: 5,
                          width: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: Theme.of(context).indicatorColor.withValues(alpha: 0.5)
                          ),
                        ),
                      ),
                    ),
    
                    Row(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.fromLTRB(16, 0, 0, 0),
                          child: Center(
                            child: Icon(FontAwesomeIcons.textHeight, color: Theme.of(context).indicatorColor),
                          ),
                        ),
                        
                        Expanded(
                          child: Slider(
                            onChangeEnd: (value){
                              readPreferencesController.onFontSizeChangeEnd(value);
                            },
    
                            activeColor: Theme.of(context).indicatorColor,
                            inactiveColor: Theme.of(context).indicatorColor.withValues(alpha: 0.2),
                            value: biblePageController.fontSize, // AQUI
                            min: 18,
                            max: 30,
                            divisions: 5,
                            // label: 'Tamaño de letra: ${fontSize.round().toString()}',
                            onChanged: (double value) {
                              readPreferencesController.onFontSizeUpdate(value);
                            },
                          ),
                        ),
                      ],
                    ),
    
                    Row(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.fromLTRB(16, 0, 0, 0),
                          child: Center(
                            child: Icon(FontAwesomeIcons.rulerVertical, color: Theme.of(context).indicatorColor),
                          ),
                        ),
                        
                        Expanded(
                          child: Slider(
                            onChangeEnd: (value){
                              readPreferencesController.onFontHeightChangeEnd(value);
                            },
    
                            activeColor: Theme.of(context).indicatorColor,
                            inactiveColor: Theme.of(context).indicatorColor.withValues(alpha: 0.2),
                            value: biblePageController.fontHeight,
                            min: 1.05,
                            max: 3.05,
                            divisions: 5,
                            // label: 'Altura de linea: ${(height * 10).round()}',
                            onChanged: (double value) {
                              readPreferencesController.onFontHeightUpdate(value);
                            },
                          ),
                        ),
                      ],
                    ),
    
    
                    Row(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.fromLTRB(16, 0, 0, 0),
                          child: Center(
                            child: Icon(FontAwesomeIcons.rulerHorizontal, color: Theme.of(context).indicatorColor),
                          ),
                        ),
                        
                        Expanded(
                          child: Slider(
                            onChangeEnd: (value){
                              readPreferencesController.onFontLetterSeparationChangeEnd(value);
                            },
    
                            activeColor: Theme.of(context).indicatorColor,
                            inactiveColor: Theme.of(context).indicatorColor.withValues(alpha: 0.2),
                            value: biblePageController.fontLetterSeparation,
                            min: -1.5,
                            max: 5,
                            divisions: 5,
                            // label: 'Separación de letras: ${(letterSeparation * 10).round()}',
                            onChanged: (double value) {
                              readPreferencesController.onFontLetterSeparationUpdate(value);
                            },
                          ),
                        ),
                      ],
                    ),
    
                    Container(
                      height: 150,
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 0,
                          crossAxisSpacing: 0
                        ),
                        itemCount: themes.length,
                        primary: true,
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        
                        itemBuilder: (context, index) => InkWell(
                          onTap: (){readPreferencesController.setTheme(themes.keys.elementAt(index));},
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                height: 48,
                                width: 48,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Theme.of(context).indicatorColor.withValues(alpha: 0.8),
                                ),
                              ),
                          
                              // Background         
                              // IconButton(
                              //   icon: Icon(Icons.circle),
                              //   iconSize: 53,
                              //   color: AppTheme.getTheme(themes.keys.elementAt(index)).canvasColor,
                              //   onPressed: (){
                              //     readPreferencesController.setTheme(themes.keys.elementAt(index));
                              //   },
                              // ),
                          
                              Container(
                                height: 45,
                                width: 45,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppTheme.getTheme(themes.keys.elementAt(index)).canvasColor,
                                ),
                              ),
                          
                              // Foreground
                              Container(
                                height: 23,
                                width: 23,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppTheme.getTheme(themes.keys.elementAt(index)).indicatorColor
                                ),
                              ),
                            ],
                          ),
                        )
                      ),
                    ),

                    Container(
                      height: MediaQuery.of(context).viewPadding.bottom,
                    )
                  ],
                )
              )
            ),
          ),
        ),
      ),
    );
  }
}