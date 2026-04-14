# Commingle Money

A Flutter package for working with monetary values, open sourced from the [**Commingle**](https://commingle.app) app available for [**iOS**](https://apps.apple.com/us/app/commingle/id6499095807) and [**Android**](https://play.google.com/store/apps/details?id=com.commingle.android). It includes global currency definitions, widgets for displaying amounts, input controllers for smooth, user-friendly editing and other monetary utilities.

<p>
  <a href="https://apps.apple.com/us/app/commingle/id6499095807">
    <img src="readme_assets/download-on-the-app-store.png" height="56" alt="Download on the App Store"/>
  </a>&nbsp;&nbsp;&nbsp;
  <a href="https://play.google.com/store/apps/details?id=com.commingle.android">
    <img src="readme_assets/get-it-on-google-play.png" height="56" alt="Get it on Google Play"/>
  </a>
</p>

## Commingle Money Field

<img src="https://github.com/chris-rutkowski/commingle_money/raw/main/readme_assets/commingle_money_field.gif" width="480" height="150" title="Commingle Money Field demo"/>

Watch the high-quality demo on [🎬 **YouTube** ](https://www.youtube.com/shorts/M9rzUIVGEg4) (1 min).

A highly polished monetary input field with support for grouping separators, rounding, and basic arithmetic operations.

```dart

// Create a controller with currency and optional initial amount.
final controller = MoneyEditingController(
  currencyCode: CurrencyCodes.usd,
  amount: Decimal.parse('123.45'), // optional
);

// Add Commingle Money Field to your widget tree
CommingleMoneyField(
  placeholder: 'amount',
  controller: controller,
  prefix: CurrencyButton( // Your custom button widget
    currencyCode: controller.currencyCode,
    onTap: (currencyCode) {
      controller.currencyCode = currencyCode;
    },
  ),
),

// And optionally provide your arithmetic functions UI
ElevatedButton(
  onPressed: () => controller.mathOperatorDispatcher.dispatch(.plus),
  child: Text('+'),
),
```

Customise the field with your own prefix/suffix, animation style and duration, and text styling to match your use case.

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
-  `abs()`

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

## 🤝 Support Commingle Money

If you find **Commingle Money** valuable, consider supporting its continued development:

<a href="https://www.buymeacoffee.com/chrisrkw" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" height="60"></a>

## 📄 Copyright and License

**Commingle Money** is maintained by Chris Rutkowski as part of the [**Commingle**](https://commingle.app) app, and open-sourced under the MIT License.
