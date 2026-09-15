import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_flutter/src/vendor/expressions/expressions.dart';

Object? eval(String source, [Map<String, dynamic> context = const {}]) {
  return const ExpressionEvaluator().eval(Expression.parse(source), context);
}

void main() {
  group('Expression.parse', () {
    test('parses integer and double literals', () {
      expect(eval('42'), 42);
      expect(eval('42'), isA<int>());
      expect(eval('4.5'), 4.5);
      expect(eval('.5'), 0.5);
      expect(eval('2e3'), 2000.0);
      expect(eval('2e-3'), 0.002);
    });

    test('treats a trailing e as a separate identifier, not an exponent', () {
      // `2e` is a number followed by a name, so parsing must fail on the junk
      // rather than silently reading `2e` as a number.
      expect(() => eval('2e'), throwsA(isA<ExpressionException>()));
    });

    test('parses string literals with escapes', () {
      expect(eval(r"'a\nb'"), 'a\nb');
      expect(eval('"it\'s"'), "it's");
      expect(eval(r'"say \"hi\""'), 'say "hi"');
    });

    test('parses keyword literals', () {
      expect(eval('true'), true);
      expect(eval('false'), false);
      expect(eval('null'), null);
    });

    test('rejects empty and malformed input', () {
      expect(() => eval(''), throwsA(isA<ExpressionException>()));
      expect(() => eval('1 +'), throwsA(isA<ExpressionException>()));
      expect(() => eval('1 2'), throwsA(isA<ExpressionException>()));
      expect(() => eval('(1'), throwsA(isA<ExpressionException>()));
      expect(() => eval('1 @ 2'), throwsA(isA<ExpressionException>()));
      expect(() => eval("'unterminated"), throwsA(isA<ExpressionException>()));
    });
  });

  group('arithmetic', () {
    test('honours operator precedence', () {
      expect(eval('2 + 3 * 4'), 14);
      expect(eval('(2 + 3) * 4'), 20);
      expect(eval('2 * 3 + 4 * 5'), 26);
      expect(eval('10 - 2 - 3'), 5); // left associative
      expect(eval('100 / 10 / 2'), 5.0);
      expect(eval('7 % 4'), 3);
    });

    test('handles unary operators', () {
      expect(eval('-3'), -3);
      expect(eval('- 3 + 5'), 2);
      expect(eval('-(2 + 3)'), -5);
      expect(eval('+4'), 4);
      expect(eval('!true'), false);
      expect(eval('~5'), -6);
      expect(eval('3 - -2'), 5);
    });

    test('divides to a double, matching Dart', () {
      expect(eval('7 / 2'), 3.5);
    });
  });

  group('comparison and logic', () {
    test('compares numbers', () {
      expect(eval('2 < 3'), true);
      expect(eval('3 <= 3'), true);
      expect(eval('4 > 5'), false);
      expect(eval('5 >= 5'), true);
      expect(eval('2 == 2'), true);
      expect(eval('2 != 2'), false);
      expect(eval('2 === 2'), true);
      expect(eval('2 !== 3'), true);
    });

    test('short-circuits && and ||', () {
      // `missing` is undefined, so evaluating the right side would throw.
      expect(eval('false && missing'), false);
      expect(eval('true || missing'), true);
      expect(() => eval('true && missing'), throwsA(isA<ExpressionException>()));
    });

    test('binds comparison tighter than logic', () {
      expect(eval('1 < 2 && 3 < 4'), true);
      expect(eval('1 > 2 || 3 < 4'), true);
    });

    test('evaluates conditionals', () {
      expect(eval('true ? 1 : 2'), 1);
      expect(eval('false ? 1 : 2'), 2);
      expect(eval('1 < 2 ? 10 * 2 : 0'), 20);
      // Right associative, like Dart and JavaScript.
      expect(eval('false ? 1 : true ? 2 : 3'), 2);
    });
  });

  group('context', () {
    test('resolves variables', () {
      expect(eval('width * 2', {'width': 21}), 42);
      expect(eval('a + b', {'a': 1, 'b': 2}), 3);
    });

    test('throws on an undefined variable', () {
      expect(() => eval('nope'), throwsA(isA<ExpressionException>()));
    });

    test('distinguishes a null value from an absent key', () {
      expect(eval('x', {'x': null}), null);
    });

    test('reads members, indices and calls', () {
      expect(eval('user.name', {'user': {'name': 'Ada'}}), 'Ada');
      expect(eval('items[1]', {'items': [10, 20, 30]}), 20);
      expect(eval("map['k']", {'map': {'k': 1}}), 1);
      expect(eval('"abc".length'), 3);
      expect(eval('double(4)', {'double': (int x) => x * 2}), 8);
      expect(eval('add(2, 3)', {'add': (int a, int b) => a + b}), 5);
    });

    test('builds list literals', () {
      expect(eval('[1, 2, 3]'), [1, 2, 3]);
      expect(eval('[]'), isEmpty);
      expect(eval('[a, 2]', {'a': 1}), [1, 2]);
    });
  });

  group('type errors', () {
    test('rejects arithmetic on non-numbers', () {
      expect(() => eval('true * 2'), throwsA(isA<ExpressionException>()));
      expect(() => eval('-null'), throwsA(isA<ExpressionException>()));
    });

    test('concatenates when either side is a string', () {
      expect(eval("'a' + 'b'"), 'ab');
      expect(eval("'n=' + 1"), 'n=1');
    });

    test('adds lists', () {
      expect(eval('[1] + [2]'), [1, 2]);
    });
  });
}
