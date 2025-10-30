import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:example/utils/parser.dart';
import 'package:linkify/linkify.dart';

/// A widget that renders parsed content with support for hashtags, mentions, links, and media
class ParsedContentRenderer extends StatelessWidget {
  final String text;
  final bool showMedia;
  final int? maxLength;

  const ParsedContentRenderer({
    Key? key,
    required this.text,
    this.showMedia = true,
    this.maxLength,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) {
      return Text(
        'No content',
        style: TextStyle(
          fontSize: 15,
          fontStyle: FontStyle.italic,
          color: Colors.grey[500],
        ),
      );
    }

    final postComponents = PostParser.parse(text);
    final displayText =
        maxLength != null && postComponents.cleanText.length > maxLength!
        ? '${postComponents.cleanText.substring(0, maxLength!)}...'
        : postComponents.cleanText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main text with hashtags, mentions, and links highlighted
        if (displayText.isNotEmpty)
          _buildTextWithHighlights(context, displayText, postComponents),

        // Hashtags chips
        if (postComponents.hashtags.isNotEmpty) ...[
          SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: postComponents.hashtags.map((tag) {
              return Chip(
                label: Text('#$tag', style: const TextStyle(fontSize: 12)),
                backgroundColor: Colors.blue[50],
                padding: EdgeInsets.symmetric(horizontal: 4),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              );
            }).toList(),
          ),
        ],

        // Mentions chips
        if (postComponents.mentions.isNotEmpty) ...[
          SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: postComponents.mentions.map((mention) {
              return Chip(
                label: Text('@$mention', style: const TextStyle(fontSize: 12)),
                backgroundColor: Colors.green[50],
                padding: EdgeInsets.symmetric(horizontal: 4),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              );
            }).toList(),
          ),
        ],

        // Links
        if (postComponents.links.isNotEmpty) ...[
          SizedBox(height: 8),
          ...postComponents.links.map((link) {
            return Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(Icons.link, size: 14, color: Colors.blue),
                  SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      link,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blue[600],
                        decoration: TextDecoration.underline,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],

        // Media previews
        if (showMedia && postComponents.media.isNotEmpty) ...[
          SizedBox(height: 8),
          ...postComponents.media.map((url) {
            return Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: _buildMediaPreview(url),
            );
          }),
        ],
      ],
    );
  }

  Widget _buildTextWithHighlights(
    BuildContext context,
    String text,
    PostComponents components,
  ) {
    // Use Linkify for URLs and then highlight hashtags and mentions
    return Linkify(
      text: text,
      linkifiers: [UrlLinkifier()],
      style: TextStyle(fontSize: 15, height: 1.4, color: Colors.grey[800]),
      linkStyle: TextStyle(
        color: Colors.blue[600],
        decoration: TextDecoration.underline,
      ),
    );
  }

  Widget _buildMediaPreview(String url) {
    // Detect if it's an image based on common image hosting patterns
    final isLikelyImage = _isImageUrl(url);

    if (isLikelyImage) {
      return _buildImagePreview(url);
    } else {
      // For other media types, show a link
      return Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey[200],
        ),
        child: Row(
          children: [
            Icon(Icons.play_circle_outline, color: Colors.grey[700]),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                url,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.blue[600],
                  decoration: TextDecoration.underline,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }
  }

  bool _isImageUrl(String url) {
    final imageExtensions = [
      '.png',
      '.jpg',
      '.jpeg',
      '.gif',
      '.webp',
      '.svg',
      '.bmp',
      '.ico',
    ];
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

    final lowerUrl = url.toLowerCase();
    return imageExtensions.any((ext) => lowerUrl.contains(ext)) ||
        imageDomains.any((domain) => lowerUrl.contains(domain));
  }

  Widget _buildImagePreview(String url) {
    return Builder(
      builder: (context) {
        return _ImagePreviewStateful(url: url);
      },
    );
  }
}

class _ImagePreviewStateful extends StatefulWidget {
  final String url;

  const _ImagePreviewStateful({required this.url});

  @override
  State<_ImagePreviewStateful> createState() => _ImagePreviewStatefulState();
}

class _ImagePreviewStatefulState extends State<_ImagePreviewStateful> {
  bool isLoading = true;
  bool hasError = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[200],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Loading indicator
            if (isLoading)
              Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[400]!),
                ),
              ),
            // Error indicator
            if (hasError)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.broken_image, size: 48, color: Colors.grey[400]),
                    SizedBox(height: 8),
                    Text(
                      'Failed to load image',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
            // Actual image
            Image.network(
              widget.url,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) {
                  // Image loaded successfully
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    setState(() {
                      isLoading = false;
                    });
                  });
                  return child;
                }
                return Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.blue[400]!,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                // Handle error
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  setState(() {
                    isLoading = false;
                    hasError = true;
                  });
                });
                return SizedBox.shrink(); // Return empty, error UI is in stack
              },
              // Add image headers to avoid CORS issues
              headers: {
                'User-Agent':
                    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
                'Accept': 'image/*',
              },
              // Cache the image
              cacheWidth: 800,
              cacheHeight: 800,
            ),
            // Tap to view fullscreen
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    _showFullscreenImage(context, widget.url);
                  },
                  child: Container(
                    child: Center(
                      child: Icon(
                        Icons.fullscreen,
                        color: Colors.white.withOpacity(0.7),
                        size: 32,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFullscreenImage(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.network(
                  url,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Icon(
                        Icons.broken_image,
                        color: Colors.white,
                        size: 64,
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    }
                    return Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    );
                  },
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: Icon(Icons.close, color: Colors.white, size: 28),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
