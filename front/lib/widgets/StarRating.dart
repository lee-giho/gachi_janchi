import 'package:flutter/material.dart';

class StarRating extends StatefulWidget {
  final Function(int) onRatingChanged; // 정수 콜백 받을 수 있는 함수

  const StarRating({super.key, required this.onRatingChanged});

  @override
  State<StarRating> createState() => _StarRatingState();
}

class _StarRatingState extends State<StarRating> {
  int selectedRating = 0;
  
  void updateRating(int rating) {
    setState(() {
      selectedRating = rating;
    });
    widget.onRatingChanged(rating); // 외부로 별점 점수 전달
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final starIndex = index + 1; // 별점 1 ~ 5
        return GestureDetector(
          onTap: () {
            updateRating(starIndex);
          },
          child: Icon(
            Icons.star,
            color: selectedRating >= starIndex
              ? Colors.yellow
              : Colors.grey,
            size: 35,
          ),
        );
      })
    );
  }
}