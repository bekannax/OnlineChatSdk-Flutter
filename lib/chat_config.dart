import 'dart:collection';
import 'package:shared_preferences/shared_preferences.dart';

class ChatConfig {
  static const String configKeyApiToken = "apiToken";
  static const String configKeyClientId = "clientId";
  static const String configKeyLastDateTimeNewMessage = "lastDateTimeNewMessage";

  static ChatConfig? _instance;
  
  SharedPreferences? _config;

  Future<void> init() async {
    _config = await SharedPreferences.getInstance();
  }

  static Future<ChatConfig> getInstance() async {
    if (_instance == null) {
      _instance = ChatConfig();
      await _instance!.init();
    }
    return _instance!;
  }

  // Проверка на инициализацию
  Future<void> _ensureInitialized() async {
    if (_config == null) {
      await init();
    }
  }

  // Установка значения
  void _setConfig(String key, dynamic value) async {
    await _ensureInitialized();  // Проверяем инициализацию

    if (value is bool) {
      _config?.setBool(key, value);
    } else if (value is double) {
      _config?.setDouble(key, value);
    } else if (value is int) {
      _config?.setInt(key, value);
    } else if (value is String) {
      _config?.setString(key, value);
    } else if (value is List<String>) {
      _config?.setStringList(key, value);
    }
  }

  // Получение строки с дефолтным значением
  Future<String> _getConfigString(String key, String def) async {
    await _ensureInitialized();  // Проверяем инициализацию

    var result = _config?.getString(key);
    if (result == null) {
      return def;
    }
    return result;
  }

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
}
