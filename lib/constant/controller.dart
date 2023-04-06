import 'package:intl/intl.dart';
import 'package:pharmacy_employee/controller/app_controller.dart';

AppController appController = AppController.instance;

String convertCurrency(num number) {
  var formatter = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '₫',
  );
  return formatter.format(number);
}
