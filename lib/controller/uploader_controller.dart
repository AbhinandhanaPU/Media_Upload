import 'dart:developer';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_upload/view/utils/utils.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class UploaderController extends GetxController {
  RxString fileName = "".obs;
  File? filee;
  Uuid uuid = const Uuid();
  RxBool isLoading = RxBool(false);
  String downloadUrl = '';

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

        // Uploading to Supabase
        await uploadToSupabase();
      } else {
        log('No file selected', name: "UploaderController");
      }
    } catch (e) {
      log('Error picking file: ${e.toString()}', name: "UploaderController");
      showToast(msg: 'Failed to select file: ${e.toString()}');
    }
  }

  Future<void> uploadToSupabase() async {
    try {
      if (!await _checkNetworkConnection()) return;
      log('Uploading.....');

      isLoading.value = true;

      if (filee == null) {
        throw Exception('No file selected');
      }

      final storageResponse = await supabase.storage.from('documents').upload(
            'files/${fileName.value}',
            filee!,
            fileOptions: const FileOptions(upsert: true),
          );

      if (storageResponse.isEmpty) {
        log('Failed to upload the file to Supabase Storage');
        throw Exception('Failed to upload the file to Supabase Storage');
      }

      downloadUrl = supabase.storage
          .from('documents')
          .getPublicUrl('files/${fileName.value}');

      if (downloadUrl.isEmpty) {
        throw Exception('Failed to retrieve the public URL');
      }

      log('downloadUrl: $downloadUrl');

      String uid = uuid.v1();

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
      showToast(msg: "Uploaded Successfully");
      log("Uploaded Successfully");
      Get.back();

      isLoading.value = false;
    } catch (e) {
      log('Error uploading file: ${e.toString()}', name: "UploaderController");
      showToast(msg: "Something Went Wrong");
      isLoading.value = false;
      showToast(msg: 'Failed to upload file ');
    }
  }
}
