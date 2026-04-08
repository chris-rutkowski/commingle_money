// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

import 'animated_character_role.dart';

final class AnimatedCharacter {
  final Key key;
  final AnimationController animationController;
  final AnimatedCharacterRole role;

  String character;
  double retiredLeading;

  AnimatedCharacter({
    required this.animationController,
    required this.role,
    required this.character,
    this.retiredLeading = 0,
  }) : key = UniqueKey();

  @override
  String toString() {
    return 'AnimatedCharacter($character - $role)';
  }
}
