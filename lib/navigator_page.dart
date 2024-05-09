import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'dummyjson.dart';
import 'json_placeholder/my_app.dart';
import 'mockpage.dart';

class NavigatorPage extends StatefulWidget {
  const NavigatorPage({super.key});

  @override
  NavigatorPageState createState() => NavigatorPageState();
}

class NavigatorPageState extends State<NavigatorPage> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    const DummyJson(),
    const MockPage(),
    const JsonPlaseholder()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: _pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: SizedBox(
                  width: 40,
                  height: 40,
                  child: Lottie.asset("assets/lotties/dummy.json")),
              label: 'dummy json',
            ),
            BottomNavigationBarItem(
              icon: SizedBox(
                  width: 40,
                  height: 40,
                  child: Lottie.asset("assets/lotties/mock.json")),
              label: 'mockapi',
            ),
            BottomNavigationBarItem(
              icon: SizedBox(
                  width: 40,
                  height: 40,
                  child: Lottie.asset("assets/lotties/placeholder.json")),
              label: 'jsonplaceholder',
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
