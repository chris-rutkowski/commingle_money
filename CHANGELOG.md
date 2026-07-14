## 3.0.0

* **Breaking:** Replaced `package:decimal` with `package:big_decimal` throughout the library (models, controllers, widgets, and utilities).

This change was made after observing performance bottlenecks with `package:decimal` while processing large datasets in the Commingle app. In my benchmarks, some arithmetic operations, such as rounding, were measured to be up to 400× slower than their `BigDecimal` equivalents. For more details, see: https://github.com/a14n/dart-decimal/issues/122.

If your application still uses `package:decimal`, you can make the migration incrementally with the following conversion helpers:

```dart
import 'package:big_decimal/big_decimal.dart';
import 'package:decimal/decimal.dart';

BigDecimal decimalToBigDecimal(Decimal value) => BigDecimal.parse(value.toString());

Decimal bigDecimalToDecimal(BigDecimal value) {
  if (value is BigDecimalInfinity) {
    throw UnsupportedError('Cannot convert infinite BigDecimal to Decimal');
  }
  return Decimal.parse(value.toPlainString());
}
```

## 2.2.1

* `CommingleMoneyField`: stopped and invisible cursor no longer triggers continuous rebuilds, improving performance when the field is not focused

## 2.2.0

* `CommingleMoneyField`: add `CommingleMoneyFieldLayout` with compact and expanded trailing-suffix layouts
* Example app: add controls for switching `CommingleMoneyField` layout and field builder decoration

## 2.1.2

* `CommingleMoneyField`: allow arithmetic operators when the current value is zero while still ignoring operators for empty values

## 2.1.1

* `CommingleMoneyField`: fix affix appearance so prefix/suffix content does not animate on initial render and only animates on later visibility changes

## 2.1.0

* `CommingleMoneyField`: add `fieldBuilder` for wrapping the field content with custom widgets such as borders, containers, or decorators

## 2.0.5

* README additions.

## 2.0.4

* README additions.

## 2.0.3

* Example app: use locale-based separator detection on web and keep `LocalePlus` on non-web platforms

## 2.0.2

* Fix README rendering on pub.dev

## 2.0.1

* Fix README rendering on pub.dev

## 2.0.0

* New widget: `CommingleMoneyField`
* Ability to perform truncated quotient on `Money` instances like `money ~/ 10`
* Introduces Bitcoin currency
* Completes the list of `CurrencyCodes` for all available currencies
* Adds `include` filtering to `Currency.list`, making it possible to include or exclude currencies before sorting
* Bug fix: Correctly updates precision of `AmountEditingController` if the currency is changed
* Bug fix: Leading-decimal lazy input like `.01` is now parsed correctly by amount and money editing controllers
* Bug fix: Corrects currency precision for BND, CNY, IRR, MGA, MRU, SGD, and VES

## 1.1.0

* Upgrade dependencies

## 1.0.0

* Initial version
