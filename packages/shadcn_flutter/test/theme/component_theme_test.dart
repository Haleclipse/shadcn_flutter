import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../test_helper.dart';

/// Reports what `ComponentTheme.maybeOf<TrackerTheme>` sees at its position.
class _Probe extends StatelessWidget {
  final void Function(TrackerTheme?) onBuild;

  const _Probe(this.onBuild);

  @override
  Widget build(BuildContext context) {
    onBuild(ComponentTheme.maybeOf<TrackerTheme>(context));
    return const SizedBox.shrink();
  }
}

void main() {
  group('ComponentTheme.reset', () {
    testWidgets('hides an ancestor theme from the subtree', (tester) async {
      TrackerTheme? outer;
      TrackerTheme? inner;
      await tester.pumpWidget(
        SimpleApp(
          child: ComponentTheme(
            data: const TrackerTheme(itemHeight: 48),
            child: Column(
              children: [
                _Probe((t) => outer = t),
                ComponentTheme<TrackerTheme>.reset(
                  child: _Probe((t) => inner = t),
                ),
              ],
            ),
          ),
        ),
      );

      expect(outer, const TrackerTheme(itemHeight: 48));
      expect(inner, isNull);
    });

    testWidgets('a theme below a reset takes effect again', (tester) async {
      TrackerTheme? seen;
      await tester.pumpWidget(
        SimpleApp(
          child: ComponentTheme(
            data: const TrackerTheme(itemHeight: 48),
            child: ComponentTheme<TrackerTheme>.reset(
              child: ComponentTheme(
                data: const TrackerTheme(itemHeight: 12),
                child: _Probe((t) => seen = t),
              ),
            ),
          ),
        ),
      );

      expect(seen, const TrackerTheme(itemHeight: 12));
    });

    testWidgets('a reset component falls back to its built-in defaults', (
      tester,
    ) async {
      await tester.pumpWidget(
        SimpleApp(
          child: ComponentTheme(
            data: const TrackerTheme(itemHeight: 48),
            child: Column(
              children: [
                const Tracker(
                  data: [
                    TrackerData(tooltip: Text('a'), level: TrackerLevel.fine),
                  ],
                ),
                const Tracker(
                  data: [
                    TrackerData(tooltip: Text('b'), level: TrackerLevel.fine),
                  ],
                ).resetInheritedStyle(),
              ],
            ),
          ),
        ),
      );

      final heights = tester
          .widgetList<Container>(find.byType(Container))
          .map((c) => c.constraints?.maxHeight)
          .toList();
      // The themed tracker takes the ancestor's 48; the reset one falls back
      // to the component's own default of 32.
      expect(heights, containsAll(<double>[48, 32]));
    });
  });

  group('Styleable.theme', () {
    testWidgets('takes precedence over an ancestor theme', (tester) async {
      await tester.pumpWidget(
        SimpleApp(
          child: ComponentTheme(
            data: const TrackerTheme(itemHeight: 48),
            child: const Tracker(
              data: [TrackerData(tooltip: Text('a'), level: TrackerLevel.fine)],
              theme: TrackerTheme(itemHeight: 10),
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(Tracker),
              matching: find.byType(Container),
            )
            .first,
      );
      expect(container.constraints?.maxHeight, 10);
    });

    testWidgets('does not reach descendants', (tester) async {
      TrackerTheme? belowTracker;
      await tester.pumpWidget(
        SimpleApp(
          child: Column(
            children: [
              const Tracker(
                data: [
                  TrackerData(tooltip: Text('a'), level: TrackerLevel.fine),
                ],
                theme: TrackerTheme(itemHeight: 10),
              ),
              _Probe((t) => belowTracker = t),
            ],
          ),
        ),
      );

      // `theme:` is read as a plain field inside Tracker.build; it never enters
      // the tree as a ComponentTheme, so nothing else can observe it.
      expect(belowTracker, isNull);
    });

    testWidgets('inheritStyle covers the whole subtree, unlike theme:', (
      tester,
    ) async {
      CardTheme? underInheritStyle;
      CardTheme? underThemeArg;
      await tester.pumpWidget(
        SimpleApp(
          child: Column(
            children: [
              Card(
                child: Builder(
                  builder: (context) {
                    underInheritStyle = ComponentTheme.maybeOf<CardTheme>(
                      context,
                    );
                    return const SizedBox.shrink();
                  },
                ),
              ).inheritStyle(const CardTheme(borderWidth: 3)),
              Card(
                theme: const CardTheme(borderWidth: 3),
                child: Builder(
                  builder: (context) {
                    underThemeArg = ComponentTheme.maybeOf<CardTheme>(context);
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      );

      expect(
        underInheritStyle?.borderWidth,
        3,
        reason: 'inheritStyle wraps the subtree',
      );
      expect(underThemeArg, isNull, reason: 'theme: stays on the widget');
    });
  });
}
