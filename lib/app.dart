// ignore_for_file: unused_import

import 'package:flutter/material.dart';

import 'dummyjson.dart';
import 'mockpage.dart';
import 'navigator_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: NavigatorPage(),
    );
  }
}
