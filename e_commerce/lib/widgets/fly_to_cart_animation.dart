import 'package:flutter/material.dart';

void showFlyToCartAnimation(
  BuildContext context, {
  required GlobalKey startKey,
  required GlobalKey endKey,
  required String imageUrl,
}) {
  final overlay = Overlay.of(context);

  final startBox = startKey.currentContext?.findRenderObject() as RenderBox?;
  final endBox = endKey.currentContext?.findRenderObject() as RenderBox?;
  if (startBox == null || endBox == null) return;

  final startOffset = startBox.localToGlobal(
    startBox.size.center(Offset.zero),
  );
  final endOffset = endBox.localToGlobal(endBox.size.center(Offset.zero));

  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (context) => _FlyingProductThumbnail(
      imageUrl: imageUrl,
      start: startOffset,
      end: endOffset,
      onCompleted: () => entry.remove(),
    ),
  );

  overlay.insert(entry);
}

class _FlyingProductThumbnail extends StatefulWidget {
  final String imageUrl;
  final Offset start;
  final Offset end;
  final VoidCallback onCompleted;

  const _FlyingProductThumbnail({
    required this.imageUrl,
    required this.start,
    required this.end,
    required this.onCompleted,
  });

  @override
  State<_FlyingProductThumbnail> createState() => _FlyingProductThumbnailState();
}

class _FlyingProductThumbnailState extends State<_FlyingProductThumbnail>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _position;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  static const double _thumbnailSize = 56;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    )..forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onCompleted();
      }
    });

    
    final controlPoint = Offset(
      (widget.start.dx + widget.end.dx) / 2,
      widget.start.dy - 60,
    );

    _position = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween(begin: widget.start, end: controlPoint)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(begin: controlPoint, end: widget.end)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 60,
      ),
    ]).animate(_controller);

    _scale = Tween<double>(begin: 1.0, end: 0.15)
        .animate(CurvedAnimation(parent: _controller, curve: const Interval(0.1, 1.0)));

    _opacity = Tween<double>(begin: 1.0, end: 0.3)
        .animate(CurvedAnimation(parent: _controller, curve: const Interval(0.6, 1.0)));
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
      builder: (context, child) {
        final pos = _position.value;
        return Positioned(
          left: pos.dx - (_thumbnailSize * _scale.value) / 2,
          top: pos.dy - (_thumbnailSize * _scale.value) / 2,
          child: Opacity(
            opacity: _opacity.value,
            child: Transform.scale(
              scale: _scale.value,
              child: child,
            ),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          widget.imageUrl,
          width: _thumbnailSize,
          height: _thumbnailSize,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}


class BouncingBadgeCount extends StatelessWidget {
  final int value;

  const BouncingBadgeCount({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(value), // rejoue l'animation à chaque changement
      tween: Tween(begin: 0.4, end: 1.0),
      duration: const Duration(milliseconds: 350),
      curve: Curves.elasticOut,
      builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
      child: Text('$value'),
    );
  }
}