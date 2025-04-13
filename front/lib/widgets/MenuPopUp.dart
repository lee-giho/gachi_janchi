import 'package:flutter/material.dart';

class MenuPopUp extends StatelessWidget {
  final String reviewId;
  const MenuPopUp({
    super.key,
    required this.reviewId
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton.icon(
            onPressed: () {
              print("수정하기");
            },
            icon: const Icon(Icons.edit, color: Colors.black),
            label: const Text(
              "수정하기",
              style: TextStyle(color: Colors.black),
            ),
          ),
          const Divider(height: 1),
          TextButton.icon(
            onPressed: () {
              print("삭제하기");
            },
            icon: const Icon(Icons.delete, color: Colors.red),
            label: const Text(
              "삭제하기",
              style: TextStyle(color: Colors.red),
            ),
          )
        ],
      ),
    );
  }
}
