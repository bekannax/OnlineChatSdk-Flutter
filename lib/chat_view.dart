import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:onlinechatsdk/chat_config.dart';
import 'package:onlinechatsdk/command.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:collection';

class ChatView extends StatelessWidget {

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
  final String _methodDestroy = "destroy";
  final String _methodSetCallback = "setCallback";

  final String id;
  final String domain;
  final String language;
  final String clientId;
  final String apiToken;
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
    required this.onOperatorSendMessage,
    required this.onClientSendMessage,
    required this.onClientMakeSubscribe,
    required this.onContactsUpdated,
    required this.onSendRate,
    required this.onClientId,
    required this.onCloseSupport,
    required this.onFullyLoaded
  }) {
    // ChatConfig.setApiToken(apiToken);
  }

  String _getSetup() {
    StringBuffer result = StringBuffer();
    result.write('?');
    if (language.isNotEmpty) {
      result.write('setup={');
      result.write('"language":"$language"');
    }
    if (clientId.isNotEmpty) {
      if (result.isEmpty) {
        result.write('setup={');
      } else {
        result.write(',');
      }
      result.write('"clientId":"$clientId"');
    }
    if (result.isNotEmpty) {
      result.write('}');
      result.write('&');
    }
    result.write("sdk-show-close-button=1");
    return result.toString();
  }

  @override
  Widget build(BuildContext context) {
    _chatWebView = InAppWebView(
      initialUrlRequest:
      URLRequest(url: WebUri('https://admin.verbox.ru/support/chat/$id/$domain${_getSetup()}')),
      initialUserScripts: UnmodifiableListView<UserScript>([]),
      initialSettings: _settings,
      onWebViewCreated: (controller) async {
        _webViewController = controller;
        _webViewController!.addJavaScriptHandler(handlerName: 'channel_$_eventOperatorSendMessage', callback: (data) {
          onOperatorSendMessage(data[0]);
        });
        _webViewController!.addJavaScriptHandler(handlerName: 'channel_$_eventClientSendMessage', callback: (data) {
          onClientSendMessage(data[0]);
        });
        _webViewController!.addJavaScriptHandler(handlerName: 'channel_$_eventClientMakeSubscribe', callback: (data) {
          onClientMakeSubscribe(data[0]);
        });
        _webViewController!.addJavaScriptHandler(handlerName: 'channel_$_eventContactsUpdated', callback: (data) {
          onContactsUpdated(data[0]);
        });
        _webViewController!.addJavaScriptHandler(handlerName: 'channel_$_eventSendRate', callback: (data) {
          onSendRate(data[0]);
        });
        _webViewController!.addJavaScriptHandler(handlerName: 'channel_$_eventClientId', callback: (data) {
          // ChatConfig.setClientId(clientId)
          print("onClientId: ${data.toString()}");
          onClientId(data[0]);
        });
        _webViewController!.addJavaScriptHandler(handlerName: 'channel_$_eventCloseSupport', callback: (data) {
          _destroy();
        });
        _webViewController!.addJavaScriptHandler(handlerName: 'channel_$_eventFullyLoaded', callback: (data) {
          onFullyLoaded(data[0]);
        });
        _webViewController!.addJavaScriptHandler(handlerName: 'channel_$_eventGetContacts', callback: (data) {
          if (onGetContacts != null) {
            onGetContacts!(data[0]);
            onGetContacts = null;
          }
        });
      },
      onLoadStart: (controller, url) async {

      },
      onPermissionRequest: (controller, request) async {
        return PermissionResponse(
            resources: request.resources,
            action: PermissionResponseAction.GRANT);
      },
      shouldOverrideUrlLoading: (controller, navigationAction) async {
        if (navigationAction.request.url != null) {
          _launchInBrowser(navigationAction.request.url!);
        }
        return NavigationActionPolicy.CANCEL;
      },
      onLoadStop: (controller, url) async {
        _callJs(_getScriptCallJs(['"$_methodSetCallback"', '"$_eventClientId"', 'function(data){window.flutter_inappwebview.callHandler("channel_$_eventClientId", data);}']));
        _callJs(_getScriptCallJs(['"$_methodSetCallback"', '"$_eventOperatorSendMessage"', 'function(data){window.flutter_inappwebview.callHandler("channel_$_eventOperatorSendMessage", data);}']));
        _callJs(_getScriptCallJs(['"$_methodSetCallback"', '"$_eventClientSendMessage"', 'function(data){window.flutter_inappwebview.callHandler("channel_$_eventClientSendMessage", data);}']));
        _callJs(_getScriptCallJs(['"$_methodSetCallback"', '"$_eventClientMakeSubscribe"', 'function(data){window.flutter_inappwebview.callHandler("channel_$_eventClientMakeSubscribe", data);}']));
        _callJs(_getScriptCallJs(['"$_methodSetCallback"', '"$_eventContactsUpdated"', 'function(data){window.flutter_inappwebview.callHandler("channel_$_eventContactsUpdated", data);}']));
        _callJs(_getScriptCallJs(['"$_methodSetCallback"', '"$_eventSendRate"', 'function(data){window.flutter_inappwebview.callHandler("channel_$_eventSendRate", data);}']));
        _callJs(_getScriptCallJs(['"$_methodSetCallback"', '"$_eventCloseSupport"', 'function(data){window.flutter_inappwebview.callHandler("channel_$_eventCloseSupport", "");}']));
        _callJs(_getScriptCallJs(['"$_methodSetCallback"', '"$_eventFullyLoaded"', 'function(data){window.flutter_inappwebview.callHandler("channel_$_eventFullyLoaded", "");}']));
      },
      onReceivedError: (controller, request, error) {

      },
      onProgressChanged: (controller, progress) {

      },
      onUpdateVisitedHistory: (controller, url, isReload) {

      },
      onConsoleMessage: (controller, consoleMessage) {
        print(consoleMessage);
      },
    );


    return Container(
        padding: EdgeInsets.only(top: MediaQuery.of(context).viewPadding.top),
        child: _chatWebView
    );
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
    _callJs(_getScriptCallJsMethod(_methodGetContacts, [Command('function(data){channel_$_eventGetContacts.postMessage(data);}')]));
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