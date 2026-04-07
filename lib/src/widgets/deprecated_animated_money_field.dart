// ignore_for_file: public_member_api_docs

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../amount_format_separators.dart';

/// Arithmetic operators supported by [OldAnimatedMoneyField].
enum OldAnimatedMoneyFieldOperator {
  plus('+'),
  minus('-'),
  multiply('×'),
  divide('÷')
  ;

  const OldAnimatedMoneyFieldOperator(this.symbol);

  /// Symbol rendered inside the field.
  final String symbol;
}

/// Controller for [OldAnimatedMoneyField].
final class OldAnimatedMoneyFieldController extends ChangeNotifier {
  /// Maximum amount of fractional digits accepted by the field.
  final int decimalDigits;

  String _leftInput = '';
  OldAnimatedMoneyFieldOperator? _operator;
  String _rightInput = '';

  /// Creates a controller with optional [initialText].
  OldAnimatedMoneyFieldController({
    this.decimalDigits = 2,
    String initialText = '',
  }) {
    _leftInput = _sanitize(initialText);
  }

  /// Current evaluated value.
  Decimal get value {
    if (_operator != null && _rightInput.isNotEmpty) {
      return _evaluate(_parse(_leftInput), _operator!, _parse(_rightInput));
    }

    return _parse(_leftInput);
  }

  /// Current operator, if any.
  OldAnimatedMoneyFieldOperator? get operator => _operator;

  /// Raw text of the left operand.
  String get leftInput => _leftInput;

  /// Raw text of the right operand.
  String get rightInput => _rightInput;

  bool get hasPendingOperatorWithoutRightOperand => _operator != null && _rightInput.isEmpty;

  bool get _isEditingRightOperand => _operator != null;

  String get _activeInput => _isEditingRightOperand ? _rightInput : _leftInput;

  String get rawEditingText => _activeInput;

  void replaceEditingText(String text) {
    final sanitized = _sanitize(text);

    if (_isEditingRightOperand) {
      if (_rightInput == sanitized) return;
      _rightInput = sanitized;
    } else {
      if (_leftInput == sanitized) return;
      _leftInput = sanitized;
    }

    notifyListeners();
  }

  /// Applies an arithmetic operator to the current value.
  void applyOperator(OldAnimatedMoneyFieldOperator newOperator) {
    if (_operator != null && _rightInput.isNotEmpty) {
      final evaluated = _evaluate(_parse(_leftInput), _operator!, _parse(_rightInput));
      _leftInput = _formatResult(evaluated);
      _rightInput = '';
      _operator = newOperator;
      notifyListeners();
      return;
    }

    if (_operator == newOperator && _rightInput.isEmpty) {
      return;
    }

    _operator = newOperator;
    notifyListeners();
  }

  /// Removes the pending operator if there is no second operand yet.
  void clearPendingOperator() {
    if (!hasPendingOperatorWithoutRightOperand) return;
    _operator = null;
    notifyListeners();
  }

  /// Evaluates the current arithmetic expression, if any.
  void evaluate() {
    if (_operator == null) return;

    if (_rightInput.isEmpty) {
      _operator = null;
      notifyListeners();
      return;
    }

    final result = _evaluate(_parse(_leftInput), _operator!, _parse(_rightInput));

    _leftInput = _formatResult(result);
    _operator = null;
    _rightInput = '';
    notifyListeners();
  }

  String _sanitize(String raw) {
    if (raw.isEmpty) return '';

    final buffer = StringBuffer();
    var hasDecimal = false;
    var fractionLength = 0;

    for (final codePoint in raw.runes) {
      final character = String.fromCharCode(codePoint);

      if (_digitRegExp.hasMatch(character)) {
        if (!hasDecimal || fractionLength < decimalDigits) {
          buffer.write(character);
          if (hasDecimal) {
            fractionLength += 1;
          }
        }
        continue;
      }

      if (character == '.' && !hasDecimal && decimalDigits > 0) {
        if (buffer.isEmpty) {
          buffer.write('0');
        }
        buffer.write('.');
        hasDecimal = true;
      }
    }

    final value = buffer.toString();

    if (value.isEmpty) return '';

    final hasDot = value.contains('.');
    final parts = value.split('.');
    final integer = _normalizeInteger(parts.first, fallbackToZero: hasDot);
    final fraction = parts.length > 1 ? parts[1] : '';

    if (!hasDot) return integer;

    return '$integer.$fraction';
  }

  String _normalizeInteger(String raw, {required bool fallbackToZero}) {
    final trimmed = raw.replaceFirst(RegExp(r'^0+(?=\d)'), '');

    if (trimmed.isNotEmpty) return trimmed;

    return fallbackToZero ? '0' : '';
  }

  Decimal _parse(String raw) {
    if (raw.isEmpty) return Decimal.zero;
    if (raw.endsWith('.')) {
      return Decimal.parse(raw.substring(0, raw.length - 1));
    }
    return Decimal.parse(raw);
  }

  Decimal _evaluate(
    Decimal left,
    OldAnimatedMoneyFieldOperator operator,
    Decimal right,
  ) {
    return switch (operator) {
      OldAnimatedMoneyFieldOperator.plus => left + right,
      OldAnimatedMoneyFieldOperator.minus => left - right,
      OldAnimatedMoneyFieldOperator.multiply => left * right,
      OldAnimatedMoneyFieldOperator.divide =>
        right == Decimal.zero ? left : (left / right).toDecimal(scaleOnInfinitePrecision: decimalDigits),
    };
  }

  String _formatResult(Decimal value) {
    final rounded = value.round(scale: decimalDigits);
    final text = rounded.toString();

    if (!text.contains('.')) return text;

    return text.replaceFirst(RegExp(r'\.?0+$'), '');
  }
}

/// Centered money field with custom animations and simple arithmetic support.
final class OldAnimatedMoneyField extends StatefulWidget {
  /// Currency text rendered before the number when there is no operator.
  final String currency;

  /// Maximum amount of digits after the decimal separator.
  final int decimalDigits;

  /// Focus node controlling the editing state.
  final FocusNode focusNode;

  /// Optional external controller.
  final OldAnimatedMoneyFieldController? controller;

  /// Optional style for the main amount text.
  final TextStyle? style;

  /// Optional style for the secondary text.
  final TextStyle? secondaryStyle;

  /// Optional color for placeholder parts such as `0` and trailing decimal zeroes.
  final Color? placeholderColor;

  /// Duration of the cursor blinking cycle.
  final Duration cursorBlinkDuration;

  /// Duration used for visible field transitions.
  final Duration contentAnimationDuration;

  const OldAnimatedMoneyField({
    super.key,
    this.currency = 'USD',
    this.decimalDigits = 2,
    required this.focusNode,
    this.controller,
    this.style,
    this.secondaryStyle,
    this.placeholderColor,
    this.cursorBlinkDuration = const Duration(milliseconds: 700),
    this.contentAnimationDuration = const Duration(milliseconds: 550),
  });

  @override
  State<OldAnimatedMoneyField> createState() => _OldAnimatedMoneyFieldState();
}

final class _OldAnimatedMoneyFieldState extends State<OldAnimatedMoneyField> with SingleTickerProviderStateMixin {
  late final TextEditingController _hiddenTextController;
  late final AnimationController _cursorController;

  OldAnimatedMoneyFieldController? _internalController;
  static const _pendingOperatorBackspaceSentinel = '0';

  OldAnimatedMoneyFieldController get _controller => widget.controller ?? _internalController!;

  @override
  void initState() {
    super.initState();

    _internalController = widget.controller == null
        ? OldAnimatedMoneyFieldController(decimalDigits: widget.decimalDigits)
        : null;

    assert(
      widget.controller == null || widget.controller!.decimalDigits == widget.decimalDigits,
      'AnimatedMoneyFieldController.decimalDigits must match AnimatedMoneyField.decimalDigits.',
    );

    _hiddenTextController = TextEditingController(text: _controller.rawEditingText);
    _cursorController = AnimationController(
      vsync: this,
      duration: widget.cursorBlinkDuration,
    );

    _controller.addListener(_onControllerChange);
    widget.focusNode.addListener(_onFocusChanged);

    if (widget.focusNode.hasFocus) {
      _cursorController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant OldAnimatedMoneyField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.cursorBlinkDuration != widget.cursorBlinkDuration) {
      _cursorController.duration = widget.cursorBlinkDuration;
    }

    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onControllerChange);
      _internalController?.removeListener(_onControllerChange);

      _internalController = widget.controller == null
          ? (_internalController ?? OldAnimatedMoneyFieldController(decimalDigits: widget.decimalDigits))
          : null;

      assert(
        widget.controller == null || widget.controller!.decimalDigits == widget.decimalDigits,
        'AnimatedMoneyFieldController.decimalDigits must match AnimatedMoneyField.decimalDigits.',
      );

      _controller.addListener(_onControllerChange);
      _syncHiddenText();
    }

    if (oldWidget.focusNode != widget.focusNode) {
      oldWidget.focusNode.removeListener(_onFocusChanged);
      widget.focusNode.addListener(_onFocusChanged);
      _onFocusChanged();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChange);
    widget.focusNode.removeListener(_onFocusChanged);
    _hiddenTextController.dispose();
    _cursorController.dispose();
    _internalController?.dispose();
    super.dispose();
  }

  void _onControllerChange() {
    _syncHiddenText();
    setState(() {});
  }

  void _syncHiddenText() {
    final text = _controller.hasPendingOperatorWithoutRightOperand
        ? _pendingOperatorBackspaceSentinel
        : _controller.rawEditingText;
    final selection = _controller.hasPendingOperatorWithoutRightOperand
        ? const TextSelection(baseOffset: 0, extentOffset: 1)
        : TextSelection.collapsed(offset: text.length);

    if (_hiddenTextController.text == text && _hiddenTextController.selection == selection) {
      return;
    }

    _hiddenTextController.value = TextEditingValue(
      text: text,
      selection: selection,
    );
  }

  void _onFocusChanged() {
    if (widget.focusNode.hasFocus) {
      _cursorController.repeat(reverse: true);
    } else {
      _controller.evaluate();
      _cursorController.stop();
      _cursorController.value = 1;
    }

    setState(() {});
  }

  void _onHiddenTextChanged(String value) {
    if (_controller.hasPendingOperatorWithoutRightOperand && value.isEmpty) {
      _controller.clearPendingOperator();
      return;
    }

    _controller.replaceEditingText(value);
  }

  @override
  Widget build(BuildContext context) {
    final separators = AmountFormatSeparators.of(context);
    final theme = Theme.of(context);
    final mainStyle =
        widget.style ?? theme.textTheme.headlineMedium ?? DefaultTextStyle.of(context).style.copyWith(fontSize: 32);
    final secondaryStyle = widget.secondaryStyle ?? mainStyle.copyWith(fontSize: (mainStyle.fontSize ?? 32) * 0.78);
    final placeholderColor = widget.placeholderColor ?? theme.hintColor;
    final mainColor = mainStyle.color ?? DefaultTextStyle.of(context).style.color ?? theme.colorScheme.onSurface;

    final chunks = _buildChunks(
      controller: _controller,
      currency: widget.currency,
      separators: separators,
      decimalDigits: widget.decimalDigits,
      mainStyle: mainStyle.copyWith(color: mainColor),
      secondaryStyle: secondaryStyle.copyWith(color: mainColor.withValues(alpha: 0.88)),
      placeholderStyle: mainStyle.copyWith(color: placeholderColor),
      placeholderSecondaryStyle: secondaryStyle.copyWith(color: placeholderColor),
      cursorVisible: widget.focusNode.hasFocus,
      cursorAnimation: _cursorController,
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.focusNode.requestFocus,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: constraints.maxWidth,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: chunks,
                  ),
                ),
              ),
              Positioned(
                child: Opacity(
                  opacity: 0,
                  child: SizedBox(
                    width: 1,
                    height: 1,
                    child: TextField(
                      key: const Key('animated-money-field-hidden-input'),
                      controller: _hiddenTextController,
                      focusNode: widget.focusNode,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      textInputAction: TextInputAction.done,
                      enableInteractiveSelection: false,
                      showCursor: false,
                      decoration: const InputDecoration(border: InputBorder.none, isCollapsed: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                      ],
                      onChanged: _onHiddenTextChanged,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildChunks({
    required OldAnimatedMoneyFieldController controller,
    required String currency,
    required AmountFormatSeparatorsData separators,
    required int decimalDigits,
    required TextStyle mainStyle,
    required TextStyle secondaryStyle,
    required TextStyle placeholderStyle,
    required TextStyle placeholderSecondaryStyle,
    required bool cursorVisible,
    required Animation<double> cursorAnimation,
  }) {
    final left = _FormattedOperand.fromRaw(
      raw: controller._leftInput,
      separators: separators,
      decimalDigits: decimalDigits,
      placeholderWhenEmpty: controller._operator == null,
    );
    final right = _FormattedOperand.fromRaw(
      raw: controller._rightInput,
      separators: separators,
      decimalDigits: decimalDigits,
      placeholderWhenEmpty: false,
    );

    final widgets = <Widget>[];

    void addTokens(List<_MoneyTokenData> tokens) {
      for (final token in tokens) {
        widgets.add(
          _AnimatedMoneyToken(
            key: ValueKey(token.id),
            token: token,
            duration: widget.contentAnimationDuration,
          ),
        );
      }
    }

    void addCursor() {
      if (!cursorVisible) return;
      widgets.add(
        _BlinkingCursor(
          animation: cursorAnimation,
          color: mainStyle.color!,
          height: (mainStyle.fontSize ?? 32) * 1.06,
        ),
      );
    }

    if (controller._operator == null) {
      addTokens([
        _MoneyTokenData(
          id: 'currency',
          text: '$currency ',
          style: controller._leftInput.isEmpty ? placeholderSecondaryStyle : secondaryStyle,
        ),
        ...left.buildTokens(
          prefix: 'value',
          mainStyle: left.isPlaceholder ? placeholderStyle : mainStyle,
          placeholderStyle: placeholderStyle,
          includePlaceholderFraction: false,
        ),
      ]);
      addCursor();
      addTokens(left.buildPlaceholderFractionTokens(prefix: 'value', style: placeholderStyle));
      return widgets;
    }

    if (controller._rightInput.isEmpty) {
      addTokens([
        ...left.buildTokens(
          prefix: 'left',
          mainStyle: mainStyle,
          placeholderStyle: placeholderStyle,
        ),
        _MoneyTokenData(
          id: 'operator',
          text: controller._operator!.symbol,
          style: mainStyle,
        ),
      ]);
      addCursor();
      return widgets;
    }

    addTokens([
      ...left.buildTokens(
        prefix: 'expression-left',
        mainStyle: placeholderStyle,
        placeholderStyle: placeholderStyle,
      ),
      _MoneyTokenData(
        id: 'expression-operator',
        text: controller._operator!.symbol,
        style: placeholderStyle,
      ),
      ...right.buildTokens(
        prefix: 'expression-right',
        mainStyle: placeholderStyle,
        placeholderStyle: placeholderStyle,
        includePlaceholderFraction: false,
      ),
    ]);
    addCursor();
    addTokens([
      ...right.buildPlaceholderFractionTokens(
        prefix: 'expression-right',
        style: placeholderStyle,
      ),
      _MoneyTokenData(
        id: 'equals',
        text: '=',
        style: placeholderStyle,
      ),
      ..._FormattedOperand.fromRaw(
        raw: controller._formatResult(controller.value),
        separators: separators,
        decimalDigits: decimalDigits,
        placeholderWhenEmpty: false,
      ).buildTokens(
        prefix: 'result',
        mainStyle: mainStyle,
        placeholderStyle: placeholderStyle,
      ),
    ]);

    return widgets;
  }
}

final _digitRegExp = RegExp(r'\d');

final class _MoneyTokenData {
  final String id;
  final String text;
  final TextStyle style;

  const _MoneyTokenData({
    required this.id,
    required this.text,
    required this.style,
  });
}

final class _AnimatedMoneyToken extends StatefulWidget {
  final _MoneyTokenData token;
  final Duration duration;

  const _AnimatedMoneyToken({
    super.key,
    required this.token,
    required this.duration,
  });

  @override
  State<_AnimatedMoneyToken> createState() => _AnimatedMoneyTokenState();
}

final class _AnimatedMoneyTokenState extends State<_AnimatedMoneyToken> with SingleTickerProviderStateMixin {
  late final AnimationController _appearController;
  late final Animation<double> _appearAnimation;

  @override
  void initState() {
    super.initState();
    _appearController = AnimationController(vsync: this, duration: widget.duration);
    _appearAnimation = CurvedAnimation(parent: _appearController, curve: Curves.easeOutCubic);
    _appearController.forward();
  }

  @override
  void didUpdateWidget(covariant _AnimatedMoneyToken oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.duration != widget.duration) {
      _appearController.duration = widget.duration;
    }
  }

  @override
  void dispose() {
    _appearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _appearAnimation,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.86, end: 1).animate(_appearAnimation),
        child: AnimatedSwitcher(
          duration: widget.duration,
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          layoutBuilder: (currentChild, previousChildren) {
            return Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                ...previousChildren,
                ...?switch (currentChild) {
                  null => null,
                  final child => [child],
                },
              ],
            );
          },
          transitionBuilder: (child, animation) {
            final fade = CurvedAnimation(parent: animation, curve: Curves.easeOut);
            final scale = Tween<double>(begin: 0.86, end: 1).animate(fade);

            return FadeTransition(
              opacity: fade,
              child: ScaleTransition(
                scale: scale,
                child: child,
              ),
            );
          },
          child: Text(
            widget.token.text,
            key: ValueKey(
              '${widget.token.id}:${widget.token.text}:${widget.token.style.color}:${widget.token.style.fontSize}',
            ),
            style: widget.token.style,
          ),
        ),
      ),
    );
  }
}

final class _BlinkingCursor extends StatelessWidget {
  final Animation<double> animation;
  final Color color;
  final double height;

  const _BlinkingCursor({
    required this.animation,
    required this.color,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: Container(
        key: const Key('animated-money-field-cursor'),
        width: 2,
        height: height,
        margin: const EdgeInsets.symmetric(horizontal: 1),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }
}

final class _FormattedOperand {
  final String integer;
  final String decimalSeparator;
  final String fraction;
  final String placeholderFraction;
  final bool isPlaceholder;

  const _FormattedOperand({
    required this.integer,
    required this.decimalSeparator,
    required this.fraction,
    required this.placeholderFraction,
    required this.isPlaceholder,
  });

  String get fullTextOrZero => '$integer$decimalSeparator$fraction$placeholderFraction';

  List<_MoneyTokenData> buildTokens({
    required String prefix,
    required TextStyle mainStyle,
    required TextStyle placeholderStyle,
    bool includePlaceholderFraction = true,
  }) {
    return [
      ..._buildIntegerTokens(prefix: prefix, style: mainStyle),
      if (decimalSeparator.isNotEmpty)
        _MoneyTokenData(
          id: '$prefix-decimal',
          text: decimalSeparator,
          style: mainStyle,
        ),
      ..._buildFractionTokens(prefix: prefix, style: mainStyle),
      if (includePlaceholderFraction) ...buildPlaceholderFractionTokens(prefix: prefix, style: placeholderStyle),
    ];
  }

  List<_MoneyTokenData> buildPlaceholderFractionTokens({
    required String prefix,
    required TextStyle style,
  }) {
    return [
      for (var index = 0; index < placeholderFraction.length; index += 1)
        _MoneyTokenData(
          id: '$prefix-placeholder-$index',
          text: placeholderFraction[index],
          style: style,
        ),
    ];
  }

  List<_MoneyTokenData> _buildIntegerTokens({
    required String prefix,
    required TextStyle style,
  }) {
    final tokens = <_MoneyTokenData>[];
    var digitIndex = 0;

    for (var index = 0; index < integer.length; index += 1) {
      final character = integer[index];

      if (_digitRegExp.hasMatch(character)) {
        tokens.add(
          _MoneyTokenData(
            id: '$prefix-int-$digitIndex',
            text: character,
            style: style,
          ),
        );
        digitIndex += 1;
      } else {
        tokens.add(
          _MoneyTokenData(
            id: '$prefix-separator-after-${digitIndex - 1}',
            text: character,
            style: style,
          ),
        );
      }
    }

    return tokens;
  }

  List<_MoneyTokenData> _buildFractionTokens({
    required String prefix,
    required TextStyle style,
  }) {
    return [
      for (var index = 0; index < fraction.length; index += 1)
        _MoneyTokenData(
          id: '$prefix-frac-$index',
          text: fraction[index],
          style: style,
        ),
    ];
  }

  factory _FormattedOperand.fromRaw({
    required String raw,
    required AmountFormatSeparatorsData separators,
    required int decimalDigits,
    required bool placeholderWhenEmpty,
  }) {
    if (raw.isEmpty) {
      return _FormattedOperand(
        integer: '0',
        decimalSeparator: '',
        fraction: '',
        placeholderFraction: '',
        isPlaceholder: placeholderWhenEmpty,
      );
    }

    final parts = raw.split('.');
    final integer = _groupInteger(parts.first.isEmpty ? '0' : parts.first, separators.grouping);
    final hasDecimal = raw.contains('.');
    final fraction = parts.length > 1 ? parts[1] : '';
    final placeholderFraction = hasDecimal ? '0' * (decimalDigits - fraction.length) : '';

    return _FormattedOperand(
      integer: integer,
      decimalSeparator: hasDecimal ? separators.decimal : '',
      fraction: fraction,
      placeholderFraction: placeholderFraction,
      isPlaceholder: false,
    );
  }

  static String _groupInteger(String input, String separator) {
    return input.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}$separator',
    );
  }
}
