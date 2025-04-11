// chat_screen.dart
import 'package:flutter/material.dart';
import 'api_service.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'global_state.dart' as globals;
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final String currentUserId;
  final String buddyId;
  final String buddyName;

  const ChatScreen({
    Key? key,
    required this.currentUserId,
    required this.buddyId,
    required this.buddyName,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String? chatId;
  List<dynamic> messages = [];
  bool isLoading = false;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  IO.Socket? socket;

  @override
  void initState() {
    super.initState();
    _initializeChat();
    _connectSocket();
  }

  void _connectSocket() {
    socket = IO.io('http://10.0.0.116:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
    socket?.connect();

    socket?.onConnect((_) {
      if (chatId != null) {
        socket?.emit('join', chatId);
        globals.activeChatId = chatId;
      }
    });

    socket?.on('new_message', (data) async {
      final isFromOther = data['senderId'] != widget.currentUserId;

      setState(() {
        messages.add(data);
      });

      // Real-time mark as read
      if (isFromOther && data['read'] == false) {
        await ApiService.markMessageAsRead(data['chatId'], data['_id']);
        socket?.emit('message_read', {
          'chatId': data['chatId'],
          'messageId': data['_id'],
          'readerId': widget.currentUserId,
        });
      }

      _scrollToBottom();
    });

    socket?.on('message_read', (data) {
      final String messageId = data['messageId'];
      final String rawTime = data['readTimestamp'];
      final DateTime utc = DateTime.parse(rawTime).toUtc();
      final pacific = utc.toLocal(); // Adjust based on device time zone (assumes device is in Pacific)

      final formatted = DateFormat.jm().format(pacific); // e.g., "6:46 AM"

      setState(() {
        final index = messages.indexWhere((m) => m['_id'] == messageId);
        if (index != -1) {
          messages[index]['read'] = true;
          messages[index]['pacificReadTime'] = formatted;
        }
      });
    });

    socket?.onDisconnect((_) => print('🔌 Socket.IO disconnected'));
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    globals.activeChatId = null;
    socket?.disconnect();
    socket?.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initializeChat() async {
    setState(() => isLoading = true);
    try {
      final chat = await ApiService.createChat(widget.currentUserId, widget.buddyId);
      chatId = chat['_id'];
      globals.activeChatId = chatId;

      if (socket != null && socket!.connected) {
        socket!.emit('join', chatId);
      }

      await _loadMessages();
    } catch (e) {
      print('Error initializing chat: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _loadMessages() async {
    if (chatId == null) return;
    try {
      final msgs = await ApiService.getMessages(chatId!);
      setState(() => messages = msgs);

      for (var msg in msgs) {
        if (msg['senderId'] != widget.currentUserId && msg['read'] == false) {
          await ApiService.markMessageAsRead(chatId!, msg['_id']);
          socket?.emit('message_read', {
            'chatId': chatId,
            'messageId': msg['_id'],
            'readerId': widget.currentUserId,
          });
        }
      }

      _scrollToBottom();
    } catch (e) {
      print('Error loading messages: $e');
    }
  }

  Future<void> _sendMessage() async {
    if (chatId == null || _messageController.text.trim().isEmpty) return;
    final content = _messageController.text.trim();
    _messageController.clear();

    try {
      await ApiService.sendMessage(chatId!, widget.currentUserId, content);
    } catch (e) {
      print('Error sending message: $e');
    }
  }

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
            Text(message['content'], style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 4),
            Text(
              "Sent: ${message['pacificTimestamp'] ?? message['timestamp']}",
              style: const TextStyle(color: Colors.white70, fontSize: 10),
            ),
            if (isMe && message['read'] == true && message['pacificReadTime'] != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  "Seen: ${message['pacificReadTime']}",
                  style: const TextStyle(color: Colors.greenAccent, fontSize: 10),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildChatList() {
    return messages.map((msg) => _buildMessageItem(msg)).toList();
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
                    // TODO: Add attachments
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
