import 'dart:ui';
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
  });

  @override
  State<VehicleCard> createState() => _VehicleCardState();
}

class _VehicleCardState extends State<VehicleCard> {
  late double dragOffset;

  @override
  void initState() {
    super.initState();
    dragOffset = widget.isOpened ? -220 : 0;
  }

  @override
  void didUpdateWidget(VehicleCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.isOpened && dragOffset != 0) {
      dragOffset = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        setState(() {
          dragOffset += details.primaryDelta!;
          if (dragOffset > 0) dragOffset = 0;
          if (dragOffset < -240) dragOffset = -240;
        });
      },
      onHorizontalDragEnd: (details) {
        if (dragOffset < -100) {
          setState(() => dragOffset = -220);
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
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _buildActionIcon(
                    Icons.edit_rounded,
                    "Edit",
                    Colors.blueAccent,
                    widget.onEdit,
                  ),
                  _buildActionIcon(
                    Icons.check_circle_outline_rounded,
                    "Select",
                    Colors.greenAccent,
                    widget.onSelect,
                  ),
                  _buildActionIcon(
                    Icons.delete_outline_rounded,
                    "Delete",
                    Colors.redAccent,
                    widget.onDelete,
                  ),
                ],
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            transform: Matrix4.translationValues(dragOffset, 0, 0),
            child: _buildGlassCarCard(width),
          ),
        ],
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
      onTap: onTap,
      child: SizedBox(
        width: 73,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(color: color.withOpacity(0.3), width: 1),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: color.withOpacity(0.9),
                fontSize: 11,
                fontWeight: FontWeight.w600,
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
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    Icons.directions_car_filled_outlined,
                    size: 50,
                    color: Colors.grey[200],
                  ),
                ),

                Positioned(top: 15, right: 15, child: _buildSlideHint()),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    _buildInfoItem("Brand", widget.brand),
                    _buildVerticalDivider(),
                    _buildInfoItem("Model", widget.model),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Divider(height: 1, thickness: 0.5),
                ),
                Row(
                  children: [
                    _buildInfoItem("Plate Number", widget.chassis),
                    _buildVerticalDivider(),
                    _buildInfoItem("Year", widget.year),
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
            style: TextStyle(
              color: Colors.grey[500],
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

  Widget _buildSlideHint() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "slide",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.black.withOpacity(0.4),
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 10,
            color: Colors.black.withOpacity(0.4),
          ),
        ],
      ),
    );
  }
}
