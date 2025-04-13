import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gachi_janchi/widgets/ExpandableText.dart';
import 'package:gachi_janchi/widgets/MenuPopUp.dart';

class ReviewTile extends StatefulWidget {
  final bool menuButton;
  final Map<String, dynamic> reviewInfo;
  final VoidCallback? fetchReview;
  const ReviewTile({
    super.key,
    required this.reviewInfo,
    required this.menuButton,
    this.fetchReview
  });

  @override
  State<ReviewTile> createState() => _ReviewtileState();
}

class _ReviewtileState extends State<ReviewTile> {

  List<Widget> drawStarRating(int rating) {
    const int maxStars = 5;

    return List.generate(maxStars, (index) {
      return Icon(
        Icons.star,
        color: index < rating
          ? Colors.yellow
          : Colors.grey
      );
    });
  }

  OverlayEntry? overlayEntry; // 오버레이 창을 위한 변수
    final LayerLink layerLink = LayerLink(); // 위젯의 위치를 추적하는 변수
    final GlobalKey buttonKey = GlobalKey();
    double buttonWidth = 25;
    double overlayWidth = 150;

    // 오버레이 창 닫는 함수
    void removeOverlay() {
      overlayEntry?.remove();
      overlayEntry = null;
    }

    // 오버레이 창을 표시하는 함수
    void showOverlay(BuildContext context, String reviewId) {
      if (overlayEntry != null) return;

      overlayEntry = OverlayEntry(
        builder: (context) => Stack(
          children: [
            // 오버레이 바깥쪽 클릭 시 닫기
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  removeOverlay();
                  setState(() {});
                },
                behavior: HitTestBehavior.translucent,
              ),
            ),
            CompositedTransformFollower(
              link: layerLink,
              offset: Offset(buttonWidth - 135, 55), // 아이콘 버튼 기준 아래쪽으로 55px
              showWhenUnlinked: false,
              child: Material(
                elevation: 5,
                borderRadius: BorderRadius.circular(15),
                color: Colors.white,
                child: MenuPopUp(
                  reviewId: reviewId,
                  fetchReview: () {
                    removeOverlay();
                    widget.fetchReview?.call();
                  },
                ), // 메뉴 팝업 UI
              ),
            ),
          ],
        ),
      );

      Overlay.of(context).insert(overlayEntry!);
    }


  // 오버레이 토글 함수 (클릭하면 열고, 다시 클릭하면 닫음)
  void toggleOverlay(BuildContext context, String reviewId) {
    if (overlayEntry != null) {
      removeOverlay();
    } else {
      showOverlay(context, reviewId);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> writer = widget.reviewInfo["writerInfo"];
    final Map<String, dynamic> review = widget.reviewInfo["review"];
    final List<dynamic> reviewImages = widget.reviewInfo["reviewImages"];
    final List<dynamic> reviewMenus = widget.reviewInfo["reviewMenus"];
    print("writer: $writer");
    print("review: $review");
    print("reviewImages: $reviewImages");
    print("reviewMenus: $reviewMenus");

    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          decoration: const BoxDecoration(
            border: Border(
              bottom:BorderSide(
                width: 1,
                color:Colors.grey
              )
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row( // 리뷰 작성자 정보(프로필 사진, 닉네임, 칭호)
                    children: [
                      writer["profileImage"] != null
                      ? CircleAvatar(
                          radius: 25,
                          backgroundImage: NetworkImage("${dotenv.env["API_ADDRESS"]}/images/profile/${writer["profileImage"]}")
                        )
                      : Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            border: Border.all(width: 1),
                            borderRadius: BorderRadius.circular(25), // 반지름도 같게
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(3.0), // 내부 padding 적용
                            child: Icon(
                              Icons.person,
                              size: 44, // 아이콘 크기는 padding 고려해서 살짝 줄이기
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      SizedBox(width: 15,),
                      Text(
                        review["userId"],
                        style: TextStyle(
                          fontSize: 16
                        ),
                      ),
                      SizedBox(width: 10,),
                      Text(
                        writer["title"] == null
                        ? ""
                        : writer["title"]
                      )
                    ],
                  ),
                  if (widget.menuButton)
                    CompositedTransformTarget(
                      link: layerLink,
                      child: IconButton(
                        key: buttonKey,
                        onPressed: () {
                          print("more_horiz 버튼 클릭");
                          toggleOverlay(context, review["id"]);
                        },
                        icon: Icon(
                          Icons.more_horiz,
                          size: buttonWidth,
                        )
                      ),
                    )
                ],
              ),
              SizedBox(height: 10),
              Row( // 별점, 작성 날짜
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: drawStarRating(review["rating"])
                  ),
                  SizedBox(width: 15),
                  Text(
                    review["createdAt"].toString().replaceFirst('T', ' '),
                    style: TextStyle(
                      color: Color.fromARGB(255, 121, 121, 121)
                    ),
                  )
                ],
              ),
              SizedBox(height: 10),
              if (reviewImages.isNotEmpty)
                Container(
                  height: 100,
                  child: ListView.builder(
                        scrollDirection: Axis.horizontal, // 가로 스크롤
                        itemCount: reviewImages.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                "${dotenv.env["API_ADDRESS"]}/images/review/${reviewImages[index]["imageName"]}",
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              )
                            )
                          );
                        }
                      ),
                ),
              SizedBox(height: 10),
              ExpandableText(
                text: review["content"],
                trimLines: 3,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 10),
              Container(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: reviewMenus.map<Widget>((menu) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            border: Border.all(width: 1),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(menu["menuName"]),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (overlayEntry != null)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTapDown: (details) {
                  final RenderBox? buttonBox = buttonKey.currentContext?.findRenderObject() as RenderBox?;

                  if (buttonBox != null) {
                    final buttonOffset = buttonBox.localToGlobal(Offset.zero);
                    final buttonSize = buttonBox.size;
                    final buttonRect = buttonOffset & buttonSize;

                    // 팝업 버튼 위치 클릭 시 닫기 무시
                    if (!buttonRect.contains(details.globalPosition)) {
                      removeOverlay();
                    }
                  } else {
                    // 버튼 RenderBox가 null일 때
                    removeOverlay();
                  }

                  setState(() {});
                },
                onPanDown: (details) {
                  final RenderBox? buttonBox = buttonKey.currentContext?.findRenderObject() as RenderBox?;

                  if (buttonBox != null) {
                    final buttonOffset = buttonBox.localToGlobal(Offset.zero);
                    final buttonSize = buttonBox.size;
                    final buttonRect = buttonOffset & buttonSize;

                    // 팝업 버튼 위치 클릭 시 닫기 무시
                    if (!buttonRect.contains(details.globalPosition)) {
                      removeOverlay();
                    }
                  } else {
                    // 버튼 RenderBox가 null일 때
                    removeOverlay();
                  }

                  setState(() {});
                },
              ),
            ),
      ] 
    );
  }
}