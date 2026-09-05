/// A small expression parser and evaluator.
///
/// shadcn_flutter used to reach for `package:expressions` to power
/// [TextInputFormatters.mathExpression], which lets a text field accept
/// `12*3+4` and settle on `40`. That package pulls in `petitparser`, `quiver`
/// and `rxdart` — three dependencies for one text formatter — so the grammar it
/// covers is reimplemented here instead, with no dependencies at all.
///
/// The syntax follows the same JavaScript-flavoured shape: number, string,
/// boolean and null literals; identifiers resolved against a context map;
/// member access, indexing and calls; the unary operators `-`, `+`, `!` and
/// `~`; the binary operators `||`, `&&`, `|`, `^`, `&`, `==`, `!=`, `<`, `>`,
/// `<=`, `>=`, `<<`, `>>`, `+`, `-`, `*`, `/` and `%`; and the `?:` conditional.
///
/// This is library-private to shadcn_flutter — it is deliberately not exported
/// from `shadcn_flutter.dart`.
library;

/// Thrown when a string cannot be parsed as an [Expression].
class ExpressionException implements Exception {
  /// Human-readable description of what went wrong.
  final String message;

  /// Offset into the source string where the problem was found.
  final int offset;

  /// Creates an [ExpressionException].
  const ExpressionException(this.message, this.offset);

  @override
  String toString() => 'ExpressionException: $message (at offset $offset)';
}

/// A parsed expression.
///
/// Build one with [Expression.parse], then hand it to
/// [ExpressionEvaluator.eval] together with a context map.
sealed class Expression {
  const Expression();

  /// Parses [input] into an [Expression].
  ///
  /// Throws [ExpressionException] if [input] is not a well-formed expression,
  /// including when it is empty or has trailing junk after a valid expression.
  factory Expression.parse(String input) {
    final parser = _Parser(_Lexer(input).tokenize());
    final expression = parser.parseExpression();
    parser.expectEnd();
    return expression;
  }
}

/// A literal value: a number, string, boolean, or null.
class Literal extends Expression {
  /// The value this literal evaluates to.
  final Object? value;

  /// Creates a [Literal].
  const Literal(this.value);

  @override
  String toString() => value is String ? '"$value"' : '$value';
}

/// A bare name, looked up in the evaluation context.
class Variable extends Expression {
  /// The identifier.
  final String name;

  /// Creates a [Variable].
  const Variable(this.name);

  @override
  String toString() => name;
}

/// A `target.property` access.
class MemberExpression extends Expression {
  /// The object being accessed.
  final Expression target;

  /// The property name.
  final String property;

  /// Creates a [MemberExpression].
  const MemberExpression(this.target, this.property);

  @override
  String toString() => '$target.$property';
}

/// A `target[index]` lookup.
class IndexExpression extends Expression {
  /// The object being indexed.
  final Expression target;

  /// The index.
  final Expression index;

  /// Creates an [IndexExpression].
  const IndexExpression(this.target, this.index);

  @override
  String toString() => '$target[$index]';
}

/// A `target(arguments)` call.
class CallExpression extends Expression {
  /// The callee.
  final Expression target;

  /// Positional arguments.
  final List<Expression> arguments;

  /// Creates a [CallExpression].
  const CallExpression(this.target, this.arguments);

  @override
  String toString() => '$target(${arguments.join(', ')})';
}

/// A prefix operator applied to one operand.
class UnaryExpression extends Expression {
  /// The operator: `-`, `+`, `!` or `~`.
  final String operator;

  /// The operand.
  final Expression argument;

  /// Creates a [UnaryExpression].
  const UnaryExpression(this.operator, this.argument);

  @override
  String toString() => '$operator$argument';
}

/// An infix operator applied to two operands.
class BinaryExpression extends Expression {
  /// The operator.
  final String operator;

  /// Left-hand operand.
  final Expression left;

  /// Right-hand operand.
  final Expression right;

  /// Creates a [BinaryExpression].
  const BinaryExpression(this.operator, this.left, this.right);

  @override
  String toString() => '($left $operator $right)';
}

/// A `[a, b, c]` list literal.
class ListExpression extends Expression {
  /// The element expressions, in order.
  final List<Expression> elements;

  /// Creates a [ListExpression].
  const ListExpression(this.elements);

  @override
  String toString() => '[${elements.join(', ')}]';
}

/// A `test ? consequent : alternate` conditional.
class ConditionalExpression extends Expression {
  /// The condition.
  final Expression test;

  /// Result when [test] is true.
  final Expression consequent;

  /// Result when [test] is false.
  final Expression alternate;

  /// Creates a [ConditionalExpression].
  const ConditionalExpression(this.test, this.consequent, this.alternate);

  @override
  String toString() => '($test ? $consequent : $alternate)';
}

/// Evaluates a parsed [Expression] against a context map.
///
/// Example:
/// ```dart
/// const evaluator = ExpressionEvaluator();
/// evaluator.eval(Expression.parse('width * 2'), {'width': 21}); // 42
/// ```
class ExpressionEvaluator {
  /// Creates an [ExpressionEvaluator].
  const ExpressionEvaluator();

  /// Evaluates [expression], resolving free identifiers through [context].
  ///
  /// Throws [ExpressionException] if the expression references a name that
  /// [context] does not define, or applies an operator to an unsupported type.
  Object? eval(Expression expression, Map<String, dynamic> context) {
    switch (expression) {
      case Literal():
        return expression.value;
      case Variable():
        if (!context.containsKey(expression.name)) {
          throw ExpressionException(
            'Undefined variable: ${expression.name}',
            0,
          );
        }
        return context[expression.name];
      case MemberExpression():
        final target = eval(expression.target, context);
        return _member(target, expression.property);
      case IndexExpression():
        final target = eval(expression.target, context);
        final index = eval(expression.index, context);
        if (target is List) {
          if (index is! int) {
            throw ExpressionException('List index must be an int', 0);
          }
          return target[index];
        }
        if (target is Map) return target[index];
        throw ExpressionException('Cannot index into $target', 0);
      case CallExpression():
        final target = eval(expression.target, context);
        final arguments = [
          for (final argument in expression.arguments) eval(argument, context),
        ];
        return Function.apply(target as Function, arguments);
      case UnaryExpression():
        return _unary(expression.operator, eval(expression.argument, context));
      case BinaryExpression():
        // Short-circuit before evaluating the right-hand side, so that
        // `a != null && a.b` behaves the way it reads.
        if (expression.operator == '&&') {
          return _truthy(eval(expression.left, context)) &&
              _truthy(eval(expression.right, context));
        }
        if (expression.operator == '||') {
          return _truthy(eval(expression.left, context)) ||
              _truthy(eval(expression.right, context));
        }
        return _binary(
          expression.operator,
          eval(expression.left, context),
          eval(expression.right, context),
        );
      case ListExpression():
        return [
          for (final element in expression.elements) eval(element, context),
        ];
      case ConditionalExpression():
        return _truthy(eval(expression.test, context))
            ? eval(expression.consequent, context)
            : eval(expression.alternate, context);
    }
  }

  static bool _truthy(Object? value) => value == true;

  static Object? _member(Object? target, String property) {
    if (target is Map) return target[property];
    // Enough of the common cases to be useful without mirrors.
    if (target is String) {
      switch (property) {
        case 'length':
          return target.length;
        case 'isEmpty':
          return target.isEmpty;
        case 'isNotEmpty':
          return target.isNotEmpty;
      }
    }
    if (target is Iterable) {
      switch (property) {
        case 'length':
          return target.length;
        case 'isEmpty':
          return target.isEmpty;
        case 'isNotEmpty':
          return target.isNotEmpty;
        case 'first':
          return target.first;
        case 'last':
          return target.last;
      }
    }
    throw ExpressionException('Cannot read "$property" of $target', 0);
  }

  static Object? _unary(String operator, Object? value) {
    switch (operator) {
      case '-':
        if (value is num) return -value;
        throw ExpressionException('Cannot negate $value', 0);
      case '+':
        if (value is num) return value;
        throw ExpressionException('Cannot apply unary + to $value', 0);
      case '!':
        return !_truthy(value);
      case '~':
        if (value is int) return ~value;
        throw ExpressionException('Cannot apply ~ to $value', 0);
    }
    throw ExpressionException('Unknown unary operator: $operator', 0);
  }

  static Object? _binary(String operator, Object? left, Object? right) {
    switch (operator) {
      case '==':
        return left == right;
      case '!=':
        return left != right;
      case '+':
        // Mirrors JavaScript loosely: numbers add, anything with a string
        // concatenates.
        if (left is num && right is num) return left + right;
        if (left is String || right is String) return '$left$right';
        if (left is List && right is List) return [...left, ...right];
        throw ExpressionException('Cannot add $left and $right', 0);
    }
    if (operator == '|' || operator == '^' || operator == '&') {
      if (left is int && right is int) {
        return switch (operator) {
          '|' => left | right,
          '^' => left ^ right,
          _ => left & right,
        };
      }
      throw ExpressionException(
        'Operator $operator requires int operands, got $left and $right',
        0,
      );
    }
    if (left is! num || right is! num) {
      throw ExpressionException(
        'Operator $operator requires num operands, got $left and $right',
        0,
      );
    }
    switch (operator) {
      case '<':
        return left < right;
      case '>':
        return left > right;
      case '<=':
        return left <= right;
      case '>=':
        return left >= right;
      case '-':
        return left - right;
      case '*':
        return left * right;
      case '/':
        return left / right;
      case '%':
        return left % right;
      case '<<':
      case '>>':
        if (left is int && right is int) {
          return operator == '<<' ? left << right : left >> right;
        }
        throw ExpressionException(
          'Operator $operator requires int operands, got $left and $right',
          0,
        );
    }
    throw ExpressionException('Unknown operator: $operator', 0);
  }
}

// ---------------------------------------------------------------------------
// Lexer
// ---------------------------------------------------------------------------

enum _TokenType { number, string, identifier, punctuator, end }

class _Token {
  final _TokenType type;
  final String value;
  final int offset;
  final Object? literal;

  const _Token(this.type, this.value, this.offset, [this.literal]);

  @override
  String toString() => '$type($value)';
}

/// Multi-character punctuators, longest first so that `<<` wins over `<`.
const List<String> _punctuators = [
  '===',
  '!==',
  '==',
  '!=',
  '<=',
  '>=',
  '&&',
  '||',
  '<<',
  '>>',
  '+',
  '-',
  '*',
  '/',
  '%',
  '<',
  '>',
  '!',
  '~',
  '&',
  '|',
  '^',
  '?',
  ':',
  '.',
  ',',
  '(',
  ')',
  '[',
  ']',
];

class _Lexer {
  final String input;
  int _offset = 0;

  _Lexer(this.input);

  List<_Token> tokenize() {
    final tokens = <_Token>[];
    while (true) {
      _skipWhitespace();
      if (_offset >= input.length) {
        tokens.add(_Token(_TokenType.end, '', _offset));
        return tokens;
      }
      tokens.add(_next());
    }
  }

  void _skipWhitespace() {
    while (_offset < input.length && _isWhitespace(input.codeUnitAt(_offset))) {
      _offset++;
    }
  }

  _Token _next() {
    final start = _offset;
    final code = input.codeUnitAt(_offset);
    if (_isDigit(code) ||
        (code == 0x2E /* . */ &&
            _offset + 1 < input.length &&
            _isDigit(input.codeUnitAt(_offset + 1)))) {
      return _readNumber(start);
    }
    if (code == 0x27 /* ' */ || code == 0x22 /* " */ ) {
      return _readString(start, code);
    }
    if (_isIdentifierStart(code)) return _readIdentifier(start);
    for (final punctuator in _punctuators) {
      if (input.startsWith(punctuator, _offset)) {
        _offset += punctuator.length;
        return _Token(_TokenType.punctuator, punctuator, start);
      }
    }
    throw ExpressionException(
      'Unexpected character "${input[_offset]}"',
      _offset,
    );
  }

  _Token _readNumber(int start) {
    while (_offset < input.length && _isDigit(input.codeUnitAt(_offset))) {
      _offset++;
    }
    var isDouble = false;
    if (_offset < input.length && input.codeUnitAt(_offset) == 0x2E /* . */ ) {
      isDouble = true;
      _offset++;
      while (_offset < input.length && _isDigit(input.codeUnitAt(_offset))) {
        _offset++;
      }
    }
    if (_offset < input.length &&
        (input.codeUnitAt(_offset) == 0x65 /* e */ ||
            input.codeUnitAt(_offset) == 0x45 /* E */ )) {
      final exponentStart = _offset;
      _offset++;
      if (_offset < input.length &&
          (input.codeUnitAt(_offset) == 0x2B /* + */ ||
              input.codeUnitAt(_offset) == 0x2D /* - */ )) {
        _offset++;
      }
      if (_offset < input.length && _isDigit(input.codeUnitAt(_offset))) {
        isDouble = true;
        while (_offset < input.length && _isDigit(input.codeUnitAt(_offset))) {
          _offset++;
        }
      } else {
        // Not an exponent after all — `2e` is a number followed by a name.
        _offset = exponentStart;
      }
    }
    final text = input.substring(start, _offset);
    final value = isDouble ? double.parse(text) : int.parse(text);
    return _Token(_TokenType.number, text, start, value);
  }

  _Token _readString(int start, int quote) {
    _offset++; // opening quote
    final buffer = StringBuffer();
    while (true) {
      if (_offset >= input.length) {
        throw ExpressionException('Unterminated string', start);
      }
      final code = input.codeUnitAt(_offset);
      if (code == quote) {
        _offset++;
        break;
      }
      if (code == 0x5C /* \ */ ) {
        _offset++;
        if (_offset >= input.length) {
          throw ExpressionException('Unterminated escape sequence', _offset);
        }
        buffer.write(switch (input[_offset]) {
          'n' => '\n',
          'r' => '\r',
          't' => '\t',
          'b' => '\b',
          'f' => '\f',
          'v' => '\v',
          final other => other,
        });
        _offset++;
        continue;
      }
      buffer.write(input[_offset]);
      _offset++;
    }
    return _Token(
      _TokenType.string,
      input.substring(start, _offset),
      start,
      buffer.toString(),
    );
  }

  _Token _readIdentifier(int start) {
    while (_offset < input.length &&
        _isIdentifierPart(input.codeUnitAt(_offset))) {
      _offset++;
    }
    return _Token(
      _TokenType.identifier,
      input.substring(start, _offset),
      start,
    );
  }

  static bool _isWhitespace(int code) =>
      code == 0x20 || code == 0x09 || code == 0x0A || code == 0x0D;

  static bool _isDigit(int code) => code >= 0x30 && code <= 0x39;

  static bool _isIdentifierStart(int code) =>
      (code >= 0x41 && code <= 0x5A) ||
      (code >= 0x61 && code <= 0x7A) ||
      code == 0x5F /* _ */ ||
      code == 0x24 /* $ */;

  static bool _isIdentifierPart(int code) =>
      _isIdentifierStart(code) || _isDigit(code);
}

// ---------------------------------------------------------------------------
// Parser
// ---------------------------------------------------------------------------

/// Binary operator precedence; higher binds tighter.
const Map<String, int> _precedence = {
  '||': 1,
  '&&': 2,
  '|': 3,
  '^': 4,
  '&': 5,
  '==': 6,
  '!=': 6,
  '===': 6,
  '!==': 6,
  '<': 7,
  '>': 7,
  '<=': 7,
  '>=': 7,
  '<<': 8,
  '>>': 8,
  '+': 9,
  '-': 9,
  '*': 10,
  '/': 10,
  '%': 10,
};

class _Parser {
  final List<_Token> tokens;
  int _index = 0;

  _Parser(this.tokens);

  _Token get _current => tokens[_index];

  bool _isPunctuator(String value) =>
      _current.type == _TokenType.punctuator && _current.value == value;

  void _expectPunctuator(String value) {
    if (!_isPunctuator(value)) {
      throw ExpressionException('Expected "$value"', _current.offset);
    }
    _index++;
  }

  void expectEnd() {
    if (_current.type != _TokenType.end) {
      throw ExpressionException(
        'Unexpected trailing input "${_current.value}"',
        _current.offset,
      );
    }
  }

  Expression parseExpression() => _parseConditional();

  Expression _parseConditional() {
    final test = _parseBinary(0);
    if (!_isPunctuator('?')) return test;
    _index++;
    final consequent = _parseConditional();
    _expectPunctuator(':');
    final alternate = _parseConditional();
    return ConditionalExpression(test, consequent, alternate);
  }

  Expression _parseBinary(int minPrecedence) {
    var left = _parseUnary();
    while (true) {
      if (_current.type != _TokenType.punctuator) return left;
      final precedence = _precedence[_current.value];
      if (precedence == null || precedence < minPrecedence) return left;
      // `===`/`!==` are accepted as aliases; Dart has no identity distinction
      // that is meaningful for these values.
      final operator = switch (_current.value) {
        '===' => '==',
        '!==' => '!=',
        final other => other,
      };
      _index++;
      final right = _parseBinary(precedence + 1);
      left = BinaryExpression(operator, left, right);
    }
  }

  Expression _parseUnary() {
    if (_current.type == _TokenType.punctuator &&
        const {'-', '+', '!', '~'}.contains(_current.value)) {
      final operator = _current.value;
      _index++;
      final argument = _parseUnary();
      // Fold `-3` into a literal so that negative numbers survive round-tripping.
      if (operator == '-' && argument is Literal && argument.value is num) {
        return Literal(-(argument.value as num));
      }
      return UnaryExpression(operator, argument);
    }
    return _parsePostfix();
  }

  Expression _parsePostfix() {
    var expression = _parsePrimary();
    while (true) {
      if (_isPunctuator('.')) {
        _index++;
        if (_current.type != _TokenType.identifier) {
          throw ExpressionException(
            'Expected a property name after "."',
            _current.offset,
          );
        }
        expression = MemberExpression(expression, _current.value);
        _index++;
      } else if (_isPunctuator('[')) {
        _index++;
        final index = parseExpression();
        _expectPunctuator(']');
        expression = IndexExpression(expression, index);
      } else if (_isPunctuator('(')) {
        _index++;
        final arguments = <Expression>[];
        if (!_isPunctuator(')')) {
          arguments.add(parseExpression());
          while (_isPunctuator(',')) {
            _index++;
            arguments.add(parseExpression());
          }
        }
        _expectPunctuator(')');
        expression = CallExpression(expression, arguments);
      } else {
        return expression;
      }
    }
  }

  Expression _parsePrimary() {
    final token = _current;
    switch (token.type) {
      case _TokenType.number:
      case _TokenType.string:
        _index++;
        return Literal(token.literal);
      case _TokenType.identifier:
        _index++;
        switch (token.value) {
          case 'true':
            return const Literal(true);
          case 'false':
            return const Literal(false);
          case 'null':
            return const Literal(null);
        }
        return Variable(token.value);
      case _TokenType.punctuator:
        if (token.value == '(') {
          _index++;
          final expression = parseExpression();
          _expectPunctuator(')');
          return expression;
        }
        if (token.value == '[') {
          _index++;
          final elements = <Expression>[];
          if (!_isPunctuator(']')) {
            elements.add(parseExpression());
            while (_isPunctuator(',')) {
              _index++;
              elements.add(parseExpression());
            }
          }
          _expectPunctuator(']');
          return ListExpression(elements);
        }
        throw ExpressionException(
          'Unexpected token "${token.value}"',
          token.offset,
        );
      case _TokenType.end:
        throw ExpressionException('Unexpected end of input', token.offset);
    }
  }
}
