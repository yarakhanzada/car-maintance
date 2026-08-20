import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:senior_project/controller/client%20controller/completed_services_controller.dart';
import 'package:senior_project/model/completed_service_model.dart';
import 'package:senior_project/view/client/completed_service_details_screen.dart';

class CompletedServicesScreen extends StatefulWidget {
  const CompletedServicesScreen({super.key});

  @override
  State<CompletedServicesScreen> createState() =>
      _CompletedServicesScreenState();
}

class _CompletedServicesScreenState extends State<CompletedServicesScreen> {
  final CompletedServicesController _controller = Get.put(
    CompletedServicesController(),
  );

  String _formatPrice(dynamic price) {
    if (price == null || price.toString() == 'null') return "0";
    double? val = double.tryParse(price.toString());
    if (val == null) return "0";
    if (val == val.toInt()) return val.toInt().toString();
    return val.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final double screenWidth = mediaQuery.size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F9),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Stack(
          children: [
            _buildBackgroundGradient(screenWidth),
            SafeArea(
              child: RefreshIndicator(
                onRefresh: _controller.fetchCompletedServices,
                color: const Color(0xFFE55757),
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  slivers: [
                    _buildHeaderSliver(screenWidth),
                    _buildBodySliver(screenWidth),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSliver(double screenWidth) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          screenWidth * 0.06,
          30,
          screenWidth * 0.06,
          10,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "الخدمات المكتملة",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1A1A1A),
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "تتبع سجلات صيانة سيارتك المكتملة",
              style: TextStyle(color: Colors.grey[500], fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBodySliver(double screenWidth) {
    return Obx(() {
      if (_controller.isLoading.value && _controller.services.isEmpty) {
        return const SliverToBoxAdapter(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(60.0),
              child: CircularProgressIndicator(
                color: Color(0xFFE55757),
                strokeWidth: 2.5,
              ),
            ),
          ),
        );
      }

      if (_controller.services.isEmpty) {
        return SliverFillRemaining(
          hasScrollBody: false,
          child: _buildEmptyState(screenWidth),
        );
      }

      return SliverPadding(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.045,
          vertical: 8,
        ),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) =>
                _buildServiceCard(_controller.services[index], screenWidth),
            childCount: _controller.services.length,
          ),
        ),
      );
    });
  }

  Widget _buildServiceCard(CompletedServiceModel service, double screenWidth) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CompletedServiceDetailsScreen(service: service),
        ),
      ).then((_) => _controller.fetchCompletedServices()),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: const Border(
            right: BorderSide(color: Color(0xFF4CAF50), width: 5),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: const Color(0xFFE55757).withOpacity(0.08),
                    child: const Icon(
                      Icons.check_circle_outline,
                      color: Color(0xFFE55757),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service.problemType.toUpperCase().replaceAll(
                            '_',
                            ' ',
                          ),
                          style: TextStyle(
                            fontSize: screenWidth * 0.032,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1A1A1A),
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "${service.brand} ${service.model}",
                          style: const TextStyle(
                            color: Color(0xFF888888),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "${_formatPrice(service.finalCost)} \$",
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: screenWidth * 0.04,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(
                  height: 1,
                  thickness: 0.4,
                  color: Color(0xFFEEEEEE),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 12,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        service.completedAt.split('T')[0],
                        style: const TextStyle(
                          color: Color(0xFF666666),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      if (service.isComplained)
                        _buildStatusBadge(
                          Icons.report_gmailerrorred_rounded,
                          "تم الإبلاغ",
                          Colors.red[400]!,
                          screenWidth,
                        )
                      else
                        _buildSmallActionBtn(
                          icon: Icons.report_problem_outlined,
                          label: "إبلاغ",
                          color: const Color(0xFFE55757),
                          onTap: () =>
                              _showComplaintSheet(service.id, screenWidth),
                          screenWidth: screenWidth,
                        ),
                      const SizedBox(width: 6),
                      if (service.isRated)
                        _buildStatusBadge(
                          Icons.star_rounded,
                          _formatPrice(service.score),
                          Colors.amber[700]!,
                          screenWidth,
                        )
                      else
                        _buildSmallActionBtn(
                          icon: Icons.star_rounded,
                          label: "تقييم",
                          color: Colors.amber[700]!,
                          onTap: () => _showRatingSheet(
                            service.id,
                            service.problemType,
                            screenWidth,
                          ),
                          screenWidth: screenWidth,
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(
    IconData icon,
    String label,
    Color color,
    double screenWidth,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: screenWidth * 0.025,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallActionBtn({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required double screenWidth,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: screenWidth * 0.025,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showComplaintSheet(int requestId, double screenWidth) {
    final TextEditingController complaintController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          padding: EdgeInsets.fromLTRB(
            20,
            12,
            20,
            MediaQuery.of(context).viewInsets.bottom + 25,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 35,
                height: 3.5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "تقديم شكوى",
                style: TextStyle(
                  fontSize: screenWidth * 0.05,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: complaintController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "ما المشكلة التي واجهتها？",
                  filled: true,
                  fillColor: const Color(0xFFF7F7F7),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE55757),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () async {
                    if (complaintController.text.isEmpty) return;
                    var result = await _controller.submitComplaint(
                      requestId: requestId,
                      complaintText: complaintController.text,
                    );
                    if (mounted) {
                      Navigator.pop(context);
                      _showSnackBar(
                        result['message'] ?? "خطأ في إرسال الشكوى",
                        result['success'] ?? false,
                        screenWidth,
                      );
                      if (result['success'] == true) {
                        _controller.fetchCompletedServices();
                      }
                    }
                  },
                  child: Text(
                    'إرسال',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: screenWidth * 0.04,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRatingSheet(int requestId, String title, double screenWidth) {
    double tempRating = 0;
    final TextEditingController commentController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            padding: EdgeInsets.fromLTRB(
              25,
              12,
              25,
              MediaQuery.of(context).viewInsets.bottom + 25,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 35,
                  height: 3.5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "تقييم الخدمة",
                  style: TextStyle(
                    fontSize: screenWidth * 0.05,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  title.replaceAll('_', ' '),
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: screenWidth * 0.032,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    5,
                    (index) => IconButton(
                      onPressed: () =>
                          setModalState(() => tempRating = index + 1.0),
                      icon: Icon(
                        index < tempRating
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        color: index < tempRating
                            ? Colors.amber
                            : Colors.grey[300],
                        size: 40,
                      ),
                    ),
                  ),
                ),
                TextField(
                  controller: commentController,
                  decoration: InputDecoration(
                    hintText: "أكتب تعليقك هنا...",
                    filled: true,
                    fillColor: const Color(0xFFF7F7F7),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A1A1A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: () async {
                      if (tempRating == 0) return;

                      var result = await _controller.submitRating(
                        requestId: requestId,
                        rating: tempRating,
                        comment: commentController.text,
                      );

                      if (mounted) {
                        Navigator.pop(context);
                        String message = result['message'] ?? "حدث خطأ ما";
                        bool isSuccess = result['success'] ?? false;

                        _showSnackBar(message, isSuccess, screenWidth);

                        if (isSuccess) {
                          _controller.fetchCompletedServices();
                        }
                      }
                    },
                    child: Text(
                      'إرسال',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: screenWidth * 0.04,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSnackBar(String msg, bool success, double screenWidth) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: TextStyle(fontSize: screenWidth * 0.035)),
        backgroundColor: success ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildEmptyState(double screenWidth) {
    return Center(
      child: Text(
        "لا توجد خدمات مكتملة حتى الآن.",
        style: TextStyle(color: Colors.grey, fontSize: screenWidth * 0.038),
      ),
    );
  }

  Widget _buildBackgroundGradient(double screenWidth) {
    return Positioned(
      top: -60,
      right: -60,
      child: Container(
        width: screenWidth * 0.55,
        height: screenWidth * 0.55,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFE55757).withOpacity(0.04),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 35, sigmaY: 35),
          child: Container(color: Colors.transparent),
        ),
      ),
    );
  }
}
