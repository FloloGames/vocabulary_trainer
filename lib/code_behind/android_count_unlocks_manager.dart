import 'package:flutter/services.dart';

class AndroidCountUnlocksManager {
  final MethodChannel _testMethodChannel = const MethodChannel("testChannel");
  // static const _testCBMethodChannel = MethodChannel("testCBChannel");
  // int _deviceUnlocks = 0;

  // static const String _testCBMethodName = "testCBMethod";

  static const String _testMethodName = "testMethod";
  static const String _getUnlockCountMethodName = "getUnlockCount";
  static const String _startForegroundService = "startForegroundService";
  static const String _endForegroundService = "endForegroundService";
  static const String _isForegroundServiceRunning =
      "isForegroundServiceRunning";
  static const String _setUnlockCountToOpenApp = "setUnlockCountToOpenApp";
  static const String _getUnlockCountToOpenApp = "getUnlockCountToOpenApp";
  static const String _vocabularyDone = "vocabularyDone";
  static const String _installApk = "installApk";

  static AndroidCountUnlocksManager instance = AndroidCountUnlocksManager();

  // AndroidCountUnlocksManager() {
  //   // testCBMethodChannel.setMethodCallHandler((call) {
  //   //   if (call.method == testCBMethodName) {
  //   //     debugText = call.arguments.toString();
  //   //     setState(() {});
  //   //   }
  //   //   return Future.value();
  //   // });
  // }

  final int unlockCountToOpenApp = 5;

  Future<bool?> installApk(String path) {
    Map<String, dynamic> map = {"path": path};
    return _testMethodChannel.invokeMethod(_installApk, map);
  }

  Future<void> vocabularyDone() {
    return _testMethodChannel.invokeMethod(_vocabularyDone);
  }

  Future<bool?> setUnlockCountToOpenApp(int count) {
    Map<String, Object> map = {"count": count};
    return _testMethodChannel.invokeMethod<bool>(_setUnlockCountToOpenApp, map);
  }

  Future<int?> getUnlockCountToOpenApp() {
    return _testMethodChannel.invokeMethod<int>(_getUnlockCountToOpenApp);
  }

  Future<bool?> startForegroundService() {
    return _testMethodChannel.invokeMethod<bool>(_startForegroundService);
  }

  Future<bool?> isForegroundServiceRunning() {
    return _testMethodChannel.invokeMethod<bool>(_isForegroundServiceRunning);
  }

  Future<bool?> endForegroundService() {
    return _testMethodChannel.invokeMethod<bool>(_endForegroundService);
  }

  Future<void> callTestMethod() {
    return _testMethodChannel.invokeMethod(_testMethodName);
  }

  Future<int?> getUnlockCount() async {
    int? count =
        await _testMethodChannel.invokeMethod(_getUnlockCountMethodName);
    count ??= -1;
    return count;
  }
}
