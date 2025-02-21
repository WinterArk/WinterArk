import 'package:flutter/material.dart';
import 'api_service.dart';

class ChatScreen extends StatefulWidget {
  final String currentUserId;
  final String buddyId;
  final String buddyName;

  const ChatScreen({
    super.key,
    required this.currentUserId,
    required this.buddyId,
    required this.buddyName,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String? chatId;
  List<dynamic> messages = [];
  bool isLoading = false;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    setState(() {
      isLoading = true;
    });
    try {
      // Create or retrieve a chat between the current user and buddy.
      final chat = await ApiService.createChat(widget.currentUserId, widget.buddyId);
      setState(() {
        chatId = chat['_id'];
      });
      await _loadMessages();
    } catch (e) {
      print('Error initializing chat: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error initializing chat.')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadMessages() async {
    if (chatId == null) return;
    try {
      final msgs = await ApiService.getMessages(chatId!);
      // Mark all received messages as read.
      for (var msg in msgs) {
        if (msg['senderId'] != widget.currentUserId && msg['read'] == false) {
          await ApiService.markMessageRead(chatId!, msg['_id']);
        }
      }
      // Reload messages after marking as read.
      final updatedMsgs = await ApiService.getMessages(chatId!);
      setState(() {
        messages = updatedMsgs;
      });
      // Scroll to bottom.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
    } catch (e) {
      print('Error loading messages: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error loading messages.')),
      );
    }
  }

  Future<void> _sendMessage() async {
    if (chatId == null || _messageController.text.trim().isEmpty) return;
    final content = _messageController.text.trim();
    _messageController.clear();
    try {
      await ApiService.sendMessage(chatId!, widget.currentUserId, content);
      await _loadMessages();
    } catch (e) {
      print('Error sending message: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error sending message.')),
      );
    }
  }

  // Build a single message widget.
  Widget _buildMessageItem(dynamic message) {
    final bool isMe = message['senderId'] == widget.currentUserId;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? Colors.blueAccent : Colors.grey[800],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment:
          isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message['content'],
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 4),
            Column(
              crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                // Display sent time using the backend-provided field.
                Text(
                  "Sent: ${message['pacificTimestamp'] ?? message['timestamp']}",
                  style: const TextStyle(color: Colors.white70, fontSize: 10),
                ),
                if (isMe && message['read'] == true && message['pacificReadTime'] != null)
                  Text(
                    "Read: ${message['pacificReadTime']}",
                    style: const TextStyle(color: Colors.green, fontSize: 10),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build the chat list with date headers.
  List<Widget> _buildChatList() {
    List<Widget> widgets = [];
    String? lastDate;
    for (var message in messages) {
      // Use the backend-provided pacificDate field (if available); otherwise, use an empty string.
      final String currentDate = message['pacificDate'] ?? '';
      if (lastDate == null || currentDate != lastDate) {
        // Insert a date header.
        widgets.add(
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                currentDate,
                style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        );
        lastDate = currentDate;
      }
      widgets.add(_buildMessageItem(message));
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.buddyName),
        backgroundColor: Colors.black,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadMessages,
              child: ListView(
                controller: _scrollController,
                children: _buildChatList(),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            color: Colors.grey[900],
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.attach_file, color: Colors.white),
                  onPressed: () {
                    // TODO: Implement attachment functionality.
                  },
                ),
                Expanded(
                  child: TextField(
                    key: const Key('chat-message-input'),
                    controller: _messageController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: TextStyle(color: Colors.white54),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  key: const Key('chat-send-button'),
                  icon: const Icon(Icons.send, color: Colors.blueAccent),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}