import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'package:senior_project/controller/VehicleController.dart';
import 'package:senior_project/controller/MaintenanceController.dart';

class MaintenanceRequestScreen extends StatefulWidget {
  final String categoryName;
  const MaintenanceRequestScreen({super.key, required this.categoryName});

  @override
  State<MaintenanceRequestScreen> createState() =>
      _MaintenanceRequestScreenState();
}

class _MaintenanceRequestScreenState extends State<MaintenanceRequestScreen> {
  // استدعاء الكنترولرات
  final VehicleController vehicleController = Get.put(VehicleController());
  final MaintenanceController maintenanceController = Get.put(
    MaintenanceController(),
  );

  bool isUrgent = true;
  int selectedDateIndex = 0;

  final List<XFile> _images = [];
  final ImagePicker _picker = ImagePicker();

  late List<DateTime> dynamicDays;
  final List<String> timeSlots = [
    "09:00 AM",
    "10:30 AM",
    "01:00 PM",
    "03:30 PM",
    "05:00 PM",
    "08:00 PM",
  ];

  @override
  void initState() {
    super.initState();
    dynamicDays = List.generate(
      7,
      (index) => DateTime.now().add(Duration(days: index)),
    );
  }

  String getSelectedVehicleName() {
    if (vehicleController.selectedVehicleId.value == null) {
      return "No vehicle selected from Garage";
    }
    try {
      var selectedVehicle = vehicleController.vehicleList.firstWhere(
        (v) => v.id == vehicleController.selectedVehicleId.value,
      );
      return "${selectedVehicle.brand} ${selectedVehicle.model}";
    } catch (e) {
      return "Select vehicle from garage";
    }
  }

  Future<void> _pickImage() async {
    if (_images.length < 3) {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) setState(() => _images.add(image));
    } else {
      Get.snackbar(
        "Limit Reached",
        "Max 3 photos allowed",
        backgroundColor: Colors.orangeAccent,
      );
    }
  }

  void submitRequest() {
    if (vehicleController.selectedVehicleId.value == null) {
      Get.snackbar(
        "Attention",
        "Please select a vehicle first",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    String? formattedDate;
    if (!isUrgent) {
      DateTime selDate = dynamicDays[selectedDateIndex];
      formattedDate = "${selDate.year}-${selDate.month}-${selDate.day}";
    }

    maintenanceController.sendMaintenanceRequest(
      vehicleId: vehicleController.selectedVehicleId.value!,
      maintenanceType: isUrgent ? "immediate" : "scheduled",
      problemType: maintenanceController.problemController.text,
      scheduledDate: formattedDate,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: Obx(
        () => Stack(
          children: [
            _buildBackgroundBlurEffect(),
            SafeArea(
              child: Column(
                children: [
                  _buildAnimatedHeader(),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 25,
                        vertical: 10,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildGlassToggle(),
                          const SizedBox(height: 30),

                          _buildSectionHeader(
                            "Selected Vehicle",
                            Icons.directions_car_filled_rounded,
                          ),
                          _buildVehicleDisplay(),

                          if (!isUrgent) ...[
                            const SizedBox(height: 30),
                            _buildSectionHeader(
                              "Pick a Date",
                              Icons.calendar_today_rounded,
                            ),
                            const SizedBox(height: 15),
                            _buildDynamicDaySelector(),
                          ],

                          const SizedBox(height: 30),
                          _buildSectionHeader(
                            "The Issue",
                            Icons.report_problem_rounded,
                          ),
                          _buildModernInput(
                            "Describe the problem...",
                            Icons.notes_rounded,
                            controller: maintenanceController.problemController,
                            maxLines: 3,
                          ),

                          const SizedBox(height: 30),
                          _buildSectionHeader(
                            "Photos",
                            Icons.camera_enhance_rounded,
                          ),
                          const SizedBox(height: 15),
                          _buildImageUploader(),

                          const SizedBox(height: 40),
                          _buildPremiumSubmitButton(),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (maintenanceController.isLoading.value)
              Container(
                color: Colors.black26,
                child: const Center(
                  child: CircularProgressIndicator(color: Color(0xFFE55757)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleDisplay() {
    return Obx(
      () => _buildModernInput(
        getSelectedVehicleName(),
        Icons.verified_user_rounded,
        readOnly: true,
        textColor: vehicleController.selectedVehicleId.value == null
            ? Colors.redAccent
            : Colors.black87,
      ),
    );
  }

  Widget _buildDynamicDaySelector() {
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: dynamicDays.length,
        itemBuilder: (context, index) {
          DateTime date = dynamicDays[index];
          bool sel = selectedDateIndex == index;
          List<String> weekdays = [
            "Mon",
            "Tue",
            "Wed",
            "Thu",
            "Fri",
            "Sat",
            "Sun",
          ];

          return GestureDetector(
            onTap: () => setState(() => selectedDateIndex = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 70,
              margin: const EdgeInsets.only(right: 15),
              decoration: BoxDecoration(
                color: sel ? const Color(0xFFE55757) : Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: sel
                    ? [
                        BoxShadow(
                          color: const Color(0xFFE55757).withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : [],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    weekdays[date.weekday - 1],
                    style: TextStyle(
                      color: sel ? Colors.white70 : Colors.grey,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${date.day}",
                    style: TextStyle(
                      color: sel ? Colors.white : const Color(0xFF1A1A1A),
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildModernInput(
    String hint,
    IconData icon, {
    int maxLines = 1,
    bool readOnly = false,
    Color? textColor,
    TextEditingController? controller,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15),
        ],
      ),
      child: TextField(
        controller:
            controller ?? (readOnly ? TextEditingController(text: hint) : null),
        readOnly: readOnly,
        maxLines: maxLines,
        style: TextStyle(
          color: textColor ?? Colors.black87,
          fontWeight: readOnly ? FontWeight.bold : FontWeight.normal,
        ),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: const Color(0xFFE55757), size: 20),
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(20),
        ),
      ),
    );
  }

  Widget _buildPremiumSubmitButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFFE55757),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE55757).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        onPressed: submitRequest,
        child: const Text(
          "CONFIRM REQUEST",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 16,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildGlassToggle() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          _toggleElement(
            "URGENT",
            isUrgent,
            () => setState(() => isUrgent = true),
          ),
          _toggleElement(
            "SCHEDULE",
            !isUrgent,
            () => setState(() => isUrgent = false),
          ),
        ],
      ),
    );
  }

  Widget _toggleElement(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? const Color(0xFFE55757) : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: active ? Colors.white : Colors.grey[500],
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageUploader() {
    return SizedBox(
      height: 90,

      child: ListView.builder(
        scrollDirection: Axis.horizontal,

        itemCount: _images.length < 3 ? _images.length + 1 : _images.length,

        itemBuilder: (context, index) {
          if (index == _images.length && _images.length < 3) {
            return Row(
              mainAxisSize: MainAxisSize.min,

              children: [
                GestureDetector(
                  onTap: _pickImage,

                  child: Container(
                    width: 85,

                    height: 85,

                    decoration: BoxDecoration(
                      color: Colors.white,

                      borderRadius: BorderRadius.circular(22),

                      border: Border.all(
                        color: const Color(0xFFE55757).withOpacity(0.2),

                        width: 2,
                      ),
                    ),

                    child: const Icon(
                      Icons.add_a_photo_rounded,

                      color: Color(0xFFE55757),

                      size: 28,
                    ),
                  ),
                ),

                const SizedBox(width: 15),

                Column(
                  mainAxisAlignment: MainAxisAlignment.center,

                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    const Text(
                      "Attach photos",

                      style: TextStyle(
                        fontWeight: FontWeight.bold,

                        fontSize: 14,

                        color: Color(0xFF1A1A1A),
                      ),
                    ),

                    Text(
                      "If available (Max 3)",

                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  ],
                ),

                const SizedBox(width: 20),
              ],
            );
          }

          return Stack(
            children: [
              Container(
                width: 85,

                height: 85,

                margin: const EdgeInsets.only(right: 12),

                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),

                  image: DecorationImage(
                    image: FileImage(File(_images[index].path)),

                    fit: BoxFit.cover,
                  ),
                ),
              ),

              Positioned(
                top: 5,

                right: 15,

                child: GestureDetector(
                  onTap: () => setState(() => _images.removeAt(index)),

                  child: Container(
                    padding: const EdgeInsets.all(2),

                    decoration: const BoxDecoration(
                      color: Colors.white,

                      shape: BoxShape.circle,
                    ),

                    child: const Icon(Icons.close, size: 14, color: Colors.red),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFE55757), size: 20),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }

  Widget _buildBackgroundBlurEffect() {
    return Positioned(
      top: -50,
      left: -50,
      child: Container(
        width: 250,
        height: 250,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFE55757).withOpacity(0.08),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
          child: Container(color: Colors.transparent),
        ),
      ),
    );
  }

  Widget _buildAnimatedHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 20, 25, 15),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Color(0xFF1A1A1A),
              size: 22,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 5),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Service Intake",
                style: TextStyle(
                  color: const Color(0xFFE55757).withOpacity(0.7),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                widget.categoryName,
                style: const TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                ),
              ),
            ],
          ),
          const Spacer(),
          const Icon(
            Icons.build_circle_outlined,
            color: Color(0xFFE55757),
            size: 30,
          ),
        ],
      ),
    );
  }
}
