import 'package:onlinechatsdk/chat_api/models/chat_api_response_error_model.dart';

class ChatApiGetClientUnreadMessageCountResponseModel {
  final ChatApiResponseErrorModel? error;
  final int result;
  new({required this.error, this.result = 0});
}