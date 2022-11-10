import 'package:intl/intl.dart';

class ChatDateTime {

  final millseconds3hour = 3600000 * 3;
  final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

  String current(int millseconds) {
    // formatter.format( DateTime.fromMillisecondsSinceEpoch(DateTime.now().millisecondsSinceEpoch + 3600000 * 3 - 86400000 * 14) )
    return dateFormat.format( DateTime.fromMillisecondsSinceEpoch(DateTime.now().millisecondsSinceEpoch + millseconds3hour + millseconds) );
  }

  String getNextDate(String inputString) {
    return dateFormat.format( DateTime.fromMillisecondsSinceEpoch( (dateFormat.parse(inputString)).millisecondsSinceEpoch + 10000 ) );
  }
}