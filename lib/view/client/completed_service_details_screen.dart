import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:senior_project/model/completed_service_model.dart';

class CompletedServiceDetailsScreen extends StatelessWidget {
  final CompletedServiceModel service;

  const CompletedServiceDetailsScreen({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    const Color scaffoldBg = Color(0xFFF4F7FA);
    final mediaQuery = MediaQuery.of(context);
    final double screenWidth = mediaQuery.size.width;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: scaffoldBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "تقرير الخدمة",
          style: TextStyle(
            color: const Color(0xFF1A1A1A),
            fontWeight: FontWeight.w900,
            fontSize: screenWidth * 0.045,
          ),
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              _buildVehicleHero(screenWidth),
              const SizedBox(height: 25),
              _buildSectionTitle("معلومات عامة", screenWidth),
              _buildInfoGrid(screenWidth),
              const SizedBox(height: 25),
              _buildSectionTitle("الجدول الزمني للخدمة", screenWidth),
              _buildTimelineCard(screenWidth),
              const SizedBox(height: 25),
              if (service.isRated || service.isComplained) ...[
                _buildSectionTitle("الآراء والدعم", screenWidth),
                _buildFeedbackCard(screenWidth),
                const SizedBox(height: 25),
              ],
              _buildSectionTitle("المهام الفنية", screenWidth),
              ...service.billItems
                  .map((item) => _buildMaintenanceTaskCard(item, screenWidth))
                  .toList(),
              const SizedBox(height: 25),
              _buildSectionTitle("ملخص الفاتورة", screenWidth),
              _buildDetailedInvoice(screenWidth),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, double screenWidth) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, right: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: screenWidth * 0.038,
          fontWeight: FontWeight.w900,
          color: const Color(0xFF2D3748),
        ),
      ),
    );
  }

  Widget _buildVehicleHero(double screenWidth) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(screenWidth * 0.06),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1A1A), Color(0xFF333333)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.directions_car_filled,
            color: Colors.white,
            size: 40,
          ),
          const SizedBox(height: 12),
          Text(
            "${service.brand} ${service.model}",
            style: TextStyle(
              color: Colors.white,
              fontSize: screenWidth * 0.055,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "رقم اللوحة: ${service.platenumber}",
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 10,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              service.status == "completed" ? "مكتمل" : service.status.toUpperCase(),
              style: const TextStyle(
                color: Color(0xFF4CAF50),
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoGrid(double screenWidth) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.05),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          _buildInfoItem(
            Icons.settings_suggest,
            "الفئة",
            service.problemType.replaceAll('_', ' '),
            screenWidth,
          ),
          Container(width: 1, height: 40, color: Colors.grey[200]),
          _buildInfoItem(
            Icons.calendar_today,
            "سنة الصنع",
            service.year,
            screenWidth,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value, double screenWidth) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 18, color: const Color(0xFFE55757)),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
          Text(
            value.toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: screenWidth * 0.03),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineCard(double screenWidth) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.06),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          _buildTimelineRow(
            Icons.radio_button_checked,
            "تم استلام الطلب",
            service.receivedAt ?? "غير متوفر",
            isLast: false,
            screenWidth: screenWidth,
          ),
          _buildTimelineRow(
            Icons.check_circle_rounded,
            "اكتملت الصيانة",
            service.completedAt,
            isLast: false,
            screenWidth: screenWidth,
          ),
          _buildTimelineRow(
            Icons.account_balance_wallet,
            "تم تأكيد الدفع",
            service.paidAt ?? "غير متوفر",
            isLast: true,
            screenWidth: screenWidth,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineRow(
    IconData icon,
    String label,
    String time, {
    required bool isLast,
    required double screenWidth,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Icon(icon, size: 18, color: const Color(0xFFE55757)),
            if (!isLast)
              Container(
                width: 2,
                height: 30,
                color: const Color(0xFFE55757).withOpacity(0.2),
              ),
          ],
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: screenWidth * 0.032,
                ),
              ),
              Text(
                time,
                style: const TextStyle(color: Colors.grey, fontSize: 11),
              ),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeedbackCard(double screenWidth) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(screenWidth * 0.05),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (service.isRated) ...[
            Row(
              children: [
                Row(
                  children: List.generate(
                    5,
                    (i) => Icon(
                      Icons.star_rounded,
                      color: i < (service.score) ? Colors.amber : Colors.grey[200],
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "(${service.score})",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "\"${service.ratingComment ?? 'لا يوجد تعليق مضاف'}\"",
              style: const TextStyle(
                color: Color(0xFF4A5568),
                fontSize: 13,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          if (service.isRated && service.isComplained) const Divider(height: 30),
          if (service.isComplained) ...[
            Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: Colors.redAccent,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  "ملاحظة الشكوى",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth * 0.032,
                    color: Colors.redAccent,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    "قيد الانتظار",
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      color: Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              service.complaintDescription ?? "لا يوجد وصف متاح.",
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMaintenanceTaskCard(dynamic item, double screenWidth) {
    List spareParts = item['spare_parts'] ?? [];
    List laborServices = item['labor_services'] ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: EdgeInsets.all(screenWidth * 0.05),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item['fault_name'] ?? "مهمة إصلاح",
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: screenWidth * 0.038,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
              ),
              Text(
                "\$${_formatPrice(item['cost'])}",
                style: TextStyle(
                  color: const Color(0xFFE55757),
                  fontWeight: FontWeight.w900,
                  fontSize: screenWidth * 0.038,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (spareParts.isNotEmpty) ...[
            const Text(
              "قطع الغيار",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: Colors.blueGrey,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            ...spareParts
                .map(
                  (part) => _buildDetailItemRow(
                    part['name'],
                    part['total_price'],
                    part['quantity'],
                  ),
                )
                .toList(),
            const SizedBox(height: 15),
          ],
          if (laborServices.isNotEmpty) ...[
            const Text(
              "أجور العمالة",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: Colors.blueGrey,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            ...laborServices
                .map(
                  (labor) => _buildDetailItemRow(
                    labor['name'],
                    labor['total_price'],
                    null,
                  ),
                )
                .toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailItemRow(String name, dynamic price, dynamic qty) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            qty != null ? "• $name (عدد $qty)" : "• $name",
            style: const TextStyle(fontSize: 12, color: Color(0xFF718096)),
          ),
          Text(
            "\$${_formatPrice(price)}",
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedInvoice(double screenWidth) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.06),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInvoiceRow(
            "المجموع الفرعي",
            "\$${_formatPrice(service.subtotal)}",
            Colors.white.withOpacity(0.6),
            screenWidth,
          ),
          const SizedBox(height: 10),
          if (double.tryParse(service.immediatePremium.toString()) != 0) ...[
            _buildInvoiceRow(
              "رسوم الخدمة الفورية",
              "+\$${_formatPrice(service.immediatePremium)}",
              Colors.orangeAccent,
              screenWidth,
            ),
            const SizedBox(height: 10),
          ],
          _buildInvoiceRow(
            "${service.subscription == "Free" ? "اشتراك مجاني" : service.subscription} (${_formatPrice(service.discountPercentage)}%)",
            "-\$${_formatPrice(service.discountAmount)}",
            const Color(0xFF4CAF50),
            screenWidth,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Divider(color: Colors.white12, thickness: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "إجمالي المدفوع",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: screenWidth * 0.04,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "\$${_formatPrice(service.finalCost)}",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: screenWidth * 0.065,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceRow(String label, String value, Color color, double screenWidth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: color, fontSize: screenWidth * 0.032)),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: screenWidth * 0.032,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  String _formatPrice(dynamic price) {
    if (price == null) return "0";

    double? val = double.tryParse(price.toString());
    if (val == null) return price.toString();

    return val.toStringAsFixed(2).replaceFirst(RegExp(r'\.00$'), '');
  }
}