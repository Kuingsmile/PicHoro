import 'dart:convert';

import 'package:flustars_flutter3/flustars_flutter3.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:uuid/uuid.dart';

import 'package:horopic/utils/common_functions.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  static const String _apiUrl = 'https://pichoro.horosama.com/pichoro/api/events';
  static const String _deviceIdKey = 'analytics_device_id';

  Future<void> trackAppOpen() async {
    try {
      final deviceId = await _getOrCreateDeviceId();
      final deviceInfo = await _collectDeviceInfo();
      final appInfo = await _collectAppInfo();

      final eventData = {
        'event_type': 'app_open',
        'timestamp': DateTime.now().toIso8601String(),
        'device_id': deviceId,
        'device_info': deviceInfo,
        'app_info': appInfo,
      };

      await _sendEvent(eventData);
    } catch (e) {
      flogErr(
        e,
        {'event_type': 'app_open'},
        'AnalyticsService',
        'trackAppOpen',
      );
    }
  }

  Future<String> _getOrCreateDeviceId() async {
    String? deviceId = SpUtil.getString(_deviceIdKey);

    if (deviceId == '' || deviceId == null) {
      deviceId = const Uuid().v4();
      await SpUtil.putString(_deviceIdKey, deviceId);
    }

    return deviceId;
  }

  Future<Map<String, dynamic>> _collectDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();
    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidInfo = await deviceInfo.androidInfo;
      return {
        'platform': 'android',
        'device': androidInfo.model,
        'manufacturer': androidInfo.manufacturer,
        'android_version': androidInfo.version.release,
        'sdk_version': androidInfo.version.sdkInt.toString(),
      };
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return {
        'platform': 'ios',
        'device': iosInfo.model,
        'system_name': iosInfo.systemName,
        'system_version': iosInfo.systemVersion,
      };
    }
    return {'platform': defaultTargetPlatform.toString()};
  }

  Future<Map<String, dynamic>> _collectAppInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return {
      'app_name': packageInfo.appName,
      'package_name': packageInfo.packageName,
      'version': packageInfo.version,
      'build_number': packageInfo.buildNumber,
    };
  }

  Future<void> _sendEvent(Map<String, dynamic> eventData) async {
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(eventData),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to send analytics event: ${response.statusCode}');
      }
    } catch (e) {
      flogErr(
        e,
        {'event_data': eventData},
        'AnalyticsService',
        '_sendEvent',
      );
    }
  }
}
