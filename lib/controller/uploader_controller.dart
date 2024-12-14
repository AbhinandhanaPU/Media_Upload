// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_upload/controller/network_controller.dart';
import 'package:media_upload/controller/notification_controller.dart';
import 'package:media_upload/supabase_config.dart';
import 'package:media_upload/view/utils/utils.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class UploaderController extends GetxController {
  RxString fileName = "".obs;
  File? filee;
  Uuid uuid = const Uuid();
  String downloadUrl = '';
  final progressData = RxDouble(0.0);

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
          'avi',
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
          'avi',
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

        final fileSize = result.files.single.size;
        final fileSizeInMB = fileSize / (1024 * 1024);

        if (fileSizeInMB > 100) {
          log('File size exceeds 100 MB', name: "UploaderController");
          showToast(
            msg:
                'The selected file exceeds the size limit of 100 MB. Please choose a smaller file.',
          );
          return;
        }

        filee = File(filePath);
        fileName.value = result.files.single.name;
        log('File selected: ${fileName.value}');

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

  // function to upload the data into subabase storage and database
  Future<void> uploadToSupabase(BuildContext context) async {
    try {
      String supabaseUrl = Config.supabaseUrl;
      String supabaseKey = Config.supabaseKey;

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
        // Download URL
        String downloadUrl =
            '$supabaseUrl/storage/v1/object/public/documents/${fileName.value}';
        if (downloadUrl.isEmpty) {
          throw Exception('Failed to retrieve the public URL');
        }
        log('Download URL: $downloadUrl');

        String uid = response.data['Id'];

        // Insert into database
        await supabase.from('Documents').insert({
          'uid': uid,
          'fileName': fileName.value,
          'url': downloadUrl,
        });
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
      showToast(msg: "Something Went Wrong. Failed to upload file.");

      filee = null;
      fileName.value = '';
      progressData.value = 0;
      _notificationCntlr.cancelNotification();
    }
  }
}
