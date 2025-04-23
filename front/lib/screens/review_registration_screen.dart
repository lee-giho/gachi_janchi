import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gachi_janchi/utils/secure_storage.dart';
import 'package:gachi_janchi/utils/serverRequest.dart';
import 'package:gachi_janchi/widgets/StarRating.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ReviewRegistrationScreen extends StatefulWidget {
  final Map<String, dynamic> data;

  const ReviewRegistrationScreen({super.key, required this.data});

  @override
  State<ReviewRegistrationScreen> createState() => _ReviewRegistrationScreenState();
}

class _ReviewRegistrationScreenState extends State<ReviewRegistrationScreen> {

  final picker = ImagePicker();
  final int maxImages = 5; // 사진 최대 업로그 개수 설정
  List<XFile> selectedImages = [];
  Set<String> selectedImageHashes = {}; // 동일한 사진 방지용 Set

  final formKey = GlobalKey<FormState>();
  var contentController = TextEditingController(); // 리뷰 내용 값 저장
  FocusNode contentFocus = FocusNode(); // 리뷰 내용 FocusNode

  List<String> selectedMenus = []; // 먹은 음식 선택 리스트

  int reviewRating = 0; // 리뷰 별점

  bool isSubmitEnabled = false; // 리뷰 작성 버튼 활성화 조건
  
  @override
  void initState() {
    super.initState();
    contentController.addListener(updateSubitButtonState);
  }

  @override
  void dispose() {
    super.dispose();
    contentController.removeListener(updateSubitButtonState);
    contentController.dispose();
    contentFocus.dispose();
  }

  // 갤러리에서 이미지 선택 (중복 방지)
  Future<void> pickImages() async {
    final List<XFile>? images = await picker.pickMultiImage();

    print("images length: ${images?.length}");

    if (images != null && images.isNotEmpty) {
      if (images.length > maxImages || selectedImages.length >= maxImages) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("최대 $maxImages개의 이미지만 선택할 수 있습니다."))
        );
        return; // 함수 종료
      } else {
        for (var image in images) {
          String imageHash = await calculateImageHash(image); // 파일의 md5 해시 생성
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
  Future<String> calculateImageHash(XFile image) async {
    final bytes = await File(image.path).readAsBytes(); // 파일을 바이트로 읽음
    return md5.convert(bytes).toString(); // md5 해시값 생성
  }

  // 버튼 상태 업데이트 함수
  void updateSubitButtonState() {
    setState(() {
      isSubmitEnabled = formKey.currentState?.validate() == true && reviewRating > 0;
    });
  }

  // 별점이 변경될 때 폼 검증 함수
  void onRatingChanged(int rating) {
    setState(() {
      reviewRating = rating;
      formKey.currentState?.validate();
      isSubmitEnabled = formKey.currentState?.validate() == true && reviewRating > 0;
    });
  }

  // 리뷰 작성 요청 함수
  Future<bool> submitReview({bool isFinalRequest = false}) async {
    print("리뷰 작성 요청");

    String? accessToken = await SecureStorage.getAccessToken();

    // .env에서 서버 URL 가져오기
    final apiAddress = Uri.parse("${dotenv.get("API_ADDRESS")}/api/review");

    final request = http.MultipartRequest('POST', apiAddress);

    // Header
    request.headers['Authorization'] = 'Bearer ${accessToken}';

    // 필수 데이터
    request.fields['visitedId'] = widget.data['visitedId'];
    request.fields['restaurantId'] = widget.data['restaurantId'];
    request.fields['rating'] = reviewRating.toString();
    request.fields['content'] = contentController.text;

    // 선택된 메뉴 리스트
    // for (String menu in selectedMenus) {
    //   request.fields['menuNames'] = menu;
    // }

    for (int i = 0; i < selectedMenus.length; i++) {
      request.fields['menuNames[$i]'] = selectedMenus[i];
    }


    // 선택된 이미지 리스트
    for (var image in selectedImages) {
      request.files.add(await http.MultipartFile.fromPath(
        'images', image.path
      ));
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        print("리뷰 작성 성공!!!");
        return true;
      } else {
        print("리뷰 작성 실패!!!");
        return false;
      }
    } catch (e) {
      if (isFinalRequest) {
        // 예외 처리
        print("네트워크 오류: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("네트워크 오류: ${e.toString()}"))
        );
      }
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Align(
          alignment: Alignment.topLeft,
          child: Text(
            "리뷰 작성",
            style: TextStyle(
              fontWeight: FontWeight.bold
            ),
          )
        )
      ),
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Container( // 전체화면
          padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
            child: Column( // 리뷰 작성하는 부분과 버튼
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: Form(
                      key: formKey,
                      child: Column( // 사진, 내용, 별점 작성하는 부분
                        children: [
                          Column( // 리뷰 사진 등록하는 부분
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "사진 등록 (선택)",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                height: 120,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  border: Border.all(width: 1),
                                  borderRadius: BorderRadius.circular(10)
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
                                        child: const Column(
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
                                    const SizedBox(width: 10),
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
                                            return Stack(
                                              children: [
                                                Padding(
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
                                                ),
                                                Positioned(
                                                  top: 0,
                                                  right: 10,
                                                  child: GestureDetector(
                                                    onTap: () async {
                                                      final imageHash = await calculateImageHash(selectedImages[index]);
                                                      setState(() {
                                                        selectedImageHashes.remove(imageHash);
                                                        selectedImages.removeAt(index);
                                                      });
                                                    },
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color: Colors.black.withOpacity(0.5),
                                                        shape: BoxShape.circle
                                                      ),
                                                      child: const Icon(
                                                        Icons.close,
                                                        color: Colors.white,
                                                        size: 20,
                                                      ),
                                                    ),
                                                  )
                                                )
                                              ]
                                            );
                                          }
                                        ),
                                    ),
                                  ],
                                )
                                ,
                              ),
                              Align(
                                alignment: Alignment.topRight,
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(0, 4, 10, 0),
                                  child: Text(
                                    "${selectedImages.length}/5",
                                    style: const TextStyle(
                                      fontSize: 12
                                    )
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 20),
                          Column( // 먹었던 메뉴 선택하는 부분
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "메뉴 (선택)",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                              MultiSelectBottomSheetField(
                                initialChildSize: 0.4,
                                maxChildSize: 0.9,
                                title: const Text("메뉴 선택"),
                                buttonText: const Text("메뉴를 선택하세요."),
                                items: (widget.data["restaurantMenu"] as List<dynamic>)
                                        .map<MultiSelectItem<String>>((menu) => MultiSelectItem<String>(
                                          menu["name"] as String,
                                          "${menu["name"]} (${menu["price"]})"
                                        ))
                                        .toList(),
                                searchable: true,
                                selectedColor: const Color.fromRGBO(122, 11, 11, 1),
                                onConfirm: (values) {
                                  setState(() {
                                    selectedMenus = values.cast<String>();
                                  });
                                  print("선택된 메뉴: $selectedMenus");
                                },
                                chipDisplay: MultiSelectChipDisplay(
                                  onTap: (value) {
                                    setState(() {
                                      selectedMenus.remove(value);
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Column( // 리뷰 내용 작성하는 부분
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "리뷰",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                              TextFormField(
                                controller: contentController,
                                focusNode: contentFocus,
                                maxLines: 5,
                                maxLength: 250,
                                keyboardType: TextInputType.multiline,
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return "리뷰 내용을 입력해주세요.";
                                  } else {
                                    return null;
                                  }
                                },
                                decoration: InputDecoration(
                                  hintText: "솔직한 리뷰를 남겨주세요.",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)
                                  ),
                                  enabledBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.black
                                    )
                                  ),
                                  focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Color.fromRGBO(122, 11, 11, 1)
                                    )
                                  )
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "별점",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                              StarRating(
                                onRatingChanged: (rating) {
                                  print("사용자가 선택한 별점: $rating");
                                  onRatingChanged(rating);
                                }
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: isSubmitEnabled && formKey.currentState!.validate()
                    ? () async {
                        print("리뷰 등록 버튼 클릭!!!");
                        print("리뷰 내용: ${contentController.text}");
                        print("별점: $reviewRating");
                        final result = await ServerRequest().serverRequest(({bool isFinalRequest = false}) => submitReview(isFinalRequest: isFinalRequest), context);
                        // submitReview();

                        if (result) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("리뷰를 작성했습니다."))
                          );
                          Navigator.pop(context);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("리뷰를 작성하지 못했습니다."))
                          );
                        }
                      }
                    : null,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    backgroundColor: const Color.fromRGBO(122, 11, 11, 1),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5)
                    )
                  ),
                  child: const Text(
                    "리뷰 등록",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold
                    ),
                  )
                )
              ],
            ),
          ),
        )
      ),
    );
  }
}