import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppVersionText extends StatelessWidget {
  final TextStyle? style;
  final String prefix;
  final bool centered;

  const AppVersionText({
    super.key,
    this.style,
    this.prefix = 'Version',
    this.centered = true,
  });

  static Future<String>? _cachedVersionFuture;

  static Future<String> _loadVersion() {
    _cachedVersionFuture ??= PackageInfo.fromPlatform()
        .then((info) {
          final build = info.buildNumber.trim();
          final version = info.version.trim();
          if (build.isEmpty) return version;
          return '$version+$build';
        })
        .catchError((_) => '1.0.0');
    return _cachedVersionFuture!;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _loadVersion(),
      builder: (context, snapshot) {
        final version = snapshot.data ?? '...';
        return Text(
          '$prefix $version',
          textAlign: centered ? TextAlign.center : TextAlign.start,
          style: style,
        );
      },
    );
  }
}
