import 'dart:collection';

import 'package:shared_preferences/shared_preferences.dart';

class ChatConfig {

  static void setLastDateTimeNewMessage(String value) async {
    (await getInstance())._setConfig(ChatConfig.configKeyLastDateTimeNewMessage, value);
  }

  static Future<String> getLastDateTimeNewMessage() async {
    return (await getInstance())._getConfigString(ChatConfig.configKeyLastDateTimeNewMessage, "");
  }

  static void setClientId(String clientId) async {
    (await getInstance())._setConfig(ChatConfig.configKeyClientId, clientId);
  }

  static Future<String> getClientId() async {
    return (await getInstance())._getConfigString(ChatConfig.configKeyClientId, "");
  }

  static void setApiToken(String token) async {
    (await getInstance())._setConfig(ChatConfig.configKeyApiToken, token);
  }

  static Future<String> getApiToken() async {
    return (await getInstance())._getConfigString(ChatConfig.configKeyApiToken, "");
  }

  static const String configKeyApiToken = "apiToken";
  static const String configKeyClientId = "clientId";
  static const String configKeyLastDateTimeNewMessage = "lastDateTimeNewMessage";
  static ChatConfig? _instance;
  
  late final SharedPreferences _config;

  Future<void> init() async {
    _config = await SharedPreferences.getInstance();
  }

  void _setConfig(String key, dynamic value) {
    if (value is bool) {
      _config.setBool(key, value);
    } else if (value is double) {
      _config.setDouble(key, value);
    } else if (value is int) {
      _config.setInt(key, value);
    } else if (value is String) {
      _config.setString(key, value);
    } else if (value is List<String>) {
      _config.setStringList(key, value);
    }
  }

  bool _getConfigBool(String key, bool def) {
    var result = _config.getBool(key);
    if (result == null) {
      return def;
    }
    return result;
  }

  int _getConfigInt(String key, int def) {
    var result = _config.getInt(key);
    if (result == null) {
      return def;
    }
    return result;
  }

  double _getConfigDouble(String key, double def) {
    var result = _config.getDouble(key);
    if (result == null) {
      return def;
    }
    return result;
  }

  String _getConfigString(String key, String def) {
    var result = _config.getString(key);
    if (result == null) {
      return def;
    }
    return result;
  }

  List<String> _getConfigListString(String key) {
    var result = _config.getStringList(key);
    if (result == null) {
      return [];
    }
    return result;
  }

  static Future<ChatConfig> getInstance() async {
    if (_instance == null) {
      _instance = ChatConfig();
      await _instance!.init();
    }
    return _instance!;
  }
}