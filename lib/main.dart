import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:schoolhq_ng/app.dart';
import 'package:schoolhq_ng/provider/school_provider.dart';
import 'package:schoolhq_ng/provider/selected_school_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SchoolProvider()),
        ChangeNotifierProvider(create: (_) => SelectedSchoolProvider()),
      ],
      child: const MyApp(),
    ),
  );
}
