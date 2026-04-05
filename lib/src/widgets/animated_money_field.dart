// ignore_for_file: public_member_api_docs

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../amount_format_separators.dart';

/// Arithmetic operators supported by [AnimatedMoneyField].
enum AnimatedMoneyFieldOperator {
  plus('+'),
  minus('-'),
  multiply('×'),
  divide('÷')
  ;

  const AnimatedMoneyFieldOperator(this.symbol);

  /// Symbol rendered inside the field.
  final String symbol;
}

/// Controller for [AnimatedMoneyField].
final class AnimatedMoneyFieldController extends ChangeNotifier {
  /// Maximum amount of fractional digits accepted by the field.
  final int decimalDigits;

  String _leftInput = '';
  AnimatedMoneyFieldOperator? _operator;
  String _rightInput = '';

  /// Creates a controller with optional [initialText].
  AnimatedMoneyFieldController({
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
  AnimatedMoneyFieldOperator? get operator => _operator;

  /// Raw text of the left operand.
  String get leftInput => _leftInput;

  /// Raw text of the right operand.
  String get rightInput => _rightInput;

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
  void applyOperator(AnimatedMoneyFieldOperator newOperator) {
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
    AnimatedMoneyFieldOperator operator,
    Decimal right,
  ) {
    return switch (operator) {
      AnimatedMoneyFieldOperator.plus => left + right,
      AnimatedMoneyFieldOperator.minus => left - right,
      AnimatedMoneyFieldOperator.multiply => left * right,
      AnimatedMoneyFieldOperator.divide =>
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
final class AnimatedMoneyField extends StatefulWidget {
  /// Currency text rendered before the number when there is no operator.
  final String currency;

  /// Maximum amount of digits after the decimal separator.
  final int decimalDigits;

  /// Focus node controlling the editing state.
  final FocusNode focusNode;

  /// Optional external controller.
  final AnimatedMoneyFieldController? controller;

  /// Optional style for the main amount text.
  final TextStyle? style;

  /// Optional style for the secondary text.
  final TextStyle? secondaryStyle;

  /// Optional color for placeholder parts such as `0` and trailing decimal zeroes.
  final Color? placeholderColor;

  const AnimatedMoneyField({
    super.key,
    this.currency = 'USD',
    this.decimalDigits = 2,
    required this.focusNode,
    this.controller,
    this.style,
    this.secondaryStyle,
    this.placeholderColor,
  });

  @override
  State<AnimatedMoneyField> createState() => _AnimatedMoneyFieldState();
}

final class _AnimatedMoneyFieldState extends State<AnimatedMoneyField> with SingleTickerProviderStateMixin {
  late final TextEditingController _hiddenTextController;
  late final AnimationController _cursorController;

  AnimatedMoneyFieldController? _internalController;

  AnimatedMoneyFieldController get _controller => widget.controller ?? _internalController!;

  @override
  void initState() {
    super.initState();

    _internalController = widget.controller == null
        ? AnimatedMoneyFieldController(decimalDigits: widget.decimalDigits)
        : null;

    assert(
      widget.controller == null || widget.controller!.decimalDigits == widget.decimalDigits,
      'AnimatedMoneyFieldController.decimalDigits must match AnimatedMoneyField.decimalDigits.',
    );

    _hiddenTextController = TextEditingController(text: _controller.rawEditingText);
    _cursorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _controller.addListener(_onControllerChange);
    widget.focusNode.addListener(_onFocusChanged);

    if (widget.focusNode.hasFocus) {
      _cursorController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedMoneyField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onControllerChange);
      _internalController?.removeListener(_onControllerChange);

      _internalController = widget.controller == null
          ? (_internalController ?? AnimatedMoneyFieldController(decimalDigits: widget.decimalDigits))
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
    final text = _controller.rawEditingText;

    if (_hiddenTextController.text == text && _hiddenTextController.selection.baseOffset == text.length) {
      return;
    }

    _hiddenTextController.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  void _onFocusChanged() {
    if (widget.focusNode.hasFocus) {
      _cursorController.repeat(reverse: true);
    } else {
      _cursorController.stop();
      _cursorController.value = 1;
    }

    setState(() {});
  }

  void _onHiddenTextChanged(String value) {
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
      child: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
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
      ),
    );
  }

  List<Widget> _buildChunks({
    required AnimatedMoneyFieldController controller,
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

    void addText({
      required String id,
      required String text,
      required TextStyle style,
    }) {
      if (text.isEmpty) return;
      widgets.add(
        _AnimatedMoneyChunk(
          id: id,
          text: text,
          style: style,
        ),
      );
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
      addText(
        id: 'currency',
        text: '$currency ',
        style: controller._leftInput.isEmpty ? placeholderSecondaryStyle : secondaryStyle,
      );
      addText(id: 'integer', text: left.integer, style: left.isPlaceholder ? placeholderStyle : mainStyle);
      addText(id: 'decimal', text: left.decimalSeparator, style: mainStyle);
      addText(id: 'fraction', text: left.fraction, style: mainStyle);
      addCursor();
      addText(
        id: 'fraction-placeholder',
        text: left.placeholderFraction,
        style: placeholderStyle,
      );
      return widgets;
    }

    if (controller._rightInput.isEmpty) {
      addText(id: 'left', text: left.fullTextOrZero, style: mainStyle);
      addText(id: 'operator', text: controller._operator!.symbol, style: mainStyle);
      addCursor();
      return widgets;
    }

    addText(
      id: 'expression-prefix',
      text: '${left.fullTextOrZero}${controller._operator!.symbol}${right.fullTextOrZero}',
      style: placeholderStyle,
    );
    addCursor();
    addText(id: 'equals', text: '=', style: placeholderStyle);
    addText(
      id: 'result',
      text: _FormattedOperand.fromRaw(
        raw: controller._formatResult(controller.value),
        separators: separators,
        decimalDigits: decimalDigits,
        placeholderWhenEmpty: false,
      ).fullTextOrZero,
      style: mainStyle,
    );

    return widgets;
  }
}

final _digitRegExp = RegExp(r'\d');

final class _AnimatedMoneyChunk extends StatelessWidget {
  final String id;
  final String text;
  final TextStyle style;

  const _AnimatedMoneyChunk({
    required this.id,
    required this.text,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
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
        text,
        key: ValueKey('$id:$text:${style.color}:${style.fontSize}'),
        style: style,
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
