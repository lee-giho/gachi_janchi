import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gachi_janchi/widgets/ExpandableText.dart';

class ReviewTile extends StatefulWidget {
  final Map<String, dynamic> reviewInfo;
  const ReviewTile({
    super.key,
    required this.reviewInfo
  });

  @override
  State<ReviewTile> createState() => _ReviewtileState();
}

class _ReviewtileState extends State<ReviewTile> {
  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> review = widget.reviewInfo["review"];
    final List<dynamic> reviewImages = widget.reviewInfo["reviewImages"];
    final List<dynamic> reviewMenus = widget.reviewInfo["reviewMenus"];
    print("review: $review");
    print("reviewImages: $reviewImages");
    print("reviewMenus: $reviewMenus");
    return Container(
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
        children: [
          Row( // 리뷰 작성자 정보(프로필 사진, 닉네임, 칭호)
            children: [
              Icon(
                Icons.account_circle,
                size: 50
              ),
              SizedBox(width: 15,),
              Text(
                review["userId"],
                style: TextStyle(
                  fontSize: 16
                ),
              ),
              SizedBox(width: 10,),
              const Text(
                "칭호",
              )
            ],
          ),
          Row( // 별점, 작성 날짜
            children: [
              Icon(
                Icons.star,
                color: Colors.yellow,
              ),
              Text(
                review["rating"].toString()
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
          Container(
            height: 100,
            child: ListView.builder(
                  scrollDirection: Axis.horizontal, // 가로 스크롤
                  padding: const EdgeInsets.symmetric(horizontal: 8),
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
          ExpandableText(
            text: review["content"],
            trimLines: 3,
            style: TextStyle(fontSize: 16),
          )
        ],
      ),
    );
  }
}