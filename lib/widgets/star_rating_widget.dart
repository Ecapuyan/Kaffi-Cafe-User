import 'package:flutter/material.dart';

class StarRating extends StatefulWidget {
  final Function(int) onRatingChanged;
  final int starCount;
  final double size;
  final Color color;

  const StarRating({
    super.key,
    required this.onRatingChanged,
    this.starCount = 5,
    this.size = 40.0,
    this.color = Colors.amber,
  });

  @override
  _StarRatingState createState() => _StarRatingState();
}

class _StarRatingState extends State<StarRating> {
  int _rating = 0;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.starCount, (index) {
        return IconButton(
          onPressed: () {
            setState(() {
              _rating = index + 1;
            });
            widget.onRatingChanged(_rating);
          },
          icon: Icon(
            index < _rating ? Icons.star : Icons.star_border,
            size: widget.size,
            color: widget.color,
          ),
        );
      }),
    );
  }
}
