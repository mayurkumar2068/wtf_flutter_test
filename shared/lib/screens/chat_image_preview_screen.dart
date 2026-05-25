import 'package:flutter/material.dart';
import '../core/strings/app_strings.dart';
import '../utils/chat_image_utils.dart';

class ChatImagePreviewScreen extends StatelessWidget {
  const ChatImagePreviewScreen({super.key, required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text(AppStrings.photoPreview),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded),
            tooltip: AppStrings.downloadPhoto,
            onPressed: () async {
              final path = await downloadChatImage(imageUrl);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    path != null
                        ? AppStrings.photoSaved
                        : AppStrings.downloadFailed,
                  ),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4,
          child: buildChatImage(
            imageUrl,
            height: MediaQuery.sizeOf(context).height * 0.7,
            width: MediaQuery.sizeOf(context).width,
          ),
        ),
      ),
    );
  }
}
