import 'package:flutter/material.dart';
import 'package:track_image/pages/track_meter_page.dart';
import 'package:track_image/pages/track_with_google.dart';

class FeatureCard extends StatelessWidget {
  Map<String, dynamic> item;
  List<Color> gradient;
  FeatureCard({super.key, required this.item, required this.gradient});

  @override
  Widget build(BuildContext context) {
    final isMLKit = item['isGoogleMLKit'] ?? false;
    return GestureDetector(
      onTap: () {
        if (isMLKit) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TrackWithGoogle(
                featureTitle: item['title'] ?? '',
                featurePrompt: item['prompt'] ?? '',
                featureIcon: item['icon'] as IconData,
              ),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TrackMeterPage(
                featureTitle: item['title'] ?? '',
                featurePrompt: item['prompt'] ?? '',
                featureIcon: item['icon'] as IconData,
              ),
            ),
          );
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradient[0].withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon container dengan gradient
            Stack(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: gradient),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    item['icon'] as IconData,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                if (isMLKit)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 24,
                      height: 24,
                      padding: EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/google.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 16),
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                item['title'] ?? "-",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff2c3e50),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(height: 8),
            // Tap indicator
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: gradient[0].withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Tap to start',
                style: TextStyle(
                  fontSize: 11,
                  color: gradient[0],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
