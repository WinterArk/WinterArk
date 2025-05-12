// reels_page.dart
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'shared_dashboard.dart';

class ReelsPage extends StatefulWidget {
  final String userId;
  const ReelsPage({super.key, required this.userId});

  @override
  _ReelsPageState createState() => _ReelsPageState();
}

class _ReelsPageState extends State<ReelsPage> with WidgetsBindingObserver {
  int _selectedTab = 0;
  int _currentReelIndex = 0;
  final List<String> _demoVideoPaths = [
    'assets/videos/demo1.mp4',
    'assets/videos/demo2.mp4',
    'assets/videos/demo3.mp4'
  ];

  final List<VideoPlayerController> _controllers = [];
  bool isLoading = true;
  bool _isPlaying = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initDemoControllers();
  }

  Future<void> _initDemoControllers() async {
    for (var path in _demoVideoPaths) {
      final c = VideoPlayerController.asset(path);
      await c.initialize();
      if (!mounted) {
        c.dispose();
        return;
      }
      c.setLooping(true);
      _controllers.add(c);
    }
    if (!mounted) return;
    setState(() {
      isLoading = false;
    });
    _playVideo(_currentReelIndex);
  }

  void _playVideo(int index) {
    for (int i = 0; i < _controllers.length; i++) {
      if (i == index) {
        _controllers[i].play();
      } else {
        _controllers[i].pause();
      }
    }
    setState(() {
      _currentReelIndex = index;
      _isPlaying = true;
    });
  }

  void _pauseAllVideos() {
    for (var controller in _controllers) {
      controller.pause();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    for (var controller in _controllers) {
      controller.dispose();
    }
    _controllers.clear();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      for (var controller in _controllers) {
        if (controller.value.isPlaying) {
          controller.pause();
        }
      }
    }
  }

  @override
  void deactivate() {
    for (var controller in _controllers) {
      controller.pause();
    }
    super.deactivate();
  }

  Widget _tabButton(String label, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = index;
        });
        if (index == 0) {
          _playVideo(_currentReelIndex);
        } else {
          _pauseAllVideos();
        }
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

  Widget _videoOverlay(int index) {
    return Positioned(
      right: 16,
      bottom: 32,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            icon: const Icon(Icons.favorite_border,
                size: 32, color: Colors.redAccent),
            onPressed: () {},
          ),
          const SizedBox(height: 12),
          IconButton(
            icon: const Icon(Icons.comment, size: 32, color: Colors.lightBlueAccent),
            onPressed: () {},
          ),
          const SizedBox(height: 12),
          IconButton(
            icon: const Icon(Icons.bookmark_border, size: 32, color: Colors.amber),
            onPressed: () {},
          ),
          const SizedBox(height: 12),
          IconButton(
            icon: const Icon(Icons.share, size: 32, color: Colors.greenAccent),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _playPauseIconOverlay() {
    return Center(
      child: AnimatedOpacity(
        opacity: _isPlaying ? 0.0 : 1.0,
        duration: const Duration(milliseconds: 300),
        child: const Icon(Icons.play_arrow, size: 80, color: Colors.white70),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false, // Disable default back arrow
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
          ? (isLoading
          ? const Center(child: CircularProgressIndicator())
          : PageView.builder(
        scrollDirection: Axis.vertical,
        controller: PageController(initialPage: _currentReelIndex),
        itemCount: _controllers.length,
        onPageChanged: (index) {
          _playVideo(index);
        },
        itemBuilder: (context, index) {
          final controller = _controllers[index];
          return GestureDetector(
            onTap: () {
              setState(() {
                if (controller.value.isPlaying) {
                  controller.pause();
                  _isPlaying = false;
                } else {
                  controller.play();
                  _isPlaying = true;
                }
              });
            },
            child: Stack(
              children: [
                SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: controller.value.size.width,
                      height: controller.value.size.height,
                      child: VideoPlayer(controller),
                    ),
                  ),
                ),
                _playPauseIconOverlay(),
                _videoOverlay(index),
                Positioned(
                  left: 16,
                  bottom: 32,
                  child: Text(
                    'Demo Reel ${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ))
          : SharedDashboard(userId: widget.userId),
    );
  }
}
