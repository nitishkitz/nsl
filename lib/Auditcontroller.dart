import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuditController extends GetxController {
  // Loading state
  var isLoading = true.obs;

  // Error message
  var errorMessage = ''.obs;

  // Data from API
  var submittedApplications = 0.obs;
  var mobileNumber = ''.obs;
  var name = ''.obs;
  var headQuarter = ''.obs;
  var territory = ''.obs;
  var retailerSeedType = <String>[].obs; // List of seed types

  @override
  void onInit() {
    super.onInit();
    fetchAuditMasterData();
  }

  Future<void> fetchAuditMasterData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? deviceId = prefs.getString('deviceId');

      if (deviceId == null || deviceId.isEmpty) {
        throw Exception('Device ID is not available in SharedPreferences');
      }

      Map<String, dynamic> requestBody = {
        "deviceId": deviceId,
      };

      print('Request Body: $requestBody');

      final response = await http
          .post(
        Uri.parse('http://3.110.159.82:8080/vyapar_mitra/rest/audit/auditMaster'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (responseData['statusCode'] == 200 && responseData['response'] != null) {
          // Decode the `response` JSON string
          final Map<String, dynamic> responseBody = jsonDecode(responseData['response']);
          print('Decoded Response Body: $responseBody');

          // Parse fields
          submittedApplications.value =
              int.tryParse(responseBody['submittedApplications']?.toString() ?? '0') ?? 0;
          mobileNumber.value = responseBody['mobileNumber'] ?? '';
          name.value = responseBody['name'] ?? '';
          headQuarter.value = responseBody['headQuarter'] ?? '';
          territory.value = responseBody['territory'] ?? '';

          // Parse retailerSeedType
          retailerSeedType.value = (responseBody['retailerSeedType'] as List<dynamic>?)
              ?.map((item) {
            if (item is Map<String, dynamic>) {
              return item['seedType']?.toString() ?? '';
            }
            return '';
          })
              .where((seedType) => seedType.isNotEmpty)
              .toList() ?? [];
        } else {
          errorMessage.value = responseData['message'] ?? 'Unknown error';
        }
      } else {
        errorMessage.value = 'Failed to fetch data: ${response.statusCode}';
      }
    } on TimeoutException catch (_) {
      errorMessage.value = 'Request timed out. Please try again.';
    } catch (e) {
      errorMessage.value = 'An error occurred: $e';
      print(e);
    } finally {
      isLoading.value = false;
    }
  }
}
