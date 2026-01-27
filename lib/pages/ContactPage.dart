import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart' as animateDo;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ContactPage extends StatefulWidget {
  const ContactPage({ Key? key }) : super(key: key);

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  String version = '1.2.2'; // Versión actual de la aplicación

  Future<String> getLatestVersion() async {
    final url = 'https://api.github.com/repos/llromerorr/yhwh/releases/latest';
    final response = await http.get(Uri.parse(url));

    print(response.body);
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data['tag_name']; // Asume que la versión está en el tag_name
    } else {
      throw Exception('Failed to load latest version');
    }
  }

  bool isOutdated(String currentVersion, String latestVersion) {
    // Asume que las versiones están en formato semántico (e.g., "1.0.0")
    final current = currentVersion.split('.').map(int.parse).toList();
    final latest = latestVersion.split('.').map(int.parse).toList();

    for (int i = 0; i < current.length; i++) {
      if (latest[i] > current[i]) {
        return true;
      } else if (latest[i] < current[i]) {
        return false;
      }
    }
    return false;
  }

  void checkForUpdates() async {
    try {
      final latestVersion = await getLatestVersion();
      if (isOutdated(version, latestVersion)) {
        print('Tu versión está desactualizada. La última versión es $latestVersion');
      } else {
        print('Estás utilizando la última versión.');
      }
    } catch (e) {
      print('Error al verificar actualizaciones: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return animateDo.FadeIn(
      duration: Duration(milliseconds: 150),
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
                  child: Image(
                    isAntiAlias: true,
                    image: AssetImage('assets/portrait_logo.png')
                  ),
                ),
              ),
              
              Container(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () => launch('https://instagram.com/iglesiayhwh'),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: EdgeInsets.all(8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(FontAwesomeIcons.instagram, color: Theme.of(context).indicatorColor),
                              Container(width: 5),
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
                        onTap: () => launch('https://www.youtube.com/@iglesiayhwh'),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: EdgeInsets.all(8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(FontAwesomeIcons.youtube, color: Theme.of(context).indicatorColor),
                              Container(width: 5),
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
                        onTap: () => launch('https://github.com/llromerorr/yhwh/releases'),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: EdgeInsets.all(8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(FontAwesomeIcons.github, color: Theme.of(context).indicatorColor,),
                              Container(width: 5),
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

                  Container(width: 15),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () => launch('https://www.tiktok.com/@iglesia.yhwh'),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: EdgeInsets.all(8),
                          height: 50,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(FontAwesomeIcons.tiktok, color: Theme.of(context).indicatorColor),
                              Container(width: 5),
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
                        onTap: () => launch('mailto:yhwh.principal@gmail.com'),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: EdgeInsets.all(8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(FontAwesomeIcons.message, color: Theme.of(context).indicatorColor,),
                              Container(width: 5),
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
                  Divider(height: 25, color: Color(0x00)),
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
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
          
                  TextButton(
                    child: Text('Version: $version',
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Baloo',
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).indicatorColor.withValues(alpha: 0.9),
                      )
                    ),
                    onPressed: checkForUpdates,
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