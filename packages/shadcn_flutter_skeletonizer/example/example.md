# Example

Wrap the app in a `SkeletonizerLayer` so the pulse follows the shadcn theme,
then use the `SkeletonExtension` methods on any widget.

```dart
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:shadcn_flutter_skeletonizer/shadcn_flutter_skeletonizer.dart';

void main() {
  runApp(
    ShadcnApp(
      title: 'Loading states',
      theme: ThemeData(
        colorScheme: ColorSchemes.lightZinc,
        radius: 0.5,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorSchemes.darkZinc,
        radius: 0.5,
      ),
      // surfaceBuilder rather than builder, so overlays are covered too.
      surfaceBuilder: (context, child) => SkeletonizerLayer(child: child),
      home: const HomePage(),
    ),
  );
}

class Profile {
  const Profile(this.name, this.email);

  final String name;
  final String email;
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final Future<List<Profile>> _profiles = Future.delayed(
    const Duration(seconds: 2),
    () => const [
      Profile('Ada Lovelace', 'ada@example.com'),
      Profile('Grace Hopper', 'grace@example.com'),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      child: FutureBuilder<List<Profile>>(
        future: _profiles,
        builder: (context, snapshot) {
          // BoneMock gives the placeholders realistic widths, so the skeleton
          // has the same shape as the loaded list.
          final profiles =
              snapshot.data ??
              const [
                Profile(BoneMock.name, BoneMock.email),
                Profile(BoneMock.name, BoneMock.email),
              ];
          return Column(
            children: [
              for (final profile in profiles)
                Card(
                  child: Basic(
                    leading: const Avatar(initials: 'AB'),
                    title: Text(profile.name),
                    subtitle: Text(profile.email),
                    // Stays interactive while the rest is a skeleton.
                    trailing: GhostButton(
                      onPressed: () {},
                      child: const Icon(LucideIcons.ellipsis),
                    ).ignoreSkeleton(),
                  ),
                ).asSkeleton(snapshot: snapshot),
            ],
          ).gap(8);
        },
      ),
    );
  }
}
```
