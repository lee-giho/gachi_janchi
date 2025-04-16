import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gachi_janchi/screens/review_edit_screen.dart';
import 'package:gachi_janchi/utils/secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MenuPopUp extends StatelessWidget {
  final String reviewId;
  final VoidCallback fetchReview;
  final VoidCallback removeOverlay;
  final VoidCallback fetchUserInfo;
  final Map<String, dynamic>? reviewInfo;
  const MenuPopUp({
    super.key,
    required this.reviewId,
    required this.fetchReview,
    required this.removeOverlay,
    required this.fetchUserInfo,
    required this.reviewInfo
  });

  @override
  Widget build(BuildContext context) {

    Future<void> deleteReview() async {
      String? accessToken = await SecureStorage.getAccessToken();

      // .env에서 서버 URL 가져오기
      final apiAddress = Uri.parse("${dotenv.get("API_ADDRESS")}/api/review/reviewId");
      final headers = {
        'Authorization': 'Bearer ${accessToken}',
        'Content-Type': 'application/json'
      };

      try {
        final response = await http.delete(
          apiAddress,
          headers: headers,
          body: json.encode({
            'reviewId': reviewId
          })
        );

        if (response.statusCode == 200) {
          // 리뷰 삭제 성공
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("리뷰 삭제 완료"))
          );
          fetchReview();
          fetchUserInfo();
        } else {
          // 리뷰 삭제 실패
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("리뷰 삭제 실패"))
          );
        }
      } catch (e) {
        // 예외 처리
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("네트워크 오류: ${e.toString()}"))
        );
      }
    }

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
            onPressed: () async {
              print("수정하기");
              removeOverlay();
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReviewEditScreen(
                    reviewInfo: reviewInfo,
                  )
                )
              );
              if (result == true) {
                fetchReview();
                fetchUserInfo();
              }
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
              // removeOverlay();
              deleteReview();
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
