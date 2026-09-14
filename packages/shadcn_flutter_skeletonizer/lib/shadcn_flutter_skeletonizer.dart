/// Skeleton loading effects for shadcn_flutter.
///
/// `package:shadcn_flutter` no longer depends on `package:skeletonizer` — the
/// skeleton components live here instead, so apps that never show a loading
/// placeholder do not pay for the dependency.
///
/// Wrap the app in a [SkeletonizerLayer] so the pulse follows the shadcn theme,
/// then use [SkeletonExtension] on any widget:
///
/// ```dart
/// import 'package:shadcn_flutter/shadcn_flutter.dart';
/// import 'package:shadcn_flutter_skeletonizer/shadcn_flutter_skeletonizer.dart';
///
/// void main() {
///   runApp(
///     ShadcnApp(
///       theme: ThemeData(colorScheme: ColorSchemes.lightZinc, radius: 0.5),
///       surfaceBuilder: (context, child) => SkeletonizerLayer(child: child),
///       home: const HomePage(),
///     ),
///   );
/// }
///
/// class HomePage extends StatelessWidget {
///   const HomePage({super.key});
///
///   @override
///   Widget build(BuildContext context) {
///     return const Text('Loading…').asSkeleton();
///   }
/// }
/// ```
///
/// Importing this library and `package:shadcn_flutter/shadcn_flutter.dart`
/// unprefixed is deliberate: it re-exports only the Skeletonizer symbols that
/// do not collide with shadcn_flutter's own. For anything else, import
/// `package:skeletonizer/skeletonizer.dart` with a prefix.
library;

export 'package:skeletonizer/skeletonizer.dart'
    show
        // Placeholder widgets for content that has no shape of its own yet;
        // shadcn_flutter used to re-export these two.
        Bone,
        BoneMock,
        // The widgets SkeletonExtension wraps things in, exposed so they can
        // also be used directly.
        Skeleton,
        Skeletonizer,
        SkeletonizerConfig,
        SkeletonizerConfigData,
        // Effects, for overriding the theme-derived pulse.
        PaintingEffect,
        PulseEffect,
        ShimmerEffect,
        SolidColorEffect;

export 'src/skeletonizer_layer.dart';
