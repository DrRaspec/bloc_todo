import 'package:bloc_todo/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class HomeShimmerView extends StatelessWidget {
  const HomeShimmerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        onPressed: null,
        backgroundColor: AppColors.shimmerButton,
        foregroundColor: AppColors.surface,
        elevation: 0,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: CustomScrollView(
          physics: const NeverScrollableScrollPhysics(),
          slivers: [
            const SliverPadding(
              padding: EdgeInsets.fromLTRB(20, 12, 20, 0),
              sliver: SliverToBoxAdapter(child: _HeaderShimmer()),
            ),
            const SliverPadding(
              padding: EdgeInsets.fromLTRB(20, 24, 20, 0),
              sliver: SliverToBoxAdapter(child: _SummaryCardShimmer()),
            ),
            const SliverPadding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
              sliver: SliverToBoxAdapter(child: _SearchBoxShimmer()),
            ),
            const SliverPadding(
              padding: EdgeInsets.fromLTRB(20, 18, 20, 0),
              sliver: SliverToBoxAdapter(child: _FilterChipsShimmer()),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 100),
              sliver: SliverList.separated(
                itemCount: 5,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return const _TodoCardShimmer();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Shimmer extends StatefulWidget {
  const _Shimmer({required this.child});

  final Widget child;

  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final value = _controller.value;

        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(-1.5 + value * 3, -0.3),
              end: Alignment(-0.5 + value * 3, 0.3),
              colors: const [
                AppColors.shimmerBase,
                AppColors.shimmerHighlight,
                AppColors.shimmerBase,
              ],
              stops: const [0.25, 0.5, 0.75],
            ).createShader(bounds);
          },
          child: child,
        );
      },
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  const _ShimmerBox({
    required this.width,
    required this.height,
    this.radius = 12,
  });

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return _Shimmer(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.shimmerBase,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

class _HeaderShimmer extends StatelessWidget {
  const _HeaderShimmer();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ShimmerBox(width: 120, height: 34, radius: 10),
              SizedBox(height: 10),
              _ShimmerBox(width: 70, height: 16, radius: 8),
            ],
          ),
        ),
        _ShimmerBox(width: 48, height: 48, radius: 16),
      ],
    );
  }
}

class _SummaryCardShimmer extends StatelessWidget {
  const _SummaryCardShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(28),
      ),
      child: const Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ShimmerBox(width: 110, height: 22, radius: 8),
                SizedBox(height: 12),
                _ShimmerBox(width: 150, height: 14, radius: 7),
              ],
            ),
          ),
          _ShimmerBox(width: 58, height: 58, radius: 29),
        ],
      ),
    );
  }
}

class _SearchBoxShimmer extends StatelessWidget {
  const _SearchBoxShimmer();

  @override
  Widget build(BuildContext context) {
    return const _ShimmerBox(width: double.infinity, height: 56, radius: 18);
  }
}

class _FilterChipsShimmer extends StatelessWidget {
  const _FilterChipsShimmer();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        _ShimmerBox(width: 64, height: 42, radius: 14),
        SizedBox(width: 10),
        _ShimmerBox(width: 82, height: 42, radius: 14),
        SizedBox(width: 10),
        _ShimmerBox(width: 70, height: 42, radius: 14),
      ],
    );
  }
}

class _TodoCardShimmer extends StatelessWidget {
  const _TodoCardShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: const Row(
        children: [
          _ShimmerBox(width: 24, height: 24, radius: 6),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ShimmerBox(width: double.infinity, height: 18, radius: 8),
                SizedBox(height: 8),
                _ShimmerBox(width: 80, height: 13, radius: 6),
                SizedBox(height: 14),
                Row(
                  children: [
                    _ShimmerBox(width: 110, height: 14, radius: 7),
                    SizedBox(width: 12),
                    _ShimmerBox(width: 74, height: 14, radius: 7),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 16),
          _ShimmerBox(width: 32, height: 32, radius: 16),
        ],
      ),
    );
  }
}
