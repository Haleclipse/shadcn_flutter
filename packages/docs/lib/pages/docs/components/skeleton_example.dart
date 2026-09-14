import 'package:docs/code_highlighter.dart';
import 'package:docs/pages/docs/components/skeleton/skeleton_example_1.dart';
import 'package:docs/pages/docs_page.dart';
import 'package:docs/pages/widget_usage_example.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../component_page.dart';

class SkeletonExample extends StatelessWidget {
  const SkeletonExample({super.key});

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      name: 'skeleton',
      description:
          'Skeleton is a placeholder for content that hasn\'t loaded yet.',
      displayName: 'Skeleton',
      children: [
        const Text(
          'Skeletons live in a separate package so that apps which never show a '
          'loading placeholder do not carry the dependency. Add it alongside '
          'shadcn_flutter:',
        ).p(),
        const CodeBlock(
          code: 'flutter pub add shadcn_flutter_skeletonizer',
          mode: 'shell',
        ).p(),
        const Text(
          'Wrap the app in a SkeletonizerLayer so the pulse follows your theme, '
          'then call asSkeleton on any widget. Use surfaceBuilder rather than '
          'builder: dialogs, toasts and popovers build outside builder and would '
          'not be covered.',
        ).p(),
        const CodeBlock(
          code:
              "import 'package:shadcn_flutter_skeletonizer/shadcn_flutter_skeletonizer.dart';\n"
              '\n'
              'ShadcnApp(\n'
              '  surfaceBuilder: (context, child) => SkeletonizerLayer(child: child),\n'
              '  home: const MyHomePage(),\n'
              ');',
          mode: 'dart',
        ).p(),
        const Alert(
          leading: Icon(LucideIcons.info),
          title: Text('Without the layer'),
          content: Text(
            'asSkeleton still works, but the pulse falls back to skeletonizer\'s '
            'own defaults instead of your color scheme.',
          ),
        ).p(),
        const Text('The package wraps ')
            .thenButton(
              child: const Text('https://pub.dev/packages/skeletonizer'),
              onPressed: () {
                openInNewTab('https://pub.dev/packages/skeletonizer');
              },
            )
            .thenText(
              ', and re-exports Bone and BoneMock for placeholder content of a '
              'realistic width.',
            )
            .p(),
        const WidgetUsageExample(
          title: 'Example',
          path: 'lib/pages/docs/components/skeleton/skeleton_example_1.dart',
          child: SkeletonExample1(),
        ),
        const Text(
          'Avatar and Image get leaf treatment automatically, since skeletonizer '
          'cannot walk their subtrees. Anything that should stay interactive '
          'inside a skeleton, such as a cancel button, takes ignoreSkeleton.',
        ).p(),
      ],
    );
  }
}
