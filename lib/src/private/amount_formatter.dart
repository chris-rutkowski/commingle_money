// ignore_for_file: public_member_api_docs

abstract class AmountFormatter {
  static String formattedMain(int main, String separator) {
    final digits = main.abs().toString();
    final buffer = StringBuffer();

    final len = digits.length;
    for (var i = 0; i < len; i++) {
      if (i > 0 && (len - i) % 3 == 0) {
        buffer.write(separator);
      }
      buffer.write(digits[i]);
    }

    final formatted = buffer.toString();
    return main < 0 ? '-$formatted' : formatted;
  }
}
