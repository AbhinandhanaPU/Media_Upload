import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_upload/supabase_config.dart';
import 'package:media_upload/view/uploading_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Config.initializeSupabase();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      home: UploadScreen(),
    );
  }
}
