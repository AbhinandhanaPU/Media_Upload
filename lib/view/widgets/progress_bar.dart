// ignore_for_file: public_member_api_docs, sort_constructors_first, must_be_immutable
import 'package:flutter/material.dart';

class ProgressBar extends StatelessWidget {
  BuildContext context;
  double value;
  String fileName;
  ProgressBar({
    super.key,
    required this.context,
    required this.value,
    required this.fileName,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(fileName),
          Text('${value.toInt()} %'),
        ],
      ),
      titleTextStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: Colors.blue[500],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 15),
        child: LinearProgressIndicator(
          value: value / 100,
        ),
      ),
    );
  }
}
