import 'package:flutter/material.dart';
import 'package:mention_tag_text_field/mention_tag_text_field.dart';

class MyCustomTag extends StatelessWidget {
  const MyCustomTag({
    super.key,
    required this.controller,
    required this.text,
  });

  final MentionTagTextEditingController controller;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      decoration: BoxDecoration(
          color: Colors.yellow.shade50,
          borderRadius: const BorderRadius.all(Radius.circular(50))),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(text,
              style: TextStyle(
                color: Colors.yellow.shade700,
              )),
          const SizedBox(
            width: 6.0,
          ),
          GestureDetector(
            onTap: () {
              controller.remove(index: 1);
            },
            child: Icon(
              Icons.close,
              size: 12,
              color: Colors.yellow.shade700,
            ),
          )
        ],
      ),
    );
  }
}
