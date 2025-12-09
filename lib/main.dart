import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:schoolhq_ng/app.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

void main() async {
  usePathUrlStrategy(); // This also works
  await Hive.initFlutter(); // <-- no path needed on Flutter
  await Hive.openBox('app');

  runApp(ProviderScope(child: const MyApp()));
}
