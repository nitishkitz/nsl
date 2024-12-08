import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nslretailaudits/submi.dart';
import 'AuditController.dart';
import 'Homepage.dart';
import 'consts.dart';
import 'location.dart';


class RetailerPotentialScreen extends StatefulWidget {
  const RetailerPotentialScreen({Key? key}) : super(key: key);

  @override
  State<RetailerPotentialScreen> createState() =>
      _RetailerPotentialScreenState();
}

class _RetailerPotentialScreenState extends State<RetailerPotentialScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _retailerNameController = TextEditingController();
  final TextEditingController _mobileNoController = TextEditingController();
  final TextEditingController _totalTurnoverController =
  TextEditingController();
  final TextEditingController _seedTurnoverController = TextEditingController();
  final TextEditingController _villageController = TextEditingController();
  final TextEditingController _talukaController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();

  String? _selectedRetailerType;
  bool? _isFocus20;
  bool? _isNVMRegistered;

  final List<String> crops = [
    'Cotton (Packets)',
    'Maize (Kg)',
    'Hybrid Paddy (Kg)',
    'Res. Paddy (Kg)',
    'Bajra (Kg)',
    'Mustard (Kg)',
    'Wheat (Kg)',
    'Jute (Kg)',
  ];

  late List<TextEditingController> totalRetailPotentialControllers;
  late List<TextEditingController> nslSalesControllers;

  bool _isRetailerInfoExpanded = true; // Initially expanded
  bool _isRetailerPotentialInfoExpanded = false; // Initially not expanded
  bool _showRetailerPotentialSection = false; // Initially not even visible

  final ScrollController _scrollController = ScrollController();
  final GlobalKey _potentialKey = GlobalKey();

  final SubmitController _submitController = Get.put(SubmitController());
  final AuditController _auditController = Get.put(AuditController()); // Added line

  @override
  void initState() {
    super.initState();
    totalRetailPotentialControllers =
        List.generate(crops.length, (_) => TextEditingController());
    nslSalesControllers =
        List.generate(crops.length, (_) => TextEditingController());

    // Attempt to fill address fields from current location
    _fillAddressFields();
  }

  Future<void> _fillAddressFields() async {
    final address = await getAddressFromLocation();
    if (address.isNotEmpty && mounted) {
      setState(() {
        _villageController.text = address['village'] ?? '';
        _talukaController.text = address['taluka'] ?? '';
        _districtController.text = address['district'] ?? '';
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _mobileNoController.dispose();
    _totalTurnoverController.dispose();
    _seedTurnoverController.dispose();
    _villageController.dispose();
    _talukaController.dispose();
    _districtController.dispose();

    for (var c in totalRetailPotentialControllers) {
      c.dispose();
    }
    for (var c in nslSalesControllers) {
      c.dispose();
    }

    super.dispose();
  }

  Widget trailingIcon(bool isExpanded) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
          color: Colors.red, borderRadius: BorderRadius.circular(6)),
      child: Icon(
        isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
        color: Colors.white,
      ),
    );
  }

  void _goToPotentialInfo() {
    setState(() {
      _isRetailerInfoExpanded = false;
      _showRetailerPotentialSection = true;
      _isRetailerPotentialInfoExpanded = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Scrollable.ensureVisible(
        _potentialKey.currentContext!,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  InputDecoration get _fieldDecoration => InputDecoration(
    border: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
      borderSide: BorderSide(color: Colors.grey),
    ),
    enabledBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
      borderSide: BorderSide(color: Colors.grey),
    ),
    focusedBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
      borderSide:
      BorderSide(color: Colors.grey),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  );

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          decoration: _fieldDecoration.copyWith(
            hintText: 'Enter $label',
          ),
          keyboardType: keyboardType,
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        DropdownButtonFormField<String>(
          decoration: _fieldDecoration,
          value: value,
          items: items,
          onChanged: onChanged,
          hint: Text('Select $label'),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildYesNoRow({
    required String question,
    required bool? value,
    required void Function(bool) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(question, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: [
            InkWell(
              onTap: () => onChanged(true),
              child: Row(
                children: [
                  _buildCheckCircle(selected: value == true),
                  const SizedBox(width: 8),
                  const Text('Yes')
                ],
              ),
            ),
            const SizedBox(width: 20),
            InkWell(
              onTap: () => onChanged(false),
              child: Row(
                children: [
                  _buildCheckCircle(selected: value == false),
                  const SizedBox(width: 8),
                  const Text('No')
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCheckCircle({required bool selected}) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? MarkedGreen : Colors.transparent,
        border: Border.all(color: Colors.grey),
      ),
      child: selected
          ? const Icon(Icons.check, color: Colors.white, size: 20)
          : null,
    );
  }

  void _showCustomDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
              color: Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 32.0),
                const Text(
                  'Retailer Added Successfully',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 32.0),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    onPressed: () {

                      Get.off(() => Homepage(), arguments: {'reload': true});
                    },
                    child: const Text(
                      'Ok',
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
              ],
            ),
          ),
        );
      },
    );
  }

  void _onSubmit() async {
    if (_validatePotentialInfo()) {
      List<Map<String, dynamic>> cropDetails = [];
      for (int i = 0; i < _auditController.retailerSeedType.length; i++) {
        String seedType = _auditController.retailerSeedType[i];
        String retailPotential = totalRetailPotentialControllers[i].text.trim();
        String nslSales = nslSalesControllers[i].text.trim();

        if (retailPotential.isNotEmpty && nslSales.isNotEmpty) {
          cropDetails.add({
            'seedType': seedType,
            'totalRetailPotential': double.tryParse(retailPotential) ?? 0.0,
            'nslSales': double.tryParse(nslSales) ?? 0.0,
          });
        }
      }

      await _submitController.submitAuditData(
        retailerName: _retailerNameController.text.trim(),
        mobileNo: _mobileNoController.text.trim(),
        retailerType: _selectedRetailerType!,
        totalTurnover: double.parse(_totalTurnoverController.text.trim()),
        seedTurnover: double.tryParse(_seedTurnoverController.text.trim()) ?? 0.0,
        village: _villageController.text.trim(),
        taluka: _talukaController.text.trim(),
        district: _districtController.text.trim(),
        crops: cropDetails,
        isFocus20: _isFocus20!,
        isNVMRegistered: _isNVMRegistered!,
      );

      _showCustomDialog();
    }
  }

  bool _validateRetailerInfo() {
    if (_retailerNameController.text.trim().isEmpty) {
      _showSnackbar('Retailer Name is required.');
      return false;
    }

    if (_mobileNoController.text.trim().isEmpty) {
      _showSnackbar('Mobile Number is required.');
      return false;
    }

    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(_mobileNoController.text.trim())) {
      _showSnackbar(
          'Enter a valid 10-digit mobile number starting with 6,7,8, or 9.');
      return false;
    }

    if (_selectedRetailerType == null || _selectedRetailerType!.isEmpty) {
      _showSnackbar('Retailer Type is required.');
      return false;
    }

    if (_totalTurnoverController.text.trim().isEmpty) {
      _showSnackbar('Total Turnover is required.');
      return false;
    }

    if (double.tryParse(_totalTurnoverController.text.trim()) == null) {
      _showSnackbar('Enter a valid number for Total Turnover.');
      return false;
    }

    if (_seedTurnoverController.text.trim().isNotEmpty &&
        double.tryParse(_seedTurnoverController.text.trim()) == null) {
      _showSnackbar('Enter a valid number for Seed Turnover.');
      return false;
    }

    if (_villageController.text.trim().isEmpty) {
      _showSnackbar('Village is required.');
      return false;
    }

    if (_talukaController.text.trim().isEmpty) {
      _showSnackbar('Taluka is required.');
      return false;
    }

    if (_districtController.text.trim().isEmpty) {
      _showSnackbar('District is required.');
      return false;
    }

    return true;
  }

  bool _validatePotentialInfo() {
    bool hasAtLeastOneFilled = false;
    for (int i = 0; i < crops.length; i++) {
      if (totalRetailPotentialControllers[i].text.trim().isNotEmpty ||
          nslSalesControllers[i].text.trim().isNotEmpty) {
        hasAtLeastOneFilled = true;
        break;
      }
    }

    if (!hasAtLeastOneFilled) {
      _showSnackbar(
          'Please fill at least one crop\'s Total Retail Potential or NSL Sales.');
      return false;
    }

    for (int i = 0; i < crops.length; i++) {
      String retailPotential = totalRetailPotentialControllers[i].text.trim();
      String nslSales = nslSalesControllers[i].text.trim();

      if (retailPotential.isNotEmpty && nslSales.isEmpty) {
        _showSnackbar('Please fill NSL Sales for ${crops[i]}.');
        return false;
      }

      if (nslSales.isNotEmpty && retailPotential.isEmpty) {
        _showSnackbar('Please fill Total Retail Potential for ${crops[i]}.');
        return false;
      }

      if (retailPotential.isNotEmpty) {
        if (double.tryParse(retailPotential) == null) {
          _showSnackbar(
              'Total Retail Potential for ${crops[i]} must be a valid number.');
          return false;
        }
      }

      if (nslSales.isNotEmpty) {
        if (double.tryParse(nslSales) == null) {
          _showSnackbar('NSL Sales for ${crops[i]} must be a valid number.');
          return false;
        }
      }
    }

    if (_isFocus20 == null) {
      _showSnackbar('Please answer the Focus 20 retailers question.');
      return false;
    }

    if (_isNVMRegistered == null) {
      _showSnackbar('Please answer the NVM registration question.');
      return false;
    }

    return true;
  }

  void _onNext() {
    if (_validateRetailerInfo()) {
      _goToPotentialInfo();
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Widget _buildSection({
    Key? key,
    required String title,
    required bool isExpanded,
    required void Function(bool) onExpansionChanged,
    required Widget trailing,
    required List<Widget> children,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        key: key,
        decoration: BoxDecoration(
          border: key != null ? Border.all(color: Colors.grey.shade300) : null,
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          boxShadow: key == null
              ? [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            )
          ]
              : [],
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            title: Text(
              title,
              style:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            collapsedBackgroundColor: Colors.white,
            backgroundColor: Colors.white,
            initiallyExpanded: isExpanded,
            childrenPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            tilePadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            maintainState: true,
            onExpansionChanged: onExpansionChanged,
            trailing: trailing,
            children: children,
          ),
        ),
      ),
    );
  }

  Widget _buildCropTable() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            border: TableBorder.all(color: Colors.grey.shade400, width: 1),
            columnSpacing: 20,
            headingRowColor: MaterialStateProperty.all(background),
            columns: const [
              DataColumn(
                  label: Text('S.No',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('Crop',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('Total Retail\nPotential',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('NSL Sales',
                      style: TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: List.generate(crops.length, (index) {
              return DataRow(cells: [
                DataCell(Text('${index + 1}')),
                DataCell(Text(crops[index])),
                DataCell(_buildTableTextField(
                  controller: totalRetailPotentialControllers[index],
                  hint: ' -',
                )),
                DataCell(_buildTableTextField(
                  controller: nslSalesControllers[index],
                  hint: ' -',
                )),
              ]);
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildTableTextField({
    required TextEditingController controller,
    required String hint,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        isDense: true,
        border: InputBorder.none,
        contentPadding:
        const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        leading: IconButton(
          icon: Image.asset('Asset/backArrow.png'),
          onPressed: () {
            Get.back();
          },
        ),
        title: const Text('Add Retailer',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.red,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Retailer Info
              _buildSection(
                title: "Retailer Info",
                isExpanded: _isRetailerInfoExpanded,
                onExpansionChanged: (e) =>
                    setState(() => _isRetailerInfoExpanded = e),
                trailing: trailingIcon(_isRetailerInfoExpanded),
                children: [
                  _buildTextField(
                      label: 'Retailer Name',
                      controller: _retailerNameController),
                  _buildTextField(
                    label: 'Mobile No',
                    controller: _mobileNoController,
                    keyboardType: TextInputType.phone,
                  ),
                  Obx(() {
                    if (_auditController.isLoading.value) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Retailer Type',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(height: 5),
                          CircularProgressIndicator(),
                          SizedBox(height: 8),
                        ],
                      );
                    } else if (_auditController.errorMessage.isNotEmpty) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Retailer Type',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(height: 5),
                          Text('Error loading retailer types',
                              style: TextStyle(color: Colors.red)),
                          SizedBox(height: 8),
                        ],
                      );
                    } else {
                      return _buildDropdown(
                        label: 'Retailer Type',
                        value: _selectedRetailerType,
                        items: _auditController.retailerSeedType
                            .map((type) => DropdownMenuItem(
                            value: type, child: Text(type)))
                            .toList(),
                        onChanged: (val) =>
                            setState(() => _selectedRetailerType = val),
                      );
                    }
                  }),
                  _buildTextField(
                    label: 'Total Turnover (in Lakhs)',
                    controller: _totalTurnoverController,
                    keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                  ),
                  _buildTextField(
                      label: 'Village', controller: _villageController),
                  _buildTextField(
                      label: 'Taluka', controller: _talukaController),
                  _buildTextField(
                      label: 'District', controller: _districtController),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8))),
                      onPressed: _onNext,
                      child: const Text("Next",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Retailer Potential Info - Visible only after pressing Next
              Visibility(
                visible: _showRetailerPotentialSection,
                child: _buildSection(
                  key: _potentialKey,
                  title: "Retailer Potential Info",
                  isExpanded: _isRetailerPotentialInfoExpanded,
                  onExpansionChanged: (e) =>
                      setState(() => _isRetailerPotentialInfoExpanded = e),
                  trailing: trailingIcon(_isRetailerPotentialInfoExpanded),
                  children: [
                    _buildCropTable(),
                    const SizedBox(height: 20),
                    _buildYesNoRow(
                      question: "Is the retailer part of Focus 20 retailers?",
                      value: _isFocus20,
                      onChanged: (val) => setState(() => _isFocus20 = val),
                    ),
                    const SizedBox(height: 20),
                    _buildYesNoRow(
                      question:
                      "Is the retailer registered in NVM program?",
                      value: _isNVMRegistered,
                      onChanged: (val) =>
                          setState(() => _isNVMRegistered = val),
                    ),
                    const SizedBox(height: 20),
                    Obx(() {
                      return SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8))),
                          onPressed: _submitController.isLoading.value
                              ? null
                              : _onSubmit,
                          child: _submitController.isLoading.value
                              ? const CircularProgressIndicator(
                            valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                              : const Text("Submit",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18)),
                        ),
                      );
                    }),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
