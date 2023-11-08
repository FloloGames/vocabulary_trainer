import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:permission_handler/permission_handler.dart';
import 'package:rxdart/rxdart.dart' as rx;
import 'package:dio/dio.dart';
import 'package:vocabulary_trainer/code_behind/android_count_unlocks_manager.dart';

class UpdateManager {
  // ignore: constant_identifier_names
  static const URL_TO_NEWEST_JSON =
      "https://raw.githubusercontent.com/FloloGames/vocabulary_trainer/main/newest_build/newest_version.json";
  // ignore: constant_identifier_names
  static const URL_TO_NEWEST_APK =
      "https://raw.githubusercontent.com/FloloGames/vocabulary_trainer/main/newest_build/app-release.apk";
  // ignore: constant_identifier_names
  static const CURRENT_VERSION = 1.3;

  static UpdateManager instance = UpdateManager();

  final rx.BehaviorSubject<double> downloadPercentStream =
      rx.BehaviorSubject<double>();

  final Dio _dio = Dio();

  // String _newest_build_hash = "";
  String _savePath = "";

  String get savePath => _savePath;

  Future<bool> isUpdateAvaiable() async {
    downloadPercentStream.add(0);

    final response = await _dio.get(URL_TO_NEWEST_JSON);
    if (response.statusMessage != "OK") {
      return false;
    }

    Map<String, dynamic> json = jsonDecode(response.data);

    double newestVersion = double.parse(json["newest_version"].toString());
    // _newest_build_hash = json["hash"];

    // print(response);
    return newestVersion > CURRENT_VERSION;
  }

  Future<bool> downloadNewestApk() async {
    String fileName = "new_apk_version.apk";

    final Directory? appDocumentsDir =
        await path_provider.getDownloadsDirectory();

    if (appDocumentsDir == null) return false;

    appDocumentsDir.createSync();

    _savePath = "${appDocumentsDir.path}/$fileName";

    if (File(_savePath).existsSync()) {
      File(_savePath).deleteSync();
    }

    final response = await _dio.download(
      URL_TO_NEWEST_APK,
      _savePath,
      onReceiveProgress: (rec, total) {
        //   downloading = true;
        //  // download = (rec / total) * 100;
        //   downloadingStr =
        //       "Downloading Image : $rec" ;
        downloadPercentStream.add((rec / total) * 100);
      },
      deleteOnError: true,
    );

    if (response.statusMessage != "OK") {
      downloadPercentStream.add(0);
      return false;
    }

    if (!File(_savePath).existsSync()) {
      downloadPercentStream.add(0);
      return false;
    }

    downloadPercentStream.add(100);

    //TODO check hash

    return true;
  }

  Future<bool> installNewestApk() async {
    File apk = File(_savePath);
    if (!apk.existsSync()) {
      return false;
    }

    if (!await _requestPermission(Permission.requestInstallPackages)) {
      return false;
    }
    // if (!await _requestPermission(Permission.manageExternalStorage)) {
    //   //return false;
    // }
    // if (!await _requestPermission(Permission.storage)) {
    //   //return false;
    // }

    // int? statusCode =
    //     await AndroidPackageInstaller.installApk(apkFilePath: _savePath);
    // if (statusCode == null) {
    //   return false;
    // }
    // PackageInstallerStatus installationStatus =
    //     PackageInstallerStatus.byCode(statusCode);
    // print(installationStatus.name);
    bool? installed =
        await AndroidCountUnlocksManager.instance.installApk(_savePath);
    installed ??= false;

    return installed;
  }

  Future<bool> _requestPermission(Permission permission) async {
    var status = await permission.status;
    if (status.isDenied) {
      PermissionStatus status = await permission.request();
      return status.isGranted;
    }
    return true;
  }
}
