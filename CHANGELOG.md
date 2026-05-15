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
