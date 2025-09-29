import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:onlinechatsdk/chat_api.dart';
import 'package:onlinechatsdk/chat_api_messages_wrapper.dart';
import 'package:onlinechatsdk/chat_config.dart';
import 'package:onlinechatsdk/chat_date_time.dart';
import 'package:onlinechatsdk/command.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:collection';

String _widgetDomain = "";

class ChatView extends StatelessWidget {

  static Future<Map<String, dynamic>> _getUnreadedMessages(String startDate) async {
    var clientId = await ChatConfig.getClientId();
    var apiToken = await ChatConfig.getApiToken();
    if (apiToken.isEmpty) {
      return {
        'success': false,
        'error': {
          'code': 0,
          'descr': 'Не задан token'
        }
      };
    }
    if (clientId.isEmpty) {
      return {
        'success': false,
        'error': {
          'code': 0,
          'descr': 'Не задан clientId'
        }
      };
    }

    final chatDateTime = ChatDateTime();
    if (startDate.isEmpty) {
      startDate = chatDateTime.current(-86400000 * 14);
    }

    var response = await ChatApi().messages(
      apiToken,
      {
        "client": {
          "clientId": clientId
        },
        "sender": "operator",
        "status": "unreaded",
        "dateRange": {
          "start": startDate,
          "stop": chatDateTime.current(0)
        }
      }
    );
    var resultWrapper = ChatApiMessagesWrapper(response);
    if (resultWrapper.getMessages().isEmpty) {
      return resultWrapper.getResult();
    }
    List<Map<String, dynamic>> unreadedMessages = [];
    resultWrapper.getMessages().forEach((element) {
      if (element["isVisibleForClient"] != null && element["isVisibleForClient"]) {
        unreadedMessages.add(element);
      }
    });
    resultWrapper.setMessages(unreadedMessages);
    return resultWrapper.getResult();
  }

  static Future<Map<String, dynamic>> getUnreadedMessages() async {
    return _getUnreadedMessages(
      '',
    );
  }

  static Future<Map<String, dynamic>> getNewMessages() async {
    String startDate = await ChatConfig.getLastDateTimeNewMessage();
    Map<String, dynamic> result = await _getUnreadedMessages(startDate);
    ChatApiMessagesWrapper resultWrapper = ChatApiMessagesWrapper(result);
    if (resultWrapper.getMessages().isEmpty) {
      ChatConfig.setLastDateTimeNewMessage( ChatDateTime().current(0) );
      return resultWrapper.getResult();
    }

    Map<String, dynamic> lastMessage = resultWrapper.getMessages()[resultWrapper.getMessages().length - 1];
    String lastDate = lastMessage['dateTime'];
    ChatConfig.setLastDateTimeNewMessage(
        ChatDateTime().getNextDate(lastDate)
    );
    return resultWrapper.getResult();
  }

  final String _eventOperatorSendMessage = "operatorSendMessage";
  final String _eventClientSendMessage = "clientSendMessage";
  final String _eventClientMakeSubscribe = "clientMakeSubscribe";
  final String _eventContactsUpdated = "contactsUpdated";
  final String _eventSendRate = "sendRate";
  final String _eventClientId = "clientId";
  final String _eventCloseSupport = "closeSupport";
  final String _eventFullyLoaded = "fullyLoaded";
  final String _eventGetContacts = "getContacts";

  final String _methodSetClientInfo = "setClientInfo";
  final String _methodSetTarget = "setTarget";
  final String _methodOpenReviewsTab = "openReviewsTab";
  final String _methodOpenTab = "openTab";
  final String _methodSendMessage = "sendMessage";
  final String _methodReceiveMessage = "receiveMessage";
  final String _methodSetOperator = "setOperator";
  final String _methodGetContacts = "getContacts";
  final String _methodGetClientId = "getClientId";
  final String _methodDestroy = "destroy";
  final String _methodSetCallback = "setCallback";

  final String id;
  final String domain;
  final String language;
  final String clientId;
  final String apiToken;
  final String css;
  final bool safeArea;
  final bool isShowCloseButton;
  final void Function(String data) onOperatorSendMessage;
  final void Function(String data) onClientSendMessage;
  final void Function(String data) onClientMakeSubscribe;
  final void Function(String data) onContactsUpdated;
  final void Function(String data) onSendRate;
  final void Function(String data) onClientId;
  final void Function() onCloseSupport;
  final void Function(String data) onFullyLoaded;
  void Function(String data)? onGetContacts = null;
  var destroyed = false;

  // only version 6.0
  final InAppWebViewSettings _settings = InAppWebViewSettings(
      useShouldOverrideUrlLoading: true,
      mediaPlaybackRequiresUserGesture: false,
      allowsInlineMediaPlayback: true,
      iframeAllow: "camera; microphone",
      iframeAllowFullscreen: true
  );

  InAppWebViewController? _webViewController;
  InAppWebView? _chatWebView;

  ChatView({
    super.key,
    required this.id,
    required this.domain,
    required this.language,
    required this.clientId,
    required this.apiToken,
          required this.css,
    this.safeArea = true,
    this.isShowCloseButton = true,
    required this.onOperatorSendMessage,
    required this.onClientSendMessage,
    required this.onClientMakeSubscribe,
    required this.onContactsUpdated,
    required this.onSendRate,
    required this.onClientId,
    required this.onCloseSupport,
    required this.onFullyLoaded
  }) {

  }

  // String _getSetup() {
  //   StringBuffer result = StringBuffer();
  //   result.write('?');
  //   if (language.isNotEmpty) {
  //     result.write('setup={');
  //     result.write('"language":"$language"');
  //   }
  //   if (clientId.isNotEmpty) {
  //     if (result.isEmpty) {
  //       result.write('setup={');
  //     } else {
  //       result.write(',');
  //     }
  //     result.write('"clientId":"$clientId"');
  //   }
  //   if (result.isNotEmpty) {
  //     result.write('}');
  //     result.write('&');
  //   }
  //   result.write("sdk-show-close-button=1");
  //   return result.toString();
  // }

  Map<String, dynamic> getSetupObj() {
    StringBuffer setup = StringBuffer();
    if (language.isNotEmpty) {
      setup.write('{');
      setup.write('"language":"$language"');
    }
    if (clientId.isNotEmpty) {
      if (setup.isEmpty) {
        setup.write('{');
      } else {
        setup.write(',');
      }
      setup.write('"clientId":"$clientId"');
    }
    if (setup.isNotEmpty) {
      setup.write('}');
      return {
        'setup': setup.toString(),
        'sdk-show-close-button': _isShowCloseButton()
      };
    }
    return {
      'sdk-show-close-button': _isShowCloseButton()
    };
  }

  String _isShowCloseButton() {
    if (isShowCloseButton) {
      return '1';
    }
    return '0';
  }

  String _getWidgetUrl() {
    return 'https://${_widgetDomain}/support/chat/$id/'; //$domain${_getSetup()}
  }

  // only version 6.0
  WebUri _getWidgetUrlObj() {
    return  WebUri.uri( Uri.https(_widgetDomain, '/support/chat/$id/$domain', getSetupObj()) );
  }

  Future<String> _initWidgetDomain() async {
    _widgetDomain = await ChatApi().getDomain();
    return _widgetDomain;
  }

  Widget _getChatWidget() {
    return InAppWebView(
      initialUrlRequest: URLRequest(url: _getWidgetUrlObj()),  // only version 6.0
      // initialUrlRequest: URLRequest(url: _getWidgetUrlObj() ),
      initialUserScripts: UnmodifiableListView<UserScript>([]),
      initialSettings: _settings,  // only version 6.0
      onWebViewCreated: (controller) async {
        _webViewController = controller;
        _webViewController!.addJavaScriptHandler(handlerName: 'channel_$_eventOperatorSendMessage', callback: (data) {
          onOperatorSendMessage( data.isNotEmpty ? data[0] : "" );
        });
        _webViewController!.addJavaScriptHandler(handlerName: 'channel_$_eventClientSendMessage', callback: (data) {
          onClientSendMessage( data.isNotEmpty ? data[0] : "" );
        });
        _webViewController!.addJavaScriptHandler(handlerName: 'channel_$_eventClientMakeSubscribe', callback: (data) {
          onClientMakeSubscribe( data.isNotEmpty ? data[0] : "" );
        });
        _webViewController!.addJavaScriptHandler(handlerName: 'channel_$_eventContactsUpdated', callback: (data) {
          onContactsUpdated( data.isNotEmpty ? data[0].toString() : "" );
        });
        _webViewController!.addJavaScriptHandler(handlerName: 'channel_$_eventSendRate', callback: (data) {
          onSendRate( data.isNotEmpty ? data[0] : "" );
        });
        _webViewController!.addJavaScriptHandler(handlerName: 'channel_$_eventClientId', callback: (data) {
          if (data.isNotEmpty) {
            ChatConfig.setClientId(data[0]);
          }
          ChatConfig.setApiToken(apiToken);
          onClientId( data.isNotEmpty ? data[0] : "" );
        });
        _webViewController!.addJavaScriptHandler(handlerName: 'channel_$_eventCloseSupport', callback: (data) {
          _destroy();
        });
        _webViewController!.addJavaScriptHandler(handlerName: 'channel_$_eventFullyLoaded', callback: (data) {
          injectCss(css);
          onFullyLoaded( data.isNotEmpty ? data[0] : "" );
          callJsGetClientId();
        });
        _webViewController!.addJavaScriptHandler(handlerName: 'channel_$_eventGetContacts', callback: (data) {
          if (onGetContacts != null) {
            onGetContacts!( data.isNotEmpty ? data[0] : "" );
            onGetContacts = null;
          }
        });
      },
      onLoadStart: (controller, url) async {

      },

      // onLoadError: (InAppWebViewController controller, Uri? url, int code, String message) async {
      //   print("onLoadError ------------ ");
      // },
      //
      // onLoadHttpError: (InAppWebViewController controller, Uri? url, int statusCode, String description) async {
      //   print("onLoadHttpError ------------ ");
      // },

      // only version 6.0
      onPermissionRequest: (controller, request) async {
        return PermissionResponse(
          resources: request.resources,
          action: PermissionResponseAction.GRANT);
      },

      // shouldOverrideUrlLoading: (controller, navigationAction) async {
      //   if (navigationAction.request.url != null) {
      //     _launchInBrowser(navigationAction.request.url!);
      //   }
      //   return NavigationActionPolicy.CANCEL;
      // },

      shouldOverrideUrlLoading: (controller, navigationAction) async {
        var uri = navigationAction.request.url!;
        if (uri.toString().contains( Uri.encodeFull( _getWidgetUrl() ) )) {
          return NavigationActionPolicy.ALLOW;
        }
        // if ([ _getWidgetUrl() ].contains(uri.toString())) {
        //   return NavigationActionPolicy.ALLOW;
        // }
        if (['http', 'https'].contains(uri.scheme)) {
          await _launchInBrowser(uri);
          return NavigationActionPolicy.CANCEL;
        } else if (!['file', 'chrome', 'data', 'javascript', 'about'].contains(uri.scheme)) {
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri);
            return NavigationActionPolicy.CANCEL;
          }
        }
        return NavigationActionPolicy.ALLOW;
      },

      onLoadStop: (controller, url) async {
        // injectCss(css);
        _callJs(_getScriptCallJs(['"$_methodSetCallback"', '"$_eventOperatorSendMessage"', 'function(data){window.flutter_inappwebview.callHandler("channel_$_eventOperatorSendMessage", data);}']));
        _callJs(_getScriptCallJs(['"$_methodSetCallback"', '"$_eventClientSendMessage"', 'function(data){window.flutter_inappwebview.callHandler("channel_$_eventClientSendMessage", data);}']));
        _callJs(_getScriptCallJs(['"$_methodSetCallback"', '"$_eventClientMakeSubscribe"', 'function(data){window.flutter_inappwebview.callHandler("channel_$_eventClientMakeSubscribe", data);}']));
        _callJs(_getScriptCallJs(['"$_methodSetCallback"', '"$_eventContactsUpdated"', 'function(data){window.flutter_inappwebview.callHandler("channel_$_eventContactsUpdated", data);}']));
        _callJs(_getScriptCallJs(['"$_methodSetCallback"', '"$_eventSendRate"', 'function(data){window.flutter_inappwebview.callHandler("channel_$_eventSendRate", data);}']));
        _callJs(_getScriptCallJs(['"$_methodSetCallback"', '"$_eventCloseSupport"', 'function(data){window.flutter_inappwebview.callHandler("channel_$_eventCloseSupport", "");}']));
        _callJs(_getScriptCallJs(['"$_methodSetCallback"', '"$_eventFullyLoaded"', 'function(data){window.flutter_inappwebview.callHandler("channel_$_eventFullyLoaded", "");}']));
      },
      // onReceivedError: (controller, request, error) {
      //
      // },
      onProgressChanged: (controller, progress) {

      },
      onUpdateVisitedHistory: (controller, url, isReload) {

      },
      onConsoleMessage: (controller, consoleMessage) {
        // print(consoleMessage);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var _view = FutureBuilder(
      future: _initWidgetDomain(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          Future.delayed(Duration.zero, () {
            showOkAlertDialog(
              context: context,
              title: "Error",
              message: snapshot.error.toString()
            ).then((value) {
              Navigator.of(context);
            });
          });
          return Scaffold(
            backgroundColor: Colors.white,
            body: Container()
          );
        } else if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else {
          return _getChatWidget();
        }
      },
    );
    Widget child = _view;
    if (safeArea) {
       child = SafeArea(
         child: child
       );
    }
    return Scaffold(
      backgroundColor: Colors.white,
      body: child
    );
  }

  void injectCss(String style) {
    if (style.isEmpty) {
      return;
    }

    String injectCssTemplate = "(function() {" +
        "var parent = document.getElementsByTagName('head').item(0);" +
        "var style = document.createElement('style');" +
        "style.type = 'text/css';" +
        "style.innerHTML = '$style';" +
        "parent.appendChild(style);" +
    "})()";

    _callJs(injectCssTemplate);
  }

  Future<void> _launchInBrowser(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {

    }
  }

  void callJsSetClientInfo(String jsonInfo) {
    _callJs(_getScriptCallJsMethod(_methodSetClientInfo, [Command(jsonInfo)]));
  }

  void callJsSetTarget(String reason) {
    _callJs(_getScriptCallJsMethod(_methodSetTarget, [reason]));
  }

  void callJsOpenReviewsTab() {
    _callJs(_getScriptCallJsMethod(_methodOpenReviewsTab, []));
  }

  void callJsOpenTab(int index) {
    _callJs(_getScriptCallJsMethod(_methodOpenTab, [index]));
  }

  void callJsSendMessage(String text) {
    _callJs(_getScriptCallJsMethod(_methodSendMessage, [text]));
  }

  void callJsReceiveMessage(String text, String operator, int simulateTyping) {
    _callJs(_getScriptCallJsMethod(_methodReceiveMessage, [text, operator, simulateTyping]));
  }

  void callJsSetOperator(String login) {
    _callJs(_getScriptCallJsMethod(_methodSetOperator, [login]));
  }

  void callJsGetContacts(Function(String data) callback) {
    onGetContacts = callback;
    _callJs(_getScriptCallJsMethod(_methodGetContacts, [Command('function(data){window.flutter_inappwebview.callHandler("channel_$_eventGetContacts", data);}')]));
  }

  void callJsGetClientId() {
    _callJs(_getScriptCallJsMethod(_methodGetClientId, [Command('function(data){window.flutter_inappwebview.callHandler("channel_$_eventClientId", data);}')]));
  }

  void _callJsDestroy() {
    _callJs(_getScriptCallJsMethod(_methodDestroy, []));
  }

  String _getScriptCallJsMethod(String method, List params) {
    List<dynamic> result = [
      '"$method"'
    ];
    params.forEach((element) {
      if (element == null) {
        result.add('"null"');
      } else if (element is int) {
        result.add(element);
      } else if (element is Long) {
        result.add(element);
      } else if (element is Command) {
        result.add(element.command);
      } else {
        result.add('"${element.toString()}"');
      }
    });
    return _getScriptCallJs(result);
  }

  String _getScriptCallJs(List params) {
    StringBuffer result = StringBuffer();
    result.write('window.MeTalk(');
    var first = true;
    params.forEach((params) {
      if (!first) {
        result.write(",");
      } else {
        first = false;
      }
      result.write(params);
    });
    result.write(");");
    return result.toString();
  }

  void _callJs(String script) {
    if (_webViewController == null) {
      return;
    }
    _webViewController?.evaluateJavascript(source: script);
  }

  void _destroy() {
    if (destroyed) {
      return;
    }
    destroyed = true;
    _callJsDestroy();
    onCloseSupport();
  }
}