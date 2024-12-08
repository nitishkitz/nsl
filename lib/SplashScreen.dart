import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Homepage.dart';
import 'consts.dart';
import 'mdocontroller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final TextEditingController mdoNameController = TextEditingController();
  final TextEditingController mobileNumberController = TextEditingController();
  final TextEditingController hqController = TextEditingController();
  final TextEditingController territoryController = TextEditingController();

  bool isDialogVisible = false;

  final MDOController mdoController = Get.put(MDOController());

  @override
  void initState() {
    super.initState();
    _checkDetailsSubmission();
  }

  Future<void> _checkDetailsSubmission() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isDetailsSubmitted = prefs.getBool('isDetailsSubmitted') ?? false;

    if (isDetailsSubmitted) {
      // Navigate directly to Homepage
      Future.delayed(const Duration(seconds: 2), () {
        Get.offAll(() => const Homepage());
      });
    } else {
      // Show the dialog box after a delay
      Future.delayed(const Duration(seconds: 2), () {
        _showDetailsDialog();
      });
    }
  }

  void _showDetailsDialog() {
    setState(() {
      isDialogVisible = true;
    });

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                const Center(
                  child: Text(
                    "Enter Details",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Divider(color: layoutsColor, height: 1),
                const SizedBox(height: 16),
                _buildTextField("MDO Name", mdoNameController, "Enter MDO Name"),
                const SizedBox(height: 10),
                _buildTextField(
                  "Mobile Number",
                  mobileNumberController,
                  "Enter Mobile Number",
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 10),
                _buildTextField("HQ", hqController, "Enter HQ"),
                const SizedBox(height: 10),
                _buildTextField("Territory", territoryController, "Enter Territory"),
                const SizedBox(height: 20),
                Obx(() {
                  return Center(
                    child: mdoController.isLoading.value
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                      onPressed: () async {
                        String mdoName = mdoNameController.text.trim();
                        String mobileNumber = mobileNumberController.text.trim();
                        String headquarter = hqController.text.trim();
                        String territory = territoryController.text.trim();

                        if (mdoName.isEmpty ||
                            mobileNumber.isEmpty ||
                            headquarter.isEmpty ||
                            territory.isEmpty) {
                          Get.snackbar(
                            'Error',
                            'Please fill all fields',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.redAccent,
                            colorText: Colors.white,
                          );
                          return;
                        }

                        // Define the regex for mobile number validation
                        RegExp mobileRegex = RegExp(r'^[6-9]\d{9}$');

                        if (!mobileRegex.hasMatch(mobileNumber)) {
                          Get.snackbar(
                            'Invalid Mobile Number',
                            'Mobile number must start with 6, 7, 8, or 9 and be 10 digits long.',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.redAccent,
                            colorText: Colors.white,
                          );
                          return;
                        }

                        await mdoController.submitDetails(
                          mdoName: mdoName,
                          mobileNumber: mobileNumber,
                          headquarter: headquarter,
                          territory: territory,
                        );

                        // Save details submission status
                        SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                        prefs.setBool('isDetailsSubmitted', true);

                        // Optionally, navigate to Homepage after submission
                        Get.offAll(() => const Homepage());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        minimumSize: Size(
                          MediaQuery.of(context).size.width * 0.8,
                          50,
                        ),
                      ),
                      child: const Text(
                        "Submit",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    ).then((_) {
      if (mounted) {
        setState(() {
          isDialogVisible = false;
        });
      }
    });
  }

  Widget _buildTextField(
      String label,
      TextEditingController controller,
      String hint, {
        TextInputType keyboardType = TextInputType.text,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: layoutsColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(color: Colors.black),
            ),
          ),
          keyboardType: keyboardType,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Align(
                          alignment: Alignment.topRight,
                          child: Image.asset(
                            'Asset/logo.png',
                            height: screenHeight * 0.15,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (!isDialogVisible)
                              Image.asset(
                                'Asset/businessmanImg.png',
                                height: screenHeight * 0.23,
                              ),
                            const SizedBox(height: 20),
                            if (!isDialogVisible)
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.asset(
                                  'Asset/retailAuditText.png',
                                  height: screenHeight * 0.025,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          if (!isDialogVisible)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Image.asset(
                                'Asset/reward.png',
                                height: screenHeight * 0.35,
                              ),
                            ),
                          Image.asset(
                            'Asset/bottomBanner.png',
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: screenHeight * 0.1,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
