import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ChatApi {

  static Future<void> getNewMessages(String token, String clientId, Function(String result) callback) async {
    final DateFormat formatter = DateFormat('yyyy-MM-dd', 'en');
    ChatApi()._messages(
      token,
      {
        "client": {
          "clientId": clientId
        },
        "sender": "operator",
        "status": "unreaded",
        "dateRange" : {
          "start": formatter.format(DateTime.now()),
          "stop": formatter.format( DateTime.fromMillisecondsSinceEpoch(DateTime.now().millisecond - 86400 * 14) )
        }
      },
      callback
    );
  }

  Future<http.Response> _post(String url, String token, Object? body) async {
    return await http.post(
      Uri.https(url),
      headers: {
        "X-Token": token,
        "Content-Type": "application/json"
      },
      body: body
    );
  }

  Future<void> _send(String token, String method, Object? params, Function(String result) callback) async {
    var result = await _post(
        'https://admin.verbox.ru/json/v1.0/$method',
        token,
        params
    );
    callback(result.body);
  }

  Future<void> _messages(String token, Object? params, Function(String result) callback) async {
    _send(
      token,
      'chat/message/getList',
      params,
      callback
    );
  }
}