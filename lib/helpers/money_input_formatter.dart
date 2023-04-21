import 'package:flutter/services.dart';

class ThreeZeroesInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Add "000" when the user inputs 3 digits
    if (newValue.text.length > 3 &&
        (newValue.text.length - oldValue.text.length) == 1) {
      String value = newValue.text;
      String lastThreeChars = value.substring(value.length - 3);
      if (lastThreeChars == "000") {
        return oldValue;
      } else {
        String newValueText =
            "${value.substring(0, value.length - 3)}000$lastThreeChars";
        return TextEditingValue(
          text: newValueText,
          selection: TextSelection.collapsed(
            offset: newValue.selection.end + 2,
          ),
        );
      }
    }

    return newValue;
  }
}
