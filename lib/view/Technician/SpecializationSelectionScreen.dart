import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:senior_project/view/Technician/TechnicianBottombar.dart';

class SpecializationSelectionScreen extends StatefulWidget {
  const SpecializationSelectionScreen({super.key});

  @override
  State<SpecializationSelectionScreen> createState() =>
      _SpecializationSelectionScreenState();
}

class _SpecializationSelectionScreenState
    extends State<SpecializationSelectionScreen> {
  String selectedSpec = "";

  final List<Map<String, dynamic>> specializations = [
    {
      "id": "mech",
      "name": "Engine Mechanic",
      "icon": Icons.settings_suggest_outlined,
      "desc": "Routine maintenance, oil changes, overhaul",
    },
    {
      "id": "elec",
      "name": "Electrical Expert",
      "icon": Icons.electric_bolt_rounded,
      "desc": "Diagnostics, sensors, wiring, software",
    },
    {
      "id": "tire",
      "name": "Tire & Suspension Specialist",
      "icon": Icons.tire_repair_rounded,
      "desc": "Balancing, alignment, shocks",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
     
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('lib/images/technician.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(color: Colors.black.withOpacity(0.6)),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 50),
                  const Text(
                    "WELCOME BACK,",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: Colors.white70,
                      letterSpacing: 2,
                    ),
                  ),
                  const Text(
                    "Select your\nSpecialization",
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),

                  const SizedBox(height: 40),

                  Expanded(
                    child: ListView.builder(
                      itemCount: specializations.length,
                      itemBuilder: (context, index) {
                        var spec = specializations[index];
                        bool isSelected = selectedSpec == spec['id'];

                        return GestureDetector(
                          onTap: () =>
                              setState(() => selectedSpec = spec['id']!),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.only(bottom: 20),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                          
                              color: isSelected
                                  ? Colors.transparent
                                  : Colors.white.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(20),
                          
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFFE55757)
                                    : Colors.white12,
                                width: 2,
                              ),
                          
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: const Color(
                                          0xFFE55757,
                                        ).withOpacity(0.3),
                                        blurRadius: 15,
                                        spreadRadius: 1,
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Row(
                              children: [
                             
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(
                                            0xFFE55757,
                                          ).withOpacity(0.2)
                                        : Colors.black26,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    spec['icon'],
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        spec['name'],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        spec['desc'],
                                        style: TextStyle(
                                          color: Colors.white60,
                                          fontSize: 13,
                                          height: 1.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            
                                Container(
                                  height: 24,
                                  width: 24,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected
                                        ? const Color(0xFFE55757)
                                        : Colors.transparent,
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color(0xFFE55757)
                                          : Colors.white30,
                                      width: 2,
                                    ),
                                  ),
                                  child: isSelected
                                      ? const Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 16,
                                        )
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

          
                  Padding(
                    padding: const EdgeInsets.only(bottom: 30),
                    child: SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: selectedSpec.isEmpty
                            ? null
                            : () => Get.offAll(() => TechnicianBottombar()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE55757),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 0,
                          disabledBackgroundColor: Colors.white10,
                        ),
                        child: const Text(
                          "CONTINUE",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
