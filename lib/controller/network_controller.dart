import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:media_upload/view/utils/utils.dart';

class NetworkController extends GetxController {
  Future<bool> checkNetworkConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      showToast(msg: 'No internet connection. Please try again later.');
      log("No internet connection", name: "UploaderController");
      return false;
    }
    return true;
  }
}
