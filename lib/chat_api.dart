import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';

class ChatApi {

  // , Function(Map<String, dynamic> result) callback
  static Future<Map<String, dynamic>> getNewMessages(String token, String clientId) async {
    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    return await ChatApi()._messages(
      token,
      {
        'client': {
          'clientId': clientId
        },
        'sender': 'operator',
        'status': 'unreaded',
        'dateRange' : {
          'start': formatter.format(DateTime.now()),
          'stop': formatter.format( DateTime.fromMillisecondsSinceEpoch(DateTime.now().millisecond - 86400 * 14) )
        }
      }
    );
  }

  Future<http.Response> _post(Uri uri, String token, Object? body) async {
    print('post body : $body');
    return await http.post(
      uri,
      headers: {
        'X-Token': token,
        'Content-Type': "application/json",
        'Accept':'application/json'
      },
      body: body
    );
  }

  Future<Map<String, dynamic>> _send(String token, String method, Map<String, dynamic>? params) async {
    var jsonString = null;
    if (params != null) {
      jsonString = Uri.encodeQueryComponent(jsonEncode(params));
      // jsonString = jsonEncode(params);
    }
    var result = await _post(
        Uri.https('admin.verbox.ru', '/json/v1.0/$method'),
        token,
        jsonString
    );
    return jsonDecode(result.body);
  }

  Future<Map<String, dynamic>> _messages(String token, Map<String, dynamic>? params) async {
    return await _send(
      token,
      'chat/message/getList',
      params
    );
  }
}