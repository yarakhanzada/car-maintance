import 'dart:ui';
import 'package:flutter/material.dart';

class FAQScreen extends StatelessWidget {
  const FAQScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    final List<Map<String, String>> faqs = [
      {
        "q": "كم من الوقت تستغرق رافعة السحب؟",
        "a": "عادة ما تستغرق بين 15 إلى 30 دقيقة بناءً على موقعك وظروف حركة المرور. يمكنك تتبع السائق مباشرة على الخريطة.",
      },
      {
        "q": "كيف يمكنني الدفع مقابل الخدمات؟",
        "a": "نحن ندعم طرق دفع متعددة بما في ذلك البطاقات الائتمانية، Apple Pay، و Google Pay. الدفع نقداً للسائق متاح أيضاً في معظم المناطق.",
      },
      {
        "q": "هل يمكنني إلغاء طلبي؟",
        "a": "نعم، يمكنك الإلغاء مجاناً خلال أول 5 دقائق. بعد ذلك، قد يتم تطبيق رسوم إلغاء صغيرة لتعويض السائق.",
      },
      {
        "q": "هل الخدمة متاحة على مدار الساعة 24/7؟",
        "a": "بالتأكيد! يعمل كراجي على مدار 24 ساعة في اليوم، 7 أيام في الأسبوع، بما في ذلك العطلات لضمان عدم بقائك عالقاً أبداً.",
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: Stack(
        children: [
          _buildTopGradient(width, height),
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildModernHeader(width, context),
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      return _buildFAQCard(faqs[index], context, width);
                    }, childCount: faqs.length),
                  ),
                ),
                _buildContactSupportCard(width),
                SliverToBoxAdapter(child: SizedBox(height: height * 0.03)),
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
              "الأسئلة",
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const Text(
              "الشائعة",
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w300,
                color: Color(0xFFE55757),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQCard(Map<String, String> faq, BuildContext context, double width) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 15,
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: const Color(0xFFE55757),
          collapsedIconColor: Colors.grey[400],
          title: Text(
            faq["q"]!,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Color(0xFF1A1A1A),
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Text(
                faq["a"]!,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                  height: 1.5,
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
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          children: [
            const Text(
              "هل لا تزال بحاجة إلى مساعدة؟",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "فريق الدعم المخصص لدينا هنا لمساعدتك على مدار الساعة 24/7 في أي مشكلة تواجهك.",
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
                minimumSize: Size(width, 55),
                elevation: 0,
              ),
              child: const Text(
                "الاتصال بالدعم",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopGradient(double width, double height) {
    return Positioned(
      top: -height * 0.15,
      left: -width * 0.25,
      child: Container(
        width: width * 0.9,
        height: width * 0.9,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFE55757).withOpacity(0.06),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
          child: const SizedBox(),
        ),
      ),
    );
  }
}