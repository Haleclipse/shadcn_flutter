import 'package:flutter_test/flutter_test.dart';
// Resizer is the layout engine behind ResizablePanel and is not exported.
import 'package:shadcn_flutter/src/resizer.dart';

/// The layout from issues #427 and #428: two collapsible panes with a plain
/// one between them. Dividers are numbered from 1, so divider 1 sits between
/// panes 0 and 1, and divider 2 between panes 1 and 2.
List<ResizableItem> panel({
  bool leftCollapsed = false,
  bool rightCollapsed = false,
}) => [
  ResizableItem(
    value: leftCollapsed ? 40 : 120,
    min: 100,
    collapsed: leftCollapsed,
    collapsedSize: 40,
  ),
  ResizableItem(value: leftCollapsed || rightCollapsed ? 480 : 400),
  ResizableItem(
    value: rightCollapsed ? 40 : 120,
    min: 100,
    collapsed: rightCollapsed,
    collapsedSize: 40,
  ),
];

/// Drags [divider] by [total] in 1px steps.
///
/// ResizablePanel makes one [Resizer] per gesture and feeds it
/// `DragUpdateDetails.primaryDelta`, so the thresholds only behave correctly
/// when the drag arrives incrementally.
void drag(List<ResizableItem> items, int divider, double total) {
  final resizer = Resizer(items);
  final step = total.isNegative ? -1.0 : 1.0;
  for (var i = 0; i < total.abs(); i++) {
    resizer.dragDivider(divider, step);
  }
}

void main() {
  // min 100, collapsedSize 40, collapseRatio 0.5, so a pane should resist for
  // (100 - 40) * 0.5 = 30px past its minimum before collapsing. Panes start at
  // 120, so 20px of the drag is taken up reaching the minimum.
  const slack = 20.0;
  const resistance = 30.0;

  group('collapse threshold', () {
    test('the leading pane resists before collapsing', () {
      final held = panel();
      drag(held, 1, -(slack + resistance - 5));
      expect(held[0].newCollapsed, isFalse);
      expect(held[0].newValue, 100);

      final collapsed = panel();
      drag(collapsed, 1, -(slack + resistance + 5));
      expect(collapsed[0].newCollapsed, isTrue);
    });

    test('the trailing pane resists by the same amount', () {
      // Regression for #427. This branch used the leading branch's negative
      // threshold, so the comparison was always true and the pane collapsed
      // the moment it reached its minimum.
      final held = panel();
      drag(held, 2, slack + resistance - 5);
      expect(held[2].newCollapsed, isFalse);
      expect(held[2].newValue, 100);

      final collapsed = panel();
      drag(collapsed, 2, slack + resistance + 5);
      expect(collapsed[2].newCollapsed, isTrue);
    });
  });

  group('expanding', () {
    test('dragging a divider away from its own collapsed pane expands it', () {
      final leading = panel(leftCollapsed: true);
      drag(leading, 1, 60);
      expect(leading[0].newCollapsed, isFalse);

      final trailing = panel(rightCollapsed: true);
      drag(trailing, 2, -60);
      expect(trailing[2].newCollapsed, isFalse);
    });

    test('collapsing one pane leaves a collapsed pane on the far side alone', () {
      // Regression for #428. The scan for something to expand walked past the
      // panes in between, so collapsing the leading pane expanded the trailing
      // one.
      for (final distance in [-60.0, -100.0, -200.0]) {
        final items = panel(rightCollapsed: true);
        drag(items, 1, distance);
        expect(
          items[2].newCollapsed,
          isTrue,
          reason:
              'trailing pane expanded after dragging divider 1 by $distance',
        );
      }
    });

    test('and the mirrored case', () {
      for (final distance in [60.0, 100.0, 200.0]) {
        final items = panel(leftCollapsed: true);
        drag(items, 2, distance);
        expect(
          items[0].newCollapsed,
          isTrue,
          reason: 'leading pane expanded after dragging divider 2 by $distance',
        );
      }
    });
  });

  test('a resize inside the limits moves both neighbours', () {
    final items = panel();
    drag(items, 1, 50);
    expect(items[0].newValue, 170);
    expect(items[1].newValue, 350);
    expect(items[2].newValue, 120);
    expect(items.every((i) => !i.newCollapsed), isTrue);
  });
}
