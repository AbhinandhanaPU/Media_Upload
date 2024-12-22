import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_upload/controller/uploader_controller.dart';

class FailedUploadsView extends StatelessWidget {
  FailedUploadsView({super.key});

  final UploaderController controller = Get.find<UploaderController>();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => ListView.builder(
        itemCount: controller.failedUploads.length,
        itemBuilder: (context, index) {
          final failedFile = controller.failedUploads[index];

          return Obx(() => Visibility(
                visible: failedFile.isVisible.value,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(0),
                  leading: const Icon(Icons.error, color: Colors.red),
                  title: Text(failedFile.fileName),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text('File size: ${failedFile.fileSize}'),
                  ),
                  trailing: IconButton(
                    onPressed: () =>
                        controller.retryUpload(failedFile, context),
                    icon: const Icon(
                      Icons.file_upload_outlined,
                      size: 30,
                    ),
                  ),
                ),
              ));
        },
      ),
    );
  }
}
