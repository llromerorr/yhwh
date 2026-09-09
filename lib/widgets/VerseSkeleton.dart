import 'package:flutter/material.dart';

/// Placeholder visual elegante (Skeleton/Shimmer) con silueta de versículos bíblicos.
/// Proporciona retroalimentación visual instantánea durante cargas asíncronas
/// de la base de datos sin alterar el layout ni la posición del AppBar.
class VerseSkeletonList extends StatefulWidget {
  final double horizontalPadding;
  final int count;

  const VerseSkeletonList({
    Key? key,
    required this.horizontalPadding,
    this.count = 8,
  }) : super(key: key);

  @override
  State<VerseSkeletonList> createState() => _VerseSkeletonListState();
}

class _VerseSkeletonListState extends State<VerseSkeletonList>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _opacityAnimation = Tween<double>(begin: 0.25, end: 0.65).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = Theme.of(context).indicatorColor.withValues(alpha: 0.12);

    return AnimatedBuilder(
      animation: _opacityAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(widget.count, (index) {
              return _buildSingleVerseSkeleton(context, baseColor, index);
            }),
          ),
        );
      },
    );
  }

  Widget _buildSingleVerseSkeleton(
      BuildContext context, Color baseColor, int index) {
    // Variación de longitudes de líneas para simular versículos reales
    final linePatterns = [
      [0.92, 0.78],
      [0.98, 0.88, 0.55],
      [0.90, 0.65],
      [0.95, 0.85, 0.70, 0.40],
      [0.85, 0.60],
      [0.95, 0.90, 0.50],
      [0.90, 0.75],
      [0.98, 0.80, 0.45],
    ];

    final pattern = linePatterns[index % linePatterns.length];

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: widget.horizontalPadding,
        vertical: 14.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Número de versículo placeholder
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 22,
                height: 12,
                decoration: BoxDecoration(
                  color: baseColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 14,
                  margin: EdgeInsets.only(
                    right: MediaQuery.of(context).size.width * (1.0 - pattern[0]),
                  ),
                  decoration: BoxDecoration(
                    color: baseColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Líneas subsiguientes del versículo
          for (int i = 1; i < pattern.length; i++) ...[
            Container(
              height: 14,
              width: MediaQuery.of(context).size.width * pattern[i],
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            if (i < pattern.length - 1) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}
