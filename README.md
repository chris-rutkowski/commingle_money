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

## Improvements
padding for money label
