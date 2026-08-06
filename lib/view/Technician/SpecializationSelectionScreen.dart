import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:senior_project/view/Technician/TechnicianBottombar.dart';

class SpecializationSelectionScreen extends StatefulWidget {
  const SpecializationSelectionScreen({super.key});

  @override
  State<SpecializationSelectionScreen> createState() => _SpecializationSelectionScreenState();
}

class _SpecializationSelectionScreenState extends State<SpecializationSelectionScreen> {
  String selectedSpec = "";

  final List<Map<String, dynamic>> specializations = [
    {
      "id": "mech",
      "name": "ميكانيك محركات",
      "icon": Icons.settings_suggest_outlined,
      "desc": "صيانة دورية، تغيير زيوت، توضيب",
    },
    {
      "id": "elec",
      "name": "خبير كهرباء",
      "icon": Icons.electric_bolt_rounded,
      "desc": "تشخيص، حساسات، تمديدات، برمجة",
    },
    {
      "id": "tire",
      "name": "تخصص إطارات ونظام تعليق",
      "icon": Icons.tire_repair_rounded,
      "desc": "موازنة، محاذاة، مساعدات",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(color: Color(0xFFF5F7FA)),
              child: SafeArea(
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(30),
                      child: Text("اختر تخصصك", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: specializations.length,
                        itemBuilder: (context, index) {
                          final spec = specializations[index];
                          bool isSelected = selectedSpec == spec["id"];
                          return GestureDetector(
                            onTap: () => setState(() => selectedSpec = spec["id"]),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFFE55757) : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  Icon(spec["icon"], color: isSelected ? Colors.white : const Color(0xFFE55757), size: 30),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(spec["name"], style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                                        Text(spec["desc"], style: TextStyle(color: isSelected ? Colors.white70 : Colors.grey, fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(30),
                      child: SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: selectedSpec.isEmpty ? null : () => Get.offAll(() => TechnicianBottombar()),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE55757),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                          child: const Text("متابعة", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}