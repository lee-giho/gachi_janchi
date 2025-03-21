import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ReviewRegistrationScreen extends StatefulWidget {
  const ReviewRegistrationScreen({super.key});

  @override
  State<ReviewRegistrationScreen> createState() => _ReviewRegistrationScreenState();
}

class _ReviewRegistrationScreenState extends State<ReviewRegistrationScreen> {

  final picker = ImagePicker();
  final int maxImages = 5; // 사진 최대 업로그 개수 설정
  List<XFile> selectedImages = [];
  Set<String> selectedImageHashes = {}; // 동일한 사진 방지용 Set

  // 갤러리에서 이미지 선택 (중복 방지)
  Future<void> pickImages() async {
    final List<XFile>? images = await picker.pickMultiImage();

    if (images != null && images.isNotEmpty) {
      if (images.length >= maxImages || selectedImages.length >= maxImages) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("최대 $maxImages개의 이미지만 선택할 수 있습니다."))
        );
        return; // 함수 종료
      } else {
        for (var image in images) {
          String imageHash = await _calculateImageHash(image); // 파일의 md5 해시 생성
          print("imageHash: $imageHash");
          if (!selectedImageHashes.contains(imageHash)) { // 중복된 해시값이 없으면 추가
            setState(() {
              selectedImages.add(image);
              selectedImageHashes.add(imageHash);
            });
          }
        }
      } 
    }
  }

  // 파일의 md5 해시값 계산
  Future<String> _calculateImageHash(XFile image) async {
    final bytes = await File(image.path).readAsBytes(); // 파일을 바이트로 읽음
    return md5.convert(bytes).toString(); // md5 해시값 생성
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Align(
          alignment: Alignment.topLeft,
          child: Text("사진 선택")
        )
      ),
      body: SafeArea(
        child: Container( // 전체화면
        padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
          child: Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "사진 등록",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        "${selectedImages.length}/5"
                      )
                    ],
                  ),
                  Container(
                    height: 120,
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(width: 1)
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            border: Border.all(width: 1),
                            borderRadius: BorderRadius.circular(10)
                          ),
                          child: InkWell(
                            onTap: () {
                              pickImages();
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.photo,
                                  size: 40,
                                ),
                                Text(
                                  "사진 등록"
                                )
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: selectedImages.isEmpty
                            ? const Center(
                                child: Text("선택된 이미지가 없습니다."),
                              )
                            : ListView.builder(
                              scrollDirection: Axis.horizontal, // 가로 스크롤
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              itemCount: selectedImages.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.file(
                                      File(selectedImages[index].path),
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                );
                              }
                            ),
                        ),
                      ],
                    )
                    ,
                  ),
                ],
              )
            ],
          ),
        )
      ),
    );
  }
}