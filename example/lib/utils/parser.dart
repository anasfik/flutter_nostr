import 'dart:core';

/// Holds the extracted pieces of a social post.
class PostComponents {
  final String cleanText; // the text with URLs preserved for highlighting
  final List<String> hashtags;
  final List<String> mentions;
  final List<String> links;
  final List<String> media;

  const PostComponents({
    required this.cleanText,
    required this.hashtags,
    required this.mentions,
    required this.links,
    required this.media,
  });

  @override
  String toString() {
    return '''
PostComponents(
  cleanText: $cleanText,
  hashtags: $hashtags,
  mentions: $mentions,
  links: $links,
  media: $media
)
''';
  }
}

/// Responsible for parsing a raw post into structured data.
class PostParser {
  // Regex patterns - more precise matching
  // Hashtag: # followed by alphanumeric characters and underscores, optionally followed by word boundary
  static final RegExp _hashtagRegex = RegExp(r'#([a-zA-Z0-9_]+)');

  // Mention: @ followed by alphanumeric characters and underscores
  static final RegExp _mentionRegex = RegExp(r'@([a-zA-Z0-9_]+)');

  // URL: http/https protocol, followed by non-whitespace characters
  // More comprehensive pattern
  static final RegExp _urlRegex = RegExp(
    r'https?://(?:[-\w.])+(?:[:\d]+)?(?:/(?:[\w/_.])*)?(?:\?(?:[\w&=%.])*)?(?:#(?:[\w.])*)?',
    caseSensitive: false,
  );

  // Media file extensions
  static final List<String> _imageExtensions = [
    '.png',
    '.jpg',
    '.jpeg',
    '.gif',
    '.webp',
    '.svg',
    '.bmp',
    '.ico',
  ];
  static final List<String> _videoExtensions = [
    '.mp4',
    '.mov',
    '.webm',
    '.avi',
    '.mkv',
    '.flv',
    '.wmv',
  ];
  static final List<String> _audioExtensions = [
    '.mp3',
    '.wav',
    '.ogg',
    '.m4a',
    '.aac',
  ];

  static PostComponents parse(String rawText) {
    if (rawText.isEmpty) {
      return const PostComponents(
        cleanText: '',
        hashtags: [],
        mentions: [],
        links: [],
        media: [],
      );
    }

    // Extract hashtags, mentions, and URLs with their positions
    final hashtags = <String>[];
    final mentions = <String>[];
    final allUrls = <String>[];

    // Extract hashtags with full context
    for (final match in _hashtagRegex.allMatches(rawText)) {
      final tag = match.group(1)!;
      hashtags.add(tag);
    }

    // Extract mentions
    for (final match in _mentionRegex.allMatches(rawText)) {
      final mention = match.group(1)!;
      mentions.add(mention);
    }

    // Extract URLs
    for (final match in _urlRegex.allMatches(rawText)) {
      final url = match.group(0)!;
      allUrls.add(url);
    }

    // Separate URLs into media and links
    final media = <String>[];
    final links = <String>[];

    for (final url in allUrls) {
      final lowerUrl = url.toLowerCase();

      // Check if URL is media (image, video, audio)
      final isImage = _imageExtensions.any((ext) => lowerUrl.contains(ext));
      final isVideo = _videoExtensions.any((ext) => lowerUrl.contains(ext));
      final isAudio = _audioExtensions.any((ext) => lowerUrl.contains(ext));

      if (isImage || isVideo || isAudio) {
        media.add(url);
      } else {
        // Also check for common image hosting domains
        if (_isImageHostingDomain(lowerUrl)) {
          media.add(url);
        } else {
          links.add(url);
        }
      }
    }

    // Keep cleanText with all original content (for highlighting)
    final cleanText = rawText;

    return PostComponents(
      cleanText: cleanText,
      hashtags: hashtags,
      mentions: mentions,
      links: links,
      media: media,
    );
  }

  /// Check if URL is from a known image hosting domain
  static bool _isImageHostingDomain(String url) {
    final imageDomains = [
      'imgur.com',
      'i.imgur.com',
      'i.redd.it',
      'redd.it',
      'cloudinary.com',
      'cdn.',
      'images.',
      'photos.',
    ];
    return imageDomains.any((domain) => url.contains(domain));
  }
}
