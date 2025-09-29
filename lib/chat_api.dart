import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatApi {

  Future<http.Response> _post(Uri uri, String token, Object? body) async {
    String? jsonBody;
    if (body != null) {
      jsonBody = jsonEncode(body);
    }
    return await http.post(
      uri,
      headers: {
        'X-Token': token,
        'Content-Type': "application/json",
        'Accept':'application/json'
      },
      body: jsonBody,
      encoding: Encoding.getByName("utf-8")
    );
  }

  Future<Map<String, dynamic>> _send(String token, String method, Map<String, dynamic>? params) async {
    var result = await _post(
        Uri.https(await getDomain(), '/json/v1.0/$method'),
        token,
        params
    );
    return jsonDecode(result.body);
  }

  Future<Map<String, dynamic>> messages(String token, Map<String, dynamic>? params) async {
    return await _send(
      token,
      'chat/message/getList',
      params
    );
  }

  Future<String> getDomain() async {
    var response = await http.get(
      Uri.https('operator.me-talk.ru', '/cabinet/assets/operatorApplication/checkConnection.json'),
    );
    if (response.statusCode == 200) {
      return 'admin.verbox.ru';
    }
    response = await http.get(
      Uri.https('operator.me-talk.ru', '/cabinet/assets/operatorApplication/checkConnection.json'),
    );
    if (response.statusCode == 200) {
      return 'admin.verbox.me';
    }
    return 'admin.verbox.ru';
  }
}