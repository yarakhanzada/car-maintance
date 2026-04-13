import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; // تأكدي من استيراد الباقة
import 'package:latlong2/latlong.dart'; // ضروري للإحداثيات
import 'package:get/get.dart';

class DriverMapScreen extends StatefulWidget {
  const DriverMapScreen({super.key});

  @override
  State<DriverMapScreen> createState() => _DriverMapScreenState();
}

class _DriverMapScreenState extends State<DriverMapScreen> {

  final List<Map<String, dynamic>> taskStatuses = [
    {"title": "في الطريق", "icon": Icons.directions_car},
    {"title": "تم الوصول", "icon": Icons.location_on},
    {"title": "جاري سحب المركبة", "icon": Icons.car_repair},
    {"title": "اكتملت المهمة", "icon": Icons.check_circle},
  ];

  int currentStatusIndex = 0;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
       
          FlutterMap(
            options: MapOptions(
              initialCenter: LatLng(33.5104, 36.2783), 
              initialZoom: 15.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.senior_project.app',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: LatLng(33.5104, 36.2783),
                    width: 50,
                    height: 50,
                    child: Icon(Icons.location_on, color: Colors.red, size: 40),
                  ),
                ],
              ),
            ],
          ),

     
          Positioned(
            top: 50,
            left: 20,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Get.back(),
              ),
            ),
          ),

        
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildBottomPanel(width),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomPanel(double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
       
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.red.shade50,
                child: const Icon(Icons.person, color: Colors.red),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "سامر علي",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      "هيونداي النترا - المزة",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.phone, color: Colors.green),
              ),
            ],
          ),
          const Divider(height: 30),

         
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _infoItem(Icons.route, "2.4 كم", "المسافة"),
              _infoItem(Icons.access_time, "12 دقيقة", "الزمن"),
            ],
          ),
          const SizedBox(height: 20),

        
          _buildStatusStepper(),

          const SizedBox(height: 20),

    
          _buildMainActionBtn(width),
        ],
      ),
    );
  }

  Widget _infoItem(IconData icon, String val, String label) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.red),
            const SizedBox(width: 5),
            Text(val, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
      ],
    );
  }

  Widget _buildStatusStepper() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(taskStatuses.length, (index) {
        bool isCurrent = index == currentStatusIndex;
        bool isDone = index < currentStatusIndex;
        return Column(
          children: [
            Icon(
              taskStatuses[index]['icon'],
              color: isCurrent
                  ? Colors.red
                  : (isDone ? Colors.green : Colors.grey.shade300),
              size: 20,
            ),
            Text(
              taskStatuses[index]['title'],
              style: TextStyle(
                fontSize: 8,
                color: isCurrent ? Colors.black : Colors.grey,
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildMainActionBtn(double width) {
    bool isLast = currentStatusIndex == taskStatuses.length - 1;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isLast ? Colors.green : const Color(0xFFE55757),
        minimumSize: Size(width, 55),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      onPressed: () {
        if (currentStatusIndex < taskStatuses.length - 1) {
          setState(() => currentStatusIndex++);
        } else {
          Get.back();
          Get.snackbar("نجاح", "تمت المهمة بنجاح");
        }
      },
      child: Text(
        isLast
            ? "إنهاء المهمة"
            : "تحديث إلى: ${taskStatuses[currentStatusIndex + 1]['title']}",
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
