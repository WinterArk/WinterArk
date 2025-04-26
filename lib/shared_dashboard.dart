import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'api_service.dart';

// Helper to format ISO timestamps into "April 22nd 2025, 10:32 PM" in local time.
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
  List<dynamic> posts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  Future<void> fetchPosts() async {
    try {
      final data = await ApiService.fetchPosts();
      setState(() {
        posts = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error fetching posts: $e')));
    }
  }

  void _showNewPostDialog() {
    final TextEditingController postController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create New Post'),
          content: TextField(
            controller: postController,
            decoration: const InputDecoration(
              hintText: 'Enter post description',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final description = postController.text.trim();
                if (description.isNotEmpty) {
                  try {
                    final newPost = await ApiService.createPost(
                      widget.userId,
                      description: description,
                    );
                    setState(() {
                      posts.insert(0, newPost);
                    });
                    Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text('Error creating post: $e')));
                  }
                }
              },
              child: const Text('Post'),
            ),
          ],
        );
      },
    );
  }

  void _showShareWorkoutDialog() async {
    List<dynamic> workouts = [];
    try {
      workouts = await ApiService.getPastWorkouts(widget.userId);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error fetching workouts: $e')));
      return;
    }
    String? selectedId;
    final TextEditingController descController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDlg) {
            return AlertDialog(
              title: const Text('Share a Workout'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<String>(
                    isExpanded: true,
                    value: selectedId,
                    hint: const Text('Select a workout'),
                    items: workouts.map<DropdownMenuItem<String>>((item) {
                      final w = item as Map<String, dynamic>;
                      final id = w['_id'] as String;
                      final name = w['exercise_name'] ?? 'Workout';
                      final date = w['date'] as String;
                      final dateStr = _formatDateTime(date);
                      return DropdownMenuItem(
                        value: id,
                        child: Text('$name on $dateStr'),
                      );
                    }).toList(),
                    onChanged: (val) => setStateDlg(() => selectedId = val),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descController,
                    decoration: const InputDecoration(
                      hintText: 'Optional description',
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: selectedId == null
                      ? null
                      : () async {
                    try {
                      final newPost = await ApiService.createPost(
                        widget.userId,
                        workoutId: selectedId,
                        description: descController.text.trim().isEmpty
                            ? null
                            : descController.text.trim(),
                      );
                      setState(() {
                        posts.insert(0, newPost);
                      });
                      Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text('Error sharing workout: $e')));
                    }
                  },
                  child: const Text('Share'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Shared Dashboard'),
        backgroundColor: Colors.black,
        actions: [
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              items: <String>['New Post', 'Share Workout']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) {
                if (value == 'New Post') {
                  _showNewPostDialog();
                } else if (value == 'Share Workout') {
                  _showShareWorkoutDialog();
                }
              },
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return WorkoutPostCard(post: post, userId: widget.userId);
        },
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

  @override
  void initState() {
    super.initState();
    currentPost = widget.post;
  }

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
    final TextEditingController editController =
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
                final newDesc = editController.text.trim();
                if (newDesc.isNotEmpty) {
                  try {
                    final updatedPost =
                    await ApiService.updatePost(currentPost['_id'], newDesc);
                    setState(() {
                      currentPost = updatedPost;
                    });
                    Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text('Error updating post: $e')));
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
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Post deleted successfully')));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error deleting post: $e')));
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
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text('Error liking post: $e')));
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
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text('Error disliking post: $e')));
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
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text('Error adding comment: $e')));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
