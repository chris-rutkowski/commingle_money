import 'amount_editing_controller.dart';

/// Overview of semantic state of an [AmountEditingController]'s input.
enum AmountEditingState {
  /// Field has a non-zero, non-empty value.
  value,

  /// Field is empty.
  empty,

  /// Field has a zero value.
  zero,

  /// Field has an error, usually due to math evaluation error.
  error,
}
