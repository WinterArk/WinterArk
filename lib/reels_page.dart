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
  bool _showReels = false;

  final List<String> _demoVideoPaths = [
    'assets/videos/demo1.mp4',
    'assets/videos/demo2.mp4',
    'assets/videos/demo3.mp4',
    'assets/videos/demo4.mp4',
    'assets/videos/demo5.mp4',
    'assets/videos/demo6.mp4',
    'assets/videos/demo7.mp4',
    'assets/videos/demo8.mp4',
    'assets/videos/demo9.mp4',
    'assets/videos/demo10.mp4',
    'assets/videos/demo11.mp4',
    'assets/videos/demo12.mp4',
    'assets/videos/demo13.mp4',
    'assets/videos/demo14.mp4',
    'assets/videos/demo15.mp4',
  ];

  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pageController = PageController(initialPage: _currentReelIndex);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    super.dispose();
  }

  void _toggleShowReels() {
    setState(() {
      _showReels = !_showReels;
    });
  }

  Widget _tabButton(String label, int index) {
    return GestureDetector(
      onTap: () {
        setState(() => _selectedTab = index);
        if (index == 0 && _showReels) {
          _pageController.jumpToPage(_currentReelIndex);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
        decoration: BoxDecoration(
          color: _selectedTab == index
              ? Colors.blueAccent.withOpacity(0.3)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: _selectedTab == index ? Colors.blueAccent : Colors.white,
            fontSize: 14,
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
        automaticallyImplyLeading: false,
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
            onPressed: () => debugPrint('Camera pressed'),
          ),
          IconButton(
            icon: Icon(
              _showReels ? Icons.visibility_off : Icons.visibility,
              color: Colors.white,
            ),
            tooltip: _showReels ? 'Hide Reels' : 'Show Reels',
            onPressed: _toggleShowReels,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
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
          ? (_showReels
          ? PageView.builder(
        scrollDirection: Axis.vertical,
        controller: _pageController,
        itemCount: _demoVideoPaths.length,
        onPageChanged: (index) {
          setState(() => _currentReelIndex = index);
        },
        itemBuilder: (context, index) {
          return _VideoTile(
            key: ValueKey(index),
            assetPath: _demoVideoPaths[index],
            index: index,
            playOnLoad: index == _currentReelIndex,
          );
        },
      )
          : Center(
        child: Text(
          'Reels are hidden.\nTap the eye icon to show.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      ))
          : SharedDashboard(userId: widget.userId),
    );
  }
}

class _VideoTile extends StatefulWidget {
  final String assetPath;
  final int index;
  final bool playOnLoad;

  const _VideoTile({
    super.key,
    required this.assetPath,
    required this.index,
    this.playOnLoad = false,
  });

  @override
  __VideoTileState createState() => __VideoTileState();
}

class __VideoTileState extends State<_VideoTile> {
  late final VideoPlayerController _controller;
  bool _initialized = false;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.assetPath)
      ..setLooping(true)
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() {
          _initialized = true;
          if (widget.playOnLoad) {
            _controller.play();
            _isPlaying = true;
          }
        });
      });
  }

  @override
  void didUpdateWidget(covariant _VideoTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_initialized) return;
    if (!oldWidget.playOnLoad && widget.playOnLoad) {
      _controller.play();
      setState(() => _isPlaying = true);
    } else if (oldWidget.playOnLoad && !widget.playOnLoad) {
      _controller.pause();
      setState(() => _isPlaying = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return GestureDetector(
      onTap: () {
        setState(() {
          if (_controller.value.isPlaying) {
            _controller.pause();
            _isPlaying = false;
          } else {
            _controller.play();
            _isPlaying = true;
          }
        });
      },
      child: Stack(
        children: [
          Center(
            child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            ),
          ),
          Center(
            child: AnimatedOpacity(
              opacity: _isPlaying ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 300),
              child: const Icon(Icons.play_arrow, size: 80, color: Colors.white70),
            ),
          ),
          Positioned(
            right: 16,
            bottom: 32,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.favorite_border, size: 32, color: Colors.redAccent),
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
          ),
          Positioned(
            left: 16,
            bottom: 32,
            child: Text(
              'Demo Reel ${widget.index + 1}',
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
  }
}
