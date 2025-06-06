import 'package:flutter/material.dart';

class TagCard extends StatefulWidget{
  final String tagName;
  final Color color;
  final VoidCallback? onTap;

  const TagCard({
    super.key,
    required this.tagName,
    required this.color,
    this.onTap,
  });

  @override
  _TagCardState createState() => _TagCardState();
}

class _TagCardState extends State<TagCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Card(
        color: widget.color,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            widget.tagName,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}