import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';

class UpdateManager {
  // URL de la API de GitHub que siempre devuelve el último Release
  static const String _githubApiUrl = 'https://api.github.com/repos/llromerorr/yhwh/releases/latest';

  static Future<void> checkForUpdates(BuildContext context) async {
    try {
      // 1. Obtener la versión actual de la app instalada
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String currentVersion = packageInfo.version; // Ej: "1.0.0"

      // 2. Consultar la API de GitHub
      var response = await Dio().get(_githubApiUrl);
      var data = response.data;

      // Limpiamos la 'v' si tu tag es "v1.2.3", para que quede "1.2.3"
      String latestTag = data['tag_name'].toString(); 
      String latestVersion = latestTag.replaceAll('v', '').replaceAll('V', ''); 

      // 3. Comparar versiones
      if (_isNewerVersion(currentVersion, latestVersion)) {
        // Buscamos el archivo .apk entre los assets del Release de GitHub
        String? apkUrl;
        for (var asset in data['assets']) {
          if (asset['name'].toString().endsWith('.apk')) {
            apkUrl = asset['browser_download_url'];
            break;
          }
        }

        if (apkUrl != null) {
          // Si encontramos el APK y es una nueva versión, mostramos la alerta
          _showUpdateDialog(context, latestVersion, apkUrl);
        }
      }
    } catch (e) {
      debugPrint("Error al buscar actualizaciones: $e");
      // Falló silenciosamente (sin internet, etc), no interrumpimos al usuario
    }
  }

  // --- Lógica para comparar "1.0.1" contra "1.2.3" matemáticamente ---
  static bool _isNewerVersion(String current, String latest) {
    List<int> currentParts = current.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    List<int> latestParts = latest.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    for (int i = 0; i < 3; i++) {
      int c = i < currentParts.length ? currentParts[i] : 0;
      int l = i < latestParts.length ? latestParts[i] : 0;
      if (l > c) return true;
      if (l < c) return false;
    }
    return false;
  }

  // --- UI: Diálogo de aviso de nueva versión ---
  static void _showUpdateDialog(BuildContext context, String newVersion, String apkUrl) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).canvasColor,
          title: Text("¡Actualización disponible!", style: TextStyle(color: Theme.of(context).indicatorColor, fontWeight: FontWeight.bold)),
          content: Text(
            "Hay una nueva versión ($newVersion) de la aplicación disponible. ¿Deseas descargarla e instalarla ahora?",
            style: TextStyle(color: Theme.of(context).indicatorColor)
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Cancelar
              child: Text("Más tarde", style: TextStyle(color: Theme.of(context).indicatorColor.withValues(alpha: 0.6))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).indicatorColor.withValues(alpha: 0.1),
                elevation: 0
              ),
              onPressed: () {
                Navigator.pop(context); // Cerramos el primer aviso
                _startDownloadAndInstall(context, apkUrl, newVersion); // Iniciamos descarga
              },
              child: Text("Actualizar", style: TextStyle(color: Theme.of(context).indicatorColor, fontWeight: FontWeight.bold)),
            )
          ],
        );
      }
    );
  }

  // --- UI: Descarga con barra de progreso e instalación ---
  static Future<void> _startDownloadAndInstall(BuildContext context, String url, String version) async {
    double progress = 0.0;
    StateSetter? dialogSetState;

    // Mostramos un diálogo inamovible con la barra de progreso
    showDialog(
      context: context,
      barrierDismissible: false, // No se puede cerrar tocando fuera
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            dialogSetState = setState; // Guardamos el setState de este diálogo para actualizar la barrita
            return AlertDialog(
              backgroundColor: Theme.of(context).canvasColor,
              title: Text("Descargando...", style: TextStyle(color: Theme.of(context).indicatorColor)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LinearProgressIndicator(
                    value: progress, 
                    backgroundColor: Theme.of(context).indicatorColor.withValues(alpha: 0.2),
                    color: Theme.of(context).indicatorColor,
                  ),
                  const SizedBox(height: 15),
                  Text("${(progress * 100).toStringAsFixed(1)} %", style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).indicatorColor)),
                ],
              ),
            );
          }
        );
      }
    );

    try {
      // Ubicación temporal para guardar el APK
      Directory tempDir = await getTemporaryDirectory();
      String savePath = "${tempDir.path}/yhwh_update_$version.apk";

      // Iniciamos la descarga con Dio
      await Dio().download(
        url,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1 && dialogSetState != null) {
            dialogSetState!(() {
              progress = received / total; // Actualizamos la variable y la UI de la barra
            });
          }
        },
      );

      // Una vez descargado, cerramos el diálogo de progreso
      Navigator.pop(context); 

      // ¡Lanzamos el instalador nativo de Android!
      await OpenFilex.open(savePath); 

    } catch (e) {
      Navigator.pop(context); // Cierra el diálogo si hay error
      debugPrint("Error en la descarga: $e");
    }
  }
}