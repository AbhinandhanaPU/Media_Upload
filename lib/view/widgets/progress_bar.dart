import 'package:flutter/material.dart';

void progressBar({
  required BuildContext context,
  required double value,
  bool isCompleted = false,
}) {
  if (isCompleted) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
    return;
  }

  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Uploading...'),
            Text('${value.toInt()} %'),
          ],
        ),
        titleTextStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Colors.blue[500],
        ),
        content: Padding(
          padding: const EdgeInsets.only(top: 15),
          child: LinearProgressIndicator(
            value: value / 100,
          ),
        ),
      );
    },
  );
}
