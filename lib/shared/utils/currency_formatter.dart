import 'package:intl/intl.dart';

extension RupeesFormatter on num {
  String inRupeesFormat({
    String currencyCode = "INR",
    String currencyLocale = "en-IN",
    bool isWithSymbol = true,
  }) {
    return NumberFormat.currency(
      locale: currencyLocale,
      name: currencyCode,
      //symbol:"${NumberFormat().simpleCurrencySymbol(currencyCode)} ",
      symbol: isWithSymbol
          ? "${NumberFormat().simpleCurrencySymbol(currencyCode)} "
          : "",
      decimalDigits: 0, // change it to get decimal places
    ).format(this);
    //return indianRupeesFormat.format(this);
  }
}
