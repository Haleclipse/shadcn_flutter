import 'package:cupertino_ui/cupertino_ui.dart' as cupertino;
import 'package:flutter/cupertino.dart' as sdk;
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:shadcn_flutter_cupertino/shadcn_flutter_cupertino.dart';

/// Records whether Cupertino localizations resolve where it is placed.
final Map<String, bool> _found = <String, bool>{};

Widget _probe(String label) => Builder(
      builder: (context) {
        _found[label] =
            Localizations.of<cupertino.CupertinoLocalizations>(
                    context, cupertino.CupertinoLocalizations) !=
                null;
        return const SizedBox.shrink();
      },
    );

void main() {
  setUp(_found.clear);

  testWidgets('CupertinoShadcnApp resolves Cupertino localizations on a page',
      (tester) async {
    await tester.pumpWidget(CupertinoShadcnApp(home: _probe('home')));
    expect(_found['home'], isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('CupertinoShadcnApp covers toasts too', (tester) async {
    late BuildContext ctx;
    await tester.pumpWidget(
      CupertinoShadcnApp(
        home: Builder(builder: (c) {
          ctx = c;
          return const SizedBox.shrink();
        }),
      ),
    );
    showToast(
      context: ctx,
      builder: (_, __) => _probe('toast'),
      showDuration: const Duration(milliseconds: 100),
    );
    await tester.pumpAndSettle();
    expect(_found['toast'], isTrue);
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
  });

  testWidgets('CupertinoLayer alone provides localizations to its subtree',
      (tester) async {
    await tester.pumpWidget(
      ShadcnApp(home: CupertinoLayer(child: _probe('layer'))),
    );
    expect(_found['layer'], isTrue);
  });

  testWidgets('a cupertino_ui date picker builds under CupertinoShadcnApp',
      (tester) async {
    await tester.pumpWidget(
      CupertinoShadcnApp(
        home: SizedBox(
          height: 300,
          child: cupertino.CupertinoDatePicker(onDateTimeChanged: (_) {}),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });

  // Regression guard for https://github.com/sunarya-thito/shadcn_flutter/issues/426:
  // package:flutter/cupertino.dart and package:cupertino_ui are separate
  // libraries with separate localization types, so the SDK copy cannot be
  // satisfied by anything this package installs.
  test('the two CupertinoLocalizations types differ', () {
    expect(
      cupertino.CupertinoLocalizations == sdk.CupertinoLocalizations,
      isFalse,
    );
  });
}
