import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:yhwh/classes/AppTheme.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';

class MainPageController extends GetxController {
  
  int mainPagetabIndex = 0;
  GetStorage getStorage = GetStorage();

  // --- VARIABLES PARA LA ACTUALIZACIÓN ---
  String currentVersion = 'Cargando...';
  String? latestVersion;
  String? apkDownloadUrl;
  String? localApkPath; 
  
  bool isUpdateAvailable = false;
  bool isDownloading = false;
  bool isDownloadCompleted = false; 
  double downloadProgress = 0.0;

  @override
  void onInit() {
    mainPagetabIndex = getStorage.read("mainPagetabIndex") ?? 0;
    super.onInit();
  }

  @override
  void onReady() async {
    Get.changeTheme(AppTheme.getTheme(getStorage.read("currentTheme") ?? 'light'));
    await initVersionInfo(); 
    super.onReady();
  }

  void bottomNavigationBarOnTap(int index) async {
    this.mainPagetabIndex = index;
    getStorage.write("mainPagetabIndex", mainPagetabIndex);
    update();
  }

  // --- LÓGICA DE ACTUALIZACIONES ---
  Future<void> initVersionInfo() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      currentVersion = packageInfo.version;
      update(['update_ui']); 
      _checkForUpdates(); 
    } catch (e) {
      debugPrint('Error al leer versión local: $e');
    }
  }

  Future<void> _checkForUpdates() async {
    try {
      final url = 'https://api.github.com/repos/llromerorr/yhwh/releases/latest';
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        String tag = data['tag_name'].toString().replaceAll('v', '').replaceAll('V', '');
        
        if (_isOutdated(currentVersion, tag)) {
          String? url;
          for (var asset in data['assets']) {
            if (asset['name'].toString().endsWith('.apk')) {
              url = asset['browser_download_url'];
              break;
            }
          }
          
          if (url != null) {
            latestVersion = tag;
            apkDownloadUrl = url;
            isUpdateAvailable = true;
            update(['update_ui']); 
          }
        }
      }
    } catch (e) {
      debugPrint('Error al verificar actualizaciones en GitHub: $e');
    }
  }

  bool _isOutdated(String current, String latest) {
    List<int> cParts = current.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    List<int> lParts = latest.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    for (int i = 0; i < 3; i++) {
      int c = i < cParts.length ? cParts[i] : 0;
      int l = i < lParts.length ? lParts[i] : 0;
      if (l > c) return true;
      if (l < c) return false;
    }
    return false;
  }

  Future<void> downloadUpdate() async {
    if (apkDownloadUrl == null) return;
    
    isDownloading = true;
    downloadProgress = 0.0;
    update(['update_ui']); 

    try {
      Directory tempDir = await getTemporaryDirectory();
      localApkPath = "${tempDir.path}/yhwh_update_$latestVersion.apk";

      int lastPercentage = 0;

      await Dio().download(
        apkDownloadUrl!,
        localApkPath!,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            int currentPercentage = ((received / total) * 100).toInt();
            // Solo repintamos si el porcentaje avanzó al menos 1% para evitar pantallazos
            if (currentPercentage > lastPercentage) {
              lastPercentage = currentPercentage;
              downloadProgress = received / total;
              update(['update_ui']); 
            }
          }
        },
      );

      isDownloading = false;
      isDownloadCompleted = true; 
      update(['update_ui']); // Actualiza el botón a "Instalar"
      update(); // Actualiza toda la app para que aparezca el Badge
      
    } catch (e) {
      isDownloading = false;
      update(['update_ui']);
      debugPrint("Error en la descarga: $e");
    }
  }

  Future<void> installUpdate() async {
    if (localApkPath != null) {
      await OpenFilex.open(localApkPath!);
    }
  }
}