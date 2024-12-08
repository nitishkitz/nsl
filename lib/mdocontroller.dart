import 'dart:async'; // Import for TimeoutException
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Homepage.dart';
import 'main.dart';

class MDOController extends GetxController {
  var isLoading = false.obs;

  late String globalDeviceId; // Declare globalDeviceId at the class level

  @override
  void onInit() {
    super.onInit();
    initializeDeviceId(); // Initialize the Device ID on controller creation
  }

  Future<void> initializeDeviceId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    globalDeviceId = prefs.getString('deviceId') ?? const Uuid().v4(); // Retrieve or generate a new Device ID
    await prefs.setString('deviceId', globalDeviceId); // Save the Device ID in SharedPreferences

    if (kDebugMode) {
      print("Initialized Device ID: $globalDeviceId");
    }
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Get.snackbar('Error', 'Location services are disabled.',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Get.snackbar('Error', 'Location permissions are denied',
            snackPosition: SnackPosition.BOTTOM);
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Get.snackbar('Error',
          'Location permissions are permanently denied, we cannot request permissions.',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }

    return true;
  }

  Future<void> submitDetails({
    required String mdoName,
    required String mobileNumber,
    required String headquarter,
    required String territory,
  }) async {
    isLoading.value = true;

    try {
      // Handle location permissions
      bool hasPermission = await _handleLocationPermission();
      if (!hasPermission) {
        isLoading.value = false;
        return;
      }

      String deviceType = GetPlatform.isAndroid ? 'Android' : 'iOS';

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      String geoLocation = '${position.latitude},${position.longitude}';
      List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude, position.longitude);
      String pincode = placemarks.first.postalCode ?? 'Unknown';

      Map<String, dynamic> requestBody = {
        "mdoName": mdoName,
        "mobileNumber": mobileNumber,
        "headquarter": headquarter,
        "territory": territory,
        "deviceId": globalDeviceId, // Use the globalDeviceId
        "deviceType": deviceType,
        "token": "",
        "geoLocation": geoLocation,
        "pincode": pincode
      };

      if (kDebugMode) {
        print("Request Body: $requestBody");
      }

      final response = await http
          .post(
        Uri.parse(
            'http://3.110.159.82:8080/vyapar_mitra/rest/audit/saveMDO'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      )
          .timeout(const Duration(seconds: 10)); // Added timeout

      if (kDebugMode) {
        print("Response Status: ${response.statusCode}");
        print("Response Body: ${response.body}");
      }

      // Save request and response bodies to SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('lastRequestBody', jsonEncode(requestBody));
      await prefs.setString('lastResponseBody', response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        await prefs.setString('mdoName', mdoName);
        await prefs.setString('mobileNumber', mobileNumber);

        // Close the dialog
        if (Get.isDialogOpen ?? false) {
          Get.back();
        }

        // Show snackbar
        Get.snackbar('Success', 'Details submitted successfully!',
            snackPosition: SnackPosition.BOTTOM);

        // Navigate to Homepage, removing all previous routes
        Get.offAll(() => const Homepage());
      } else {
        Future.delayed(const Duration(milliseconds: 100), () {
          Get.snackbar('Error', 'Failed to submit details.',
              snackPosition: SnackPosition.BOTTOM);
        });
      }
    } on TimeoutException catch (e) {
      if (kDebugMode) {
        print("Timeout Exception: $e");
      }
      Future.delayed(const Duration(milliseconds: 100), () {
        Get.snackbar('Error', 'Request timed out. Please try again.',
            snackPosition: SnackPosition.BOTTOM);
      });
    } catch (e) {
      if (kDebugMode) {
        print("Exception in submitDetails: $e");
      }
      Future.delayed(const Duration(milliseconds: 100), () {
        Get.snackbar('Error', 'An error occurred: $e',
            snackPosition: SnackPosition.BOTTOM);
      });
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveDeviceId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    globalDeviceId = prefs.getString('deviceId') ?? const Uuid().v4(); // Generate or retrieve a Device ID
    await prefs.setString('deviceId', globalDeviceId); // Save it in SharedPreferences

    if (kDebugMode) {
      print("Device ID saved: $globalDeviceId");
    }
  }


}
