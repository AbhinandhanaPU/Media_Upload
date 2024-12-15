import 'package:get/get.dart';

class FailedUpload {
  String fileName;
  String filePath;
  String fileSize;
  String errorMessage;
  RxBool isVisible; // Make this reactive

  FailedUpload({
    required this.fileName,
    required this.filePath,
    required this.fileSize,
    required this.errorMessage,
    bool? visible,
  }) : isVisible = (visible ?? true).obs; // Initialize as observable
}
