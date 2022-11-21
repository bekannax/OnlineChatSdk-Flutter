import 'package:flutter/material.dart';
import 'package:onlinechatsdk/chat_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OnlineChatSdk-Flutter Demo',
      home: ChatView(
        id: "593adecd804fc4e32e7e865d659f2356",
        domain: "sms-tx.ru",
        language: "ru",
        clientId: "",
        apiToken: "",
        onOperatorSendMessage: (String data) {},
        onClientSendMessage: (String data) {},
        onClientMakeSubscribe: (String data) {},
        onContactsUpdated: (String data) {},
        onSendRate: (String data) {},
        onClientId: (String data) {},
        onCloseSupport: () {},
        onFullyLoaded: (String data) {},
      ),
    );
  }
}