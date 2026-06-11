import 'dart:ui';
import 'package:flutter/material.dart';

class ComplaintsScreen extends StatefulWidget {
  const ComplaintsScreen({super.key});

  @override
  State<ComplaintsScreen> createState() => _ComplaintsScreenState();
}

class _ComplaintsScreenState extends State<ComplaintsScreen> {
  String selectedType = "تأخير";
  final List<String> issueTypes = [
    "السائق",
    "التسعير",
    "تأخير",
    "تقني",
    "آخر",
  ];

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: Stack(
        children: [
          _buildTopGradient(width, height),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: width * 0.06),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildHeader(context),
                  const SizedBox(height: 40),
                  _buildSectionTitle("ما الخطأ الذي حدث؟"),
                  const SizedBox(height: 15),
                  _buildIssueSelector(width),
                  const SizedBox(height: 35),
                  _buildSectionTitle("صف مشكلتك بالتفصيل"),
                  const SizedBox(height: 15),
                  _buildMessageInput(),
                  const SizedBox(height: 40),
                  _buildSubmitButton(width, context),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              size: 16,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ),
        const SizedBox(height: 30),
        const Text(
          "المساعدة و",
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1A1A1A),
            height: 1,
          ),
        ),
        const Text(
          "الدعم الفني",
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w300,
            color: Color(0xFFE55757),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1A1A1A),
      ),
    );
  }

  Widget _buildIssueSelector(double width) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: issueTypes.map((type) {
        final bool isSelected = selectedType == type;
        return ChoiceChip(
          label: Text(type),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) {
              setState(() {
                selectedType = type;
              });
            }
          },
          selectedColor: const Color(0xFFE55757),
          backgroundColor: Colors.white,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const TextField(
        maxLines: 5,
        decoration: InputDecoration(
          hintText: "يرجى كتابة تفاصيل المشكلة هنا...",
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildSubmitButton(double width, BuildContext context) {
    return Container(
      width: width,
      height: 55,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(24),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("تم استلام ملاحظاتك بنجاح!"),
              backgroundColor: Color(0xFF1A1A1A),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        child: const Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.send_rounded, color: Colors.white, size: 20),
              SizedBox(width: 12),
              Text(
                "إرسال الملاحظات",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopGradient(double width, double height) {
    return Positioned(
      top: -height * 0.1,
      right: -width * 0.2,
      child: Container(
        width: width * 0.7,
        height: width * 0.7,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFE55757).withOpacity(0.05),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: const SizedBox(),
        ),
      ),
    );
  }
}