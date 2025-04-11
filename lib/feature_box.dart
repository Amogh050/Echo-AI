import 'package:flutter/material.dart';
import 'package:echo_ai/pallete.dart';

class FeatureBox extends StatelessWidget {
  final Color color;
  final String headerText;
  final String description;
  const FeatureBox({
    super.key,
    required this.color,
    required this.headerText,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 35, vertical: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color,
            color.withOpacity(0.8),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  getIconForHeader(headerText),
                  color: Pallete.mainFontColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  headerText,
                  style: const TextStyle(
                    fontFamily: 'Cera Pro',
                    fontSize: 20,
                    color: Pallete.mainFontColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(
                fontFamily: 'Cera Pro',
                fontSize: 16,
                color: Pallete.mainFontColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  IconData getIconForHeader(String header) {
    switch (header) {
      case 'Gemini':
        return Icons.chat_bubble_outline;
      case 'Stability Diffusion':
        return Icons.image_outlined;
      case 'Smart Voice Assistant':
        return Icons.mic_none_outlined;
      default:
        return Icons.lightbulb_outline;
    }
  }
}
