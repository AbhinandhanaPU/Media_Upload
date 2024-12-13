// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart' as dio;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_upload/supabase_config.dart';
import 'package:media_upload/view/utils/utils.dart';
import 'package:media_upload/view/widgets/progress_bar.dart';
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

  Future<bool> _checkNetworkConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      showToast(msg: 'No internet connection. Please try again later.');
      log("No internet connection", name: "UploaderController");
      return false;
    }
    return true;
  }

  Future<void> pickFile(BuildContext context) async {
    try {
      if (!await _checkNetworkConnection()) return;

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
      } else {
        log('No file selected', name: "UploaderController");
      }
    } catch (e) {
      log('Error picking file: ${e.toString()}', name: "UploaderController");
      showToast(msg: 'Failed to select file: ${e.toString()}');
    }
  }

  Future<void> uploadToSupabase(BuildContext context) async {
    try {
      String supabaseUrl = Config.supabaseUrl;
      String supabaseKey = Config.supabaseKey;

      if (!await _checkNetworkConnection()) return;
      log('Uploading.....');

      progressData.value = 0.0;
      progressBar(context: context, value: progressData.value);

      if (filee == null) {
        throw Exception('No file selected');
      }
      // uploading documents
      dio.FormData formData = dio.FormData.fromMap({
        'file': await dio.MultipartFile.fromFile(
          filee!.path,
          filename: fileName.value,
        ),
      });

      String uploadUrl =
          '$supabaseUrl/storage/v1/object/documents/files/${fileName.value}';

      final response = await dioClient.post(
        uploadUrl,
        data: formData,
        options: dio.Options(
          headers: {'Authorization': 'Bearer $supabaseKey'},
        ),
        onSendProgress: (sent, total) {
          if (total != -1) {
            progressData.value = (sent / total) * 100;
          }
        },
      );
      log('Response: ${response.data}');

      // Download Url
      String downloadUrl =
          '$supabaseUrl/storage/v1/object/public/documents/files/${fileName.value}';
      if (downloadUrl.isEmpty) {
        throw Exception('Failed to retrieve the public URL');
      }
      log('Download URL: $downloadUrl');

      //  uploading details to database
      String uid = const Uuid().v1();
      final dbResponse = await supabase.from('Documents').insert({
        'uid': uid,
        'fileName': fileName.value,
        'url': downloadUrl,
      });

      if (dbResponse.error != null) {
        throw Exception(dbResponse.error!.message);
      }

      filee = null;
      fileName.value = '';
      progressData.value = 0;

      progressBar(context: context, value: 100, isCompleted: true);
      showToast(msg: "Uploaded Successfully");
      log("Uploaded Successfully");
    } catch (e) {
      log('Error uploading file: ${e.toString()}');
      showToast(msg: "Something Went Wrong. Failed to upload file.");

      progressBar(
        context: context,
        value: progressData.value,
        isCompleted: true,
      );

      if (e is dio.DioException) {
        log('Dio error: ${e.response?.data}');
      }
    }
  }
}
