import 'package:flutter/material.dart';

class StarRating extends StatefulWidget {
  final Function(int) onRatingChanged; // 정수 콜백 받을 수 있는 함수
  final int initialRating;

  const StarRating({
    super.key, 
    required this.onRatingChanged,
    this.initialRating = 0
  });

  @override
  State<StarRating> createState() => _StarRatingState();
}

class _StarRatingState extends State<StarRating> {
  late int selectedRating;
  
  @override
  void initState() {
    super.initState();
    selectedRating = widget.initialRating;
  }

  @override
  void didUpdateWidget(covariant StarRating oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialRating != widget.initialRating) {
      setState(() {
        selectedRating = widget.initialRating;
        print("updated selectedRating: $selectedRating");
      });
    }
  }

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