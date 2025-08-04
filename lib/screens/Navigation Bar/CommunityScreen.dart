import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_selector/emoji_selector.dart'; // ✅ Replaced emoji picker

import '../../services/CommunityService.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late final CommunityService _chatService;
  final String classId = "CSE2";

  @override
  void initState() {
    super.initState();
    _chatService = CommunityService(classId: classId);
  }

  void _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      await _chatService.sendMessage(message);
      _messageController.clear();
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _deleteMessage(String docId) async {
    await FirebaseFirestore.instance
        .collection('community_chats')
        .doc(classId)
        .collection('messages')
        .doc(docId)
        .delete();
  }

  Widget _buildMessageTile(
      Map<String, dynamic> messageData, bool isMe, String docId) {
    return GestureDetector(
      onLongPress: isMe
          ? () => showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Delete Message"),
          content: const Text("Do you want to delete this message?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                await _deleteMessage(docId);
                Navigator.pop(context);
              },
              child: const Text("Delete"),
            ),
          ],
        ),
      )
          : null,
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isMe ? Colors.blue[100] : Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              if (!isMe)
                Text(
                  messageData['senderName'] ?? 'Unknown',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              Text(messageData['message'] ?? ''),
            ],
          ),
        ),
      ),
    );
  }

  void _showEmojiBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SizedBox(
        height: 300,
        child: EmojiSelector(
          onSelected: (emoji) {
            setState(() {
              _messageController.text += emoji.char;

            });
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Class Group Chat"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _chatService.getMessageStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final messageData =
                    messages[index].data()! as Map<String, dynamic>;
                    final isMe = currentUser?.uid == messageData['senderId'];
                    return _buildMessageTile(
                        messageData, isMe, messages[index].id);
                  },
                );
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.emoji_emotions_outlined),
                  onPressed: _showEmojiBottomSheet,
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
