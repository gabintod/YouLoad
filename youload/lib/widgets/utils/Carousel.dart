import 'package:flutter/material.dart';

class Carousel extends StatefulWidget {
  final int index;
  final List<Widget> children;
  final Duration transitionDuration;
  final Curve transitionCurve;

  const Carousel({
    Key? key,
    required this.index,
    required this.children,
    this.transitionDuration = const Duration(milliseconds: 200),
    this.transitionCurve = Curves.linear,
  }) : super(key: key);

  @override
  _CarouselState createState() => _CarouselState();
}

class _CarouselState extends State<Carousel> {
  late int _previousIndex;
  late int _index;

  @override
  void initState() {
    _previousIndex = _index = widget.index;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_index != widget.index) {
      _previousIndex = _index;
      _index = widget.index;
    }

    return AnimatedSwitcher(
      duration: widget.transitionDuration,
      transitionBuilder: (child, animation) {
        var tweenIn = Tween(begin: const Offset(1, 0), end: Offset.zero).chain(CurveTween(curve: widget.transitionCurve));
        var tweenOut = Tween(begin: const Offset(-1, 0), end: Offset.zero).chain(CurveTween(curve: widget.transitionCurve));

        return SlideTransition(
          position: animation.drive(_index > _previousIndex
              ? (child.key == ValueKey(_index) ? tweenIn : tweenOut)
              : (child.key == ValueKey(_index) ? tweenOut : tweenIn)),
          child: child,
        );
      },
      child: Container(
        key: ValueKey(_index),
        child: widget.children[_index],
      ),
    );
  }
}
