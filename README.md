# OnlineChatSdk-Flutter

## Добавление в проект
```groovy
onlinechatsdk:
    path: ./../OnlineChatSdk-Flutter-0.0.1
```

В SDK используется библиотека [flutter_inappwebview](https://github.com/pichillilorenzo/flutter_inappwebview) версии 6.0. Пока данная библиотека в pub.dev недоступа. Поэтому нужно скачать исходники с github и добавить её через path:

```groovy
flutter_inappwebview:
    path: ./../flutter_inappwebview-6.0.0-beta.12
```

## Получение id
Перейдите в раздел «Online чат - Ваш сайт - Настройки - Установка» и скопируйте значение переменной id.
![](https://github.com/bekannax/OnlineChatSdk-Android/blob/master/images/2019-03-21_16-53-28.png?raw=true)

## Пример использования
```dart
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OnlineChatSdk-Flutter Demo',
      home: ChatView(
        id: "<Ваш id>",
        domain: "<Домен вашего сайта>",
        language: "ru",
        clientId: "",
        apiToken: "<Токен для доступа к Rest Api>",
        onOperatorSendMessage: (String data) {}, //  оператор отправил сообщение посетителю.
        onClientSendMessage: (String data) {}, // посетитель отправил сообщение оператору
        onClientMakeSubscribe: (String data) {}, // посетитель заполнил форму
        onContactsUpdated: (String data) {}, // посетитель обновил информацию о себе
        onSendRate: (String data) {}, //  посетитель отправил новый отзыв
        onClientId: (String data) {}, //  уникальный идентификатор посетителя
        onCloseSupport: () {}, // пользователь закрыл виджет
        onFullyLoaded: (String data) {}, // видлжет загружен и готов к работае
      ),
    );
  }
```
## Методы
 * **setClientInfo** - изменение информации о посетителе.
 * **setTarget** - пометить посетителя целевым.
 * **openReviewsTab** - отобразить форму для отзыва.
 * **openTab** - отобразить необходимую вкладку.
 * **sendMessage** - отправка сообщения от имени клиента.
 * **receiveMessage** - отправка сообщения от имени оператора.
 * **setOperator** - выбор любого оператора.
 * **getContacts** - получение контактных данных.

```java
chatView.callJsSetClientInfo("{name: \"Имя\", email: \"test@mail.ru\"}");

chatView.callJsSetTarget("reason");

chatView.callJsOpenReviewsTab();

chatView.callJsOpenTab(1);

chatView.callJsSendMessage("Здравствуйте! У меня серьёзная проблема!");

chatView.callJsReceiveMessage("Мы уже спешим на помощь ;)", null, 2000);

chatView.callJsSetOperator("Логин оператора");

chatView.callJsGetContacts(
    (data) => {
    }
);
```
Подробное описание методов можно прочесть в разделе «Интеграция и API - Javascript API».

## Получение token
Перейдите в раздел «Интеграция и API - REST API», скопируйте существующий token или добавьте новый.
![](https://github.com/bekannax/OnlineChatSdk-Android/blob/master/images/2022-11-11_20-54-36.png?raw=true)

## Получение новых сообщений от оператора
Для получения новых сообщений, в `ChatView` есть два статичных метода **getUnreadedMessages** и **getNewMessages**.

**getUnreadedMessages** - возвращает все непрочитанные сообщения.

**getNewMessages** работает аналогичным образом, но при повторном запросе предыдущие сообщения уже не возвращаются.
Перед использование методов, нужно указать `apiToken`.

```java
Map<String, dynamic> data = await ChatView.getNewMessages();
Map<String, dynamic> data = await ChatView.getUnreadedMessages();
```
Формат `data` аналогичен ответу метода /chat/message/getList в Rest Api.

Подробное описание можно прочесть в разделе «Интеграция и API - REST API - Инструкции по подключению».

![](https://github.com/bekannax/OnlineChatSdk-Android/blob/master/images/2022-11-11_20-55-08.png?raw=true)