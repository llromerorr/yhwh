import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart' as animateDo;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';
import 'package:yhwh/controllers/MainPageController.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return animateDo.FadeIn(
      duration: const Duration(milliseconds: 150),
      child: Scaffold(
        backgroundColor: Theme.of(context).canvasColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: Colors.white,
                radius: 100,
                child: Container(
                  child: const Image(
                    isAntiAlias: true,
                    image: AssetImage('assets/portrait_logo.png')
                  ),
                ),
              ),
              
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () => launchUrl(Uri.parse('https://instagram.com/iglesiayhwh')),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(FontAwesomeIcons.instagram, color: Theme.of(context).indicatorColor),
                              const SizedBox(width: 5),
                              Text(
                              'Instagram',
                              style: TextStyle(
                                color: Theme.of(context).indicatorColor,
                                fontSize: 18,
                                fontWeight: FontWeight.bold
                              ),
                            ),
                            ],
                          ),
                        ),
                      ),

                      InkWell(
                        onTap: () => launchUrl(Uri.parse('https://www.youtube.com/@iglesiayhwh')),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(FontAwesomeIcons.youtube, color: Theme.of(context).indicatorColor),
                              const SizedBox(width: 5),
                              Text(
                              'Youtube',
                              style: TextStyle(
                                color: Theme.of(context).indicatorColor,
                                fontSize: 18,
                                fontWeight: FontWeight.bold
                              ),
                            ),
                            ],
                          ),
                        ),
                      ),

                      InkWell(
                        onTap: () => launchUrl(Uri.parse('https://github.com/llromerorr/yhwh/releases')),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(FontAwesomeIcons.github, color: Theme.of(context).indicatorColor,),
                              const SizedBox(width: 5),
                              Text(
                              'Github',
                              style: TextStyle(
                                color: Theme.of(context).indicatorColor,
                                fontSize: 18,
                                fontWeight: FontWeight.bold
                              ),
                            ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(width: 15),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () => launchUrl(Uri.parse('https://www.tiktok.com/@iglesia.yhwh')),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          height: 50,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(FontAwesomeIcons.tiktok, color: Theme.of(context).indicatorColor),
                              const SizedBox(width: 5),
                              Text(
                              'Tiktok',
                              style: TextStyle(
                                color: Theme.of(context).indicatorColor,
                                fontSize: 18,
                                fontWeight: FontWeight.bold
                              ),
                            ),
                            ],
                          ),
                        ),
                      ),
                      
                      InkWell(
                        onTap: () => launchUrl(Uri.parse('mailto:yhwh.principal@gmail.com')),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(FontAwesomeIcons.solidEnvelope, color: Theme.of(context).indicatorColor,),
                              const SizedBox(width: 5),
                              Text(
                              'Email',
                              style: TextStyle(
                                color: Theme.of(context).indicatorColor,
                                fontSize: 18,
                                fontWeight: FontWeight.bold
                              ),
                            ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                ]
              ),

              Column(
                children: <Widget>[
                  const Divider(height: 25, color: Color(0x00)),
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: RichText(
                        text: TextSpan(
                          text: 'Desarrollado por Luis Romero',
                          style: TextStyle(
                              fontSize: 15,
                              fontFamily: 'Baloo',
                              color: Theme.of(context).indicatorColor.withValues(alpha: 0.7),
                              height: 1.2
                          )
                        ),
                        textAlign: TextAlign.center,
                      )
                  ),
                  const SizedBox(height: 10),
          
                  // LÓGICA REACTIVA DE LA ACTUALIZACIÓN
                  GetBuilder<MainPageController>(
                    id: 'update_ui', // Actualización optimizada sin parpadeos
                    builder: (_) {
                      return Column(
                        children: [
                          Text(
                            'Versión: ${_.currentVersion}',
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'Baloo',
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).indicatorColor.withValues(alpha: 0.6),
                            )
                          ),
                          
                          AnimatedSize(
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.easeOutCubic,
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: _.isDownloadCompleted
                                  ? Container(
                                      key: const Key('install_btn'),
                                      margin: const EdgeInsets.only(top: 15),
                                      child: ElevatedButton.icon(
                                        icon: Icon(Icons.download_done_rounded, color: Theme.of(context).canvasColor, size: 20),
                                        label: Text(
                                          '¡Instalar Ahora!',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontFamily: 'Baloo',
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context).canvasColor, 
                                          )
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Theme.of(context).indicatorColor, 
                                          elevation: 2,
                                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
                                        ),
                                        onPressed: _.installUpdate, 
                                      ),
                                    )
                                  : _.isDownloading
                                      ? Container(
                                          key: const Key('downloading'),
                                          margin: const EdgeInsets.only(top: 15),
                                          child: Column(
                                            children: [
                                              Text(
                                                'Descargando... ${(_.downloadProgress * 100).toInt()}%',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontFamily: 'Baloo',
                                                  fontWeight: FontWeight.bold,
                                                  color: Theme.of(context).indicatorColor,
                                                )
                                              ),
                                              const SizedBox(height: 8),
                                              SizedBox(
                                                width: 150,
                                                child: LinearProgressIndicator(
                                                  value: _.downloadProgress,
                                                  backgroundColor: Theme.of(context).indicatorColor.withValues(alpha: 0.2),
                                                  color: Theme.of(context).indicatorColor,
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : _.isUpdateAvailable
                                          ? Container(
                                              key: const Key('update_btn'),
                                              margin: const EdgeInsets.only(top: 15),
                                              child: TextButton.icon(
                                                icon: Icon(Icons.system_update_rounded, color: Theme.of(context).indicatorColor, size: 18),
                                                label: Text(
                                                  'Actualizar a v${_.latestVersion}',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontFamily: 'Baloo',
                                                    fontWeight: FontWeight.bold,
                                                    color: Theme.of(context).indicatorColor,
                                                  )
                                                ),
                                                style: TextButton.styleFrom(
                                                  backgroundColor: Theme.of(context).indicatorColor.withValues(alpha: 0.1),
                                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
                                                ),
                                                onPressed: _.downloadUpdate, 
                                              ),
                                            )
                                          : const SizedBox.shrink(key: Key('empty')),
                            ),
                          ),
                        ],
                      );
                    }
                  ),
                ],
              ),
            ],
          ),
        )
      ),
    );
  }
}