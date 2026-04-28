import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:senior_project/controller/completed_services_controller.dart';
import 'package:senior_project/model/completed_service_model.dart';
import 'package:senior_project/view/client/completed_service_details_screen.dart';

class CompletedServicesScreen extends StatefulWidget {
  const CompletedServicesScreen({super.key});

  @override
  State<CompletedServicesScreen> createState() => _CompletedServicesScreenState();
}

class _CompletedServicesScreenState extends State<CompletedServicesScreen> {
  final CompletedServicesController _controller = CompletedServicesController();
  late Future<List<CompletedServiceModel>> _futureServices;

  @override
  void initState() {
    super.initState();
    _futureServices = _controller.fetchCompletedServices();
  }

  void _refreshData() {
    setState(() {
      _futureServices = _controller.fetchCompletedServices();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F9),
      body: Stack(
        children: [
          _buildBackgroundGradient(),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                Expanded(
                  child: FutureBuilder<List<CompletedServiceModel>>(
                    future: _futureServices,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: Color(0xFFE55757), strokeWidth: 2.5));
                      } else if (snapshot.hasError) {
                        return Center(child: Text("Error: ${snapshot.error}"));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return _buildEmptyState();
                      }

                      return RefreshIndicator(
                        onRefresh: () async => _refreshData(),
                        color: const Color(0xFFE55757),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                          physics: const BouncingScrollPhysics(),
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) => _buildServiceCard(snapshot.data![index]),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 25, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Completed Services",
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF1A1A1A), letterSpacing: -0.8),
          ),
          SizedBox(height: 3),
          Text(
            "Track your completed car maintenance logs",
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(CompletedServiceModel service) {
    double cost = double.tryParse(service.finalCost) ?? 0.0;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CompletedServiceDetailsScreen(service: service)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: const Border(left: BorderSide(color: Color(0xFF4CAF50), width: 5)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 8))],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: const Color(0xFFE55757).withOpacity(0.08),
                    child: const Icon(Icons.check_circle_outline, color: Color(0xFFE55757), size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service.problemType.toUpperCase().replaceAll('_', ' '),
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A), height: 1.2),
                        ),
                        const SizedBox(height: 2),
                        Text("${service.brand} ${service.model}", style: const TextStyle(color: Color(0xFF888888), fontSize: 11)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text("${cost.toStringAsFixed(0)} \$", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF1A1A1A))),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1, thickness: 0.4, color: Color(0xFFEEEEEE)),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 12, color: Colors.grey),
                      const SizedBox(width: 5),
                      Text(service.completedAt.split('T')[0], style: const TextStyle(color: Color(0xFF666666), fontSize: 11, fontWeight: FontWeight.w500)),
                    ],
                  ),
                  Row(
                    children: [
                      if (service.isComplained)
                        _buildStatusBadge(Icons.report_gmailerrorred_rounded, "Reported", Colors.red[400]!)
                      else
                        _buildSmallActionBtn(icon: Icons.report_problem_outlined, label: "Report", color: const Color(0xFFE55757), onTap: () => _showComplaintSheet(service.id)),
                      const SizedBox(width: 6),
                      if (service.isRated)
                        _buildStatusBadge(Icons.star_rounded, "${service.score}", Colors.amber[700]!)
                      else
                        _buildSmallActionBtn(icon: Icons.star_rounded, label: "Rate", color: Colors.amber[700]!, onTap: () => _showRatingSheet(service.id, service.problemType)),
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

  Widget _buildStatusBadge(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSmallActionBtn({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
        child: Row(
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  void _showComplaintSheet(int requestId) {
    final TextEditingController complaintController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).viewInsets.bottom + 25),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 35, height: 3.5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            const Text("File a Complaint", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 15),
            TextField(
              controller: complaintController,
              maxLines: 4,
              decoration: InputDecoration(hintText: "What went wrong?", filled: true, fillColor: const Color(0xFFF7F7F7), border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE55757), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), elevation: 0),
                onPressed: () async {
                  if (complaintController.text.isEmpty) return;
                  var result = await _controller.submitComplaint(requestId: requestId, complaintText: complaintController.text);
                  if (mounted) {
                    Navigator.pop(context);
                    _showSnackBar(result['message'], result['success']);
                    if (result['success']) _refreshData();
                  }
                },
                child: const Text("Submit", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRatingSheet(int requestId, String title) {
    double tempRating = 0;
    final TextEditingController commentController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.fromLTRB(25, 12, 25, MediaQuery.of(context).viewInsets.bottom + 25),
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(35))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 35, height: 3.5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 20),
              const Text("Rate Service", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
              Text(title.replaceAll('_', ' '), style: TextStyle(color: Colors.grey[500], fontSize: 13)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) => IconButton(
                  onPressed: () => setModalState(() => tempRating = index + 1.0),
                  icon: Icon(index < tempRating ? Icons.star_rounded : Icons.star_outline_rounded, color: index < tempRating ? Colors.amber : Colors.grey[300], size: 40),
                )),
              ),
              TextField(
                controller: commentController,
                decoration: InputDecoration(hintText: "Your comment...", filled: true, fillColor: const Color(0xFFF7F7F7), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A1A1A), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                  onPressed: () async {
                    if (tempRating == 0) return;
                    var result = await _controller.submitRating(requestId: requestId, rating: tempRating, comment: commentController.text);
                    if (mounted) {
                      Navigator.pop(context);
                      _showSnackBar(result['message'], result['success']);
                      if (result['success']) _refreshData();
                    }
                  },
                  child: const Text("Submit", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSnackBar(String msg, bool success) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: success ? Colors.green : Colors.red, behavior: SnackBarBehavior.floating));
  }

  Widget _buildEmptyState() {
    return const Center(child: Text("No completed services yet.", style: TextStyle(color: Colors.grey)));
  }

  Widget _buildBackgroundGradient() {
    return Positioned(
      top: -60, left: -60,
      child: Container(
        width: 220, height: 220,
        decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFFE55757).withOpacity(0.04)),
        child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 35, sigmaY: 35), child: Container(color: Colors.transparent)),
      ),
    );
  }
}