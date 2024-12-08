import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'AuditController.dart';
import 'RetailerPotentialScreen.dart';
import 'consts.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final AuditController auditController = Get.put(AuditController());

  @override
  void initState() {
     auditController.fetchAuditMasterData();
    super.initState();
  }

  Future<void> _refreshData() async {
    try {
      await auditController.fetchAuditMasterData();
      Fluttertoast.showToast(
        msg: "Data refreshed successfully!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to refresh data: $e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double primaryContainerHeight = screenHeight / 3;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Container(color: background),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: primaryContainerHeight,
            child: Container(
              decoration: const BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30.0),
                  bottomRight: Radius.circular(30.0),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            child: Image.asset(
              'Asset/leftleaf.png',
              height: primaryContainerHeight,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Image.asset(
              'Asset/rightleaf.png',
              height: primaryContainerHeight,
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _refreshData,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Obx(() {
                            if (auditController.isLoading.value) {
                              return const Center(child: CircularProgressIndicator());
                            } else if (auditController.errorMessage.isNotEmpty) {
                              return Center(
                                child: Text(
                                  auditController.errorMessage.value,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              );
                            } else {
                              return Row(
                                children: [
                                  _buildProfileAvatar('Asset/businessmanImg.png'),
                                  const SizedBox(width: 10),
                                  _buildGreetingTexts(
                                    'Good Morning',
                                    auditController.name.value,
                                    auditController.headQuarter.value,
                                    auditController.territory.value,
                                    auditController.mobileNumber.value,
                                  ),
                                ],
                              );
                            }
                          }),
                          const SizedBox(height: 20),
                          Obx(() => _buildRetailerDataCard(auditController.submittedApplications.value)),
                          const SizedBox(height: 20),
                          _buildAddRetailerCard(context),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  child: Image.asset(
                    'Asset/bottomBanner.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileAvatar(String assetPath) {
    return CircleAvatar(
      radius: 26,
      backgroundColor: Colors.white,
      child: ClipOval(
        child: Image.asset(
          assetPath,
          fit: BoxFit.cover,
          width: 35,
          height: 35,
        ),
      ),
    );
  }

  Widget _buildGreetingTexts(
      String greeting,
      String name,
      String headQuarter,
      String territory,
      String mobileNumber,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: const TextStyle(color: Colors.white, fontSize: 22),
        ),
        Text(
          "$mobileNumber",
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        Text(
          '$headQuarter-$territory',
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildRetailerDataCard(int submittedApplications) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              _buildDataAvatar('Asset/dashboardImg.png'),
              const SizedBox(width: 10),
              const Text(
                'Number of Retailers\nData Submitted',
                style: TextStyle(color: Colors.black87, fontSize: 16),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 28.0),
            child: Text(
              '$submittedApplications',
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataAvatar(String assetPath) {
    return CircleAvatar(
      radius: 25,
      backgroundColor: Colors.grey[300],
      child: ClipOval(
        child: Image.asset(
          assetPath,
          fit: BoxFit.cover,
          width: 40,
          height: 40,
        ),
      ),
    );
  }

  Widget _buildAddRetailerCard(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'Asset/businessmanImg.png',
            height: 150,
            fit: BoxFit.cover,
          ),
          ElevatedButton.icon(
            onPressed: () async {
              final result = await Get.to(() => RetailerPotentialScreen());
              if (result != null && result == true) {
                await _refreshData();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              'Add Retailer',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}
