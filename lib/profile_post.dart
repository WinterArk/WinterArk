class ProfilePost {
  final String id;
  final String userId;
  final String mediaUrl;
  final String mediaType;
  final String? caption;
  final DateTime createdAt;

  ProfilePost({
    required this.id,
    required this.userId,
    required this.mediaUrl,
    required this.mediaType,
    this.caption,
    required this.createdAt,
  });

  factory ProfilePost.fromJson(Map<String, dynamic> json) {
    return ProfilePost(
      id: json['_id'] as String,
      userId: json['userId'] as String,               // ← pull in userId
      mediaUrl: json['mediaUrl'] as String,
      mediaType: json['mediaType'] as String,
      caption: (json['caption'] as String?) ?? '',      // safe null-to-empty
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'userId': userId,
    'mediaUrl': mediaUrl,
    'mediaType': mediaType,
    'caption': caption,
    'createdAt': createdAt.toIso8601String(),
  };
}
