## 2.0.0

* New widget: `CommingleMoneyField`
* Ability to perform truncated quotient on `Money` instances like `money ~/ 10`
* Introduces Bitcoin currency
* Completes the list of `CurrencyCodes` for all available currencies
* Adds `include` filtering to `Currency.list`, making it possible to include or exclude currencies before sorting
* Bug fix: Correctly updates precision of `AmountEditingController` if the currency is changed
* Bug fix: Leading-decimal lazy input like `.01` is now parsed correctly by amount and money editing controllers

## 1.1.0

* Upgrade dependencies

## 1.0.0

* Initial version
