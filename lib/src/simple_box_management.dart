import 'dart:async';
import 'package:flutter/material.dart';
import 'package:simple_box/src/simple_box_state.dart';

class SimpleBox<T extends SimpleBoxState> {
  final StreamController<T> _streamController =
      StreamController<T>.broadcast();
  int _referenceCount = 0;
  bool _isDisposed = false;

  // Expose these for testing
  @visibleForTesting
  int get referenceCount => _referenceCount;
  
  @visibleForTesting
  bool get isDisposed => _isDisposed;

  @visibleForTesting
  void addReference() => _addReference();
  
  @visibleForTesting
  void removeReference() => _removeReference();

  @protected
  void updateState(T state) {
    if (!_isDisposed) {
      try {
        _streamController.sink.add(state);
      } catch (e) {
        debugPrint('Error updating state: $e');
      }
    }
  }

  Stream<T> get _stream => _streamController.stream;

  void _addReference() {
    _referenceCount++;
  }

  void _removeReference() {
    _referenceCount--;
    if (_referenceCount <= 0) {
      _dispose();
    }
  }

  void _dispose() {
    if (!_isDisposed) {
      _isDisposed = true;
      _streamController.close();
    }
  }
}

class SimpleBoxWidget<T extends SimpleBoxState> extends StatefulWidget {
  const SimpleBoxWidget({
    super.key,
    required this.builder,
    this.listener,
    required this.simpleBox,
  });

  final Widget Function(T) builder;
  final void Function(T)? listener;
  final SimpleBox<T> simpleBox;

  @override
  State<SimpleBoxWidget<T>> createState() => _SimpleBoxWidgetState<T>();
}

class _SimpleBoxWidgetState<T extends SimpleBoxState> extends State<SimpleBoxWidget<T>> {
  @override
  void initState() {
    super.initState();
    widget.simpleBox._addReference();
  }

  @override
  void dispose() {
    widget.simpleBox._removeReference();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<T>(
      stream: widget.simpleBox._stream,
      builder: (_, snapshot) {
        // Create the state only once
        final T state = snapshot.data ?? InitialState() as T;
        
        if (widget.listener != null) {
          widget.listener!(state);
        }
        return widget.builder(state);
      },
    );
  }
}
