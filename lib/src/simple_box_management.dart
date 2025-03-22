import 'dart:async';
import 'package:flutter/material.dart';
import 'package:simple_box/src/simple_box_state.dart';

class SimpleBox {
  final StreamController<SimpleBoxState> _streamController =
      StreamController<SimpleBoxState>.broadcast();

  @protected
  void updateState(SimpleBoxState state) => _streamController.sink.add(state);

  Stream<SimpleBoxState> get _stream => _streamController.stream;

  void _dispose() {
    _streamController.close();
  }
}

class SimpleBoxWidget extends StatefulWidget {
  const SimpleBoxWidget({
    super.key,
    required this.builder,
    this.listener,
    required this.simpleBox,
  });

  final Widget Function(SimpleBoxState) builder;
  final void Function(SimpleBoxState)? listener;
  final SimpleBox simpleBox;

  @override
  State<SimpleBoxWidget> createState() => _SimpleBoxWidgetState();
}

class _SimpleBoxWidgetState extends State<SimpleBoxWidget> {
  @override
  void dispose() {
    widget.simpleBox._dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SimpleBoxState>(
      stream: widget.simpleBox._stream,
      builder: (_, snapshot) {
        if (widget.listener != null) {
          widget.listener!(snapshot.data ?? InitialState());
        }
        return widget.builder(snapshot.data ?? InitialState());
      },
    );
  }
}
