// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_upload/controller/network_controller.dart';
import 'package:media_upload/controller/notification_controller.dart';
import 'package:media_upload/model/failed_uploads.dart';
import 'package:media_upload/supabase_config.dart';
import 'package:media_upload/view/utils/utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class UploaderController extends GetxController {
  RxString fileName = "".obs;
  RxString fileSize = "".obs;
  File? filee;
  String downloadUrl = '';
  final progressData = RxDouble(0.0);
  final isVideo = false.obs;
  final videoThumbnail = Rxn<File>();

  dio.Dio dioClient = dio.Dio();

  final supabase = Supabase.instance.client;
  final NotificationController _notificationCntlr = NotificationController();
  final NetworkController _networkController = NetworkController();

  // function to pick the document and videos
  Future<void> pickFile(BuildContext context) async {
    try {
      if (!await _networkController.checkNetworkConnection()) return;

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowedExtensions: [
          'mp4',
          'mov',
          'pdf',
          'doc',
          'docx',
          'xls',
          'xlsx',
          'ppt',
        ],
        type: FileType.custom,
        allowCompression: true,
      );

      if (result != null) {
        final filePath = result.files.single.path!;
        final fileExtension = filePath.split('.').last.toLowerCase();
        final allowedExtensions = [
          'mp4',
          'mov',
          'pdf',
          'doc',
          'docx',
          'xls',
          'xlsx',
          'ppt',
        ];

        if (!allowedExtensions.contains(fileExtension)) {
          log('Invalid file type', name: "UploaderController");
          showToast(msg: 'Invalid file type. Please select a supported file.');
          return;
        }

        final int fileSizeInBytes = result.files.single.size;
        final double fileSizeInMb = fileSizeInBytes / (1024 * 1024);

        final String formattedSize = formatFileSize(fileSizeInBytes);
        if (fileSizeInMb > 100) {
          log('File size exceeds 100 MB', name: "UploaderController");

          showToast(
              msg:
                  'The selected file exceeds the size limit of 100 MB. Please choose a smaller file.');
          return;
        }

        filee = File(filePath);
        fileName.value = result.files.single.name;
        fileSize.value = formattedSize;
        log('File selected: ${fileName.value}');

        final List<String> videoFormats = ['mp4', 'mov'];

        isVideo.value = videoFormats
            .any((format) => filee!.path.toLowerCase().endsWith('.$format'));

        if (isVideo.value) {
          final thumbnail = await generateVideoThumbnail(filee!.path);
          if (thumbnail != null) {
            videoThumbnail.value = thumbnail;
          }
        }

        // Uploading to Supabase
        await uploadToSupabase(context);
      } else {
        log('No file selected', name: "UploaderController");
      }
    } catch (e) {
      log('Error picking file: ${e.toString()}', name: "UploaderController");
      showToast(msg: 'Failed to select file: ${e.toString()}');
    }
  }

  Future<File?> generateVideoThumbnail(String videoPath) async {
    try {
      final String? thumbnailPath = await VideoThumbnail.thumbnailFile(
        video: videoPath,
        thumbnailPath: (await getTemporaryDirectory()).path,
        imageFormat: ImageFormat.JPEG,
        maxHeight: 150,
        quality: 75,
      );
      if (thumbnailPath != null) {
        return File(thumbnailPath);
      }
    } catch (e) {
      log("Error generating thumbnail: $e");
    }
    return null;
  }

  String supabaseUrl = Config.supabaseUrl;
  String supabaseKey = Config.supabaseKey;

  // function to upload the data into subabase storage and database
  Future<void> uploadToSupabase(BuildContext context) async {
    try {
      if (!await _networkController.checkNetworkConnection()) return;
      log('Uploading.....');

      progressData.value = 0.0;

      if (filee == null) {
        throw Exception('No file selected');
      }

      // Uploading documents
      dio.FormData formData = dio.FormData.fromMap({
        'file': await dio.MultipartFile.fromFile(
          filee!.path,
          filename: fileName.value,
        ),
      });

      String uploadUrl =
          '$supabaseUrl/storage/v1/object/documents/${fileName.value}';

      final response = await dioClient.post(
        uploadUrl,
        data: formData,
        options: dio.Options(
          headers: {'Authorization': 'Bearer $supabaseKey'},
        ),
        onSendProgress: (sent, total) {
          if (total != -1) {
            progressData.value = (sent / total) * 100;
            _notificationCntlr.showProgressNotification(
              progress: progressData.value.toInt(),
              maxProgress: 100,
              fileName: fileName.string,
            );
          }
        },
      );

      log('Response: ${response.data}');

      if (response.statusCode == 200) {
        filee = null;
        fileName.value = '';
        progressData.value = 0;
        _notificationCntlr.cancelNotification();

        showToast(msg: "Uploaded Successfully");
        log("Uploaded Successfully");
      } else {
        throw Exception('Error uploading file: ${response.data}');
      }
    } catch (e) {
      if (e is dio.DioException) {
        showToast(msg: " ${e.response?.data['message']} ");
        log('Dio error: ${e.response?.data}');
      }
      log('Error uploading file: ${e.toString()}');
      showToast(msg: "Try Again.");
      addFailedUpload(
          fileName.value, filee!.path, fileSize.value, e.toString());

      filee = null;
      fileName.value = '';
      progressData.value = 0;
      _notificationCntlr.cancelNotification();
    }
  }

  RxList<FailedUpload> failedUploads = <FailedUpload>[].obs;

  Future<void> retryUpload(
      FailedUpload failedFile, BuildContext context) async {
    try {
      failedFile.isVisible.value = false;
      fileName.value = failedFile.fileName;
      fileSize.value = failedFile.fileSize;
      String filePath = failedFile.filePath;
      filee = File(filePath);

      // To upload
      await uploadToSupabase(context);

      // remove the item if file uploaded successfully
      failedUploads.remove(failedFile);
    } catch (e) {
      if (e is dio.DioException) {
        showToast(msg: " ${e.response?.data['message']} ");
        log('Dio error: ${e.response?.data}');
      }
      log('Retry upload failed: ${e.toString()}');
      showToast(msg: "Retry failed for file: ${failedFile.fileName}");

      _notificationCntlr.cancelNotification();
    } finally {
      _notificationCntlr.cancelNotification();
    }
  }

  void addFailedUpload(
      String fileName, String filePath, String fileSize, String errorMessage) {
    failedUploads.add(FailedUpload(
      fileName: fileName,
      filePath: filePath,
      fileSize: fileSize,
      errorMessage: errorMessage,
    ));
  }

  String formatFileSize(int bytes) {
    const int kb = 1024;
    const int mb = kb * 1024;
    const int gb = mb * 1024;

    if (bytes >= gb) {
      return '${(bytes / gb).toStringAsFixed(2)} GB';
    } else if (bytes >= mb) {
      return '${(bytes / mb).toStringAsFixed(2)} MB';
    } else if (bytes >= kb) {
      return '${(bytes / kb).toStringAsFixed(2)} KB';
    } else {
      return '$bytes Bytes';
    }
  }
}
