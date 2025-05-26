import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'api_service.dart';
import 'button_effects/ui_helpers.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

String _formatDateTime(String iso) {
  final dt = DateTime.parse(iso).toLocal();
  final month = DateFormat.MMMM().format(dt);
  final day = dt.day;
  String suffix;
  if (day >= 11 && day <= 13) {
    suffix = 'th';
  } else {
    switch (day % 10) {
      case 1:
        suffix = 'st';
        break;
      case 2:
        suffix = 'nd';
        break;
      case 3:
        suffix = 'rd';
        break;
      default:
        suffix = 'th';
    }
  }
  final year = dt.year;
  final time = DateFormat('h:mm a').format(dt);
  return '$month $day$suffix $year, $time';
}

class SharedDashboard extends StatefulWidget {
  final String userId;
  const SharedDashboard({super.key, required this.userId});

  @override
  _SharedDashboardState createState() => _SharedDashboardState();
}

class _SharedDashboardState extends State<SharedDashboard> {
  late IO.Socket socket;
  List<dynamic> posts = [];
  bool isLoading = true;
  TextEditingController? postController;

  @override
  void initState() {
    super.initState();
    _initSocket();
    fetchPosts();
  }

  @override
  void dispose() {
    socket.dispose();
    postController?.dispose();
    super.dispose();
  }

  void _initSocket() {
    socket = IO.io(
      ApiService.BASE_URL,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setQuery({'userId': widget.userId})
          .build(),
    );

    // Explicitly connect
    socket.connect();

    socket.onConnect((_) {
      debugPrint('⚡ Socket connected as ${socket.id}');
      // join your personal room
      socket.emit('join', widget.userId);
      debugPrint('📥 Emitted join for room ${widget.userId}');
    });

    socket.onConnectError((err) {
      debugPrint('❌ Socket connect error: $err');
    });

    socket.onError((err) {
      debugPrint('⚠️ Socket error: $err');
    });

    socket.onDisconnect((_) {
      debugPrint('🔌 Socket disconnected');
    });

    socket.on('new_post', (data) {
      debugPrint('📨 new_post received: ${data['description']}');
      setState(() {
        posts.insert(0, data);
      });
    });
  }

  Future<void> fetchPosts() async {
    setState(() => isLoading = true);
    try {
      final data = await ApiService.fetchSharedPosts(widget.userId);
      setState(() {
        posts = data;
      });
    } catch (e) {
      showShortFadeSnack(context, 'Error fetching posts: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showNewPostDialog() {
    postController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create New Post'),
        content: TextField(
          controller: postController,
          decoration: const InputDecoration(hintText: 'Enter post description'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final desc = postController!.text.trim();
              if (desc.isEmpty) return;
              try {
                final newPost = await ApiService.createPost(widget.userId, description: desc);
                // we’ll also get it via socket—but insert locally immediately:
                setState(() => posts.insert(0, newPost));
                Navigator.pop(ctx);
              } catch (e) {
                showShortFadeSnack(context, 'Error creating post: $e');
              }
            },
            child: const Text('Post'),
          ),
        ],
      ),
    );
  }

  void _showShareWorkoutDialog() async {
    List<dynamic> workouts;
    try {
      workouts = await ApiService.getPastWorkouts(widget.userId);
    } catch (e) {
      showShortFadeSnack(context, 'Error fetching workouts: $e');
      return;
    }
    String? selectedId;
    final descCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, setDlg) => AlertDialog(
          title: const Text('Share a Workout'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<String>(
                isExpanded: true,
                value: selectedId,
                hint: const Text('Select a workout'),
                items: workouts.map((item) {
                  final w = item as Map<String, dynamic>;
                  final id = w['_id'] as String;
                  final name = w['exercise_name'] ?? 'Workout';
                  final dateStr = _formatDateTime(w['date'] as String);
                  return DropdownMenuItem(value: id, child: Text('$name on $dateStr'));
                }).toList(),
                onChanged: (v) => setDlg(() => selectedId = v),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(hintText: 'Optional description'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx2), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: selectedId == null
                  ? null
                  : () async {
                try {
                  final newPost = await ApiService.createPost(
                    widget.userId,
                    workoutId: selectedId,
                    description: descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
                  );
                  setState(() => posts.insert(0, newPost));
                  Navigator.pop(ctx2);
                } catch (e) {
                  showShortFadeSnack(ctx, 'Error sharing workout: $e');
                }
              },
              child: const Text('Share'),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shared Dashboard'),
        backgroundColor: Colors.black,
        centerTitle: true,
        actions: [
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              items: const ['New Post', 'Share Workout']
                  .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                  .toList(),
              onChanged: (v) {
                if (v == 'New Post') _showNewPostDialog();
                if (v == 'Share Workout') _showShareWorkoutDialog();
              },
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: posts.length,
        itemBuilder: (_, i) => WorkoutPostCard(post: posts[i], userId: widget.userId),
      ),
    );
  }
}

class WorkoutPostCard extends StatefulWidget {
  final dynamic post;
  final String userId;
  const WorkoutPostCard({super.key, required this.post, required this.userId});

  @override
  _WorkoutPostCardState createState() => _WorkoutPostCardState();
}

class _WorkoutPostCardState extends State<WorkoutPostCard> {
  late dynamic currentPost;
  TextEditingController? editController;

  @override
  void initState() {
    super.initState();
    currentPost = widget.post;
  }


  @override
  void dispose() {
    editController?.dispose();
    super.dispose();
  }

  // Compute liked/disliked state dynamically from currentPost.
  bool get isLiked =>
      (currentPost['likedBy'] as List<dynamic>? ?? []).contains(widget.userId);
  bool get isDisliked =>
      (currentPost['dislikedBy'] as List<dynamic>? ?? []).contains(widget.userId);

  Widget _buildPostContent() {
    final workout = currentPost['workoutId'];
    if (workout != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            workout['exercise_name'] ?? 'Workout',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text('Sets: ${workout['sets']}   Reps: ${workout['reps']}'),
          Text('Weight: ${workout['weight']} ${workout['weightUnit']}'),
          if ((currentPost['description'] as String?)?.isNotEmpty ?? false)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                currentPost['description'],
                style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
              ),
            ),
          Text(
            'Date: ${_formatDateTime(workout['date'])}',
            style: const TextStyle(fontSize: 12, color: Colors.white70),
          ),
        ],
      );
    } else {
      return Text(
        currentPost['description'] ?? '',
        style: const TextStyle(fontSize: 16),
      );
    }
  }

  void _showPostOptions() {
    showMenu<String>(
      context: context,
      position: const RelativeRect.fromLTRB(200, 100, 0, 0),
      items: const <PopupMenuEntry<String>>[
        PopupMenuItem<String>(value: 'edit', child: Text('Edit Post')),
        PopupMenuItem<String>(value: 'delete', child: Text('Delete Post')),
      ],
    ).then((value) {
      if (value == 'edit') {
        _showEditDialog();
      } else if (value == 'delete') {
        _deletePost();
      }
    });
  }

  void _showEditDialog() {
    editController =
    TextEditingController(text: currentPost['description']);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Post'),
          content: TextField(
            controller: editController,
            decoration: const InputDecoration(
              hintText: 'Update post description',
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final newDesc = editController!.text.trim();
                if (newDesc.isNotEmpty) {
                  try {
                    final updatedPost =
                    await ApiService.updatePost(currentPost['_id'], newDesc);
                    setState(() {
                      currentPost = updatedPost;
                    });
                    Navigator.pop(context);
                  } catch (e) {
                     showShortFadeSnack(context, 'Error updating post: $e');
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deletePost() async {
    try {
      await ApiService.deletePost(currentPost['_id']);
      showShortFadeSnack(context, 'Post deleted successfully');
      // Optionally, signal the parent widget to refresh the posts list.
    } catch (e) {
      showShortFadeSnack(context, 'Error deleting post: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isCreator = currentPost['userId']?['_id'] == widget.userId;
    return Card(
      margin: const EdgeInsets.all(10),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: Text(
                        currentPost['userId']?['name'] != null && currentPost['userId']['name'].isNotEmpty
                            ? currentPost['userId']['name'][0]
                            : 'U',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      currentPost['userId']?['name'] ?? 'Unknown',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                if (isCreator)
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: _showPostOptions,
                  ),
              ],
            ),
            const SizedBox(height: 10),
            _buildPostContent(),
            const SizedBox(height: 10),
            Row(
              children: [
                IconButton(
                  icon: Icon(isLiked ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
                      color: isLiked ? Colors.blue : Colors.grey),
                  onPressed: () async {
                    try {
                      final updatedPost = await ApiService.likePost(currentPost['_id'], widget.userId);
                      setState(() {
                        currentPost = updatedPost;
                      });
                    } catch (e) {
                      showShortFadeSnack(context, 'Error liking post: $e');
                    }
                  },
                ),
                Text(((currentPost['likedBy'] as List<dynamic>?)?.length ?? 0).toString()),
                const SizedBox(width: 20),
                IconButton(
                  icon: Icon(isDisliked ? Icons.thumb_down : Icons.thumb_down_alt_outlined,
                      color: isDisliked ? Colors.red : Colors.grey),
                  onPressed: () async {
                    try {
                      final updatedPost = await ApiService.dislikePost(currentPost['_id'], widget.userId);
                      setState(() {
                        currentPost = updatedPost;
                      });
                    } catch (e) {
                      showShortFadeSnack(context, 'Error disliking post: $e');
                    }
                  },
                ),
                Text(((currentPost['dislikedBy'] as List<dynamic>?)?.length ?? 0).toString()),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(),
            Column(
              children: (currentPost['comments'] as List<dynamic>).map((comment) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(comment['userId']?['name'] ?? 'Anonymous'),
                  subtitle: Text(comment['text'] ?? ''),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Add a comment...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onSubmitted: (text) async {
                try {
                  final updatedPost = await ApiService.commentOnPost(currentPost['_id'], widget.userId, text);
                  setState(() {
                    currentPost['comments'] = updatedPost['comments'];
                  });
                } catch (e) {
                    showShortFadeSnack(context, 'Error adding comment: $e');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
