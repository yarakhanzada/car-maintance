import 'dart:ui';
import 'package:flutter/material.dart';

class MyGarageScreen extends StatefulWidget {
  const MyGarageScreen({super.key});

  @override
  State<MyGarageScreen> createState() => _MyGarageScreenState();
}

class _MyGarageScreenState extends State<MyGarageScreen> {
  String? openedCardTitle;

  void _showAddVehicleDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Add",
      barrierColor: Colors.black.withOpacity(0.6),
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (context, anim1, anim2) => const SizedBox(),
      transitionBuilder: (context, anim1, anim2, child) {
        final curvedValue = Curves.easeInOutQuart.transform(anim1.value);
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Opacity(
            opacity: anim1.value,
            child: Transform.translate(
              offset: Offset(0, (1 - curvedValue) * 40),
              child: AlertDialog(
                backgroundColor: Colors.white.withOpacity(0.9),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(35),
                ),
                title: Column(
                  children: [
                    Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Register Vehicle",
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 24,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildAnimatedTextField(
                      hint: "Car Model",
                      icon: Icons.directions_car_rounded,
                    ),
                    const SizedBox(height: 15),
                    _buildAnimatedTextField(
                      hint: "Plate Number",
                      icon: Icons.tag_rounded,
                    ),
                  ],
                ),
                actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                actions: [
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          child: const Text(
                            "Cancel",
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE55757),
                            foregroundColor: Colors.white,
                            elevation: 5,
                            shadowColor: const Color(
                              0xFFE55757,
                            ).withOpacity(0.4),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: const Text(
                            "Add Car",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedTextField({
    required String hint,
    required IconData icon,
  }) {
    return TextField(
      style: const TextStyle(fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: Colors.grey[400],
          fontWeight: FontWeight.w400,
        ),
        prefixIcon: Icon(icon, color: const Color(0xFFE55757), size: 22),
        filled: true,
        fillColor: Colors.grey[100]?.withOpacity(0.7),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Color(0xFFE55757), width: 1.5),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double width = constraints.maxWidth;
          final double height = constraints.maxHeight;

          return Stack(
            children: [
              _buildBackgroundGradient(height),
              CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  _buildSliverHeader(width),
                  SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: width * 0.06,
                      vertical: 15,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: GestureDetector(
                        onTap: _showAddVehicleDialog,
                        child: _buildInteractiveAddCard(width),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        width * 0.07,
                        10,
                        width * 0.06,
                        15,
                      ),
                      child: const Text(
                        "Registered Vehicles",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: width * 0.06),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _buildSlidableCard(
                          width,
                          "Audi R8",
                          "V10 Performance",
                          "B-1234-JK",
                        ),
                        const SizedBox(height: 20),
                        _buildSlidableCard(
                          width,
                          "G-Wagon",
                          "AMG G63",
                          "G-9999-ST",
                        ),
                        const SizedBox(height: 150),
                      ]),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSlidableCard(
    double width,
    String title,
    String subtitle,
    String plate,
  ) {
    double dragOffset = (openedCardTitle == title) ? -220 : 0;

    return StatefulBuilder(
      builder: (context, setStateInternal) {
        return GestureDetector(
          onHorizontalDragUpdate: (details) {
            setStateInternal(() {
              dragOffset += details.primaryDelta!;
              if (dragOffset > 0) dragOffset = 0;
              if (dragOffset < -240) dragOffset = -240;
            });
          },
          onHorizontalDragEnd: (details) {
            setState(() {
              if (dragOffset < -100) {
                dragOffset = -220;
                openedCardTitle = title;
              } else {
                dragOffset = 0;
                openedCardTitle = null;
              }
            });
          },
          child: Stack(
            children: [
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Edit Button
                      _buildActionIcon(
                        Icons.edit_rounded,
                        "Edit",
                        Colors.blueAccent,
                      ),
                      _buildActionIcon(
                        Icons.check_circle_outline_rounded,
                        "Select",
                        Colors.greenAccent,
                      ),
                      // Delete Button
                      _buildActionIcon(
                        Icons.delete_outline_rounded,
                        "Delete",
                        Colors.redAccent,
                      ),
                    ],
                  ),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                transform: Matrix4.translationValues(dragOffset, 0, 0),
                child: _buildGlassCarCard(width, title, subtitle, plate),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionIcon(IconData icon, String label, Color color) {
    return Container(
      width: 75,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.3), width: 1),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: color.withOpacity(0.9),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundGradient(double height) {
    return Positioned(
      top: -100,
      right: -100,
      child: Container(
        width: 300,
        height: 300,
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

  Widget _buildSliverHeader(double width) {
    return SliverToBoxAdapter(
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(width * 0.06, 30, width * 0.06, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "My Garage",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1A1A1A),
                      letterSpacing: -1,
                    ),
                  ),
                  _buildStatusBadge(),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                "Welcome to your personal vehicle hub",
                style: TextStyle(color: Colors.grey[500], fontSize: 15),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE55757).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        "PREMIUM",
        style: TextStyle(
          color: Color(0xFFE55757),
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInteractiveAddCard(double width) {
    return Container(
      width: width,
      height: 110,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [
            const Color(0xFFE55757),
            const Color(0xFFEF8E8E).withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE55757).withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            Positioned(
              top: -20,
              right: -20,
              child: Icon(
                Icons.add_circle_outline_rounded,
                size: 150,
                color: Colors.white.withOpacity(0.15),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(25),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Add New Vehicle",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "Tap to register a new car to your garage",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.5)),
                    ),
                    child: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassCarCard(
    double width,
    String title,
    String subtitle,
    String plate,
  ) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                child: Icon(
                  Icons.directions_car_filled_outlined,
                  size: 60,
                  color: Colors.grey[300],
                ),
              ),
              Positioned(
                top: 15,
                right: 15,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black.withOpacity(0.05)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "slide",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.black.withOpacity(0.4),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 10,
                        color: Colors.black.withOpacity(0.4),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(color: Colors.grey[500], fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    plate,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
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
}
