import 'dart:io';

class CheckConnection {
  bool? _needUseAlternativeUrl;

  Future<String> getDomain() async {
    if (await isNeedUseAlternativeUrl()) {
      return "admin.verbox.me";
    }
    return "admin.verbox.ru";
  }

  Future<String> getApiDomain() async {
    if (await isNeedUseAlternativeUrl()) {
      return "widget.site-chat.me";
    }
    return "widget.apibcknd.com";
  }

  Future<bool> isNeedUseAlternativeUrl() async {
    if (_needUseAlternativeUrl != null) {
      return _needUseAlternativeUrl!;
    }

    const check = "https://operator.me-talk.ru/cabinet/assets/operatorApplication/checkConnection.json";
    const checkAlternative = "https://operator.site-chat.me/cabinet/assets/operatorApplication/checkConnection.json"; // operator.verbox.me

    var result = await _requestGet(check);
    if (result.isEmpty) {
      _needUseAlternativeUrl = false;
      return false;
    }
    result = await _requestGet(checkAlternative);
    if (result.isEmpty) {
      _needUseAlternativeUrl = true;
      return true;
    }
    return false;
  }

  Future<String> _requestGet(String sUrl) async {
    HttpClient? client;
    HttpClientRequest? request;
    HttpClientResponse? response;

    try {
      client = HttpClient();
      client.connectionTimeout = const Duration(milliseconds: 3000);

      final uri = Uri.parse(sUrl);
      request = await client.getUrl(uri);
      response = await request.close().timeout(
        const Duration(milliseconds: 3000),
      );

      if (response.statusCode == HttpStatus.ok) {
        return "";
      } else {
        return "HTTP error code: ${response.statusCode}";
      }
    } catch (e) {
      return "URL failed: ${e.toString()}";
    } finally {
      client?.close(force: true);
    }
  }
}