import 'dart:convert';
import 'dart:io';

import 'package:onlinechatsdk/%D1%81heck_%D1%81onnection.dart';
import 'package:onlinechatsdk/chat_api/models/chat_api_get_client_unread_message_count_response_model.dart';
import 'package:onlinechatsdk/chat_api/models/chat_api_response_error_model.dart';
import 'package:onlinechatsdk/chat_api/models/chat_api_response_model.dart';

class ChatApi {
  final String orgId;
  final String siteId;
  final String clientId;
  final CheckConnection checkConnection = CheckConnection();
  final String apiUrl = "https://%s/comet/%s?orgId=%s&siteId=%s&clientId=%s";

  new({required this.orgId, required this.siteId, required this.clientId});

  Future<String> getDomain() async {
    return checkConnection.getApiDomain();
  }

  Future<ChatApiResponseModel> requestGet(String sUrl) async {
    HttpClient? client;
    HttpClientRequest? request;
    HttpClientResponse? response;
    ChatApiResponseModel result;

    try {
      client = HttpClient();
      client.connectionTimeout = const Duration(milliseconds: 5000);

      final uri = Uri.parse(sUrl);
      request = await client.getUrl(uri);
      response = await request.close().timeout(
        const Duration(milliseconds: 5000),
      );

      if (response.statusCode == HttpStatus.ok) {
        final responseBody = await response.transform(utf8.decoder).join();

        if (responseBody.isEmpty) {
          result = ChatApiResponseModel(
            error: ChatApiResponseErrorModel(
              code: 0,
              descr: "empty response :: inputStream == null",
            ),
            result: ""
          );
        } else {
          result = ChatApiResponseModel(
            result: responseBody.trim(),
            error: null
          );
        }
      } else {
        result = ChatApiResponseModel(
          error: ChatApiResponseErrorModel(
            code: response.statusCode,
            descr: "HTTP error code: ${response.statusCode}"
          ),
          result: ""
        );
      }
    } catch (e) {
      result = ChatApiResponseModel(
        error: ChatApiResponseErrorModel(
          code: 0,
          descr: "URL failed: ${e.toString()}",
        ),
        result: ""
      );
    } finally {
      client?.close(force: true);
    }

    return result;
  }

  ChatApiResponseErrorModel? checkAuthParams() {
    String error = "";
    if (orgId.isEmpty) {
      error = "orgId.isEmpty() ";
    }
    if (siteId.isEmpty) {
      error += "siteId.isEmpty() ";
    }
    if (clientId.isEmpty) {
      error += "clientId.isEmpty()";
    }
    if (error.isEmpty) {
      return null;
    }
    return ChatApiResponseErrorModel(
      code: 0,
      descr: "auth params not init: $error"
    );
  }

  Future<ChatApiGetClientUnreadMessageCountResponseModel> getClientUnreadMessageCount() async {
    final checkAuthParamsError = checkAuthParams();
    if (checkAuthParamsError != null) {
      return ChatApiGetClientUnreadMessageCountResponseModel(
        error: checkAuthParamsError,
      );
    }

    // https://widget.apibcknd.com/comet/getClientUnreadMessageCount?orgId=&siteId=&clientId=
    final url = _formatApiUrl(
      await checkConnection.getApiDomain(),
      "getClientUnreadMessageCount",
      orgId,
      siteId,
      clientId,
    );

    final response = await requestGet(url);
    if (response.error != null) {
      return ChatApiGetClientUnreadMessageCountResponseModel(
        error: response.error!
      );
    }

    if (response.result.isEmpty) {
      return ChatApiGetClientUnreadMessageCountResponseModel(
        result: 0,
        error: null
      );
    }

    try {
      return ChatApiGetClientUnreadMessageCountResponseModel(
        result: int.parse(response.result),
        error: null
      );
    } catch (e) {
      return ChatApiGetClientUnreadMessageCountResponseModel(
        error: ChatApiResponseErrorModel(
          code: 0,
          descr: "failed to parse result: ${e.toString()}",
        ),
      );
    }
  }

  String _formatApiUrl(
      String domain,
      String endpoint,
      String orgId,
      String siteId,
      String clientId,
      ) {
    return apiUrl
        .replaceFirst('%s', domain)
        .replaceFirst('%s', endpoint)
        .replaceFirst('%s', orgId)
        .replaceFirst('%s', siteId)
        .replaceFirst('%s', clientId);
  }
}