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
        caption: _captionCtrl.text.trim().isEmpty
            ? null
            : _captionCtrl.text.trim(),
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
    return Scaffold(
      appBar: AppBar(
        title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          glowingIcon(Icons.post_add, blueGrotto, 28),
          const SizedBox(width: 8),
          Text(
            "New Post",
            style: glowingTextStyle(
              blueGrotto,
              size: 26,
            ),
          ),
        ],
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
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Photo column
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        neonPicker(
                          icon: glowingIcon(Icons.photo_library, babyBlue, 24),
                          label: 'Pick Photo',
                          glowColor: babyBlue,
                          onTap: () => _pickAndUpload(
                            source: ImageSource.gallery,
                            mediaType: 'image',
                          ),
                        ),
                        const SizedBox(height: 40),
                        neonPicker(
                          icon: glowingIcon(Icons.camera_alt, babyBlue, 24),
                          label: 'Take Photo',
                          glowColor: babyBlue,
                          onTap: () => _pickAndUpload(
                            source: ImageSource.camera,
                            mediaType: 'image',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(width: 48),

                    // Video column
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        neonPicker(
                          icon: glowingIcon(Icons.video_library, aquamarine, 24),
                          label: 'Pick Video',
                          glowColor: aquamarine,
                          onTap: () => _pickAndUpload(
                            source: ImageSource.gallery,
                            mediaType: 'video',
                          ),
                        ),
                        const SizedBox(height: 40),
                        neonPicker(
                          icon: glowingIcon(Icons.videocam, aquamarine, 24),
                          label: 'Record Video',
                          glowColor: aquamarine,
                          onTap: () => _pickAndUpload(
                            source: ImageSource.camera,
                            mediaType: 'video',
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