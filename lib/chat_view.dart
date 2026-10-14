import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'dart:ffi';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:onlinechatsdk/chat_api/chat_api.dart';
import 'package:onlinechatsdk/chat_api/chat_api_messages_wrapper_old.dart';
import 'package:onlinechatsdk/chat_api/chat_api_old.dart';
import 'package:onlinechatsdk/chat_api/models/chat_api_get_client_unread_message_count_response_model.dart';
import 'package:onlinechatsdk/chat_config.dart';
import 'package:onlinechatsdk/chat_date_time.dart';
import 'package:onlinechatsdk/command.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:collection';

String _widgetDomain = "";

class ChatView extends StatelessWidget {

  static Future<ChatApiGetClientUnreadMessageCountResponseModel> getUnreadMessagesCount() async {
    return (await ChatApi(
        orgId: await ChatConfig.getOrgId(),
        siteId: await ChatConfig.getSiteId(),
        clientId: await ChatConfig.getClientId()
    )).getClientUnreadMessageCount();
  }

  @Deprecated("")
  static Future<Map<String, dynamic>> _getUnreadedMessages({
    String startDate = '',
    required String apiToken
  }) async {
    var clientId = await ChatConfig.getClientId();
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

    var response = await ChatApiOld().messages(
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
    var resultWrapper = ChatApiMessagesWrapperOld(response);
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

  @Deprecated("")
  static Future<Map<String, dynamic>> getUnreadedMessages({
    required String apiToken
  }) async {
    return _getUnreadedMessages(
      apiToken: apiToken
    );
  }

  @Deprecated("")
  static Future<Map<String, dynamic>> getNewMessages({
    required String apiToken
  }) async {
    String startDate = await ChatConfig.getLastDateTimeNewMessage();
    Map<String, dynamic> result = await _getUnreadedMessages(
      apiToken: apiToken,
      startDate: startDate
    );
    ChatApiMessagesWrapperOld resultWrapper = ChatApiMessagesWrapperOld(result);
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
  final String _eventSiteId = "siteId";
  final String _eventCloseSupport = "closeSupport";
  final String _eventFullyLoaded = "fullyLoaded";
  final String _eventGetContacts = "getContacts";
  final String _eventUnreadedMessagesCountUpdated = "unreadedMessagesCountUpdated";

  final String _methodSetClientInfo = "setClientInfo";
  final String _methodSetTarget = "setTarget";
  final String _methodOpenReviewsTab = "openReviewsTab";
  final String _methodOpenTab = "openTab";
  final String _methodSendMessage = "sendMessage";
  final String _methodReceiveMessage = "receiveMessage";
  final String _methodSetOperator = "setOperator";
  final String _methodGetContacts = "getContacts";
  final String _methodGetClientId = "getClientId";
  final String _methodGetSiteId = "getSiteId";
  final String _methodDestroy = "destroy";
  final String _methodSetCallback = "setCallback";
  final String _methodAllMessagesRead = "allMessagesRead";

  final String id;
  final String domain;
  final String language;
  final String clientId;
  final String css;
  final bool safeArea;
  final bool isShowCloseButton;
  final void Function(List<dynamic> data) onOperatorSendMessage;
  final void Function(List<dynamic> data) onClientSendMessage;
  final void Function(String data) onClientMakeSubscribe;
  final void Function(String data) onContactsUpdated;
  final void Function(String data) onSendRate;
  final void Function(String data) onClientId;
  final void Function(List<dynamic> data) onUnreadedMessagesCountUpdated;
  final void Function() onCloseSupport;
  final void Function(String data) onFullyLoaded;
  final int textZoom;
  final _ChatViewController _controller = _ChatViewController();

  ChatView({
    super.key,
    required this.id,
    required this.domain,
    required this.language,
    required this.clientId,
    required this.css,
    this.safeArea = true,
    this.isShowCloseButton = true,
    required this.onOperatorSendMessage,
    required this.onClientSendMessage,
    required this.onClientMakeSubscribe,
    required this.onContactsUpdated,
    required this.onSendRate,
    required this.onClientId,
    required this.onUnreadedMessagesCountUpdated,
    required this.onCloseSupport,
    required this.onFullyLoaded,
    required this.textZoom,
  }) {
    _controller.settings = InAppWebViewSettings(
      useShouldOverrideUrlLoading: true,
      mediaPlaybackRequiresUserGesture: false,
      allowsInlineMediaPlayback: true,
      iframeAllow: "camera; microphone",
      iframeAllowFullscreen: true,
      textZoom: textZoom
    );
    ChatConfig.setOrgId(id);
    ChatConfig.setConfigString(key: 'apiToken', value: '');
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
    return 'https://${_widgetDomain}/json/anonymous/online/sdk/$id/'; //$domain${_getSetup()}
  }

  // only version 6.0
  WebUri _getWidgetUrlObj() {
    return  WebUri.uri( Uri.https(_widgetDomain, '/json/anonymous/online/sdk/$id/$domain', getSetupObj()) );
  }

  Future<String> _initWidgetDomain() async {
    _widgetDomain = await ChatApi(
      orgId: id,
      siteId: '',
      clientId: ''
    ).getDomain();
    return _widgetDomain;
  }

  @override
  Widget build(BuildContext context) {
    var _view = FutureBuilder(
      future: _initWidgetDomain(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          Future.delayed(Duration.zero, () {
            // print("------ error: ${snapshot.error.toString()}");
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

  Widget _getChatWidget() {
    var _widget = InAppWebView(
      initialUrlRequest: URLRequest(url: _getWidgetUrlObj()),  // only version 6.0
      // initialUrlRequest: URLRequest(url: _getWidgetUrlObj() ),
      initialUserScripts: UnmodifiableListView<UserScript>([]),
      initialSettings: _controller.settings,  // only version 6.0
      onWebViewCreated: (controller) async {
        _controller.webViewController = controller;
        _controller.webViewController!.addJavaScriptHandler(handlerName: 'channel_$_eventOperatorSendMessage', callback: (data) {
          onOperatorSendMessage( data );
        });
        _controller.webViewController!.addJavaScriptHandler(handlerName: 'channel_$_eventClientSendMessage', callback: (data) {
          onClientSendMessage( data );
        });
        _controller.webViewController!.addJavaScriptHandler(handlerName: 'channel_$_eventClientMakeSubscribe', callback: (data) {
          onClientMakeSubscribe( data.isNotEmpty ? data[0] : "" );
        });
        _controller.webViewController!.addJavaScriptHandler(handlerName: 'channel_$_eventContactsUpdated', callback: (data) {
          onContactsUpdated( data.isNotEmpty ? data[0].toString() : "" );
        });
        _controller.webViewController!.addJavaScriptHandler(handlerName: 'channel_$_eventSendRate', callback: (data) {
          onSendRate( data.isNotEmpty ? data[0] : "" );
        });
        _controller.webViewController!.addJavaScriptHandler(handlerName: 'channel_$_eventClientId', callback: (data) {
          if (data.isNotEmpty) {
            ChatConfig.setClientId(data[0]);
          }
          // ChatConfig.setApiToken(apiToken);
          onClientId( data.isNotEmpty ? data[0] : "" );
        });
        _controller.webViewController!.addJavaScriptHandler(handlerName: 'channel_$_eventSiteId', callback: (data) {
          if (data.isNotEmpty) {
            ChatConfig.setSiteId(data[0]);
          }
          // ChatConfig.setApiToken(apiToken);
          // onClientId( data.isNotEmpty ? data[0] : "" );
        });
        _controller.webViewController!.addJavaScriptHandler(handlerName: 'channel_$_eventCloseSupport', callback: (data) {
          _destroy();
        });
        _controller.webViewController!.addJavaScriptHandler(handlerName: 'channel_$_eventFullyLoaded', callback: (data) async {
          injectCss(css);
          onFullyLoaded( data.isNotEmpty ? data[0] : "" );
          callJsGetClientId();
          callJsGetSiteId();
        });
        _controller.webViewController!.addJavaScriptHandler(handlerName: 'channel_$_eventGetContacts', callback: (data) {
          if (_controller.onGetContacts != null) {
            _controller.onGetContacts!( data.isNotEmpty ? data[0] : "" );
            _controller.onGetContacts = null;
          }
        });
        _controller.webViewController!.addJavaScriptHandler(handlerName: 'channel_$_eventUnreadedMessagesCountUpdated', callback: (data) {
          onUnreadedMessagesCountUpdated( data );
        });
      },
      onLoadStart: (controller, url) async {
        _controller.webViewController = controller;
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
        _controller.webViewController = controller;
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
        _controller.webViewController = controller;
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
        _controller.webViewController = controller;
        // injectCss(css);
        await _callJs(_getScriptCallJs(['"$_methodSetCallback"', '"$_eventOperatorSendMessage"', 'function(data){window.flutter_inappwebview.callHandler("channel_$_eventOperatorSendMessage", data);}']));
        await _callJs(_getScriptCallJs(['"$_methodSetCallback"', '"$_eventClientSendMessage"', 'function(data){window.flutter_inappwebview.callHandler("channel_$_eventClientSendMessage", data);}']));
        await _callJs(_getScriptCallJs(['"$_methodSetCallback"', '"$_eventClientMakeSubscribe"', 'function(data){window.flutter_inappwebview.callHandler("channel_$_eventClientMakeSubscribe", data);}']));
        await _callJs(_getScriptCallJs(['"$_methodSetCallback"', '"$_eventContactsUpdated"', 'function(data){window.flutter_inappwebview.callHandler("channel_$_eventContactsUpdated", data);}']));
        await _callJs(_getScriptCallJs(['"$_methodSetCallback"', '"$_eventSendRate"', 'function(data){window.flutter_inappwebview.callHandler("channel_$_eventSendRate", data);}']));
        await _callJs(_getScriptCallJs(['"$_methodSetCallback"', '"$_eventCloseSupport"', 'function(data){window.flutter_inappwebview.callHandler("channel_$_eventCloseSupport", "");}']));
        await _callJs(_getScriptCallJs(['"$_methodSetCallback"', '"$_eventFullyLoaded"', 'function(data){window.flutter_inappwebview.callHandler("channel_$_eventFullyLoaded", "");}']));
        await _callJs(_getScriptCallJs(['"$_methodSetCallback"', '"$_eventUnreadedMessagesCountUpdated"', 'function(data){window.flutter_inappwebview.callHandler("channel_$_eventUnreadedMessagesCountUpdated", "");}']));
      },
      // onReceivedError: (controller, request, error) {
      //
      // },
      onProgressChanged: (controller, progress) {
        _controller.webViewController = controller;
      },
      onUpdateVisitedHistory: (controller, url, isReload) {
        _controller.webViewController = controller;
      },
      onConsoleMessage: (controller, consoleMessage) {
        _controller.webViewController = controller;
        // print(consoleMessage);
      },
    );

    return _widget;
  }

  void injectCss(String style) async {
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

    await _callJs(injectCssTemplate);
  }

  Future<void> _launchInBrowser(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {

    }
  }

  Future<bool> callJsSetClientInfo(String jsonInfo) async {
    return await _callJs(_getScriptCallJsMethod(_methodSetClientInfo, [Command(jsonInfo)]));
  }

  Future<bool> callJsSetTarget(String reason) async {
    return await _callJs(_getScriptCallJsMethod(_methodSetTarget, [reason]));
  }

  Future<bool> callJsOpenReviewsTab() async {
    return await _callJs(_getScriptCallJsMethod(_methodOpenReviewsTab, []));
  }

  Future<bool> callJsOpenTab(int index) async {
    return await _callJs(_getScriptCallJsMethod(_methodOpenTab, [index]));
  }

  Future<bool> callJsSendMessage(String text) async {
    return await _callJs(_getScriptCallJsMethod(_methodSendMessage, [text]));
  }

  Future<bool> callJsReceiveMessage(String text, String operator, int simulateTyping) async {
    return await _callJs(_getScriptCallJsMethod(_methodReceiveMessage, [text, operator, simulateTyping]));
  }

  Future<bool> callJsSetOperator(String login) async {
    return await _callJs(_getScriptCallJsMethod(_methodSetOperator, [login]));
  }

  Future<bool> callJsGetContacts(Function(String data) callback) async {
    _controller.onGetContacts = callback;
    return await _callJs(_getScriptCallJsMethod(_methodGetContacts, [Command('function(data){window.flutter_inappwebview.callHandler("channel_$_eventGetContacts", data);}')]));
  }

  Future<bool> callJsGetClientId() async {
    return await _callJs(_getScriptCallJsMethod(_methodGetClientId, [Command('function(data){window.flutter_inappwebview.callHandler("channel_$_eventClientId", data);}')]));
  }

  Future<bool> callJsGetSiteId() async {
    return await _callJs(_getScriptCallJsMethod(_methodGetSiteId, [Command('function(data){window.flutter_inappwebview.callHandler("channel_$_eventSiteId", data);}')]));
  }

  Future<bool> _callJsDestroy() async {
    return await _callJs(_getScriptCallJsMethod(_methodDestroy, []));
  }

  Future<bool> callJsAllMessagesRead() async {
    return await _callJs(_getScriptCallJsMethod(_methodAllMessagesRead, []));
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

  Future<bool> _callJs(String script) async {
    if (_controller.webViewController == null) {
      return false;
    }
    await _controller.webViewController?.evaluateJavascript(source: script);
    return true;
  }

  void _destroy() {
    if (_controller.destroyed) {
      return;
    }
    _controller.destroyed = true;
    _callJsDestroy();
    onCloseSupport();
  }
}

class _ChatViewController {
  late InAppWebViewSettings settings;
  InAppWebViewController? webViewController = null;
  InAppWebView? chatWebView = null;
  void Function(String data)? onGetContacts = null;
  var destroyed = false;
}