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
  final _allFeatures = Features.feature;

  List<Map<String, dynamic>> get _gptFeatures =>
      _allFeatures.where((f) => f['isGoogleMLKit'] == false).toList();

  List<Map<String, dynamic>> get _mlKitFeatures =>
      _allFeatures.where((f) => f['isGoogleMLKit'] == true).toList();

  @override
  Widget build(BuildContext context) {
    final gptGradients = FunctionHelper.generateGradients(_gptFeatures.length);
    final mlKitGradients = FunctionHelper.generateGradients(
      _mlKitFeatures.length,
    );

    return Scaffold(
      backgroundColor: const Color(0xfff7f9fb),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── App Bar ──────────────────────────────────────────────────
            SliverAppBar(
              expandedHeight: 250,
              floating: false,
              pinned: true,
              backgroundColor: const Color(0xff10bddc),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
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
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.2),
                        ),
                        child: const Icon(
                          Icons.grid_view_rounded,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Pacific Tracker',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
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
            ),

            // ── Section: GPT ─────────────────────────────────────────────
            if (_gptFeatures.isNotEmpty) ...[
              const SliverPadding(
                padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
                sliver: SliverToBoxAdapter(
                  child: _SectionHeader(
                    icon: Icons.auto_awesome,
                    label: 'GPT Vision',
                    color: Color(0xff10bddc),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverToBoxAdapter(
                  child: _FeatureWrap(
                    features: _gptFeatures,
                    gradients: gptGradients,
                  ),
                ),
              ),
            ],

            // ── Section: Google ML Kit ────────────────────────────────────
            if (_mlKitFeatures.isNotEmpty) ...[
              const SliverPadding(
                padding: EdgeInsets.fromLTRB(20, 28, 20, 12),
                sliver: SliverToBoxAdapter(
                  child: _SectionHeader(
                    icon: Icons.center_focus_strong,
                    label: 'Google ML Kit',
                    color: Color(0xff34a853),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                sliver: SliverToBoxAdapter(
                  child: _FeatureWrap(
                    features: _mlKitFeatures,
                    gradients: mlKitGradients,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Wrap pengganti SliverGrid ───────────────────────────────────────────────
//
// Keunggulan vs SliverGrid + childAspectRatio:
//   • Tinggi tiap card ditentukan oleh kontennya sendiri → tidak ada overflow
//   • Kalau konten item lebih panjang, baris itu saja yang melebar ke bawah
//   • Jumlah kolom tetap 2, tapi bisa disesuaikan lewat `columns`
class _FeatureWrap extends StatelessWidget {
  const _FeatureWrap({
    required this.features,
    required this.gradients,
    this.columns = 2,
  });

  final List<Map<String, dynamic>> features;
  final List<List<Color>> gradients;
  final int columns;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Padding horizontal luar (20+20) + spacing antar kolom
    const outerPadding = 20.0 * 2;
    final totalSpacing = 16.0 * (columns - 1);
    final cardWidth = (screenWidth - outerPadding - totalSpacing) / columns;

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: List.generate(features.length, (index) {
        return SizedBox(
          width: cardWidth,
          // Tidak ada height tetap — card bebas menyesuaikan konten
          child: FeatureCard(item: features[index], gradient: gradients[index]),
        );
      }),
    );
  }
}

// ── Section header ──────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: color,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Divider(color: color.withOpacity(0.25), thickness: 1)),
      ],
    );
  }
}
