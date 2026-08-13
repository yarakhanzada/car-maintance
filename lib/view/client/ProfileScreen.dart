import 'dart:ui';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:senior_project/controller/client controller/SubscriptionController.dart';
import 'package:senior_project/controller/client controller/profile_controller.dart';
import 'package:senior_project/services/api_config.dart';
import 'package:senior_project/view/client/SystemSupportScreen.dart';
import '../../controller/logout_controller.dart';
import 'EditProfileScreen.dart';
import '../../widgets/logout_widget.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final ProfileController controller = Get.put(ProfileController());
  final LogoutController logoutController = Get.put(LogoutController());
  final SubscriptionController subscriptionController = Get.put(
    SubscriptionController(),
  );

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F7),
        body: Stack(
          children: [
            _buildBackgroundGradient(),
            Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              final user = controller.profile.value;
              if (user == null) {
                return const Center(child: Text("لا توجد بيانات"));
              }
              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(25, 70, 25, 20),
                      child: Column(
                        children: [
                          _buildProfileHeader(user),
                          const SizedBox(height: 40),
                          _buildSubscriptionCard(context, width),
                          const SizedBox(height: 20),

                          _buildBenefitsCard(),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _buildSectionTitle("إعدادات الحساب"),
                        _buildMenuTile(
                          icon: Icons.person_outline_rounded,
                          title: "تعديل الملف الشخصي",
                          subtitle: "حدث بياناتك الشخصية",
                          onTap: () async {
                            final result = await Get.to(
                              () => EditProfileScreen(),
                              arguments: user,
                            );
                            if (result == true) controller.getProfile();
                          },
                        ),
                        _buildMenuTile(
                          icon: Icons.history_rounded,
                          title: "نظام الدعم والمعلومات ",
                          subtitle: "تحقق من نظام الدعم والمعلومات  ",
                          onTap: () =>
                              Get.to(() => const SystemSupportScreen()),
                        ),
                        const SizedBox(height: 15),
                        _buildSectionTitle("إجراءات"),
                        _buildLogoutTile(),
                        const SizedBox(height: 80),
                      ]),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(user) {
    String initial = (user.name != null && user.name.isNotEmpty)
        ? user.name[0].toUpperCase()
        : "U";

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(2.5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFE55757), width: 1),
          ),
          child: CircleAvatar(
            radius: 32,
            backgroundColor: Colors.white,
            child: Text(
              initial,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE55757),
              ),
            ),
          ),
        ),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user.name ?? "",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFE55757).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                user.email ?? "",
                style: const TextStyle(
                  color: Color(0xFFE55757),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSubscriptionCard(BuildContext context, double width) {
    return Obx(() {
      if (subscriptionController.isLoading.value &&
          subscriptionController.mySubscriptions.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (subscriptionController.mySubscriptions.isEmpty) {
        return _buildEmptySubscription(width);
      }

      final mySub = subscriptionController.mySubscriptions.first;
      final bool isPending = mySub['status'] == "pending";

      final planDetails = mySub['subscription'] ?? mySub;

      if (planDetails == null) {
        return _buildEmptySubscription(width);
      }

      final String planName = (planDetails['name'] ?? "باقة").toString();
      final imageUrl = (planDetails['image_url'] ?? '').toString();

      String formattedDate = "";

      if (!isPending) {
        String rawDate = (mySub['end_date'] ?? "").toString();

        if (rawDate.isNotEmpty) {
          try {
            formattedDate = DateFormat(
              'yyyy-MM-dd',
            ).format(DateTime.parse(rawDate));
          } catch (_) {
            formattedDate = "غير محدد";
          }
        }
      }
      final String statusLabel = (mySub['status_label'] ?? "غير معروف")
          .toString();

      final String tier = (planDetails['tier'] ?? "").toString();

      final String price = (planDetails['price'] ?? "").toString();

      final String discount = (planDetails['discount_percentage'] ?? "0")
          .toString();

      final int duration = planDetails['duration'] ?? 0;
      return SizedBox(
        width: width,
        height: 170,
        child: PageView(
          scrollDirection: Axis.horizontal,
          reverse: true,
          children: [
            _buildPlanImageCard(
              width,
              imageUrl,
              planName,
              formattedDate,
              isPending,
            ),

            _buildPlanDetailsCard(
              width,
              isPending,
              statusLabel,
              tier,
              price,
              discount,
              duration,
              formattedDate,
              mySub['id'],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildPlanImageCard(
    double width,
    String imageUrl,
    String planName,
    String formattedDate,
    bool isPending,
  ) {
    return Container(
      width: width,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),

      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),

        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network("${ApiConfig.base}$imageUrl", fit: BoxFit.cover),

            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.bottomLeft,
                  colors: [
                    Colors.black.withOpacity(.25),
                    Colors.black.withOpacity(.45),
                  ],
                ),
              ),
            ),

            Positioned(
              right: 20,
              bottom: 55,

              child: Text(
                planName,

                textAlign: TextAlign.right,

                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,

                  shadows: [
                    Shadow(
                      blurRadius: 12,
                      color: Colors.black,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 15,
              right: 15,

              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),

                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.9),
                  borderRadius: BorderRadius.circular(30),
                ),

                child: Row(
                  mainAxisSize: MainAxisSize.min,

                  children: [
                    Icon(
                      isPending ? Icons.hourglass_top : Icons.check_circle,

                      size: 15,

                      color: isPending ? Colors.orange : Colors.green,
                    ),

                    const SizedBox(width: 5),

                    Text(
                      isPending ? "بانتظار الموافقة" : "تنتهي $formattedDate",

                      style: TextStyle(
                        color: isPending
                            ? Colors.orange.shade700
                            : Colors.green.shade700,

                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // تلميح السحب أسفل اليسار
            Positioned(
              bottom: 12,
              left: 15,

              child: Row(
                children: [
                  const Icon(Icons.swipe_left, color: Colors.white, size: 18),

                  const SizedBox(width: 5),

                  Text(
                    "اسحب للتفاصيل",
                    style: TextStyle(
                      color: Colors.white.withOpacity(.9),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanDetailsCard(
    double width,
    bool isPending,
    String statusLabel,
    String tier,
    String price,
    String discount,
    int duration,
    String formattedDate,
    int requestId,
  ) {
    return Container(
      width: width,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      padding: const EdgeInsets.all(12),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(.08), blurRadius: 12),
        ],
      ),

      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                isPending ? Icons.hourglass_top : Icons.verified,
                size: 18,
                color: isPending ? Colors.orange : Colors.green,
              ),

              const SizedBox(width: 6),

              Expanded(
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isPending ? Colors.orange : Colors.green,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _compactInfo(
                  Icons.workspace_premium,
                  tier.toUpperCase(),
                ),
              ),

              Expanded(child: _compactInfo(Icons.payments, "$price ل.س")),
            ],
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(child: _compactInfo(Icons.discount, "$discount%")),

              Expanded(
                child: _compactInfo(Icons.calendar_month, "$duration يوم"),
              ),
            ],
          ),
          if (isPending) ...[
            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 32,

              child: ElevatedButton.icon(
                onPressed: () {
                  Get.defaultDialog(
                    title: "إلغاء الطلب",

                    middleText: "هل أنت متأكد من إلغاء طلب الاشتراك؟",

                    titleStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),

                    middleTextStyle: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),

                    radius: 20,

                    textCancel: "رجوع",

                    textConfirm: "إلغاء الطلب",

                    cancelTextColor: Colors.grey,

                    confirmTextColor: Colors.white,

                    buttonColor: const Color(0xFFE55757),

                    onCancel: () {},

                    onConfirm: () {
                      Get.back();

                      subscriptionController.cancelSubscriptionRequest(
                        requestId,
                      );
                    },
                  );
                },

                icon: const Icon(Icons.cancel_outlined, size: 17),

                label: const Text(
                  "إلغاء الطلب",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade50,
                  foregroundColor: Colors.red,
                  elevation: 0,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBenefitsCard() {
    return Obx(() {
      final benefits = subscriptionController.subscriptionBenefits.value;

      if (benefits == null) {
        return const SizedBox();
      }

     final List<dynamic> freeBenefits =
    (benefits['free_benefits'] as List?) ?? [];

final Map<String, dynamic> discounts =
    (benefits['permanent_discounts'] as Map?)?.cast<String, dynamic>() ?? {};
print('freeBenefits type: ${freeBenefits.runtimeType}');
print('freeBenefits: $freeBenefits');
      return Container(
        padding: const EdgeInsets.all(18),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(.1),
                    shape: BoxShape.circle,
                  ),

                  child: const Icon(
                    Icons.workspace_premium,
                    color: Colors.orange,
                  ),
                ),

                const SizedBox(width: 10),

                const Text(
                  "مميزات اشتراكك",
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ],
            ),

            const SizedBox(height: 20),

         for (final benefit in freeBenefits)
  _buildBenefitItem(
    benefit['spare_part_id'] == 2
        ? Icons.oil_barrel
        : benefit['spare_part_id'] == 3
            ? Icons.filter_alt
            : benefit['spare_part_id'] == 4
                ? Icons.electric_bolt
                : Icons.build,
    benefit,
  ),
            const Divider(height: 30),

            const Text(
              "الخصومات الدائمة",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),

            const SizedBox(height: 15),

            _buildDiscountItem(
              "أجور اليد",
              discounts['labor_discount']['percentage'],
            ),

            _buildDiscountItem(
              "قطع الغيار",
              discounts['parts_discount']['percentage'],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildBenefitItem(IconData icon, dynamic data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),

      padding: const EdgeInsets.all(12),

      decoration: BoxDecoration(
        color: const Color(0xffF8F8FA),
        borderRadius: BorderRadius.circular(15),
      ),

      child: Row(
        children: [
          Icon(icon, color: const Color(0xffE55757)),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['label'] ?? "",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),

                Text(
                  data['unlimited'] == true
                      ? "استخدام غير محدود"
                      : "متبقي ${data['remaining']} من ${data['total']}",

                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _compactInfo(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 17, color: const Color(0xFFE55757)),

        const SizedBox(width: 5),

        Expanded(
          child: Text(
            value,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildLogoutTile() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(child: LogoutWidget()),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "تسجيل الخروج",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                Text(
                  "اخرج من حسابك",
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 2),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F7),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.red, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 11.5, color: Colors.grey),
        ),
        trailing: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 12,
          color: Colors.black12,
        ),
      ),
    );
  }

  Widget _buildDiscountItem(String title, String percentage) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,

        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),

            decoration: BoxDecoration(
              color: Colors.green.withOpacity(.1),
              borderRadius: BorderRadius.circular(20),
            ),

            child: Text(
              "$percentage%",
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 5, 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.black38,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildEmptySubscription(double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFFFEEAEA),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.account_balance_wallet_rounded,
              color: Color(0xFFE55757),
              size: 24,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "لا توجد باقة نشطة",
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: Color(0xFF1A1D26),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "اشترك في إحدى باقاتنا المتاحة لفتح الميزات المميزة",
                  style: TextStyle(
                    color: const Color(0xFF2D3243).withOpacity(0.5),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundGradient() {
    return Positioned(
      top: -50,
      right: -50,
      child: Container(
        width: 280,
        height: 280,
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
