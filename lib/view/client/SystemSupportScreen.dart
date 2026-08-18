import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geocoding/geocoding.dart';

class SystemSupportScreen extends StatefulWidget {
  const SystemSupportScreen({super.key});

  @override
  State<SystemSupportScreen> createState() => _SystemSupportScreenState();
}

class _SystemSupportScreenState extends State<SystemSupportScreen> {
  String _currentAddress = "جاري تحديد الموقع...";

  @override
  void initState() {
    super.initState();
    _getAddress();
  }

  Future<void> _getAddress() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        33.5138,
        36.2765,
      );
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _currentAddress =
              "${place.subLocality ?? ''}، ${place.locality ?? ''}".trim();
        });
      }
    } catch (e) {
      setState(() {
        _currentAddress = "دمشق - المزة";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F7),
        body: Stack(
          children: [
            // Gradient background effect in the top-right corner
            const SupportBackground(),

            SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: width * 0.06),
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    _buildHeader(),
                    const SizedBox(height: 40),

                    _buildSectionTitle("معلومات عن النظام"),
                    const SizedBox(height: 15),
                    _buildInfoCard(
                      "اسم التطبيق",
                      "CarTiak",
                      Icons.apps_rounded,
                    ),
                    _buildInfoCard("الإصدار", "1.0.4", Icons.update_rounded),
                    _buildInfoCard(
                      "الهدف من النظام",
                      "تسهيل عمليات إدارة الحجوزات، صيانة المركبات، وربط العملاء بالورش الفنية.",
                      Icons.info_outline_rounded,
                    ),

                    const SizedBox(height: 40),

                    _buildSectionTitle("تواصل مع الدعم الفني"),
                    const SizedBox(height: 15),
                    _buildInfoCard(
                      "رقم الاتصال",
                      "0935573658",
                      Icons.call_rounded,
                      onTap: _launchPhoneCall,
                    ),
                    _buildInfoCard(
                      "البريد الإلكتروني",
                      "yarakhanzada@gmail.com",
                      Icons.email_outlined,
                      onTap: _launchEmail,
                    ),

                    const SizedBox(height: 20),
                    _buildLocationCard(),

                    const SizedBox(height: 40),
                    const Text(
                      "فريق الدعم الفني جاهز لمساعدتك في أي وقت، لا تتردد في التواصل معنا.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Embedded background class
  Widget _buildHeader() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Get.back(),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20,
              color: Color(0xFFE55757),
            ),
          ),
        ),
        const SizedBox(width: 20),
        const Text(
          "مركز الدعم",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Color(0xFF2D2D2D),
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFFE55757),
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(child: Divider(thickness: 0.5)),
      ],
    );
  }

  Widget _buildInfoCard(
    String title,
    String value,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    final card = Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFFE55757), size: 22),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          if (onTap != null)
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Colors.grey,
            ),
        ],
      ),
    );
    return onTap == null ? card : GestureDetector(onTap: onTap, child: card);
  }

  Widget _buildLocationCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(
                Icons.location_on_rounded,
                color: Color(0xFFE55757),
                size: 22,
              ),
              SizedBox(width: 10),
              Text(
                "مقر الورشة الرئيسي",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "تفضل بزيارتنا في مركز الصيانة المعتمد لتقديم كافة خدمات الإصلاح والفحص لمركبتك.",
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.map, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                _currentAddress,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _openWorkshopLocation,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFE55757),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(
                child: Text(
                  "توجّه إلى الموقع عبر الخرائط",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper functions
  Future<void> _launchPhoneCall() async {
    final Uri uri = Uri(scheme: 'tel', path: '+963935573658');
    await launchUrl(uri);
  }

  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(scheme: 'mailto', path: 'yarakhanzada@gmail.com');
    await launchUrl(emailUri);
  }

  Future<void> _openWorkshopLocation() async {
    final Uri uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=33.5138,36.2765',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class SupportBackground extends StatelessWidget {
  const SupportBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: -50,
      right: -50,
      child: Container(
        width: 250,
        height: 250,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFE55757).withOpacity(0.06),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
          child: Container(color: Colors.transparent),
        ),
      ),
    );
  }
}
