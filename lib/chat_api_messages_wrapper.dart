
class ChatApiMessagesWrapper {

  late Map<String, dynamic> _result;
  late List<dynamic> _dataArray;
  late Map<String, dynamic> _data;
  late List<dynamic> _messages;

  ChatApiMessagesWrapper(Map<String, dynamic> response) {
    _result = response;
    _dataArray = [];
    _data = {};
    _messages = [];

    if (response['result'] == null) {
      return;
    }
    _dataArray = response['result'] as List<dynamic>;
    if (_dataArray.isEmpty) {
      return;
    }
    _data = _dataArray[0];
    if (_data['messages'] == null) {
      return;
    }
    _messages = _data['messages'] as List<dynamic>;
  }

  List<dynamic> getMessages() {
    return _messages;
  }

  void setMessages(List<dynamic> messages) {
    _messages = messages;
  }

  Map<String, dynamic> getResult() {
    _data['messages'] = _messages;
    if (_dataArray.isEmpty) {
      _dataArray = [_data];
    } else {
      _dataArray[0] = _data;
    }
    _result['result'] = _dataArray;
    return _result;
  }
}