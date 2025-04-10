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
        crossAxisAlignment: CrossAxisAlignment.start,
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
    );
  }
}