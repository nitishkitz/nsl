import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nslretailaudits/consts.dart';

import 'AuditController.dart';
import 'SplashScreen.dart';
import 'mdocontroller.dart';
late String globalDeviceId;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensures proper initialization
  Get.put<AuditController>(AuditController(), permanent: true);

  // Initialize MDOController as a singleton
  Get.put<MDOController>(MDOController(), permanent: true);
  MDOController mdoController = Get.put(MDOController());
  await mdoController.saveDeviceId(); // Save the Device ID during initialization


  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
        useMaterial3: true,
      ),
      home:const SplashScreen()
    );
  }
}



