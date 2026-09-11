import 'package:flutter/material.dart';
import 'app_theme.dart';

class LoadingShimmer extends StatefulWidget {
  final double height;
  final double? width;
  final double radius;

  const LoadingShimmer({
    super.key,
    this.height = 20,
    this.width,
    this.radius = 8,
  });

  @override
  State<LoadingShimmer> createState() => _LoadingShimmerState();
}

class _LoadingShimmerState extends State<LoadingShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.radius),
          gradient: LinearGradient(
            begin: Alignment(-1 + _c.value * 2, 0),
            end: Alignment(1 + _c.value * 2, 0),
            colors: const [
              Color(0xFF1A0F3E),
              Color(0xFF2A1F5E),
              Color(0xFF1A0F3E),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
      ),
    );
  }
}

class LoadingList extends StatelessWidget {
  final int count;
  const LoadingList({super.key, this.count = 5});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: count,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            const LoadingShimmer(width: 50, height: 50, radius: 25),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  LoadingShimmer(height: 14, width: 150),
                  SizedBox(height: 6),
                  LoadingShimmer(height: 10, width: 80),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
