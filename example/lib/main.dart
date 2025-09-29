import 'package:flutter/material.dart';
import 'package:onlinechatsdk/chat_view.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  late ChatView chat;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    String newCss = ".widget-header.draggable { display: none !important; }";

    // newCss = ".widget-header{display: none !important;}";

    // newCss = "div.widget-header.widget-header-color{pointer-events: none !important;opacity: 0 !important; height: 0 !important;padding-top: 0 !important;padding-bottom: 0 !important;}";
    newCss = "div.widget-header{display: none !important;}";

    // newCss = ".online-chat-root .widget-header-background { background-image: linear-gradient(90deg, #00c7c4, #000ea8) !important; }";
    // newCss = "div.onlineChatTextarea{ background: none !important; } .chatTab, div.chat-history-wrapper{background: url(https://maximumwallhd.com/wp-content/uploads/2015/07/fonds-ecran-ile-paradisique-15.jpg) !important; background-size: cover !important;}";

    newCss = "";

    chat = ChatView(
      id: "593adecd804fc4e32e7e865d659f2356",
      domain: "demo.ru",
      language: "ru",
      clientId: "",
      apiToken: "",
      css: newCss,
      onOperatorSendMessage: (String data) {},
      onClientSendMessage: (String data) {},
      onClientMakeSubscribe: (String data) {},
      onContactsUpdated: (String data) {},
      onSendRate: (String data) {},
      onClientId: (String data) {},
      onCloseSupport: () {},
      onFullyLoaded: (String data) {
        // chat.injectCss(newCss);
        chat.callJsSetClientInfo("{name: \"Имя\", email: \"test@mail.ru\"}");
        // chat.callJsSetClientInfo("{name: \"${it.name}\", email: \"${it.email}\", phone: \"${it.phone}\"}")
      },
      safeArea: true,
    );

    return MaterialApp(
      title: 'OnlineChatSdk-Flutter Demo',
      color: Colors.white,
      home: chat,
    );
  }
}