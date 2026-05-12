import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:senior_project/controller/auth_controller.dart';
import 'package:senior_project/widgets/garage_widgets.dart';
import 'package:senior_project/widgets/vehicle_card.dart';
import '../../controller/VehicleController.dart';

class MyGarageScreen extends StatefulWidget {
  const MyGarageScreen({super.key});

  @override
  State<MyGarageScreen> createState() => _MyGarageScreenState();
}

class _MyGarageScreenState extends State<MyGarageScreen> {
  final VehicleController controller = Get.put(VehicleController());

  final TextEditingController brandController = TextEditingController();
  final TextEditingController modelController = TextEditingController();
  final TextEditingController yearController = TextEditingController();
  final TextEditingController plateController = TextEditingController();

  int? openedVehicleId;

  void _clearControllers() {
    brandController.clear();
    modelController.clear();
    yearController.clear();
    plateController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double width = constraints.maxWidth;

          return Stack(
            children: [
              const GarageBackground(),
              CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  GarageHeader(width: width),

                  SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: width * 0.06,
                      vertical: 15,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: AddVehicleCard(
                        width: width,
                        onTap: () => _showAddVehicleDialog(context),
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
                        ),
                      ),
                    ),
                  ),

                  Obx(() {
                    if (controller.isLoading.value &&
                        controller.vehicleList.isEmpty) {
                      return const SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(40.0),
                            child: CircularProgressIndicator(
                              color: Color(0xFFE55757),
                            ),
                          ),
                        ),
                      );
                    }

                    if (controller.vehicleList.isEmpty) {
                      return SliverToBoxAdapter(
                        child: Center(
                          child: Column(
                            children: [
                              const SizedBox(height: 50),
                              Icon(
                                Icons.directions_car_filled_outlined,
                                size: 80,
                                color: Colors.grey[300],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "No vehicles in your garage.",
                                style: TextStyle(color: Colors.grey[500]),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: width * 0.06),
                      sliver: Obx(
                        () => SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final vehicle = controller.vehicleList[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: VehicleCard(
                                brand: vehicle.brand,
                                model: vehicle.model,
                                year: vehicle.year.toString(),
                                chassis: vehicle.plate_number,
                                isOpened: openedVehicleId == vehicle.id,
                                isSelected:
                                    controller.selectedVehicleId.value ==
                                    vehicle.id,
                                onSlide: (isOpened) {
                                  setState(() {
                                    openedVehicleId = isOpened
                                        ? vehicle.id
                                        : null;
                                  });
                                },
                                onDelete: () {
                                  Get.defaultDialog(
                                    title: "Delete Vehicle",
                                    middleText:
                                        "Are you sure you want to remove this vehicle?",
                                    textConfirm: "Delete",
                                    textCancel: "Cancel",
                                    confirmTextColor: Colors.white,
                                    buttonColor: const Color(0xFFE55757),
                                    onConfirm: () {
                                      controller.deleteVehicle(vehicle.id);
                                      Get.back();
                                    },
                                  );
                                },
                                onEdit: () {},
                                onSelect: () {
                                  controller.selectVehicle(vehicle.id);
                                  setState(() {
                                    openedVehicleId = null;
                                  });
                                },
                              ),
                            );
                          }, childCount: controller.vehicleList.length),
                        ),
                      ),
                    );
                  }),
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),

              Obx(
                () =>
                    controller.isLoading.value &&
                        controller.vehicleList.isNotEmpty
                    ? const Positioned(
                        top: 50,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: LinearProgressIndicator(
                            color: Color(0xFFE55757),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAddVehicleDialog(BuildContext context) {
    _clearControllers();
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
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GarageInputField(
                        controller: brandController,
                        hint: "Brand (e.g. Toyota)",
                        icon: Icons.apartment_rounded,
                      ),
                      const SizedBox(height: 12),
                      GarageInputField(
                        controller: modelController,
                        hint: "Car Model",
                        icon: Icons.directions_car_rounded,
                      ),
                      const SizedBox(height: 12),
                      GarageInputField(
                        controller: yearController,
                        hint: "Year",
                        icon: Icons.calendar_today_rounded,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      GarageInputField(
                        controller: plateController,
                        hint: "Plate Number ",
                        icon: Icons.tag_rounded,
                      ),
                    ],
                  ),
                ),
                actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                actions: [
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            "Cancel",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (brandController.text.isNotEmpty &&
                                modelController.text.isNotEmpty) {
                              controller.addVehicle(
                                brand: brandController.text,
                                model: modelController.text,
                                year: yearController.text,
                                plate: plateController.text,
                              );
                              Navigator.pop(context);
                            } else {
                              Get.snackbar(
                                "Error",
                                "Please fill Brand and Model",
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE55757),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: const Text("Add Car"),
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
}
