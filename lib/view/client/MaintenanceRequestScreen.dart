import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';

class MaintenanceRequestScreen extends StatefulWidget {
  final String categoryName;
  const MaintenanceRequestScreen({super.key, required this.categoryName});

  @override
  State<MaintenanceRequestScreen> createState() =>
      _MaintenanceRequestScreenState();
}

class _MaintenanceRequestScreenState extends State<MaintenanceRequestScreen> {
  bool isUrgent = true;
  int selectedMonthIndex = 0;
  int selectedDateIndex = 0;
  String? selectedTimeSlot;

  // منطق الصور
  final List<XFile> _images = [];
  final ImagePicker _picker = ImagePicker();

  final List<String> months = ["September", "October", "November", "December"];
  final List<String> days = [
    "Mon 12",
    "Tue 13",
    "Wed 14",
    "Thu 15",
    "Fri 16",
    "Sat 17",
  ];
  final List<String> timeSlots = [
    "09:00 AM",
    "10:30 AM",
    "01:00 PM",
    "03:30 PM",
    "05:00 PM",
    "08:00 PM",
  ];

  Future<void> _pickImage() async {
    if (_images.length < 3) {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _images.add(image);
        });
      }
    } else {
      Get.snackbar(
        "Limit Reached",
        "You can only upload up to 3 photos",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orangeAccent,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: Stack(
        children: [
          _buildBackgroundBlurEffect(),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                          "Vehicle Info",
                          Icons.directions_car_filled_rounded,
                        ),
                        _buildModernInput(
                          "e.g. Mercedes-Benz G63",
                          Icons.car_rental_rounded,
                        ),

                        if (!isUrgent) ...[
                          const SizedBox(height: 30),
                          _buildSectionHeader(
                            "Pick a Date",
                            Icons.calendar_today_rounded,
                          ),
                          const SizedBox(height: 15),
                          _buildMonthStrip(),
                          const SizedBox(height: 15),
                          _buildDaySelector(),
                          const SizedBox(height: 25),
                          _buildSectionHeader(
                            "Pick a Time",
                            Icons.watch_later_rounded,
                          ),
                          const SizedBox(height: 15),
                          _buildTimeGrid(),
                        ],

                        const SizedBox(height: 30),
                        _buildSectionHeader(
                          "The Issue",
                          Icons.report_problem_rounded,
                        ),
                        _buildModernInput(
                          "Describe the problem...",
                          Icons.notes_rounded,
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
        ],
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: const Icon(
              Icons.build_circle_outlined,
              color: Color(0xFFE55757),
              size: 24,
            ),
          ),
        ],
      ),
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

  Widget _buildGlassToggle() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10),
        ],
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

  Widget _buildModernInput(String hint, IconData icon, {int maxLines = 1}) {
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
        maxLines: maxLines,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.grey[400], size: 20),
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(20),
        ),
      ),
    );
  }

  Widget _buildMonthStrip() {
    return SizedBox(
      height: 35,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: months.length,
        itemBuilder: (context, index) {
          bool sel = selectedMonthIndex == index;
          return GestureDetector(
            onTap: () => setState(() => selectedMonthIndex = index),
            child: Padding(
              padding: const EdgeInsets.only(right: 25),
              child: Text(
                months[index],
                style: TextStyle(
                  color: sel ? const Color(0xFFE55757) : Colors.grey[400],
                  fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                  fontSize: 16,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDaySelector() {
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        itemBuilder: (context, index) {
          bool sel = selectedDateIndex == index;
          return GestureDetector(
            onTap: () => setState(() => selectedDateIndex = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 70,
              margin: const EdgeInsets.only(right: 15),
              decoration: BoxDecoration(
                color: sel ? const Color(0xFFE55757) : Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  if (sel)
                    BoxShadow(
                      color: const Color(0xFFE55757).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    days[index].split(" ")[0],
                    style: TextStyle(
                      color: sel ? Colors.white70 : Colors.grey,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    days[index].split(" ")[1],
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

  Widget _buildTimeGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2.2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemCount: timeSlots.length,
      itemBuilder: (context, index) {
        bool sel = selectedTimeSlot == timeSlots[index];
        return GestureDetector(
          onTap: () => setState(() => selectedTimeSlot = timeSlots[index]),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              color: sel
                  ? const Color(0xFFE55757).withOpacity(0.12)
                  : Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: sel ? const Color(0xFFE55757) : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Center(
              child: Text(
                timeSlots[index],
                style: TextStyle(
                  color: sel
                      ? const Color(0xFFE55757)
                      : const Color(0xFF1A1A1A),
                  fontSize: 12,
                  fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      },
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
        onPressed: () {
          Get.snackbar(
            "Success",
            "Your request has been sent!",
            snackPosition: SnackPosition.BOTTOM,
            // backgroundColor: Colors.,
            colorText: Colors.black87,
          );
        },
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
}
