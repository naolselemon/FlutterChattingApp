import "package:chatting/widgets/chat_messages.dart";
import "package:chatting/widgets/new_messages.dart";
import "package:firebase_auth/firebase_auth.dart";

import "package:flutter/material.dart";

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("chat center"),
        actions: [
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            icon: const Icon(Icons.exit_to_app),
          ),
        ],
      ),
      body: const Column(
        children: [
          Expanded(child: ChatMessages()),
          NewMessages(),
        ],
      ),
    );
  }
}
