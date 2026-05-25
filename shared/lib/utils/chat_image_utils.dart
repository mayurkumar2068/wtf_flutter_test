import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../screens/chat_image_preview_screen.dart';
import '../utils/sync_host_resolver.dart';
import 'app_theme.dart';

/// Resolves message imageUrl to a displayable URI (local file or network).
String resolveChatImageUrl(String? imageUrl) {
  if (imageUrl == null || imageUrl.isEmpty) return '';
  if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
    return imageUrl;
  }
  if (imageUrl.startsWith('/uploads/')) {
    return '${SyncHostResolver.baseUrl}$imageUrl';
  }
  return imageUrl;
}

bool isLocalImagePath(String url) {
  if (url.isEmpty) return false;
  return url.startsWith('/') && !url.startsWith('/uploads');
}

Widget buildChatImage(String? imageUrl, {double height = 160, double? width}) {
  final resolved = resolveChatImageUrl(imageUrl);
  if (resolved.isEmpty) {
    return const SizedBox.shrink();
  }
  final w = width ?? 220.0;
  if (isLocalImagePath(resolved) && File(resolved).existsSync()) {
    return Image.file(
      File(resolved),
      height: height,
      width: w,
      fit: BoxFit.cover,
      gaplessPlayback: true,
      errorBuilder: (_, __, ___) => _brokenImage(height, w),
    );
  }
  return Image.network(
    resolved,
    height: height,
    width: w,
    fit: BoxFit.cover,
    gaplessPlayback: true,
    loadingBuilder: (ctx, child, progress) {
      if (progress == null) return child;
      return SizedBox(
        height: height,
        width: w,
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    },
    errorBuilder: (_, __, ___) => _brokenImage(height, w),
  );
}

Widget _brokenImage(double height, double width) {
  return Container(
    height: height,
    width: width,
    color: AppColors.neutral100,
    alignment: Alignment.center,
    child: const Icon(Icons.broken_image_outlined, color: AppColors.neutral500),
  );
}

Future<void> openChatImagePreview(BuildContext context, String? imageUrl) {
  final resolved = resolveChatImageUrl(imageUrl);
  if (resolved.isEmpty) return Future.value();
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => ChatImagePreviewScreen(imageUrl: resolved),
    ),
  );
}

/// Download / share image (works for network and local paths).
Future<String?> downloadChatImage(String imageUrl) async {
  final resolved = resolveChatImageUrl(imageUrl);
  if (resolved.isEmpty) return null;

  List<int> bytes;
  String filename;

  if (isLocalImagePath(resolved) && File(resolved).existsSync()) {
    bytes = await File(resolved).readAsBytes();
    filename = 'chat_${DateTime.now().millisecondsSinceEpoch}.jpg';
  } else {
    final res = await http.get(Uri.parse(resolved));
    if (res.statusCode != 200) return null;
    bytes = res.bodyBytes;
    final uri = Uri.parse(resolved);
    filename = uri.pathSegments.isNotEmpty
        ? uri.pathSegments.last
        : 'chat_${DateTime.now().millisecondsSinceEpoch}.jpg';
  }

  final dir = await getApplicationDocumentsDirectory();
  final outDir = Directory('${dir.path}/chat_downloads');
  if (!outDir.existsSync()) outDir.createSync(recursive: true);
  final outFile = File('${outDir.path}/$filename');
  await outFile.writeAsBytes(bytes);
  await Share.shareXFiles([XFile(outFile.path)], text: 'Chat photo');
  return outFile.path;
}
