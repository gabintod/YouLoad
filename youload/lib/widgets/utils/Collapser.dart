import 'package:flutter/material.dart';

class Collapser extends StatefulWidget {
  final bool collapsed;
  final Widget child;
  final Duration duration;
  final Curve curve;
  final Axis direction;
  final Alignment alignment;

  const Collapser({
    Key? key,
    required this.collapsed,
    this.duration = const Duration(milliseconds: 200),
    this.curve = Curves.easeOut,
    required this.child,
    this.direction = Axis.vertical,
    this.alignment = Alignment.center,
  }) : super(key: key);

  @override
  _CollapserState createState() => _CollapserState();
}

class _CollapserState extends State<Collapser>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  late Animation<double> animation;

  @override
  void initState() {
    controller = AnimationController(vsync: this, duration: widget.duration);
    animation = AlwaysStoppedAnimation(widget.collapsed ? 0.0 : 1.0);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) => ClipRect(
        child: Align(
          alignment: widget.alignment,
          heightFactor: widget.direction == Axis.vertical ? animation.value : null,
          widthFactor: widget.direction == Axis.horizontal ? animation.value : null,
          child: animation.value > 0 ? child : null,
        ),
      ),
      child: widget.child,
    );
  }

  @override
  void didUpdateWidget(Collapser old) {
    controller.duration = widget.duration;

    if (old.collapsed != widget.collapsed) {
      animation = Tween(
        begin: old.collapsed ? 0.0 : 1.0,
        end: widget.collapsed ? 0.0 : 1.0,
      ).animate(CurveTween(curve: widget.curve).animate(controller));
      controller.forward(from: 0);
    }

    super.didUpdateWidget(old);
  }

  @override
  void dispose() {
    controller.dispose();

    super.dispose();
  }
}
