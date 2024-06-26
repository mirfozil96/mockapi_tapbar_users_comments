import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/widgets/transparent_app_bar.dart';
import '../../../albums/models/album_model.dart';
import '../../../albums/presentation/widgets/album_tile.dart';
import '../../../albums/repositories/albums_repository.dart';
import '../../../posts/models/post_model.dart';
import '../../../posts/presentation/widgets/post_tile.dart';
import '../../../posts/repositories/post_repository.dart';
import '../../models/user_model.dart';
import '../../repositories/user_repository.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({
    super.key,
    required this.userId,
  });

  final int userId;

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  late final _userFuture = UserRepository().getUserById(widget.userId);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TransparentAppBar(),
      body: FutureBuilder<User>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) return const Center(child: Text('An error!'));

          if (!snapshot.hasData) {
            return const Center(child: Text('No data found!'));
          }

          final user = snapshot.data!;

          return _UserScreenContent(user: user);
        },
      ),
    );
  }
}

class _UserScreenContent extends StatelessWidget {
  const _UserScreenContent({
    required this.user,
  });

  final User user;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(child: _buildUserInfo(context)),

            // TabBar
            SliverPersistentHeader(
              pinned: true,
              delegate: _TabBarDelegate(
                child: ColoredBox(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: const TabBar(
                    labelColor: Colors.blue,
                    indicatorColor: Colors.blue,
                    tabs: [
                      Tab(text: 'Posts'),
                      Tab(text: 'Albums'),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          children: [
            _PostsList(userId: user.id),
            _AlbumsList(userId: user.id),
          ],
        ),
      ),
    );
  }

  /// User info widget.
  /// Contains name, username, address, etc.
  Widget _buildUserInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // User avatar
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.blueGrey,
          child: Lottie.asset("assets/lotties/user.json"),
        ),
        const SizedBox(height: 5),

        // Name
        Center(
          child: Text(
            user.name,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        const SizedBox(height: 5),

        // Username
        Center(child: Text('@${user.username}')),

        // Email, website, phone, location.
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 20,
          ),
          child: IconTheme(
            data: const IconThemeData(
              color: Colors.blueGrey,
              size: 18,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.email),
                    const SizedBox(width: 5),
                    Text(user.email),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(Icons.link),
                    const SizedBox(width: 5),
                    Text(
                      user.website,
                      style: const TextStyle(color: Colors.blue),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(Icons.call),
                    const SizedBox(width: 5),
                    Text(
                      user.phone,
                      style: const TextStyle(color: Colors.blue),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(Icons.location_on),
                    const SizedBox(width: 5),
                    Text(user.address.toStringShort()),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PostsList extends StatefulWidget {
  const _PostsList({
    required this.userId,
  });

  final int userId;

  @override
  State<_PostsList> createState() => _PostsListState();
}

class _PostsListState extends State<_PostsList> {
  late final _postsFuture = PostRepository().getAllPostsByUser(widget.userId);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Post>>(
      future: _postsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) return const Center(child: Text('An error!'));

        if (!snapshot.hasData) {
          return const Center(child: Text('No data found!'));
        }

        final posts = snapshot.data!;

        if (posts.isEmpty) {
          return const Center(child: Text('No Posts found!'));
        }

        return ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) {
            return PostTile(post: posts[index]);
          },
        );
      },
    );
  }
}

class _AlbumsList extends StatefulWidget {
  const _AlbumsList({
    required this.userId,
  });

  final int userId;

  @override
  State<_AlbumsList> createState() => _AlbumsListState();
}

class _AlbumsListState extends State<_AlbumsList> {
  late final _albumsFuture = AlbumRepository().getAllAlbumByUser(widget.userId);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Album>>(
      future: _albumsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) return const Center(child: Text('An error!'));

        if (!snapshot.hasData) {
          return const Center(child: Text('No data found!'));
        }

        final albums = snapshot.data!;

        if (albums.isEmpty) {
          return const Center(child: Text('No Albums found!'));
        }

        return ListView.builder(
          itemCount: albums.length,
          itemBuilder: (context, index) {
            return AlbumTile(album: albums[index]);
          },
        );
      },
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  const _TabBarDelegate({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => 40;

  @override
  double get minExtent => 40;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
