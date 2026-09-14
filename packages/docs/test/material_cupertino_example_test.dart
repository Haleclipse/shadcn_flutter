import 'package:docs/pages/docs/components/material/cupertino_example_1.dart';
import 'package:docs/pages/docs/components/material/material_example_1.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cupertino_ui/cupertino_ui.dart' show CupertinoButton;
import 'package:material_ui/material_ui.dart' show Icons;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:shadcn_flutter_cupertino/shadcn_flutter_cupertino.dart';
import 'package:shadcn_flutter_material/shadcn_flutter_material.dart';

/// Hosts an example the way `main.dart` does: both delegate sets registered
/// app-wide and both interop layers installed over the whole surface, so that
/// routes pushed on the root navigator (showDialog, showCupertinoDialog) can
/// still find their theme and localizations.
Widget _host(Widget child) => ShadcnApp(
      localizationsDelegates: const [
        ...kMaterialLocalizationsDelegates,
        ...kCupertinoLocalizationsDelegates,
      ],
      surfaceBuilder: (context, surface) => MaterialLayer(
        localizations: false,
        child: CupertinoLayer(localizations: false, child: surface),
      ),
      home: child,
    );

void main() {
  testWidgets('Material example builds, increments and opens both dialogs',
      (tester) async {
    await tester.pumpWidget(_host(const MaterialExample1()));
    expect(tester.takeException(), isNull);

    // The counter starts at 0 and the FAB increments it. This is the bit that
    // silently did nothing before: showSnackBar threw for want of
    // MaterialLocalizations, so setState was never reached.
    expect(find.text('0'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    expect(find.text('1'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Open Material Dialog'));
    await tester.pumpAndSettle();
    expect(find.text('This is Material dialog'), findsOneWidget);
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open shadcn_flutter Dialog'));
    await tester.pumpAndSettle();
    expect(find.text('This is shadcn_flutter dialog'), findsOneWidget);
  });

  testWidgets('Cupertino example builds, increments and opens both dialogs',
      (tester) async {
    await tester.pumpWidget(_host(const CupertinoExample1()));
    expect(tester.takeException(), isNull);

    expect(find.text('0'), findsOneWidget);
    await tester.tap(find.byType(CupertinoButton));
    await tester.pumpAndSettle();
    expect(find.text('1'), findsOneWidget);

    await tester.tap(find.text('Open Cupertino Dialog'));
    await tester.pumpAndSettle();
    expect(find.text('This is Cupertino dialog'), findsOneWidget);
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open shadcn_flutter Dialog'));
    await tester.pumpAndSettle();
    expect(find.text('This is shadcn_flutter dialog'), findsOneWidget);
  });
}
