// ignore_for_file: public_member_api_docs

enum AnimatedCharacterRole {
  placeholder,
  digit,
  groupingSeparator,
  decimalSeparator,
  fractionalDigit,
  fractionalPlaceholder,
  operator,
}

extension AnimatedCharacterRoleExtension on AnimatedCharacterRole {
  bool get isPlaceholder => this == .placeholder || this == .fractionalPlaceholder;
}
