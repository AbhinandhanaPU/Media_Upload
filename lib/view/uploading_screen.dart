import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_upload/controller/uploader_controller.dart';
import 'package:media_upload/view/widgets/custom_button.dart';

class UploadScreen extends StatelessWidget {
  UploadScreen({super.key});
  final UploaderController uploaderController = Get.put(UploaderController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Media'),
        centerTitle: true,
        foregroundColor: Colors.blue[400],
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 30),
        child: Center(
          child: DottedBorder(
            dashPattern: const [6, 14],
            strokeWidth: 2,
            color: Colors.grey,
            strokeCap: StrokeCap.round,
            borderType: BorderType.RRect,
            radius: const Radius.circular(15),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
              height: 350,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 15),
                    Image.asset(
                      'asset/file.png',
                      height: 100,
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'Upload Your Files',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const Text(
                      'Videos or Documents with max size of 100MB',
                      style: TextStyle(fontWeight: FontWeight.w400),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: 15,
                        top: 10,
                      ),
                      child: GestureDetector(
                        onTap: () async {
                          await uploaderController
                              .pickFile(context)
                              .then((value) async {
                            // Uploading to Supabase
                            await uploaderController.uploadToSupabase(context);
                          });
                        },
                        child: const CustomButton(
                          width: 180,
                          height: 80,
                          text: 'Choose File',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
