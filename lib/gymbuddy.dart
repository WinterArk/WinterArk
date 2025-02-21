import 'package:flutter/material.dart';
import 'api_service.dart';
import 'past_workouts.dart';
import 'chat_screen.dart'; // Import the new chat screen

class GymBuddyScreen extends StatefulWidget {
  final String currentUserId; // The logged-in user's id
  const GymBuddyScreen({super.key, required this.currentUserId});

  @override
  _GymBuddyScreenState createState() => _GymBuddyScreenState();
}

class _GymBuddyScreenState extends State<GymBuddyScreen> {
  final TextEditingController _searchController = TextEditingController();
  String searchFilter = 'both'; // Options: 'both', 'name', or 'username'
  List<dynamic> searchResults = [];
  bool isLoadingSearch = false;

  // Sectioned buddy lists
  List<dynamic> incomingRequests = [];
  List<dynamic> outgoingRequests = [];
  List<dynamic> connectedBuddies = [];
  bool isLoadingBuddies = false;

  @override
  void initState() {
    super.initState();
    _loadUserBuddies();
  }

  // Fetch all GymBuddy docs that involve this user (either as requester or recipient)
  Future<void> _loadUserBuddies() async {
    setState(() => isLoadingBuddies = true);
    try {
      final buddies = await ApiService.fetchUserBuddies(widget.currentUserId);
      final userId = widget.currentUserId;

      final newIncoming = <dynamic>[];
      final newOutgoing = <dynamic>[];
      final newConnected = <dynamic>[];

      for (var doc in buddies) {
        final docStatus = doc['status'];
        final userIdObj = doc['userId'];
        final buddyIdObj = doc['buddyId'];

        if (docStatus == 'connected') {
          newConnected.add(doc);
        } else if (docStatus == 'pending') {
          if (userIdObj['_id'] == userId) {
            newOutgoing.add(doc);
          } else if (buddyIdObj['_id'] == userId) {
            newIncoming.add(doc);
          }
        }
      }

      setState(() {
        incomingRequests = newIncoming;
        outgoingRequests = newOutgoing;
        connectedBuddies = newConnected;
      });
    } catch (e) {
      print('Error loading buddies: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading buddies: $e')),
      );
    } finally {
      setState(() => isLoadingBuddies = false);
    }
  }

  // For searching new users
  void _searchUsers() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
      });
      return;
    }
    setState(() {
      isLoadingSearch = true;
    });
    try {
      final results = await ApiService.searchUsers(query, searchFilter);
      // Remove current user from results
      results.removeWhere((user) => user['_id'] == widget.currentUserId);
      setState(() {
        searchResults = results;
      });
    } catch (e) {
      print('Error searching users: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error searching users: $e')),
      );
    } finally {
      setState(() {
        isLoadingSearch = false;
      });
    }
  }

  // Add a gym buddy request
  void _addGymBuddy(String buddyId) async {
    try {
      await ApiService.addGymBuddy(widget.currentUserId, buddyId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gym buddy request sent!')),
      );
      setState(() {
        searchResults.removeWhere((user) => user['_id'] == buddyId);
      });
      _loadUserBuddies();
    } catch (e) {
      print('Error adding gym buddy: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding gym buddy: $e')),
      );
    }
  }

  // Accept (set status = connected)
  void _acceptRequest(String docId) async {
    try {
      await ApiService.updateBuddyStatus(docId, 'connected');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request accepted!')),
      );
      _loadUserBuddies();
    } catch (e) {
      print('Error accepting request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error accepting request: $e')),
      );
    }
  }

  // Decline (set status = removed)
  void _declineRequest(String docId) async {
    try {
      await ApiService.updateBuddyStatus(docId, 'removed');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request declined.')),
      );
      _loadUserBuddies();
    } catch (e) {
      print('Error declining request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error declining request: $e')),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Build connected buddies using a dedicated widget that shows an unread badge.
  Widget _buildConnectedBuddies() {
    if (connectedBuddies.isEmpty) {
      return const Text('No connected buddies',
          style: TextStyle(color: Colors.white70));
    }
    return Column(
      children: connectedBuddies.map((doc) {
        final docUserId = doc['userId']['_id'];
        final bool amUserId = (docUserId == widget.currentUserId);
        final theOther = amUserId ? doc['buddyId'] : doc['userId'];
        final otherName = theOther['name'] ?? 'Unnamed';
        final otherUsername = theOther['username'] ?? 'No username';
        return ConnectedBuddyCard(
          currentUserId: widget.currentUserId,
          buddy: theOther,
          buddyName: otherName,
          buddyUsername: otherUsername,
          onChatOpened: () async {
            // Refresh buddies (and thus unread counts) after returning from chat
            await _loadUserBuddies();
          },
        );
      }).toList(),
    );
  }

  Widget _buildIncomingRequests() {
    if (incomingRequests.isEmpty) {
      return const Text('No incoming requests',
          style: TextStyle(color: Colors.white70));
    }
    return Column(
      children: incomingRequests.map((doc) {
        final docId = doc['_id'];
        final user = doc['userId'];
        final userName = user['name'] ?? 'Unnamed';
        final userUsername = user['username'] ?? 'No username';
        return Card(
          color: Colors.grey[850],
          child: ListTile(
            key: Key('incoming-request-$docId'),
            title: Text(userName, style: const TextStyle(color: Colors.white)),
            subtitle: Text(userUsername,
                style: const TextStyle(color: Colors.white70)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  key: Key('accept-request-$docId'),
                  icon: const Icon(Icons.check, color: Colors.green),
                  onPressed: () => _acceptRequest(docId),
                ),
                IconButton(
                  key: Key('decline-request-$docId'),
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () => _declineRequest(docId),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildOutgoingRequests() {
    if (outgoingRequests.isEmpty) {
      return const Text('No outgoing requests',
          style: TextStyle(color: Colors.white70));
    }
    return Column(
      children: outgoingRequests.map((doc) {
        final buddy = doc['buddyId'];
        final docId = doc['_id'];
        final buddyName = buddy['name'] ?? 'Unnamed';
        final buddyUsername = buddy['username'] ?? 'No username';
        return Card(
          color: Colors.grey[850],
          child: ListTile(
            key: Key('outgoing-request-$docId'),
            title: Text(buddyName, style: const TextStyle(color: Colors.white)),
            subtitle: Text(buddyUsername,
                style: const TextStyle(color: Colors.white70)),
            trailing: IconButton(
              key: Key('cancel-outgoing-$docId'),
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: () => _declineRequest(docId),
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Gym Buddies'),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // ====== Search UI ======
            Row(
              children: [
                Expanded(
                  child: TextField(
                    key: const Key('gymbuddy-search'),
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search by name or username...',
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: Colors.grey[900],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: IconButton(
                        key: const Key('gymbuddy-search-btn'),
                        icon: const Icon(Icons.search, color: Colors.white),
                        onPressed: _searchUsers,
                      ),
                    ),
                    onSubmitted: (_) => _searchUsers(),
                  ),
                ),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  dropdownColor: Colors.black,
                  value: searchFilter,
                  icon: const Icon(Icons.filter_list, color: Colors.white),
                  style: const TextStyle(color: Colors.white),
                  underline: Container(
                    height: 2,
                    color: Colors.blueAccent,
                  ),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        searchFilter = newValue;
                      });
                    }
                  },
                  items: <String>['both', 'name', 'username']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value.toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // ====== MAIN CONTENT ======
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Show search results first
                    if (isLoadingSearch)
                      const Center(child: CircularProgressIndicator())
                    else
                      Column(
                        children: searchResults.map((user) {
                          return Card(
                            key: Key('gymbuddy-result-${user['_id']}'),
                            color: Colors.grey[900],
                            child: ListTile(
                              title: Text(
                                user['name'] ?? '',
                                style: const TextStyle(color: Colors.white),
                              ),
                              subtitle: Text(
                                user['username'] ?? '',
                                style: const TextStyle(color: Colors.white70),
                              ),
                              trailing: IconButton(
                                key: Key('gymbuddy-add-${user['_id']}'),
                                icon: const Icon(Icons.person_add,
                                    color: Colors.blueAccent),
                                onPressed: () {
                                  _addGymBuddy(user['_id']);
                                },
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    const SizedBox(height: 20),
                    // Incoming Requests
                    const Text(
                      'Incoming Requests',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    if (isLoadingBuddies)
                      const Center(child: CircularProgressIndicator())
                    else
                      _buildIncomingRequests(),
                    const SizedBox(height: 20),
                    // Outgoing Requests
                    const Text(
                      'Outgoing Requests',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    if (isLoadingBuddies)
                      const Center(child: CircularProgressIndicator())
                    else
                      _buildOutgoingRequests(),
                    const SizedBox(height: 20),
                    // Connected Buddies
                    const Text(
                      'Connected Buddies',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
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

// New widget to show a connected buddy with chat icon and unread badge.
class ConnectedBuddyCard extends StatelessWidget {
  final String currentUserId;
  final Map buddy;
  final String buddyName;
  final String buddyUsername;
  final VoidCallback onChatOpened;

  const ConnectedBuddyCard({
    Key? key,
    required this.currentUserId,
    required this.buddy,
    required this.buddyName,
    required this.buddyUsername,
    required this.onChatOpened,
  }) : super(key: key);

  Future<int> _fetchUnreadCount() async {
    // Create or retrieve chat between currentUserId and buddy
    final chat = await ApiService.createChat(currentUserId, buddy['_id']);
    final unreadCount = await ApiService.getUnreadCount(chat['_id'], currentUserId);
    return unreadCount;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[850],
      child: ListTile(
        title: Text(buddyName, style: const TextStyle(color: Colors.white)),
        subtitle:
        Text(buddyUsername, style: const TextStyle(color: Colors.white70)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FutureBuilder<int>(
              future: _fetchUnreadCount(),
              builder: (context, snapshot) {
                int unreadCount = 0;
                if (snapshot.hasData) {
                  unreadCount = snapshot.data!;
                }
                return Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chat, color: Colors.green),
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(
                              currentUserId: currentUserId,
                              buddyId: buddy['_id'],
                              buddyName: buddyName,
                            ),
                          ),
                        );
                        onChatOpened();
                      },
                    ),
                    if (unreadCount > 0)
                      Positioned(
                        right: 4,
                        top: 4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 20,
                            minHeight: 20,
                          ),
                          child: Center(
                            child: Text(
                              '$unreadCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.calendar_today, color: Colors.blueAccent),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PastWorkoutsCalendar(
                      buddyId: buddy['_id'],
                      buddyName: buddyName,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}