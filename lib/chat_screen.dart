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
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  IO.Socket? socket;

  @override
  void initState() {
    super.initState();
    _connectSocket();
    _initializeChat();
  }

  void _connectSocket() {
    socket = IO.io(
      'http://18.234.214.233:3000',
      <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
      },
    );
    socket!.connect();

    socket!.on('connect', (_) {
      if (chatId != null) {
        socket!.emit('join', chatId);
        globals.activeChatId = chatId;
      }
    });

    socket!.on('new_message', (data) async {
      if (data['senderId'] == widget.currentUserId) return;

      final raw = data['timestamp'] as String;
      final dt  = DateTime.parse(raw).toUtc().toLocal();
      data['pacificTimestamp'] = DateFormat.jm().format(dt);

      setState(() => messages.add(data));
      _scrollToBottom();

      await ApiService.markMessageAsRead(chatId!, data['_id']);
      socket!.emit('message_read', {
        'chatId':     chatId,
        'messageId':  data['_id'],
        'readerId':   widget.currentUserId,
      });
    });


    socket!.on('message_read', (data) {
      final msgId = data['messageId'] as String;
      final rawTime = data['readTimestamp'] as String;
      final dt = DateTime.parse(rawTime).toUtc().toLocal();
      final formatted = DateFormat.jm().format(dt);

      final idx = messages.indexWhere((m) => m['_id'] == msgId);
      if (idx != -1) {
        setState(() {
          messages[idx]['read'] = true;
          messages[idx]['pacificReadTime'] = formatted;
        });
      }
    });

    socket!.on('disconnect', (_) => debugPrint('🔌 Socket disconnected'));
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
      chatId = chat['_id'] as String;
      globals.activeChatId = chatId;
      socket?.emit('join', chatId);
      await _loadMessages();
    } catch (e) {
      debugPrint('Error initializing chat: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _loadMessages() async {
    if (chatId == null) return;
    try {
      final rawList = await ApiService.getMessages(chatId!);
      final formatted = rawList.map((m) {
        final raw = m['timestamp'] as String;
        final dt  = DateTime.parse(raw).toUtc().toLocal();
        m['pacificTimestamp'] = DateFormat.jm().format(dt);
        return m;
      }).toList();

      setState(() => messages = formatted);
      _scrollToBottom();


      for (var m in messages) {
        if (m['senderId'] != widget.currentUserId && m['read'] == false) {
          await ApiService.markMessageAsRead(chatId!, m['_id']);
          socket?.emit('message_read', {
            'chatId': chatId,
            'messageId': m['_id'],
            'readerId': widget.currentUserId,
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading messages: $e');
    }
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (chatId == null || text.isEmpty) return;
    _messageController.clear();

    final now = DateTime.now();
    final pacific = now.toLocal();
    final newMsg = {
      '_id': now.microsecondsSinceEpoch.toString(),  // temporary unique id
      'chatId': chatId,
      'senderId': widget.currentUserId,
      'content': text,
      'timestamp': now.toUtc().toIso8601String(),
      'pacificTimestamp': DateFormat.jm().format(pacific),
      'read': false,
    };
    setState(() => messages.add(newMsg));
    _scrollToBottom();

    socket?.emit('send_message', {
      'chatId': chatId,
      'senderId': widget.currentUserId,
      'content': text,
    });

    ApiService.sendMessage(chatId!, widget.currentUserId, text).catchError((e) {
      debugPrint('HTTP send error: $e');
    });
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

  Widget _buildMessageItem(dynamic msg) {
    final isMe = msg['senderId'] == widget.currentUserId;
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
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(msg['content'] as String, style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 4),
            Text(
              'Sent: ${msg['pacificTimestamp']}',
              style: const TextStyle(color: Colors.white70, fontSize: 10),
            ),
            if (isMe && (msg['read'] as bool))
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Seen: ${msg['pacificReadTime'] ?? ''}',
                  style: const TextStyle(color: Colors.greenAccent, fontSize: 10),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: Text(widget.buddyName), backgroundColor: Colors.black),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadMessages,
              child: ListView(
                controller: _scrollController,
                children: messages.map(_buildMessageItem).toList(),
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
                  onPressed: () {},
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
