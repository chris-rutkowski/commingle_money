/// Separators used for formatting and parsing amounts.
final class AmountFormatSeparators {
  /// The grouping separator, typically used for thousands, often a comma or space.
  final String grouping;

  /// The decimal separator, typically a dot or comma.
  final String decimal;

  /// Creates an instance of [AmountFormatSeparators] with the specified [grouping] and [decimal] separators.
  const AmountFormatSeparators({
    this.grouping = ',',
    this.decimal = '.',
  });

  /// Common format for the `pl_PL` locale where the grouping separator is a space
  /// and the decimal separator is a comma.
  factory AmountFormatSeparators.pl() => const AmountFormatSeparators(
    grouping: ' ',
    decimal: ',',
  );
}
