# Commingle Money

A Flutter package for working with monetary values, open sourced from the [Commingle](https://commingle.app) app. It includes global currency definitions, widgets for displaying amounts, input controllers for smooth, user-friendly editing and other monetary utilities.

##  Explore the Example App

Clone the repository and run the included Example app to see the library in action. The interactive demos let you explore features, validate their usefulness, and inspect the underlying implementation.

<img src="https://github.com/chris-rutkowski/commingle_money/raw/main/readme_assets/example_app.webp" width="830" height="434" title="MoneyLabel demo"/>

## 🏷️ Money Label

<img src="https://github.com/chris-rutkowski/commingle_money/raw/main/readme_assets/money_label.gif" width="144" height="55" title="MoneyLabel demo"/>

`MoneyLabel` is a rich and flexible widget for presenting `Money` values.

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

## 💳 Money Editing Controller

<img src="https://github.com/chris-rutkowski/commingle_money/raw/main/readme_assets/money_editing_controller.gif" width="203" height="122" title="MoneyEditingController demo"/>


`MoneyEditingController` is a powerful controller you can assign to any `TextField` to handle monetary input with precision, formatting, and validation. It supports:

- Simple input
- Formula input - user can type `2 + 3(4 - 2) ÷ 5 × 1.5`
- Automatic rounding and formatting when unfocused

```dart
final controller = MoneyEditingController(
  currencyCode: CurrencyCodes.usd, // or 'USD'
  amount: Decimal.parse('123.45'),
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

You can also set the value programmatically using `value` setter or to just change a currency  using `currencyCode` setter.

You can listen as the user types, e.g., to highlight the field in red or disable the save button based on the overall state:

```dart
controller.addListener(() {
  final state = controller.state;
  // handle: AmountEditingState.value, .empty, .zero, or .error
});
```

### 🔢 Amount Editing Controller

`AmountEditingController` is a lightweight alternative to `MoneyEditingController` that operates directly on `Decimal` values. It lets you control the desired precision without involving currency logic.

💡 `MoneyEditingController` is built on top of `AmountEditingController`.

## 💵 Money

`Money` is a simple yet powerful value class that combines a `currencyCode` with a `Decimal` amount.

```dart
Money(
  currencyCode: CurrencyCodes.usd, // or simply 'USD'
  amount: Decimal.parse('123.45'),
);
```

It provides utility methods like:

-  `rounded()`: 2.99 → 3 
-  `roundedToCurrencyPrecision()`: 2.567 → 2.57.

You can also use math operators directly: `+ – × ÷`. All operations return a new `Money` instance, rounded to the currency precision. You can combine `Money` values of the same currency with `int`, `double`, or `Decimal` values.


```dart
final usd1 = Money(currencyCode: 'USD', amount: Decimal.fromInt(1))
final usd2 = Money(currencyCode: 'USD', amount: Decimal.fromInt(2))

final total = usd1 + usd2 * 3 - 1 / 2; // = 6.5 USD
```

## 🌍 Currency

The library includes a comprehensive list of **155 worldwide currencies**, each with detailed metadata.

```dart
final usd = Currency.fromCode('USD');

// Result:
Currency(
  code: 'USD',
  precision: 2,
  emojiFlag: '🇺🇸',
  symbol: '$',
  englishName: 'United States Dollar',
  englishCountryNames: {
    'United States',
    'Ecuador',
    'El Salvador',
    'Panama',
    …
  },
),
```

You can retrieve all currencies using: `Currency.list()`, or filter them as user types:

```dart
Currency.list((c) => c.englishName.contains(searchQuery))
```

You can also use constants like `CurrencyCodes.chf` for quick access to a curated subset of popular currencies.

## 🧮 Decimal Utilities

`DecimalUtils` is an extension on `Decimal` that provides helpful utilities for rounding, scaling, and working with numeric data in a finance-friendly way.

- `round2()` rounds the decimal to two decimal places (unless `scale` is provided).
- `upperBound` and `lowerBound` help round values to chart-friendly boundaries,  
  e.g. `1234.56` → `1300` (upper), `1200` (lower).
- utility functions like `min`, `max`, and `sum`
- converters `Decimal` → `int` as well as `double` → `Decimal`

## ⚠️ Known Issues

Aligning `MoneyLabel` precisely to the baseline can be tricky. By design, the widget displays the currency symbol and decimal part using a smaller font than the main number.

I experimented with multiple approaches - `CrossAxisAlignment.baseline`, `RichText` and even low-level `TextPainter` font metrics. None produced fully reliable results across fonts settings, especially with the Odometer animation enabled.

As a workaround, the widget exposes `secondaryPadding` property that lets you manually tweak the top/bottom alignment of secondary elements. While not ideal, this gives you full control to fine-tune the appearance for your chosen font and style.

## 🙌 Acknowledgements

This library wouldn’t be possible without the excellent work of the Flutter community.

[decimal](https://pub.dev/packages/decimal), [equatable](https://pub.dev/packages/equatable), [expressions](https://pub.dev/packages/expressions), [animated_flip_counter](animated_flip_counter)

While not part of the core library, I recommend using [locale_plus](https://pub.dev/packages/locale_plus) like demonstrated in Example app.

## 🤝 Contributing

Contributions are very welcome! If you spot a bug, want to improve something, or add a feature, feel free to fork the repository and raise a pull request.

## 🎯 Trivia

- ✅ Tests coverage: >95%
- 📦 [Commingle Money on pub.dev](https://pub.dev/packages/commingle_money)
- 🛠 [Commingle Money on GitHub](https://github.com/chris-rutkowski/commingle_money)
- 📱 [Commingle App](https://commingle.app)
- 🧑‍💻 [My Linked In](https://www.linkedin.com/in/chris-rutkowski/)

## 📄 Copyright and License

**Commingle Money** is maintained by Chris Rutkowski as part of the [Commingle](https://commingle.app) app, and open-sourced under the MIT License.
