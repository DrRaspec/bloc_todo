import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Today',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.8,
                  color: Color(0xFF111111),
                ),
              ),
              SizedBox(height: 4),
              Text(
                '3 tasks',
                style: TextStyle(fontSize: 15, color: Color(0xFF777777)),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {
            // TODO: Open settings
          },
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF111111),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          icon: const Icon(Icons.tune_rounded),
        ),
      ],
    );
  }
}
