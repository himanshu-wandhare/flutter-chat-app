import 'package:flutter/material.dart';
import 'package:flutter_chat_app/widgets/message_bubble.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final _supabase = Supabase.instance.client;

class ChatMessages extends StatelessWidget {
  ChatMessages({super.key});

  final _chatStream = _supabase
      .from('chat')
      .stream(primaryKey: ['id'])
      .order('created_at');

  @override
  Widget build(BuildContext context) {
    final authenticatedUser = _supabase.auth.currentUser!;

    return StreamBuilder(
      stream: _chatStream,
      builder: (ctx, chatSnapshot) {
        if (chatSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (chatSnapshot.hasError) {
          return const Center(child: Text("Something went wrong"));
        }

        final loadedMessages = chatSnapshot.data ?? [];

        if (loadedMessages.isEmpty) {
          return const Center(child: Text("No message found!"));
        }

        return ListView.builder(
          padding: const EdgeInsets.only(left: 13, right: 13, bottom: 40),
          reverse: true,
          itemCount: loadedMessages.length,
          itemBuilder: (ctx, index) {
            final chatMessage = loadedMessages[index];
            final nextChatMessage =
                index + 1 < loadedMessages.length
                    ? loadedMessages[index + 1]
                    : null;

            final currentMessageUserId = chatMessage['user_id'];
            final nextMessageUserId =
                nextChatMessage != null ? nextChatMessage['user_id'] : null;
            final isNextUserSame = currentMessageUserId == nextMessageUserId;

            return MessageBubble(
              key: ValueKey(chatMessage['id']),
              userImagePath: isNextUserSame ? null : chatMessage['image_path'],
              username: isNextUserSame ? null : chatMessage['username'],
              message: chatMessage['text'],
              isFirstInSequence: !isNextUserSame,
              isMe: authenticatedUser.id == currentMessageUserId,
            );
          },
        );
      },
    );
  }
}
