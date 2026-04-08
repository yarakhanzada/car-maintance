import 'dart:ui';
import 'package:flutter/material.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  double userRating = 0;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F7),
        body: Stack(
          children: [
            _buildBackgroundGradient(),
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  _buildTabBar(),
                  Expanded(
                    child: TabBarView(
                      physics: const BouncingScrollPhysics(),
                      children: [
                        _buildBookingsList(isPast: false),
                        _buildBookingsList(isPast: true),
                      ],
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(25, 30, 25, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "My Bookings",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1A1A1A),
              letterSpacing: -1,
            ),
          ),
          Text(
            "Track your car maintenance status",
            style: TextStyle(color: Colors.grey[600], fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10),
          ],
        ),
        child: TabBar(
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: const Color(0xFFE55757),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: "Upcoming"),
            Tab(text: "Past History"),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingsList({required bool isPast}) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      itemCount: isPast ? 2 : 2,
      itemBuilder: (context, index) {
        return _buildInteractiveBookingCard(
          isPast: isPast,
          service: index == 0 ? "Full Car Detailing" : "Engine Checkup",
          car: "Audi R8 • B-1234-JK",
          date: isPast ? "12 March, 2026" : "Tomorrow, 10:00 AM",
          status: isPast ? "Completed" : (index == 0 ? "Confirmed" : "Pending"),
          price: index == 0 ? "50.00" : "85.00",
        );
      },
    );
  }

  Widget _buildInteractiveBookingCard({
    required bool isPast,
    required String service,
    required String car,
    required String date,
    required String status,
    required String price,
  }) {
    Color statusColor = status == "Confirmed"
        ? Colors.green
        : (status == "Pending" ? Colors.orange : Colors.blueGrey);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: InkWell(
          onTap: isPast ? () => _showRatingSheet(context, service) : null,
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(width: 6, color: statusColor),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: statusColor.withOpacity(0.1),
                          child: Icon(
                            Icons.settings_outlined,
                            color: statusColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                service,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                car,
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          "\$$price",
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                            color: Color(0xFFE55757),
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      child: Divider(height: 1, thickness: 0.5),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_month_outlined,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              date,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        isPast
                            ? _buildRateButton()
                            : _buildStatusBadge(status, statusColor),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildRateButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE55757), Color(0xFFFB8C8C)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE55757).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Row(
        children: [
          Icon(Icons.star_rounded, color: Colors.white, size: 14),
          SizedBox(width: 4),
          Text(
            "RATE NOW",
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showRatingSheet(BuildContext context, String serviceTitle) {
    double tempRating = 0;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.fromLTRB(30, 15, 30, 30),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.98),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(45)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 25),
              const Text(
                "How was your experience?",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Rating for: $serviceTitle",
                style: TextStyle(
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 35),

              AnimatedScale(
                scale: tempRating == 0 ? 1.0 : 1.2,
                duration: const Duration(milliseconds: 300),
                child: Text(
                  tempRating == 5
                      ? "🤩"
                      : (tempRating >= 4
                            ? "😊"
                            : (tempRating >= 3
                                  ? "😐"
                                  : (tempRating > 0 ? "😞" : "⭐"))),
                  style: const TextStyle(fontSize: 65),
                ),
              ),

              const SizedBox(height: 25),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  bool isSelected = index < tempRating;
                  return IconButton(
                    onPressed: () =>
                        setModalState(() => tempRating = index + 1.0),
                    icon: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        isSelected
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        color: isSelected
                            ? const Color(0xFFFFB800)
                            : Colors.grey[300],
                        size: isSelected ? 48 : 42,
                        shadows: isSelected
                            ? [
                                Shadow(
                                  color: const Color(
                                    0xFFFFB800,
                                  ).withOpacity(0.5),
                                  blurRadius: 15,
                                ),
                              ]
                            : [],
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 40),

              Container(
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: tempRating == 0
                      ? null
                      : const LinearGradient(
                          colors: [Color(0xFF1A1A1A), Color(0xFF454545)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  color: tempRating == 0 ? Colors.grey[200] : null,
                  boxShadow: [
                    if (tempRating > 0)
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: tempRating == 0
                      ? null
                      : () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                  child: Text(
                    "Submit Review",
                    style: TextStyle(
                      color: tempRating == 0 ? Colors.grey[500] : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundGradient() {
    return Positioned(
      top: -50,
      left: -50,
      child: Container(
        width: 250,
        height: 250,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFE55757).withOpacity(0.05),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
          child: Container(color: Colors.transparent),
        ),
      ),
    );
  }
}
