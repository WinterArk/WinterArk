// shared_dashboard.dart
import 'package:flutter/material.dart';
import 'api_service.dart';

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
                    final newPost =
                    await ApiService.createPost(widget.userId, description);
                    setState(() {
                      posts.insert(0, newPost);
                    });
                    Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error creating post: $e')));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Prevent duplicate back/sign-out arrow
        title: const Text('Shared Dashboard'),
        backgroundColor: Colors.black,
        actions: [
          // Dropdown button for actions (currently only "New Post")
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              items: <String>['New Post']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) {
                if (value == 'New Post') {
                  _showNewPostDialog();
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
  // Use a mutable copy of the post so we can update it
  late dynamic currentPost;

  @override
  void initState() {
    super.initState();
    currentPost = widget.post;
  }

  // Compute liked/disliked state dynamically from currentPost.
  bool get isLiked =>
      (currentPost['likedBy'] as List<dynamic>? ?? []).contains(widget.userId);
  bool get isDisliked =>
      (currentPost['dislikedBy'] as List<dynamic>? ?? []).contains(widget.userId);

  // Display a popup menu with Edit/Delete options (only for the post creator)
  void _showPostOptions() {
    showMenu<String>(
      context: context,
      position: const RelativeRect.fromLTRB(200, 100, 0, 0), // Adjust position as needed
      items: const <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'edit',
          child: Text('Edit Post'),
        ),
        PopupMenuItem<String>(
          value: 'delete',
          child: Text('Delete Post'),
        ),
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
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
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
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error updating post: $e')));
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
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post deleted successfully')));
      // Optionally, signal the parent widget to refresh the posts list.
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting post: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if the logged-in user is the creator of this post.
    final bool isCreator = currentPost['userId']?['_id'] == widget.userId;
    return Card(
      margin: const EdgeInsets.all(10),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with user info and (if creator) an options button.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: Text(
                        currentPost['userId']?['name'] != null &&
                            currentPost['userId']['name'].isNotEmpty
                            ? currentPost['userId']['name'][0]
                            : 'U',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      currentPost['userId']?['name'] ?? 'Unknown',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
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
            // Post description
            Text(
              currentPost['description'] ?? '',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            // Like/Dislike Row
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    isLiked ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
                    color: isLiked ? Colors.blue : Colors.grey,
                  ),
                  onPressed: () async {
                    try {
                      final updatedPost = await ApiService.likePost(
                          currentPost['_id'], widget.userId);
                      setState(() {
                        currentPost = updatedPost;
                      });
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error liking post: $e')),
                      );
                    }
                  },
                ),
                Text(((currentPost['likedBy'] as List<dynamic>?)?.length ?? 0)
                    .toString()),
                const SizedBox(width: 20),
                IconButton(
                  icon: Icon(
                    isDisliked
                        ? Icons.thumb_down
                        : Icons.thumb_down_alt_outlined,
                    color: isDisliked ? Colors.red : Colors.grey,
                  ),
                  onPressed: () async {
                    try {
                      final updatedPost = await ApiService.dislikePost(
                          currentPost['_id'], widget.userId);
                      setState(() {
                        currentPost = updatedPost;
                      });
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error disliking post: $e')),
                      );
                    }
                  },
                ),
                Text(((currentPost['dislikedBy'] as List<dynamic>?)?.length ?? 0)
                    .toString()),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(),
            // Comments List
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
            // Input to add a comment
            TextField(
              decoration: const InputDecoration(
                labelText: 'Add a comment...',
                border: OutlineInputBorder(),
                contentPadding:
                EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onSubmitted: (text) async {
                try {
                  final updatedPost = await ApiService.commentOnPost(
                      currentPost['_id'], widget.userId, text);
                  setState(() {
                    currentPost['comments'] = updatedPost['comments'];
                  });
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error adding comment: $e')));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
