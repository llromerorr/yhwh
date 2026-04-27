import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:yhwh/controllers/MainPageController.dart';
import 'package:yhwh/pages/BiblePage.dart';
import 'package:animate_do/animate_do.dart' as animateDo;
import 'package:yhwh/pages/ContactPage.dart'; // Import original recuperado

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: Theme.of(context).canvasColor,

      body: GetBuilder<MainPageController>(
        init: MainPageController(),
        builder: (controller) {
          switch (controller.mainPagetabIndex) {
            case 0:
              return BiblePage();
            case 1:
              return const ContactPage(); // Regresamos al ContactPage
            default:
              return animateDo.FadeIn(child: const Center(child: Text("En desarrollo")), duration: const Duration(milliseconds: 150));
          }        
        },
      ),

      bottomNavigationBar: Container( 
        child: Container(
          foregroundDecoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Theme.of(context).indicatorColor.withValues(alpha: 0.5),
                width: 1.5
              )
            )
          ),
            
          child: GetBuilder<MainPageController>(
            init: MainPageController(),
            builder: (_){
              return ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 36, sigmaY: 36, tileMode: TileMode.mirror),
                  child: BottomNavigationBar(
                    currentIndex: _.mainPagetabIndex,
                    elevation: 0,
                    type: BottomNavigationBarType.fixed,
                    backgroundColor: Theme.of(context).canvasColor.withValues(alpha: 0.3),
                    selectedItemColor: Theme.of(context).indicatorColor.withValues(alpha: 0.9),
                    unselectedItemColor: Theme.of(context).indicatorColor.withValues(alpha: 0.6),
                              
                    items: [
                      const BottomNavigationBarItem(
                        icon: Icon(Icons.book),
                        label: 'Biblia',
                      ),
                              
                      BottomNavigationBarItem(
                        icon: Badge(
                          isLabelVisible: _.isDownloadCompleted, 
                          backgroundColor: Colors.red,
                          label: const Text('1', style: TextStyle(color: Colors.white, fontSize: 10)), 
                          child: const Icon(Icons.alternate_email_rounded),
                        ),
                        label: 'Contacto',
                      ),
                    ],
                              
                    onTap: _.bottomNavigationBarOnTap
                  ),
                ),
              );
            },
          )
        ),
      )
    );
  }
}