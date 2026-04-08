import 'dart:ui';
import 'package:flutter/material.dart';

class FAQScreen extends StatelessWidget {
  const FAQScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    final List<Map<String, String>> faqs = [
      {
        "q": "How long does the tow truck take?",
        "a":
            "Usually between 15 to 30 minutes depending on your location and traffic conditions. You can track the driver live on the map.",
      },
      {
        "q": "How can I pay for services?",
        "a":
            "We support multiple payment methods including Credit Cards, Apple Pay, and Google Pay. Cash to driver is also available in most areas.",
      },
      {
        "q": "Can I cancel my request?",
        "a":
            "Yes, you can cancel for free within the first 5 minutes. After that, a small cancellation fee may apply to compensate the driver.",
      },
      {
        "q": "Is the service available 24/7?",
        "a":
            "Absolutely! My Garage operates 24 hours a day, 7 days a week, including holidays to ensure you're never stuck.",
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: Stack(
        children: [
          _buildTopGradient(),
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildModernHeader(width, context),

                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      return _buildFAQCard(faqs[index], context);
                    }, childCount: faqs.length),
                  ),
                ),

                _buildContactSupportCard(width),
                const SliverToBoxAdapter(child: SizedBox(height: 30)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernHeader(double width, BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(width * 0.05, 10, width * 0.05, 30),
        child: Column(
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
              "Common",
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1A1A1A),
                letterSpacing: -1.5,
                height: 1,
              ),
            ),
            const Text(
              "Questions",
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w300,
                color: Color(0xFFE55757),
                letterSpacing: -1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQCard(Map<String, String> faq, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: const Color(0xFFE55757),
          collapsedIconColor: Colors.grey[400],
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          title: Text(
            faq['q']!,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: Color(0xFF1A1A1A),
            ),
          ),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F7),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                faq['a']!,
                style: TextStyle(
                  color: Colors.grey[700],
                  height: 1.6,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactSupportCard(double width) {
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: width * 0.05, vertical: 20),
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1A1A1A).withOpacity(0.2),
              blurRadius: 25,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          children: [
            const Icon(
              Icons.headset_mic_rounded,
              color: Color(0xFFE55757),
              size: 40,
            ),
            const SizedBox(height: 15),
            const Text(
              "Still have questions?",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Our dedicated support team is here to help you 24/7 with any issues.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 25),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE55757),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                minimumSize: const Size(double.infinity, 55),
                elevation: 0,
              ),
              child: const Text(
                "Contact Support",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopGradient() {
    return Positioned(
      top: -150,
      left: -100,
      child: Container(
        width: 400,
        height: 400,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFE55757).withOpacity(0.06),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
          child: Container(color: Colors.transparent),
        ),
      ),
    );
  }
}
