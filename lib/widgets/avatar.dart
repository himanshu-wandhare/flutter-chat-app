import 'package:flutter/material.dart';
import 'package:flutter_chat_app/utils/avatar_cache.dart';

class Avatar extends StatelessWidget {
  const Avatar({super.key, required this.avatarPath, required this.isMe});

  final String? avatarPath;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: AvatarCache.getUrl(avatarPath),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircleAvatar(radius: 23);
        }

        return CircleAvatar(
          backgroundImage: NetworkImage(snapshot.data!),
          backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(180),
          radius: 23,
        );
      },
    );
  }
}
