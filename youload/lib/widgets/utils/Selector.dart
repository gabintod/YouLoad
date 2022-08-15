import 'package:flutter/material.dart';

class Selector extends StatefulWidget {
  final List<Widget> items;
  final int selection;
  final Duration animationDuration;
  final Curve animationCurve;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? selectionBackgroundColor;
  final Color? selectionForegroundColor;
  final EdgeInsets margin;
  final EdgeInsets padding;
  final EdgeInsets itemPadding;
  final Function(int selected)? onSelection;

  const Selector({
    Key? key,
    required this.items,
    required this.selection,
    this.animationDuration = const Duration(milliseconds: 200),
    this.animationCurve = Curves.easeOut,
    this.backgroundColor,
    this.foregroundColor,
    this.selectionBackgroundColor,
    this.selectionForegroundColor,
    this.margin = EdgeInsets.zero,
    this.padding = EdgeInsets.zero,
    this.itemPadding = const EdgeInsets.all(15),
    this.onSelection,
  }) : super(key: key);

  @override
  _SelectorState createState() => _SelectorState();
}

class _SelectorState extends State<Selector>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  late Animation<double> animation;

  @override
  void initState() {
    controller =
        AnimationController(vsync: this, duration: widget.animationDuration);
    animation = AlwaysStoppedAnimation(widget.selection.toDouble());

    super.initState();
  }

  Widget items(Color color) {
    return Row(
      children: widget.items
          .map<Widget>(
            (item) => Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => widget.onSelection?.call(widget.items.indexOf(item)),
                child: Container(
                  padding: widget.itemPadding,
                  child: DefaultTextStyle(
                    style: TextStyle(color: color),
                    textAlign: TextAlign.center,
                    child: IconTheme(
                      data: IconThemeData(color: color),
                      child: item,
                    ),
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = widget.backgroundColor ?? Colors.grey[200]!;
    Color foregroundColor = Theme.of(context).colorScheme.onSurface;
    Color selectionBackgroundColor = Theme.of(context).colorScheme.secondary;
    Color selectionForegroundColor = Theme.of(context).colorScheme.onSecondary;

    return Container(
      margin: widget.margin,
      padding: widget.padding,
      decoration: ShapeDecoration(
        shape: const StadiumBorder(),
        color: backgroundColor,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) => Stack(
          children: [
            items(foregroundColor),
            Positioned.fill(
              child: AnimatedBuilder(
                animation: animation,
                builder: (context, child) {
                  double selectionOffset =
                      animation.value / (widget.items.length - 1) * 2 - 1;

                  return Align(
                    alignment: Alignment(selectionOffset, 0),
                    child: Container(
                      clipBehavior: Clip.antiAlias,
                      width: constraints.maxWidth / widget.items.length,
                      decoration: ShapeDecoration(
                        shape: const StadiumBorder(),
                        color: selectionBackgroundColor,
                      ),
                      child: OverflowBox(
                        alignment: Alignment(selectionOffset, 0),
                        maxWidth: constraints.maxWidth,
                        child: child,
                      ),
                    ),
                  );
                },
                child: items(selectionForegroundColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void didUpdateWidget(Selector old) {
    if (old.animationDuration != widget.animationDuration) {
      controller.duration = widget.animationDuration;
    }

    if (old.selection != widget.selection) {
      animation = Tween<double>(
        begin: old.selection.toDouble(),
        end: widget.selection.toDouble(),
      ).animate(CurveTween(curve: widget.animationCurve).animate(controller));
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
