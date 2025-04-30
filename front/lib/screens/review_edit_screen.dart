import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gachi_janchi/utils/secure_storage.dart';
import 'package:gachi_janchi/utils/serverRequest.dart';
import 'package:gachi_janchi/widgets/StarRating.dart';
import 'package:image_picker/image_picker.dart';
import 'package:crypto/crypto.dart';
import 'package:multi_select_flutter/bottom_sheet/multi_select_bottom_sheet_field.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:multi_select_flutter/multi_select_flutter.dart';

class ReviewEditScreen extends StatefulWidget {
  final Map<String, dynamic>? reviewInfo;
  const ReviewEditScreen({
    super.key,
    required this.reviewInfo,
  });

  @override
  State<ReviewEditScreen> createState() => _ReviewEditScreenState();
}

class _ReviewEditScreenState extends State<ReviewEditScreen> {

  List<dynamic> restaurantMenus = [];

  // 기존 리뷰 데이터
  List<String> originalImageNames = [];
  List<String> originalMenus = [];
  String originalContent = "";
  int originalRating = 0;

  // 수정한 리뷰 데이터
  List<String> removeOriginalImageNames = [];
  List<XFile> changeImages = [];
  Set<String> changeImageHashes = {}; // 동일한 사진 방지용 Set
  List<String> changeMenus = [];
  var changeContentController = TextEditingController(); // 리뷰 내용 값 저장
  int changeRating = 0;

  final formKey = GlobalKey<FormState>();
  final picker = ImagePicker();
  final int maxImages = 5; // 사진 최대 업로그 개수 설정
  FocusNode changeContentFocus = FocusNode(); // 리뷰 내용 FocusNode

  bool isImageChanged = false;
  bool isMenuChanged = false;
  bool isContentChanged = false;
  bool isRatingChanged = false;

  @override
  void initState() {
    super.initState();
    initReviewData();
  }

  @override
  void dispose() {
    super.dispose();
    changeContentController.removeListener(() {
      isReviewModified("content");
    });
    changeContentController.dispose();
  }

  Future<void> initReviewData() async {
    await ServerRequest().serverRequest(({bool isFinalRequest = false}) => getRestaurantMenus(isFinalRequest: isFinalRequest), context);

    setState(() {
      originalImageNames = List<String>.from(widget.reviewInfo!["reviewImages"].map((img) => img["imageName"]));
      
      originalMenus = List<String>.from(widget.reviewInfo!["reviewMenus"].map((menu) => menu["menuName"]));
      changeMenus = originalMenus;

      originalContent = widget.reviewInfo!["review"]["content"];
      changeContentController.text = originalContent;

      originalRating = widget.reviewInfo!["review"]["rating"];
      changeRating = originalRating;
    });

    // 리뷰 내용 변경 리스너 등록
    changeContentController.addListener(() {
      isReviewModified("content");
    });

    print("restaurantMenus: $restaurantMenus");
    print("reviewInfo: ${widget.reviewInfo}");
    print("originalImageNames: $originalImageNames");
    print("originalMenus: $originalMenus");
    print("originalContent: $originalContent");
    print("originalRating: $originalRating");

    print("changeMenus: $changeMenus");
    print("changeContentController: $changeContentController");
    print("changeRating: $changeRating");
  }

  Future<bool> getRestaurantMenus({bool isFinalRequest = false}) async {
    print("음식점 메뉴 불러오기 시작");
    String? accessToken = await SecureStorage.getAccessToken();

    // .env에서 서버 URL 가져오기
    final apiAddress = Uri.parse("${dotenv.get("API_ADDRESS")}/api/restaurant/menu?restaurantId=${widget.reviewInfo!["review"]["restaurantId"]}");
    final headers = {
      'Authorization': 'Bearer ${accessToken}',
      'Content-Type': 'application/json'
    };

    try {
      final response = await http.get(
        apiAddress,
        headers: headers
      );
      if (response.statusCode == 200) {
        print("음식점 메뉴 불러오기 성공");

        // UTF-8로 디코딩
        final decodedData = utf8.decode(response.bodyBytes);
        final data = json.decode(decodedData);

        print("API 응답 데이터: ${data}");

        setState(() {
          restaurantMenus = data["menu"];
        });

        print("음식점 메뉴 불러오기 성공");
        return true;
      } else {
        print("음식점 메뉴 불러오기 실패");
        return false;
      }
    } catch (e) {
      if (isFinalRequest) {
        // 예외 처리
        print("네트워크 오류: $e");
        ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("네트워크 오류: ${e.toString()}")));
      }
      return false;
    }
  }

  // 갤러리에서 이미지 선택 (중복 방지)
  Future<void> pickImages() async {
    final List<XFile>? images = await picker.pickMultiImage();

    print("images length: ${images?.length}");

    if (images != null && images.isNotEmpty) {
      if (images.length > maxImages || // 선택한 이미지가 6개 이상일 경우
          changeImages.length >= maxImages || // 추가로 선택한 이미지가 5개 이상일 경우
          originalImageNames.length + changeImages.length >= maxImages || // 기존 이미지와 추가로 선택한 이미지의 합이 5 이상일 경우
          originalImageNames.length + images.length > maxImages || // 기존 이미지와 선택한 이미지의 합이 6 이상일 경우
          changeImages.length + images.length > maxImages) { // 추가로 선택한 이미지와 선택한 이미지의 합이 6 이상일 경우
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("최대 $maxImages개의 이미지만 선택할 수 있습니다."))
        );
        return; // 함수 종료
      } else {
        for (var image in images) {
          String imageHash = await calculateImageHash(image); // 파일의 md5 해시 생성
          print("imageHash: $imageHash");
          if (!changeImageHashes.contains(imageHash)) { // 중복된 해시값이 없으면 추가
            setState(() {
              changeImages.add(image);
              changeImageHashes.add(imageHash);
            });
          }
        }
      } 
    }

    isReviewModified("image");
  }

  // 파일의 md5 해시값 계산
  Future<String> calculateImageHash(XFile image) async {
    final bytes = await File(image.path).readAsBytes(); // 파일을 바이트로 읽음
    return md5.convert(bytes).toString(); // md5 해시값 생성
  }

  // 별점이 변경될 때 폼 검증 함수
  void onRatingChanged(int rating) {
    setState(() {
      changeRating = rating;
      formKey.currentState?.validate();
    });
    isReviewModified("rating");
  }

  void isReviewModified(String type) {
    setState(() {
      if (type == "image") {
        // 이미지 변경
        if (removeOriginalImageNames.isNotEmpty || changeImages.isNotEmpty) {
          isImageChanged = true;
        } else {
          isImageChanged = false;
        }
      } else if (type == "menu") {
        // 메뉴 변경
        if (!isSameList(originalMenus, changeMenus)) {
          isMenuChanged = true;
        } else {
          isMenuChanged = false;
        }
      } else if (type == "content") {
        // 리뷰 내용 변경
        if (originalContent != changeContentController.text) {
          isContentChanged = true;
        } else {
          isContentChanged = false;
        }
      } else if (type == "rating") {
        // 별점 변경
        if (originalRating != changeRating) {
          isRatingChanged = true;
        } else {
          isRatingChanged = false;
        }
      }
    });
    print("===================================");
    print("isImageChanged: $isImageChanged");
    print("isMenuChanged: $isMenuChanged");
    print("isContentChanged: $isContentChanged");
    print("isRatingChanged: $isRatingChanged");
    print("===================================");
  }

  // 리스트 내용 비교 함수 (순서 X)
  bool isSameList(List<String> a, List<String> b) {
    final aSorted = [...a]..sort();
    final bSorted = [...b]..sort();
    return listEquals(aSorted, bSorted);
  }

  Widget deleteIcon() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        shape: BoxShape.circle
      ),
      child: const Icon(
        Icons.close,
        color: Colors.white,
        size: 20,
      ),
    );
  }

  Future<bool> submitReviewUpdate({bool isFinalRequest = false}) async {
    String? accessToken = await SecureStorage.getAccessToken();
    final reviewId = widget.reviewInfo!["review"]["id"];

    // 필드별 변경 여부


    // .env에서 서버 URL 가져오기
    final apiAddress = Uri.parse("${dotenv.get("API_ADDRESS")}/api/review");

    final request = http.MultipartRequest('PATCH', apiAddress);

    // Header
    request.headers['Authorization'] = 'Bearer ${accessToken}';

    request.fields['reviewId'] = reviewId;
    print("originalImageNames.length: ${originalImageNames.length}");
    print("widget.reviewInfo: ${widget.reviewInfo!["reviewImages"].length}");
    if (isImageChanged) {
      if (removeOriginalImageNames.isNotEmpty) {
        print("removeOriginalImageNames");
        for (int i = 0; i < removeOriginalImageNames.length; i++) {
          request.fields['removeOriginalImageNames[$i]'] = removeOriginalImageNames[i];
        }
      } 
      if (changeImages.isNotEmpty) {
        print("changeImages");
        for (var image in changeImages) {
          request.files.add(await http.MultipartFile.fromPath(
            'changeImages', image.path
          ));
        }
      }
    } 
    if (isMenuChanged) {
      print("isMenuChanged");
      if (changeMenus.isEmpty) {
        request.fields['changeMenus'] = "remove all";
      } else {
        for (int i = 0; i < changeMenus.length; i++) {
          request.fields['changeMenus[$i]'] = changeMenus[i];
        }
      }
    }
    if (isContentChanged) {
      print("isContentChanged");
      request.fields['changeContent'] = changeContentController.text;
    }
    if (isRatingChanged) {
      print("isRatingChanged");
      request.fields['changeRating'] = changeRating.toString();
    }

    print(request.fields);
    print(request.files);

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        print("리뷰 수정 성공!!!");
        return true;
      } else {
        print("리뷰 수정 실패!!!");
        return false;
      }
    } catch (e) {
      if (isFinalRequest) {
        // 예외 처리
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
            "리뷰 수정",
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
                                      child: originalImageNames.isEmpty 
                                        ? changeImages.isEmpty
                                          ? const Center( // originalImages와 changeImages가 둘 다 없을 때
                                              child: Text("선택된 이미지가 없습니다."),
                                            )
                                          : ListView.builder( // changeImages만 있을 때
                                              scrollDirection: Axis.horizontal, // 가로 스크롤
                                              padding: const EdgeInsets.symmetric(horizontal: 8),
                                              itemCount: changeImages.length,
                                              itemBuilder: (context, index) {
                                                // 새로 추가된 이미지
                                                return Stack(
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets.only(right: 10),
                                                      child: ClipRRect(
                                                        borderRadius: BorderRadius.circular(10),
                                                        child: Image.file(
                                                          File(changeImages[index].path),
                                                          width: 100,
                                                          height: 100,
                                                          fit: BoxFit.cover,
                                                        )
                                                      )
                                                    ),
                                                    Positioned(
                                                      top: 0,
                                                      right: 10,
                                                      child: GestureDetector(
                                                        onTap: () async {
                                                          final imageHash = await calculateImageHash(changeImages[index]);
                                                          setState(() {
                                                            changeImageHashes.remove(imageHash);
                                                            changeImages.removeAt(index);
                                                          });
                                                          isReviewModified("image");
                                                        },
                                                        child: deleteIcon()
                                                      )
                                                    )
                                                  ]
                                                );  
                                              }
                                            )
                                        : changeImages.isEmpty
                                          ? ListView.builder( // originalImage만 있을 때
                                              scrollDirection: Axis.horizontal, // 가로 스크롤
                                              padding: const EdgeInsets.symmetric(horizontal: 8),
                                              itemCount: originalImageNames.length,
                                              itemBuilder: (context, index) {
                                                // 기존 이미지
                                                return Stack(
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets.only(right: 10),
                                                      child: ClipRRect(
                                                        borderRadius: BorderRadius.circular(10),
                                                        child: Image.network(
                                                          "${dotenv.env["API_ADDRESS"]}/images/review/${originalImageNames[index]}",
                                                          width: 100,
                                                          height: 100,
                                                          fit: BoxFit.cover,
                                                        )
                                                      )
                                                    ),
                                                    Positioned(
                                                      top: 0,
                                                      right: 10,
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          setState(() {
                                                            removeOriginalImageNames.add(originalImageNames[index]);
                                                            originalImageNames.removeAt(index);
                                                          });
                                                          isReviewModified("image");
                                                        },
                                                        child: deleteIcon()
                                                      )
                                                    )
                                                  ]
                                                );
                                              }
                                            )
                                          : ListView.builder( // originalImages와 changeImages 둘 다 있을 때
                                            scrollDirection: Axis.horizontal, // 가로 스크롤
                                            padding: const EdgeInsets.symmetric(horizontal: 8),
                                            itemCount: originalImageNames.length + changeImages.length,
                                            itemBuilder: (context, index) {
                                              if (index < originalImageNames.length) {
                                                // 기존 이미지
                                                return Stack(
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets.only(right: 10),
                                                      child: ClipRRect(
                                                        borderRadius: BorderRadius.circular(10),
                                                        child: Image.network(
                                                          "${dotenv.env["API_ADDRESS"]}/images/review/${originalImageNames[index]}",
                                                          width: 100,
                                                          height: 100,
                                                          fit: BoxFit.cover,
                                                        )
                                                      )
                                                    ),
                                                    Positioned(
                                                      top: 0,
                                                      right: 10,
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          setState(() {
                                                            removeOriginalImageNames.add(originalImageNames[index]);
                                                            originalImageNames.removeAt(index);
                                                          });
                                                          isReviewModified("image");
                                                        },
                                                        child: deleteIcon()
                                                      )
                                                    )
                                                  ]
                                                );
                                              } else {
                                                // 새로 추가된 이미지
                                                final changedIndex = index - originalImageNames.length;
                                                return Stack(
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets.only(right: 10),
                                                      child: ClipRRect(
                                                        borderRadius: BorderRadius.circular(10),
                                                        child: Image.file(
                                                          File(changeImages[changedIndex].path),
                                                          width: 100,
                                                          height: 100,
                                                          fit: BoxFit.cover,
                                                        )
                                                      )
                                                    ),
                                                    Positioned(
                                                      top: 0,
                                                      right: 10,
                                                      child: GestureDetector(
                                                        onTap: () async {
                                                          final imageHash = await calculateImageHash(changeImages[changedIndex]);
                                                          setState(() {
                                                            changeImageHashes.remove(imageHash);
                                                            changeImages.removeAt(changedIndex);
                                                          });
                                                          isReviewModified("image");
                                                        },
                                                        child: deleteIcon()
                                                      )
                                                    )
                                                  ]
                                                );
                                              }
                                              
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
                                    "${originalImageNames.length + changeImages.length}/5",
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
                                items: (restaurantMenus)
                                        .map<MultiSelectItem<String>>((menu) => MultiSelectItem<String>(
                                          menu["name"] as String,
                                          "${menu["name"]} (${menu["price"]})"
                                        ))
                                        .toList(),
                                initialValue: changeMenus,
                                searchable: true,
                                selectedColor: const Color.fromRGBO(122, 11, 11, 1),
                                onConfirm: (values) {
                                  setState(() {
                                    changeMenus = (values.cast<String>());
                                  });
                                  print("선택된 메뉴: $changeMenus");
                                  isReviewModified("menu");
                                },
                                chipDisplay: MultiSelectChipDisplay(
                                  onTap: (value) {
                                    setState(() {
                                      changeMenus.remove(value);
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
                                controller: changeContentController,
                                focusNode: changeContentFocus,
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
                                initialRating: changeRating,
                                onRatingChanged: (rating) {
                                  print("사용자가 선택한 별점: $rating");
                                  onRatingChanged(rating);
                                }
                              ),
                            ],
                          ),
                          const SizedBox(height: 20)
                        ],
                      ),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: (isImageChanged || isMenuChanged || isContentChanged || isRatingChanged) && (formKey.currentState?.validate() ?? false)
                    ? () async {
                        print("리뷰 수정 버튼 클릭!!!");
                        final result = await ServerRequest().serverRequest(({bool isFinalRequest = false}) => submitReviewUpdate(isFinalRequest: isFinalRequest), context);
                        
                        if (result) {
                          Navigator.pop(context, true);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("리뷰를 수정했습니다."))
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("리뷰를 수정하지 못했습니다."))
                          );
                        }
                        // submitReviewUpdate();
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
                    "리뷰 수정",
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