# shadcn_flutter_skeletonizer

Skeleton loading effects for
[shadcn_flutter](https://pub.dev/packages/shadcn_flutter), built on
[skeletonizer](https://pub.dev/packages/skeletonizer).

`shadcn_flutter` used to depend on `skeletonizer` directly. It no longer does,
so apps that never show a loading placeholder do not carry it. The API is the
same apart from one rename.

## Install

```shell
flutter pub add shadcn_flutter_skeletonizer
```

`skeletonizer` comes along transitively. Add it directly only if you use more of
its API than this package re-exports.

## Use

Wrap the app in a `SkeletonizerLayer` so the pulse follows the shadcn theme,
then call the extension methods on any widget:

```dart
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:shadcn_flutter_skeletonizer/shadcn_flutter_skeletonizer.dart';

void main() {
  runApp(
    ShadcnApp(
      theme: ThemeData(colorScheme: ColorSchemes.lightZinc, radius: 0.5),
      surfaceBuilder: (context, child) => SkeletonizerLayer(child: child),
      home: const ProfilePage(),
    ),
  );
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Profile>(
      future: loadProfile(),
      builder: (context, snapshot) {
        return Basic(
          leading: const Avatar(initials: 'AB'),
          title: Text(snapshot.data?.name ?? BoneMock.name),
          subtitle: Text(snapshot.data?.email ?? BoneMock.email),
        ).asSkeleton(snapshot: snapshot);
      },
    );
  }
}
```

Use `surfaceBuilder` rather than `builder`. Toasts, dialogs and popovers build
outside `builder`, so a layer installed there would not reach them.

### Extension methods

| Method | What it does |
| :--- | :--- |
| `.asSkeleton()` | Skeletonizes the widget. Pass `snapshot:` to drive it from an `AsyncSnapshot`, or `leaf: true` / `unite: true` / `replacement:` for the other modes. |
| `.asSkeletonSliver()` | The same, for widgets inside a `CustomScrollView`. |
| `.ignoreSkeleton()` | Leaves the widget out of an enclosing skeleton. |
| `.excludeSkeleton()` | Keeps the widget's real appearance inside a skeleton. |

`Avatar` and `Image` get leaf treatment automatically, which avoids
[skeletonizer#17](https://github.com/Milad-Akarie/skeletonizer/issues/17).

## Theming

`SkeletonizerLayer` derives its pulse from the ambient `ThemeData`: the primary
color at 5% to 10% alpha, over one second. Override it per layer, or app wide
through `SkeletonTheme`:

```dart
ComponentTheme(
  data: const SkeletonTheme(
    duration: Duration(milliseconds: 800),
    enableSwitchAnimation: false,
  ),
  child: const MyApp(),
);
```

`SkeletonizerLayer` implements `Styleable<SkeletonTheme>`, so it also takes a
`theme:` argument for one layer and `.inheritStyle(...)` for a subtree.

## Migrating from `shadcn_flutter`

Three changes:

1. Add this package and import it. The extension methods, `Bone` and `BoneMock`
   come from here now.
2. `ShadcnSkeletonizerConfigLayer` is now `SkeletonizerLayer`. It reads
   `Theme.of(context)` itself rather than taking a `ThemeData`, and its `theme:`
   argument is a `SkeletonTheme` like every other shadcn component.
3. `ShadcnApp` no longer installs the configuration, so add
   `surfaceBuilder: (context, child) => SkeletonizerLayer(child: child)`.

```dart
// before, shadcn_flutter installed this itself
Text('Loading').asSkeleton();

// after
ShadcnApp(
  surfaceBuilder: (context, child) => SkeletonizerLayer(child: child),
  home: Text('Loading').asSkeleton(),
);
```

The extension methods still work without the layer. The pulse just falls back to
skeletonizer's own defaults instead of following the shadcn theme.

## See also

- [shadcn_flutter](https://pub.dev/packages/shadcn_flutter)
- [shadcn_flutter_material](https://pub.dev/packages/shadcn_flutter_material)
- [shadcn_flutter_cupertino](https://pub.dev/packages/shadcn_flutter_cupertino)
