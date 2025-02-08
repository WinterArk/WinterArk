import 'package:flutter/material.dart';
import 'api_service.dart';

class GymBuddyScreen extends StatefulWidget {
  final String currentUserId; // The logged-in user's id
  const GymBuddyScreen({Key? key, required this.currentUserId}) : super(key: key);

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

  // Automatically load buddy data when screen first appears
  @override
  void initState() {
    super.initState();
    _loadUserBuddies();
  }

  // Fetch all GymBuddy docs that involve this user (either as userId or buddyId).
  Future<void> _loadUserBuddies() async {
    setState(() => isLoadingBuddies = true);
    try {
      final buddies = await ApiService.fetchUserBuddies(widget.currentUserId);

      // We'll categorize them into incoming/outgoing/connected
      final userId = widget.currentUserId;

      final newIncoming = <dynamic>[];
      final newOutgoing = <dynamic>[];
      final newConnected = <dynamic>[];

      for (var doc in buddies) {
        final docStatus = doc['status']; // 'pending', 'connected', 'removed', etc.
        final userIdObj = doc['userId'];  // => { _id, name, username, email }
        final buddyIdObj = doc['buddyId']; // => { _id, name, username, email }

        if (docStatus == 'connected') {
          // Connected docs go to newConnected
          newConnected.add(doc);
        } else if (docStatus == 'pending') {
          // Check which side is the "owner" vs. "recipient"
          if (userIdObj['_id'] == userId) {
            // If the doc userId == me => I sent the request => Outgoing
            newOutgoing.add(doc);
          } else if (buddyIdObj['_id'] == userId) {
            // If the doc buddyId == me => I'm receiving => Incoming
            newIncoming.add(doc);
          }
        }
        // If doc.status == 'removed' or anything else, you can skip or handle
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
      // Remove myself from results
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
        // Remove from search results
        searchResults.removeWhere((user) => user['_id'] == buddyId);
      });
      // Reload so we see it under Outgoing
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

  Widget _buildIncomingRequests() {
    if (incomingRequests.isEmpty) {
      return const Text('No incoming requests', style: TextStyle(color: Colors.white70));
    }
    return Column(
      children: incomingRequests.map((doc) {
        final docId = doc['_id'];
        final user = doc['userId']; // the sender
        final userName = user['name'] ?? 'Unnamed';
        final userUsername = user['username'] ?? 'No username';
        return Card(
          color: Colors.grey[850],
          child: ListTile(
            title: Text(userName, style: const TextStyle(color: Colors.white)),
            subtitle: Text(userUsername, style: const TextStyle(color: Colors.white70)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.check, color: Colors.green),
                  onPressed: () => _acceptRequest(docId),
                ),
                IconButton(
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
      return const Text('No outgoing requests', style: TextStyle(color: Colors.white70));
    }
    return Column(
      children: outgoingRequests.map((doc) {
        final buddy = doc['buddyId']; // the receiver
        final docId = doc['_id'];
        final buddyName = buddy['name'] ?? 'Unnamed';
        final buddyUsername = buddy['username'] ?? 'No username';
        return Card(
          color: Colors.grey[850],
          child: ListTile(
            title: Text(buddyName, style: const TextStyle(color: Colors.white)),
            subtitle: Text(buddyUsername, style: const TextStyle(color: Colors.white70)),
            // If you want to let user cancel the request, you can do a delete or set status=removed
            trailing: IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: () => _declineRequest(docId),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildConnectedBuddies() {
    if (connectedBuddies.isEmpty) {
      return const Text('No connected buddies', style: TextStyle(color: Colors.white70));
    }
    return Column(
      children: connectedBuddies.map((doc) {
        final docUserId = doc['userId']['_id'];
        final docBuddyId = doc['buddyId']['_id'];
        // figure out which one is "the other person"
        final bool amUserId = (docUserId == widget.currentUserId);
        final theOther = amUserId ? doc['buddyId'] : doc['userId'];

        final otherName = theOther['name'] ?? 'Unnamed';
        final otherUsername = theOther['username'] ?? 'No username';
        return Card(
          color: Colors.grey[850],
          child: ListTile(
            title: Text(otherName, style: const TextStyle(color: Colors.white)),
            subtitle: Text(otherUsername, style: const TextStyle(color: Colors.white70)),
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
                                icon: const Icon(Icons.person_add, color: Colors.blueAccent),
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
