import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ProfileWidget extends StatelessWidget {
  final String? imagePath;

  const ProfileWidget({super.key, this.imagePath});

  @override
  Widget build(BuildContext context) {
    // 경로가 null이거나 빈 문자열이면 null 처리
    final resolvedImagePath = (imagePath != null && imagePath!.isNotEmpty)
        ? (imagePath!.startsWith("http")
            ? imagePath!
            : "${dotenv.get("API_ADDRESS")}/images/profile/$imagePath")
        : null;

    return CircleAvatar(
      radius: 50,
      backgroundColor: Colors.grey[300],
      backgroundImage:
          resolvedImagePath != null ? NetworkImage(resolvedImagePath) : null,
      child: resolvedImagePath == null
          ? const Icon(Icons.person, size: 50, color: Colors.black)
          : null,
    );
  }
}
