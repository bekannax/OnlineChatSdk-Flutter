import 'package:onlinechatsdk/chat_api/models/chat_api_response_error_model.dart';

class ChatApiResponseModel {
  final ChatApiResponseErrorModel? error;
  final String result;
  new({required this.error, required this.result});
}