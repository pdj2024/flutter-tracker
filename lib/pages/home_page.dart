import 'package:flutter/material.dart';
import 'package:track_image/constants/features.dart';
import 'package:track_image/helper/function_helper.dart';
import 'package:track_image/widgets/feature_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final feature = Features.feature;

  @override
  Widget build(BuildContext context) {
    final gradients = FunctionHelper.generateGradients(feature.length);

    return Scaffold(
      backgroundColor: Color(0xfff7f9fb),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar dengan gradient
            SliverAppBar(
              expandedHeight: 250,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xff10bddc), Color(0xff2fd5f2)],
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.2),
                        ),
                        child: Icon(
                          Icons.grid_view_rounded,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        "Pacific Tracker",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Choose your tracking feature',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              backgroundColor: Color(0xff10bddc),
            ),

            // Grid Features
            SliverPadding(
              padding: EdgeInsets.all(20),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final item = feature[index];
                  return FeatureCard(item: item, gradient: gradients[index]);
                }, childCount: feature.length),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
