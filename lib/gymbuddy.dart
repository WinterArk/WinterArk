// gymbuddy.dart
import 'package:flutter/material.dart';
import 'api_service.dart';
import 'past_workouts.dart';
import 'chat_screen.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'button_effects/ui_helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GymBuddyScreen extends StatefulWidget {
  final String currentUserId;
  final bool showBackArrow;
  const GymBuddyScreen({
    Key? key,
    required this.currentUserId,
    this.showBackArrow = false,  
  }) : super(key: key);

  @override
  _GymBuddyScreenState createState() => _GymBuddyScreenState();
}

class _GymBuddyScreenState extends State<GymBuddyScreen> {
  final TextEditingController _searchController = TextEditingController();
  String searchFilter = 'both';
  List<dynamic> searchResults = [];
  bool isLoadingSearch = false;

  List<dynamic> incomingRequests = [];
  List<dynamic> outgoingRequests = [];
  List<dynamic> connectedBuddies = [];
  bool isLoadingBuddies = false;

  IO.Socket? socket;

  @override
  void initState() {
    super.initState();
    _loadUserBuddies();
    _connectSocket();
  }

  @override
  void dispose() {
    socket?.disconnect();
    socket?.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUserBuddies() async {
    setState(() => isLoadingBuddies = true);
    try {
      final buddies = await ApiService.fetchUserBuddies(widget.currentUserId);
      final userId = widget.currentUserId;
      final newIncoming = <dynamic>[];
      final newOutgoing = <dynamic>[];
      final newConnected = <dynamic>[];

      for (var doc in buddies) {
        final status = doc['status'];
        if (status == 'connected') {
          newConnected.add(doc);
        } else if (status == 'pending') {
          if (doc['userId']['_id'] == userId) {
            newOutgoing.add(doc);
          } else if (doc['buddyId']['_id'] == userId) {
            newIncoming.add(doc);
          }
        }
      }

      setState(() {
        incomingRequests = newIncoming;
        outgoingRequests = newOutgoing;
        connectedBuddies = newConnected;
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('connected_buddies_count', newConnected.length);
    } catch (e) {
      showShortFadeSnack(context, 'Error loading buddies: $e');
    } finally {
      setState(() => isLoadingBuddies = false);
    }
  }

  void _connectSocket() {
    socket = IO.io(
      'http://18.234.214.233:3000',
      {
        'transports': ['websocket'],
        'autoConnect': true,
        'query': {'userId': widget.currentUserId},
      },
    );
    socket?.connect();
    socket?.on('new_message', (_) => _loadUserBuddies());
    socket?.on('unread_count_update', (_) => _loadUserBuddies());
    socket?.on('message_read', (_) => _loadUserBuddies());
    socket?.onDisconnect((_) => debugPrint('Socket disconnected'));
  }

  void _searchUsers() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() => searchResults = []);
      return;
    }
    setState(() => isLoadingSearch = true);
    try {
      final results = await ApiService.searchUsers(query, searchFilter);
      results.removeWhere((u) => u['_id'] == widget.currentUserId);
      setState(() => searchResults = results);
    } catch (e) {
      showShortFadeSnack(context, 'Search error: $e');
    } finally {
      setState(() => isLoadingSearch = false);
    }
  }

  Future<void> _addGymBuddy(String buddyId) async {
    try {
      await ApiService.addGymBuddy(widget.currentUserId, buddyId);
      showShortFadeSnack(context, 'Request sent');
      setState(() => searchResults.removeWhere((u) => u['_id'] == buddyId));
      _loadUserBuddies();
    } catch (e) {
      showShortFadeSnack(context, 'Error: $e');
    }
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 18)),
    );
  }

  Widget _buildIncomingRequests() {
    if (incomingRequests.isEmpty) {
      return const Text('No incoming', style: TextStyle(color: Colors.white70));
    }
    return Column(
      children: incomingRequests.map((doc) {
        final id = doc['_id'];
        final user = doc['userId'];
        return ListTile(
          tileColor: Colors.grey[850],
          title: Text(user['name'] ?? '', style: const TextStyle(color: Colors.white)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.check, color: Colors.green),
                onPressed: () => ApiService.updateBuddyStatus(id, 'connected').then((_) => _loadUserBuddies()),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.red),
                onPressed: () => ApiService.updateBuddyStatus(id, 'removed').then((_) => _loadUserBuddies()),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildOutgoingRequests() {
    if (outgoingRequests.isEmpty) {
      return const Text('No outgoing', style: TextStyle(color: Colors.white70));
    }
    return Column(
      children: outgoingRequests.map((doc) {
        final id = doc['_id'];
        final buddy = doc['buddyId'];
        return ListTile(
          tileColor: Colors.grey[850],
          title: Text(buddy['name'] ?? '', style: const TextStyle(color: Colors.white)),
          trailing: IconButton(
            icon: const Icon(Icons.close, color: Colors.red),
            onPressed: () => ApiService.updateBuddyStatus(id, 'removed').then((_) => _loadUserBuddies()),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildConnectedBuddies() {
    if (connectedBuddies.isEmpty) {
      return const Text(
        'No connected',
        style: TextStyle(color: Colors.white70),
      );
    }

    // Build a list of widgets: Divider, Card, Divider, Card, ..., Divider
    final List<Widget> children = [];

    // top line
    children.add(const Divider(
      color: Colors.white24,
      thickness: 1,
      height: 1,
    ));

    for (var doc in connectedBuddies) {
      final other = doc['userId']['_id'] == widget.currentUserId
          ? doc['buddyId']
          : doc['userId'];

      children.add(
        ConnectedBuddyCard(
          currentUserId: widget.currentUserId,
          buddy: other,
          buddyName: other['name'] ?? '',
          buddyUsername: other['username'] ?? '',
          onChatOpened: _loadUserBuddies,
        ),
      );

      // separator after each card
      children.add(const Divider(
        color: Colors.white24,
        thickness: 1,
        height: 1,
      ));
    }

    return Column(
      // shrinkWrap behavior
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: 8),
          Text(
            "Gym Buddies",
            style: glowingTextStyle(
              Colors.white,
              size: 26,
            ),
          ),
        ],
      ),
      automaticallyImplyLeading: false,
      backgroundColor: Colors.black,
      centerTitle: true,
      elevation: 0,
        // <-- Conditionally show a back arrow:
        leading: widget.showBackArrow
          ? IconButton(
              icon: glowingIcon(Icons.arrow_back, Colors.white, 24),
              onPressed: () => Navigator.of(context).pop(),
            )
          : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: Colors.grey[900],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search, color: Colors.white),
                        onPressed: _searchUsers,
                      ),
                    ),
                    onSubmitted: (_) => _searchUsers(),
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: searchFilter,
                  dropdownColor: Colors.black,
                  style: const TextStyle(color: Colors.white),
                  underline: Container(height: 2, color: Colors.blueAccent),
                  items: ['both', 'name', 'username']
                      .map((v) => DropdownMenuItem(value: v, child: Text(v.toUpperCase())))
                      .toList(),
                  onChanged: (v) => setState(() => searchFilter = v!),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isLoadingSearch)
                      const Center(child: CircularProgressIndicator())
                    else if (searchResults.isNotEmpty)
                      Column(
                        children: searchResults.map((u) {
                          return ListTile(
                            tileColor: Colors.grey[900],
                            title: Text(u['name'] ?? '', style: const TextStyle(color: Colors.white)),
                            trailing: IconButton(
                              icon: const Icon(Icons.person_add, color: Colors.blueAccent),
                              onPressed: () => _addGymBuddy(u['_id']),
                            ),
                          );
                        }).toList(),
                      ),
                    _buildSectionHeader('Incoming Requests'),
                    if (isLoadingBuddies)
                      const Center(child: CircularProgressIndicator())
                    else
                      _buildIncomingRequests(),
                    _buildSectionHeader('Outgoing Requests'),
                    if (isLoadingBuddies)
                      const Center(child: CircularProgressIndicator())
                    else
                      _buildOutgoingRequests(),
                    _buildSectionHeader('Connected Buddies'),
                    if (isLoadingBuddies)
                      const Center(child: CircularProgressIndicator())
                    else
                      _buildConnectedBuddies(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ConnectedBuddyCard extends StatefulWidget {
  final String currentUserId;
  final Map buddy;
  final String buddyName;
  final String buddyUsername;
  final VoidCallback onChatOpened;

  const ConnectedBuddyCard({
    super.key,
    required this.currentUserId,
    required this.buddy,
    required this.buddyName,
    required this.buddyUsername,
    required this.onChatOpened,
  });

  @override
  _ConnectedBuddyCardState createState() => _ConnectedBuddyCardState();
}

class _ConnectedBuddyCardState extends State<ConnectedBuddyCard> {
  int unreadCount = 0;
  String? chatId;
  IO.Socket? socket;
  late final Color _avatarColor;
  late final String _initial;

  @override
  void initState() {
    super.initState();
    _setupChatAndSocket();
    // take the first letter
    _initial = widget.buddyName.isNotEmpty
        ? widget.buddyName[0].toUpperCase()
        : '?';

    // pick a color based on the name’s hash
    final hash = widget.buddyName.hashCode;
    final swatch = Colors.primaries[hash % Colors.primaries.length];
    _avatarColor = swatch.shade700;
  }

  Future<void> _setupChatAndSocket() async {
    try {
      final chat = await ApiService.createChat(widget.currentUserId, widget.buddy['_id']);
      chatId = chat['_id'];
      final count = await ApiService.getUnreadCount(chatId!, widget.currentUserId);
      setState(() => unreadCount = count);
      socket = IO.io(
        'http://18.234.214.233:3000',
        {'transports': ['websocket'], 'autoConnect': true},
      );
      socket?.onConnect((_) => socket?.emit('join', chatId));
      socket?.on('new_message', (data) {
        if (data['chatId'] == chatId && data['senderId'] == widget.buddy['_id']) {
          setState(() => unreadCount++);
        }
      });
      socket?.on('message_read', (data) {
        if (data['chatId'] == chatId && data['readerId'] == widget.currentUserId) {
          setState(() => unreadCount = 0);
        }
      });
    } catch (e) {
      debugPrint('Chat setup error: $e');
    }
  }

  @override
  void dispose() {
    socket?.disconnect();
    socket?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Divider(color: Colors.white24, height: 1),
        ListTile(
          contentPadding: EdgeInsets.zero,
          tileColor: Colors.black,
          leading: CircleAvatar(
            backgroundColor: _avatarColor,
            radius: 18,
            child: Text(
              _initial,
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          title: Row(
            children: [
              Text(widget.buddyName, style: const TextStyle(color: Colors.white)),
              const SizedBox(width: 8),
              FutureBuilder<int>(
                future: ApiService.getUserStreak(widget.buddy['_id']),
                builder: (ctx, snap) {
                  final streak = snap.data ?? 0;
                  return streak > 0
                      ? Row(
                    children: [
                      const Icon(Icons.local_fire_department, color: Colors.orange, size: 16),
                      const SizedBox(width: 4),
                      Text(streak.toString(), style: const TextStyle(color: Colors.white, fontSize: 12)),
                    ],
                  )
                      : const SizedBox.shrink();
                },
              ),
            ],
          ),
          subtitle: Text(widget.buddyUsername, style: const TextStyle(color: Colors.white70)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chat, color: Colors.green),
                    onPressed: () async {
                      // mark unread read before opening
                      if (chatId != null) {
                        final msgs = await ApiService.getMessages(chatId!);
                        for (var m in msgs) {
                          if (m['senderId'] == widget.buddy['_id'] && m['read'] == false) {
                            await ApiService.markMessageAsRead(chatId!, m['_id']);
                            socket?.emit('message_read', {
                              'chatId': chatId,
                              'messageId': m['_id'],
                              'readerId': widget.currentUserId,
                            });
                          }
                        }
                      }
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            currentUserId: widget.currentUserId,
                            buddyId: widget.buddy['_id'],
                            buddyName: widget.buddyName,
                          ),
                        ),
                      );
                      setState(() => unreadCount = 0);
                      widget.onChatOpened();
                    },
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 4,
                      top: 4,
                      child: CircleAvatar(
                        radius: 8,
                        backgroundColor: Colors.red,
                        child: Text(
                          unreadCount.toString(),
                          style: const TextStyle(color: Colors.white, fontSize: 10),
                        ),
                      ),
                    ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.calendar_today, color: Colors.blueAccent),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PastWorkoutsCalendar(
                      buddyId: widget.buddy['_id'],
                      buddyName: widget.buddyName,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
