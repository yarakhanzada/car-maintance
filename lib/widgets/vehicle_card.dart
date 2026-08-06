import 'package:flutter/material.dart';

class VehicleCard extends StatefulWidget {
  final String brand;
  final String model;
  final String year;
  final String chassis;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onSelect;
  final bool isOpened;
  final Function(bool) onSlide;
  final bool isSelected;

  const VehicleCard({
    super.key,
    required this.brand,
    required this.model,
    required this.year,
    required this.chassis,
    this.onEdit,
    this.onDelete,
    this.onSelect,
    required this.isOpened,
    required this.onSlide,
    this.isSelected = false,
  });

  @override
  State<VehicleCard> createState() => _VehicleCardState();
}

class _VehicleCardState extends State<VehicleCard> {
  late double dragOffset;
  final double maxDragOffset = -170;

  @override
  void initState() {
    super.initState();
    dragOffset = widget.isOpened ? maxDragOffset : 0;
  }

  @override
  void didUpdateWidget(VehicleCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.isOpened && dragOffset != 0) {
      setState(() => dragOffset = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: GestureDetector(
        onHorizontalDragUpdate: (details) {
          setState(() {
            dragOffset += details.primaryDelta!;
            if (dragOffset > 0) dragOffset = 0;
            if (dragOffset < maxDragOffset) dragOffset = maxDragOffset;
          });
        },
        onHorizontalDragEnd: (details) {
          if (dragOffset < (maxDragOffset / 2)) {
            setState(() => dragOffset = maxDragOffset);
            widget.onSlide(true);
          } else {
            setState(() => dragOffset = 0);
            widget.onSlide(false);
          }
        },
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _buildActionIcon(
                      Icons.check_circle_outline_rounded,
                      "اختيار",
                      Colors.greenAccent,
                      widget.onSelect,
                    ),
                    _buildActionIcon(
                      Icons.delete_outline_rounded,
                      "حذف",
                      Colors.redAccent,
                      widget.onDelete,
                    ),
                  ],
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              transform: Matrix4.translationValues(dragOffset, 0, 0),
              child: Stack(
                children: [
                  _buildGlassCarCard(width),

                  // 🔥 التعديل البصري الجديد: مؤشر سهمين صريح وواضح جداً للسحب
                  if (dragOffset == 0)
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        width: 45,
                        decoration: BoxDecoration(
                          // تدرج لوني ناعم يسحب عين المستخدم للحافة اليسرى
                          gradient: LinearGradient(
                            colors: [
                              Colors.grey.withOpacity(0.15),
                              Colors.transparent,
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(24),
                            bottomLeft: Radius.circular(24),
                          ),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.keyboard_arrow_left_rounded,
                                color: Color.fromARGB(70, 65, 62, 62),
                                size: 18,
                              ),
                              Transform(
                                transform: Matrix4.translationValues(6, 0, 0),
                                child: const Icon(
                                  Icons.keyboard_arrow_left_rounded,
                                  color: Color.fromARGB(133, 14, 12, 12),
                                  size: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
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

  Widget _buildActionIcon(
    IconData icon,
    String label,
    Color color,
    VoidCallback? onTap,
  ) {
    return InkWell(
      onTap: () {
        setState(() => dragOffset = 0);
        if (onTap != null) onTap();
      },
      child: SizedBox(
        width: 85,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(color: color.withOpacity(0.3), width: 1),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: color.withOpacity(0.9),
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassCarCard(double width) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: widget.isSelected
            ? Border.all(color: const Color(0xFFE55757), width: 1.5)
            : Border.all(color: Colors.transparent, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 70,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Center(
              child: Icon(
                Icons.directions_car_filled_outlined,
                size: 50,
                color: Colors.grey[200],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    _buildInfoItem("النوع", widget.brand),
                    _buildVerticalDivider(),
                    _buildInfoItem("الموديل", widget.model),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Divider(height: 1, thickness: 0.5),
                ),
                Row(
                  children: [
                    _buildInfoItem("رقم اللوحة", widget.chassis),
                    _buildVerticalDivider(),
                    _buildInfoItem("السنة", widget.year),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF9E9E9E),
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF1A1A1A),
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 20,
      width: 1.5,
      margin: const EdgeInsets.symmetric(horizontal: 15),
      color: Colors.grey[200],
    );
  }
}
