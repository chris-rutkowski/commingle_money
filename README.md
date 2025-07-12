# Commingle Money

A Flutter package for working with monetary values, open sourced from the [Commingle](https://commingle.app) app. It includes global currency definitions, widgets for displaying amounts, and input controllers for smooth, user-friendly editing.

## Money Label

<img src="https://github.com/chris-rutkowski/commingle_money/raw/main/readme_assets/money_label.gif" width="144" height="55" title="MoneyLabel demo"/>


`MoneyLabel` is a rich and flexible widget for presenting `Money` values. It supports:

- **Odometer-style animations** for amount changes
- Configurable **decimal behavior** - e.g. round, show when needed…
- Currency and negative sign display choice  
- Custom colors for positive, negative, and zero values
- Full control over **text styles**

```dart
MoneyLabel(
  money: Money(
    currencyCode: 'USD', 
    amount: Decimal.parse('1234.56')
  ),
  fractionalMode: MoneyLabelFractionalMode.flexible,
  displayCurrency: true,
  displayNegativeSign: true,
  separators: AmountFormatSeparatorsData(
    grouping: 
    decimal: 
  ),
  animation: MoneyLabelAnimation(
    duration: 
    curve: 
  ),
  primaryTextStyle: Theme.of(context).textTheme.bodyLarge,
  secondaryTextStyle: Theme.of(context).textTheme.bodySmall,
  positiveColor: Colors.green,
  negativeColor: Colors.red,
  zeroColor: Colors.grey
  primaryTextStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
)
```

You can wrap your app with the `MoneyLabelDefaults` inherited widget to provide default styles, colors, and behavior for all `MoneyLabel` instances.

## Money Editing Controller

<img src="https://github.com/chris-rutkowski/commingle_money/raw/main/readme_assets/money_editing_controller.gif" width="203" height="122" title="MoneyEditingController demo"/>


`MoneyEditingController` is a powerful controller you can assign to any `TextField` to handle monetary input with precision, formatting, and validation. It supports:

- Simple input
- Formula input - user can type `2+3(4-2)+5×1.5`
- Automatic rounding and formatting when unfocused

```dart
final controller = MoneyEditingController(
  currencyCode: CurrencyCodes.usd, // or "USD"
  amount: Decimal.parse("123.45"),
  separators: AmountFormatSeparatorsData(
    grouping: 
    decimal: 
  ),
);

TextField(
  controller: controller.textController,
  focusNode: controller.focusNode,
  keyboardType: const TextInputType.numberWithOptions(decimal: true),
)
```

You can listen to changes as the user types:

```dart
controller.addListener(() {
  final amount = controller.value;
  // your code
});
```

You can change the entire value or just a currency using `value` and `currencyCode` setters.

## Improvements
padding for money label
