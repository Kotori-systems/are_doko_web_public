import 'package:flutter/material.dart';

class StatefulWrapper extends StatefulWidget {
  const StatefulWrapper({
    required this.child,
    required this.onInit,
    required this.buildContext,
    this.onDispose,
    super.key,
  });

  final void Function(BuildContext) onInit;
  final BuildContext buildContext;
  final void Function()? onDispose;
  final Widget child;

  @override
  State<StatefulWrapper> createState() => _StatefulWrapperState();
}

class _StatefulWrapperState extends State<StatefulWrapper> {
  @override
  void initState() {
    super.initState();
    widget.onInit(widget.buildContext);
  }

  @override
  void dispose() {
    widget.onDispose?.call();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
