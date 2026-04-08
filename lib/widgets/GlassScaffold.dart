import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:senior_project/widgets/GlassBackButton.dart';

class GlassScaffold extends StatelessWidget {
  final Widget child;
  final bool showBackButton;

  const GlassScaffold({
    super.key,
    required this.child,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('lib/images/startscreen.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
              child: Container(color: Colors.black.withOpacity(0.6)),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: child,
              ),
            ),
          ),
          // زر العودة
          if (showBackButton)
            const Positioned(top: 20, left: 10, child: GlassBackButton()),
        ],
      ),
    );
  }
}
