import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:senior_project/controller/technician  controller/technician_tasks_controller.dart';
import 'package:senior_project/controller/technician%20%20controller/task_action_controller.dart';
import '../../controller/technician  controller/task_details_controller.dart'; // make sure this is the path to the new details controller
import '../../model/technician model/maintenance_task_model.dart';

class NewTasksScreen extends StatelessWidget {
  const NewTasksScreen({super.key});

  void _showTaskDetails(BuildContext context, int taskId) {
    final detailsController = Get.put(TaskDetailsController());
    detailsController.fetchTaskDetails(taskId);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
            border: Border.all(color: Colors.white.withOpacity(0.5)),
          ),
          child: Obx(() {
            if (detailsController.isLoadingDetails.value) {
              return Center(
                child: LoadingAnimationWidget.staggeredDotsWave(
                  color: const Color(0xFFE55757),
                  size: 50,
                ),
              );
            }

            final detailedTask = detailsController.taskDetails.value;
            if (detailedTask == null) {
              return const Center(
                child: Text(
                  "Failed to load details. Please try again.",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              );
            }

            return _buildDetailsContent(context, detailedTask);
          }),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TechnicianTasksController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: Stack(
        children: [
          _buildAmbientDecor(),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return Center(
                        child: LoadingAnimationWidget.staggeredDotsWave(
                          color: const Color(0xFFE55757),
                          size: 60,
                        ),
                      );
                    }

                    // 2. Case with no maintenance tasks
                    if (controller.taskList.isEmpty) {
                      return RefreshIndicator(
                        onRefresh: () => controller.fetchTechnicianTasks(),
                        color: const Color(0xFFE55757),
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.25,
                            ),
                            Center(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.assignment_late_outlined,
                                    size: 70,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 15),
                                  const Text(
                                    "لا يوجد مهام مسندة لقسمك حالياً.",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    // 3. Display the main task list
                    return RefreshIndicator(
                      onRefresh: () => controller.fetchTechnicianTasks(),
                      color: const Color(0xFFE55757),
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                        itemCount: controller.taskList.length,
                        itemBuilder: (context, index) {
                          final task = controller.taskList[index];
                          return _buildTaskCard(context, task);
                        },
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "المهام المتاحة",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: const Color(0xFFE55757).withOpacity(0.7),
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            "طلبات جديدة",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(BuildContext context, MaintenanceTask task) {
    final serviceReq = task.maintenanceRequest?.serviceRequest;
    final vehicle = serviceReq?.vehicle;
    final customer = serviceReq?.user;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildBadge(
                task.department?.name ?? "Maintenance",
                const Color(0xFFE55757),
              ),
              _buildStatusBadge(task.status, task.statusLabel ?? task.status),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const CircleAvatar(
                radius: 25,
                backgroundColor: Color(0xFFF1F2F6),
                child: Icon(
                  Icons.person_outline_rounded,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer?.name ?? "Customer",
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "${vehicle?.brand ?? ''} ${vehicle?.model ?? ''} • ${vehicle?.year ?? ''}",
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          Row(
            children: [
              Expanded(
                child: _buildButton(
                  "عرض التفاصيل",
                  Colors.black,
                  Colors.white,
                  () => _showTaskDetails(context, task.id),
                ),
              ),
              const SizedBox(width: 12),
              _buildQuickAcceptButton(() {
                final actionController = Get.put(TaskActionController());
                actionController.startTask(task.id);
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsContent(BuildContext context, dynamic task) {
    final serviceReq = task.maintenanceRequest?.serviceRequest;
    final faults = task.inspection?.faults ?? [];

    return Column(
      children: [
        const SizedBox(height: 12),
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.black12,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(30),
            children: [
              const Text(
                "تقرير التشخيص",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 25),

              // 1. Main problem type
              _buildDetailInfoBox(
                "المشكلة المبلغ عنها",
                serviceReq?.problemType ?? "No description provided.",
                Icons.troubleshoot_rounded,
              ),
              const SizedBox(height: 20),

              // 2. Vehicle plate number and customer contact info
              _buildDetailInfoBox(
                "السيارة & معلومات الاتصال",
                "رقم اللوحة: ${serviceReq?.vehicle?.plateNumber ?? 'N/A'}\nرقم الزبون : ${serviceReq?.user?.phone ?? 'N/A'}",
                Icons.directions_car_filled_rounded,
              ),
              const SizedBox(height: 20),

              // 3. Display the list of faults, required parts, and services in full detail
              if (faults.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                  child: Text(
                    "المهام المطلوبة & القطع",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ),
                ...faults.map(
                  (fault) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.black.withOpacity(0.05)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const CircleAvatar(
                              radius: 18,
                              backgroundColor: Color(0xFFFFECEC),
                              child: Icon(
                                Icons.build_rounded,
                                size: 16,
                                color: Color(0xFFE55757),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    fault.faultName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  Text(
                                    fault.description,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (fault.time != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFFE55757,
                                  ).withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  "${fault.time} Min",
                                  style: const TextStyle(
                                    color: Color(0xFFE55757),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),

                        // Display the spare parts required for this fault and the price/quantity pivot
                        if (fault.spareParts != null &&
                            fault.spareParts.isNotEmpty) ...[
                          const Divider(height: 25),
                          const Row(
                            children: [
                              Icon(
                                Icons.extension_rounded,
                                size: 16,
                                color: Colors.orange,
                              ),
                              SizedBox(width: 6),
                              Text(
                                "Spare Parts Needed:",
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          ...fault.spareParts.map<Widget>(
                            (part) => Padding(
                              padding: const EdgeInsets.only(top: 4.0, left: 4),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "• ${part.name} (x${part.pivot?.quantity ?? 1})",
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    "${part.pivot?.totalPrice ?? part.price ?? '0'} SP",
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],

                        // Display the labor services and their fees required for the maintenance
                        if (fault.laborServices != null &&
                            fault.laborServices.isNotEmpty) ...[
                          const Divider(height: 25),
                          const Row(
                            children: [
                              Icon(
                                Icons.room_service_rounded,
                                size: 16,
                                color: Colors.blue,
                              ),
                              SizedBox(width: 6),
                              Text(
                                "خدمات اليد العاملة:",
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          ...fault.laborServices.map<Widget>(
                            (service) => Padding(
                              padding: const EdgeInsets.only(top: 4.0, left: 4),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "• ${service.name}",
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    "${service.pivot?.totalPrice ?? service.price ?? '0'} SP",
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // 4. Engineer's notes (if any)
              if (task.inspection?.notes != null &&
                  task.inspection!.notes!.isNotEmpty) ...[
                _buildDetailInfoBox(
                  " ملاحظات المهندس (${task.inspection?.user?.name ?? 'Engineer'})",
                  task.inspection!.notes!,
                  Icons.rate_review_rounded,
                ),
                const SizedBox(height: 20),
              ],

              const SizedBox(height: 20),
              _buildButton(
                "بدء المهمة",
                const Color(0xFFE55757),
                Colors.white,
                () {
                  final actionController = Get.put(TaskActionController());
                  actionController.startTask(task.id);
                },
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => _showRejectDialog(context, task.id),
                child: const Text(
                  "رفض المهمة",
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status, String statusLabel) {
    Color badgeColor = Colors.orange;
    if (status == "in_progress") badgeColor = Colors.blue;
    if (status == "completed") badgeColor = Colors.green;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        statusLabel,
        style: TextStyle(
          color: badgeColor,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildButton(
    String text,
    Color bg,
    Color textCol,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: textCol,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAcceptButton(VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 55,
        width: 55,
        decoration: BoxDecoration(
          color: const Color(0xFFE55757),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.check_rounded, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildDetailInfoBox(String title, String desc, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F2F6).withOpacity(0.5),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: const Color(0xFFE55757)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            desc,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              height: 1.4,
              color: Color(0xFF2D3748),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmbientDecor() {
    return Positioned(
      top: -100,
      left: -100,
      child: CircleAvatar(
        radius: 150,
        backgroundColor: const Color(0xFFE55757).withOpacity(0.03),
      ),
    );
  }

  // Rejection dialog
  void _showRejectDialog(BuildContext context, int taskId) {
    final actionController = Get.put(TaskActionController());
    final textController = TextEditingController();

    Get.dialog(
      BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          backgroundColor: Colors.white.withOpacity(0.95),
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.report_problem_rounded,
                        color: Colors.red,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "رفض المهمة",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                const Text(
                  "من فضلك حدد السبب لرفض هذه المهمة:",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: textController,
                  maxLines: 4,
                  maxLength: 200,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    hintText:
                        "e.g., لا تتوفر المعدات اللازمة في القسم حالياً...",
                    hintStyle: TextStyle(
                      color: Colors.grey.withOpacity(0.6),
                      fontSize: 13,
                    ),
                    fillColor: const Color(0xFFF8F9FD),
                    filled: true,
                    counterStyle: const TextStyle(fontWeight: FontWeight.bold),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(
                        color: Colors.black.withOpacity(0.05),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(
                        color: Color(0xFFE55757),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Get.back(),
                        child: const Text(
                          "انهاء",
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE55757),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                        ),
                        onPressed: () {
                          actionController.rejectTask(
                            taskId,
                            textController.text,
                          );
                        },
                        child: const Text(
                          "إرسال",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
