import 'package:flutter/material.dart';

class WeatherInfoWidget extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const WeatherInfoWidget({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontFamily: 'Montserrat',
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontFamily: 'Montserrat',
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}
