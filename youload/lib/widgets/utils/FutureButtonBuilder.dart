import 'package:flutter/material.dart';

class FutureButtonBuilder extends StatefulWidget {
  final Future Function()? callback;
  final Widget Function(BuildContext context, void Function()? callback) builder;

  const FutureButtonBuilder({
    Key? key,
    this.callback,
    required this.builder,
  }) : super(key: key);

  @override
  _FutureButtonBuilderState createState() => _FutureButtonBuilderState();
}

class _FutureButtonBuilderState extends State<FutureButtonBuilder> {
  Future? future;

  @override
  Widget build(BuildContext context) {
    if (future == null) {
      return widget.builder(context, callback);
    }

    return FutureBuilder(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return widget.builder(context, callback);
        }

        return widget.builder(context, null);
      },
    );
  }

  void callback() {
    setState(() {
      future = widget.callback?.call();
    });
  }
}
