import 'package:flutter/material.dart' as sdk;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart' as material;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:shadcn_flutter_material/shadcn_flutter_material.dart';

/// Reports whether a [material.Material] ancestor is reachable from where it is
/// placed, recording the answer under [label].
final Map<String, bool> _found = <String, bool>{};

Widget _probe(String label) => Builder(
      builder: (context) {
        _found[label] =
            LookupBoundary.findAncestorWidgetOfExactType<material.Material>(
                    context) !=
                null;
        return const SizedBox.shrink();
      },
    );

void main() {
  setUp(_found.clear);

  group('MaterialShadcnApp provides a Material ancestor', () {
    testWidgets('to home', (tester) async {
      await tester.pumpWidget(MaterialShadcnApp(home: _probe('home')));
      expect(_found['home'], isTrue);
      expect(tester.takeException(), isNull);
    });

    testWidgets('to a named route', (tester) async {
      await tester.pumpWidget(
        MaterialShadcnApp(
          initialRoute: '/x',
          routes: {'/x': (_) => _probe('named')},
        ),
      );
      expect(_found['named'], isTrue);
    });

    testWidgets('to a pushed route', (tester) async {
      final key = GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        MaterialShadcnApp(navigatorKey: key, home: const SizedBox.shrink()),
      );
      key.currentState!
          .push(ShadcnPageRoute(builder: (_) => _probe('pushed')));
      await tester.pumpAndSettle();
      expect(_found['pushed'], isTrue);
    });

    testWidgets('through a caller-supplied builder', (tester) async {
      await tester.pumpWidget(
        MaterialShadcnApp(
          builder: (context, child) => child!,
          home: _probe('builder'),
        ),
      );
      expect(_found['builder'], isTrue);
    });

    // MaterialLayer is installed via ShadcnApp.surfaceBuilder precisely so that
    // it also covers ToastLayer, which sits above ShadcnApp.builder.
    testWidgets('inside a toast', (tester) async {
      late BuildContext ctx;
      await tester.pumpWidget(
        MaterialShadcnApp(
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
      // Let the auto-dismiss timer fire, so it does not outlive the test.
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
    });

    testWidgets('inside a shadcn dialog overlay', (tester) async {
      late BuildContext ctx;
      await tester.pumpWidget(
        MaterialShadcnApp(
          home: Builder(builder: (c) {
            ctx = c;
            return const SizedBox.shrink();
          }),
        ),
      );
      showOverlay(ctx, DialogConfiguration(), builder: (_) => _probe('dialog'));
      await tester.pumpAndSettle();
      expect(_found['dialog'], isTrue);
    });
  });

  testWidgets('MaterialLayer under a plain ShadcnApp works the same',
      (tester) async {
    await tester.pumpWidget(
      ShadcnApp(
        localizationsDelegates: kMaterialLocalizationsDelegates,
        builder: (context, child) => MaterialLayer(child: child!),
        home: _probe('layer'),
      ),
    );
    expect(_found['layer'], isTrue);
  });

  testWidgets('a material_ui TextField builds without asserting',
      (tester) async {
    await tester.pumpWidget(const MaterialShadcnApp(home: material.TextField()));
    expect(tester.takeException(), isNull);
  });

  // Regression guard for https://github.com/sunarya-thito/shadcn_flutter/issues/426.
  //
  // Flutter still ships package:flutter/material.dart, so an app upgrading to
  // 0.0.54 keeps compiling against it — but its Material is a different class
  // from material_ui's, and debugCheckHasMaterial only accepts its own. Nothing
  // shadcn_flutter_material provides can satisfy the SDK copy, so the fix is
  // migrating the import, and this test pins the behaviour so the docs stay
  // honest about it.
  testWidgets('an SDK flutter/material TextField cannot see material_ui Material',
      (tester) async {
    await tester.pumpWidget(const MaterialShadcnApp(home: sdk.TextField()));
    expect(
      tester.takeException(),
      isA<FlutterError>().having((e) => e.message, 'message',
          contains('No Material widget found')),
    );
  });
}
