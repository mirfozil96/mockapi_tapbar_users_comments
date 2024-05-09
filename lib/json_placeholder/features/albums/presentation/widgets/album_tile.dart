import 'package:flutter/material.dart';

import '../../models/album_model.dart';
import '../screens/album_screen.dart';

class AlbumTile extends StatelessWidget {
  const AlbumTile({
    super.key,
    required this.album,
  });

  final Album album;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.collections, size: 30),
      title: Text(album.title),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              return AlbumScreen(albumId: album.id);
            },
          ),
        );
      },
    );
  }
}
