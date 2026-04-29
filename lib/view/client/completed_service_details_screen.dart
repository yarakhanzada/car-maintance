import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:senior_project/model/completed_service_model.dart';

class CompletedServiceDetailsScreen extends StatelessWidget {
  final CompletedServiceModel service;

  const CompletedServiceDetailsScreen({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    const Color scaffoldBg = Color(0xFFF4F7FA);

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
  backgroundColor: scaffoldBg, 
  elevation: 0,             
  scrolledUnderElevation: 0,   
  surfaceTintColor: Colors.transparent,
  centerTitle: true,
  leading: IconButton(
    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
    onPressed: () => Navigator.pop(context),
  ),
  title: const Text(
    "Service Report",
    style: TextStyle(
      color: Color(0xFF1A1A1A),
      fontWeight: FontWeight.w900,
      fontSize: 18,
    ),
  ),
),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            _buildVehicleHero(),
            const SizedBox(height: 25),
            
            _buildSectionTitle("General Information"),
            _buildInfoGrid(),
            const SizedBox(height: 25),

            _buildSectionTitle("Service Timeline"),
            _buildTimelineCard(),
            const SizedBox(height: 25),

            if (service.isRated || service.isComplained) ...[
              _buildSectionTitle("Feedback & Support"),
              _buildFeedbackCard(),
              const SizedBox(height: 25),
            ],

            _buildSectionTitle("Technical Tasks"),
            ...service.billItems.map((item) => _buildMaintenanceTaskCard(item)).toList(),
            const SizedBox(height: 25),

            _buildSectionTitle("Billing Summary"),
            _buildDetailedInvoice(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(title, 
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF2D3748))),
    );
  }

  Widget _buildVehicleHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1A1A), Color(0xFF333333)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          const Icon(Icons.directions_car_filled, color: Colors.white, size: 40),
          const SizedBox(height: 12),
          Text("${service.brand} ${service.model}", 
            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text("CHASSIS: ${service.chassisNumber}", 
            style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10, letterSpacing: 1)),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(color: const Color(0xFF4CAF50).withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
            child: Text(service.status.toUpperCase(), style: const TextStyle(color: Color(0xFF4CAF50), fontSize: 10, fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoGrid() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: Row(
        children: [
          _buildInfoItem(Icons.settings_suggest, "Category", service.problemType.replaceAll('_', ' ')),
          Container(width: 1, height: 40, color: Colors.grey[200]),
          _buildInfoItem(Icons.calendar_today, "Model Year", service.year),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 18, color: const Color(0xFFE55757)),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
          Text(value.toUpperCase(), textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildTimelineCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: Column(
        children: [
          _buildTimelineRow(Icons.radio_button_checked, "Request Received", service.receivedAt ?? "N/A", isLast: false),
          _buildTimelineRow(Icons.check_circle_rounded, "Maintenance Done", service.completedAt, isLast: false),
          _buildTimelineRow(Icons.account_balance_wallet, "Payment Verified", service.paidAt ?? "N/A", isLast: true),
        ],
      ),
    );
  }

  Widget _buildTimelineRow(IconData icon, String label, String time, {required bool isLast}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Icon(icon, size: 18, color: const Color(0xFFE55757)),
            if (!isLast) Container(width: 2, height: 30, color: const Color(0xFFE55757).withOpacity(0.2)),
          ],
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              Text(time, style: const TextStyle(color: Colors.grey, fontSize: 11)),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeedbackCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (service.isRated) ...[
            Row(
              children: [
                Row(
                  children: List.generate(5, (i) => Icon(Icons.star_rounded, 
                    color: i < (service.score) ? Colors.amber : Colors.grey[200], size: 20)),
                ),
                const SizedBox(width: 8),
                Text("(${service.score})", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 8),
            Text("\"${service.ratingComment ?? 'No comment provided'}\"", 
              style: const TextStyle(color: Color(0xFF4A5568), fontSize: 13, fontStyle: FontStyle.italic)),
          ],
          if (service.isRated && service.isComplained) const Divider(height: 30),
          if (service.isComplained) ...[
            Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.redAccent, size: 18),
                const SizedBox(width: 8),
                const Text("Complaint Note", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.redAccent)),
                const Spacer(),
                Container(
                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                   decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                   child: const Text("PENDING", style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.orange)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(service.complaintDescription ?? "No description available.", style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ],
      ),
    );
  }

  Widget _buildMaintenanceTaskCard(dynamic item) {
    List spareParts = item['spare_parts'] ?? [];
    List laborServices = item['labor_services'] ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(item['fault_name'] ?? "Repair Task", 
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF1A1A1A)))),
              Text("\$${_formatPrice(item['cost'])}", 
                style: const TextStyle(color: Color(0xFFE55757), fontWeight: FontWeight.w900, fontSize: 15)),
            ],
          ),
          const SizedBox(height: 12),
          if (spareParts.isNotEmpty) ...[
            const Text("SPARE PARTS", style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.blueGrey, letterSpacing: 1)),
            const SizedBox(height: 8),
            ...spareParts.map((part) => _buildDetailItemRow(part['name'], part['total_price'], part['quantity'])).toList(),
            const SizedBox(height: 15),
          ],
          if (laborServices.isNotEmpty) ...[
            const Text("LABOR SERVICES", style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.blueGrey, letterSpacing: 1)),
            const SizedBox(height: 8),
            ...laborServices.map((labor) => _buildDetailItemRow(labor['name'], labor['total_price'], null)).toList(),
          ]
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
          Text(qty != null ? "• $name (x$qty)" : "• $name", style: const TextStyle(fontSize: 12, color: Color(0xFF718096))),
          Text("\$${_formatPrice(price)}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
Widget _buildDetailedInvoice() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        children: [
          _buildInvoiceRow("Subtotal", "\$${_formatPrice(service.subtotal)}", Colors.white.withOpacity(0.6)),
          const SizedBox(height: 10),
          
          if (double.tryParse(service.immediatePremium.toString()) != 0) ...[
            _buildInvoiceRow("Immediate Premium", "+\$${_formatPrice(service.immediatePremium)}", Colors.orangeAccent),
            const SizedBox(height: 10),
          ],

          _buildInvoiceRow(
            "${service.subscription} (${_formatPrice(service.discountPercentage)}%)", 
            "-\$${_formatPrice(service.discountAmount)}", 
            const Color(0xFF4CAF50)
          ),
          
          const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Divider(color: Colors.white12, thickness: 1)),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total Paid", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              Text(
                "\$${_formatPrice(service.finalCost)}", 
                style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900)
              ),
            ],
          ),
        ],
      ),
    );
  }
  Widget _buildInvoiceRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: color, fontSize: 13)),
        Text(value, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold)),
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