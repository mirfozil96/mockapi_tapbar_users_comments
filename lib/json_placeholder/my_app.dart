import 'package:flutter/material.dart';

import 'features/albums/presentation/views/albums_view.dart';
import 'features/posts/presentation/views/posts_view.dart';
import 'features/users/presentation/views/users_view.dart';

class JsonPlaseholder extends StatefulWidget {
  const JsonPlaseholder({super.key});

  @override
  State<JsonPlaseholder> createState() => _JsonPlaseholderState();
}

class _JsonPlaseholderState extends State<JsonPlaseholder>
    with SingleTickerProviderStateMixin {
  static const List<_Nav> _navItems = [
    _Nav(label: 'Users', iconData: Icons.groups, view: UsersView()),
    _Nav(label: 'Posts', iconData: Icons.newspaper_rounded, view: PostsView()),
    _Nav(label: 'Albums', iconData: Icons.collections, view: AlbumsView()),
  ];

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _navItems.length, vsync: this);
    _tabController.addListener(_onTabChange);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChange() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _currentIndex = _tabController.index;
      });
    }
  }

  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      appBar: AppBar(
        title: Text(_navItems[_currentIndex].label),
      ),
      body: Row(
        children: [
          if (isLargeScreen)
            NavigationRail(
              selectedIndex: _currentIndex,
              onDestinationSelected: (int index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              labelType: NavigationRailLabelType.all,
              destinations: _navItems
                  .map(
                    (e) => NavigationRailDestination(
                      label: Text(e.label),
                      icon: Icon(e.iconData),
                    ),
                  )
                  .toList(),
            ),
          Expanded(
            child: Column(
              children: [
                if (!isLargeScreen)
                  TabBar(
                    controller: _tabController,
                    tabs: _navItems
                        .map((e) => Tab(
                              icon: Icon(e.iconData),
                              text: e.label,
                            ))
                        .toList(),
                  ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: _navItems.map((e) => e.view).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Nav {
  const _Nav({
    required this.label,
    required this.iconData,
    required this.view,
  });

  final String label;
  final IconData iconData;
  final Widget view;
}
