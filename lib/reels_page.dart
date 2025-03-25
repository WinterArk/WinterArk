// reels_page.dart
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'api_service.dart';
import 'shared_dashboard.dart';

class ReelsPage extends StatefulWidget {
  final String userId;
  const ReelsPage({super.key, required this.userId});

  @override
  _ReelsPageState createState() => _ReelsPageState();
}

class _ReelsPageState extends State<ReelsPage> {
  int _selectedTab = 0;
  VideoPlayerController? _controller;
  List<dynamic> reels = [];
  bool isLoadingReels = true;

  @override
  void initState() {
    super.initState();
    fetchReels();
  }

  Future<void> fetchReels() async {
    try {
      reels = await ApiService.fetchReels();
      setState(() {
        isLoadingReels = false;
      });
      if (reels.isNotEmpty) {
        _controller = VideoPlayerController.network(reels[0]['videoUrl'])
          ..initialize().then((_) {
            setState(() {});
          });
      }
    } catch (e) {
      setState(() {
        isLoadingReels = false;
      });
      debugPrint('Error fetching reels: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Widget _tabButton(String label, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        decoration: BoxDecoration(
          color: _selectedTab == index
              ? Colors.blueAccent.withOpacity(0.3)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: _selectedTab == index ? Colors.blueAccent : Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white12,
            borderRadius: BorderRadius.circular(30),
          ),
          child: const TextField(
            decoration: InputDecoration(
              hintText: 'Search...',
              hintStyle: TextStyle(color: Colors.white70),
              border: InputBorder.none,
              prefixIcon: Icon(Icons.search, color: Colors.white),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt, color: Colors.white),
            onPressed: () {
              debugPrint('Camera icon pressed');
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _tabButton('FYP', 0),
                _tabButton('Shared Dashboard', 1),
              ],
            ),
          ),
        ),
      ),
      body: _selectedTab == 0
          ? Center(
        child: isLoadingReels
            ? const CircularProgressIndicator()
            : (_controller != null && _controller!.value.isInitialized)
            ? AspectRatio(
          aspectRatio: _controller!.value.aspectRatio,
          child: VideoPlayer(_controller!),
        )
            : const Text('No reels available', style: TextStyle(color: Colors.white)),
      )
          : SharedDashboard(userId: widget.userId),
    );
  }
}
