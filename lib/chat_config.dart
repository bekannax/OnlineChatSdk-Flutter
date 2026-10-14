import 'package:shared_preferences/shared_preferences.dart';

class ChatConfig {

  static void setLastDateTimeNewMessage(String value) async {
    await (await getInstance())._setConfig(ChatConfig.configKeyLastDateTimeNewMessage, value);
  }

  static Future<String> getLastDateTimeNewMessage() async {
    return await (await getInstance())._getConfigString(ChatConfig.configKeyLastDateTimeNewMessage, "");
  }

  static void setConfigString({required String key, required String value}) async {
    await (await getInstance())._setConfig(key, value);
  }

  static void setClientId(String clientId) async {
    await (await getInstance())._setConfig(ChatConfig.configKeyClientId, clientId);
  }

  static Future<String> getClientId() async {
    return await (await getInstance())._getConfigString(ChatConfig.configKeyClientId, "");
  }

  static Future<String> getOrgId() async {
    return await (await getInstance())._getConfigString(ChatConfig.configKeyOrgId, "");
  }

  static void setOrgId(String orgId) async {
    await (await getInstance())._setConfig(ChatConfig.configKeyOrgId, orgId);
  }

  static Future<String> getSiteId() async {
    return (await getInstance())._getConfigString(ChatConfig.configKeySiteId, "");
  }

  static void setSiteId(String clientId) async {
    await (await getInstance())._setConfig(ChatConfig.configKeySiteId, clientId);
  }

  static const String configKeyClientId = "clientId";
  static const String configKeyLastDateTimeNewMessage = "lastDateTimeNewMessage";
  static const String configKeyOrgId = "orgId";
  static const String configKeySiteId = "siteId";
  static ChatConfig? _instance;
  
  SharedPreferences? _config = null;

  Future<SharedPreferences> _getConfig() async {
    if (_config == null) {
      _config = await SharedPreferences.getInstance();
    }
    return _config!;
  }

  Future<void> _setConfig(String key, dynamic value) async {
    if (value is bool) {
      await (await _getConfig()).setBool(key, value);
    } else if (value is double) {
      await (await _getConfig()).setDouble(key, value);
    } else if (value is int) {
      await (await _getConfig()).setInt(key, value);
    } else if (value is String) {
      await (await _getConfig()).setString(key, value);
    } else if (value is List<String>) {
      await (await _getConfig()).setStringList(key, value);
    }
  }

  Future<bool> _getConfigBool(String key, bool def)  async {
    var result = (await _getConfig()).getBool(key);
    if (result == null) {
      return def;
    }
    return result;
  }

  Future<int> _getConfigInt(String key, int def) async {
    var result = (await _getConfig()).getInt(key);
    if (result == null) {
      return def;
    }
    return result;
  }

  Future<double> _getConfigDouble(String key, double def) async {
    var result = (await _getConfig()).getDouble(key);
    if (result == null) {
      return def;
    }
    return result;
  }

  Future<String> _getConfigString(String key, String def) async {
    var result = (await _getConfig()).getString(key);
    if (result == null) {
      return def;
    }
    return result;
  }

  Future<List<String>> _getConfigListString(String key) async {
    var result = (await _getConfig()).getStringList(key);
    if (result == null) {
      return [];
    }
    return result;
  }

  static Future<ChatConfig> getInstance() async {
    if (_instance == null) {
      _instance = ChatConfig();
      await _instance!._getConfig();
    }
    return _instance!;
  }
}