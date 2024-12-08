import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SubmitController extends GetxController {
  var isLoading = false.obs;

  Future<void> submitAuditData({
    required String retailerName,
    required String mobileNo, // Changed here
    required String retailerType,
    required double totalTurnover,
    required double seedTurnover,
    required String village,
    required String taluka,
    required String district,
    required List<Map<String, dynamic>> crops,
    required bool isFocus20,
    required bool isNVMRegistered,
  }) async {
    isLoading.value = true;

    try {
      // Retrieve deviceId and mobileNumber from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final deviceId = prefs.getString('deviceId') ?? '';
      final mobileNumber = prefs.getString('mobileNumber') ?? '';

      if (deviceId.isEmpty || mobileNumber.isEmpty) {
        throw Exception("Device ID or Mobile Number not found in SharedPreferences");
      }

      // Prepare the request body
      final requestBody = {
        "deviceId": deviceId,
        "mobileNumber": mobileNumber,
        "retailerDetails": {
          "retailerName": retailerName,
          "mobileNumber": mobileNo,
          "retailerType": retailerType,
          "totalTurnoverLakhs": totalTurnover,
          "seedTurnoverLakhs": seedTurnover,
          "village": village,
          "taluka": taluka,
          "district": district,
        },
        "cropWiseDetails": {
          "crops": crops,
          "focus20Retailer": isFocus20 ? "Yes" : "No",
          "registeredInNVM": isNVMRegistered ? "Yes" : "No"
        }
      };

      print("Request Body: ${jsonEncode(requestBody)}"); // Debugging: Print the request body

      // Send the POST request
      final response = await http.post(
        Uri.parse('http://3.110.159.82:8080/vyapar_mitra/rest/audit/saveAuditData'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      print("Response Status Code: ${response.statusCode}"); // Debugging: Print the status code
      print("Response Body: ${response.body}"); // Debugging: Print the response body

      if (response.statusCode == 200) {
        // Handle success
        Get.snackbar("Success", "Retailer added successfully");
      } else {
        // Handle error
        throw Exception("Failed to submit data: ${response.body}");
      }
    } catch (e) {
      print("Error: $e"); // Debugging: Print the error
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
