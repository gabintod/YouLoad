import 'package:flutter/material.dart';

class KeepAliveBuilder extends StatefulWidget {
  final WidgetBuilder builder;

  const KeepAliveBuilder({Key? key, required this.builder}) : super(key: key);

  @override
  _KeepAliveBuilderState createState() => _KeepAliveBuilderState();
}

class _KeepAliveBuilderState extends State<KeepAliveBuilder> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) => widget.builder(context);

  @override
  bool get wantKeepAlive => true;
}