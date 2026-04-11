import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OTPSquare extends StatelessWidget {
  final Function(String)? onChanged;

  const OTPSquare({super.key, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      width: 48,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
      ),
      child: TextField(
        onChanged: (value) {
          if (onChanged != null) onChanged!(value);

          if (value.length == 1) {
            FocusScope.of(context).nextFocus();
          } else if (value.isEmpty) {
            FocusScope.of(context).previousFocus();
          }
        },
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        inputFormatters: [
          LengthLimitingTextInputFormatter(1),
          FilteringTextInputFormatter.digitsOnly,
        ],
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: "•",
          hintStyle: TextStyle(color: Colors.white24),
        ),
      ),
    );
  }
}
