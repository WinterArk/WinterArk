// lib/upload_page.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_service.dart';
import 'profile_post.dart';
import 'button_effects/ui_helpers.dart';

class UploadPage extends StatefulWidget {
  final String userId;
  const UploadPage({Key? key, required this.userId}) : super(key: key);

  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _captionCtrl = TextEditingController();
  bool _isLoading = false;

  Future<void> _pickAndUpload({
    required ImageSource source,
    required String mediaType,
  }) async {
    try {
      final XFile? filePicked = mediaType == 'image'
          ? await _picker.pickImage(source: source)
          : await _picker.pickVideo(source: source);
      if (filePicked == null) return;

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken');
      if (token == null) {
        showShortFadeSnack(context, 'Not logged in');
        return;
      }

      setState(() => _isLoading = true);

      await ApiService.createProfilePost(
        File(filePicked.path),
        mediaType: mediaType,
        caption:
            _captionCtrl.text.trim().isEmpty ? null : _captionCtrl.text.trim(),
        token: token,
      );

      showShortFadeSnack(context, 'Uploaded successfully!');
    } catch (e) {
      showShortFadeSnack(context, 'Upload failed: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _captionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double buttonSize = MediaQuery.of(context).size.width * 0.3;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          // children: [
          //   glowingIcon(Icons.post_add, Colors.white, 28),
          //   const SizedBox(width: 8),
          //   Text(
          //     "New Post",
          //     style: glowingTextStyle(
          //       Colors.white,
          //       size: 26,
          //     ),
          //   ),
          // ],
        ),
        backgroundColor: Colors.black,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // TextField(
                //   controller: _captionCtrl,
                //   style: const TextStyle(color: Colors.white70),
                //   decoration: inputDecoration('Caption (optional)'),
                // ),
                // const SizedBox(height: 24),

                // Centered two-column layout
                const SizedBox(height: 165),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Photo column
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Pick Photo
                        GestureDetector(
                          onTap: () => _pickAndUpload(
                            source: ImageSource.gallery,
                            mediaType: 'image',
                          ),
                          child: Container(
                            width: buttonSize,
                            height: buttonSize,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow:
                                  glowShadows(blueGrotto, radii: [6, 12, 18]),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                glowingIcon(
                                    Icons.photo_library, blueGrotto, 32),
                                const SizedBox(height: 8),
                                Text('Pick Photo',
                                    style:
                                        glowingTextStyle(blueGrotto, size: 16)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Take Photo
                        GestureDetector(
                          onTap: () => _pickAndUpload(
                            source: ImageSource.camera,
                            mediaType: 'image',
                          ),
                          child: Container(
                            width: buttonSize,
                            height: buttonSize,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow:
                                  glowShadows(blueGrotto, radii: [6, 12, 18]),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                glowingIcon(Icons.camera_alt, blueGrotto, 32),
                                const SizedBox(height: 8),
                                Text('Take Photo',
                                    style:
                                        glowingTextStyle(blueGrotto, size: 16)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 48),
                    // Video column
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Pick Video
                        GestureDetector(
                          onTap: () => _pickAndUpload(
                            source: ImageSource.gallery,
                            mediaType: 'video',
                          ),
                          child: Container(
                            width: buttonSize,
                            height: buttonSize,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow:
                                  glowShadows(aquamarine, radii: [6, 12, 18]),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                glowingIcon(
                                    Icons.video_library, aquamarine, 32),
                                const SizedBox(height: 8),
                                Text('Pick Video',
                                    style:
                                        glowingTextStyle(aquamarine, size: 16)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Record Video
                        GestureDetector(
                          onTap: () => _pickAndUpload(
                            source: ImageSource.camera,
                            mediaType: 'video',
                          ),
                          child: Container(
                            width: buttonSize,
                            height: buttonSize,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow:
                                  glowShadows(aquamarine, radii: [6, 12, 18]),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                glowingIcon(Icons.videocam, aquamarine, 32),
                                const SizedBox(height: 8),
                                Text('Record Video',
                                    style:
                                        glowingTextStyle(aquamarine, size: 16)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
