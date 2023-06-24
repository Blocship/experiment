import 'package:flutter/material.dart';

class StoriesPageView extends StatefulWidget {
  final Widget? Function(BuildContext context, int index) itemBuilder;
  final void Function()? outOfRangeCompleted;
  final int itemCount;
  const StoriesPageView({
    super.key,
    required this.itemBuilder,
    required this.itemCount,
    this.outOfRangeCompleted,
  });

  @override
  _StoriesPageViewState createState() => _StoriesPageViewState();
}

class _StoriesPageViewState extends State<StoriesPageView> {
  final ObservableObject<bool> _outOfRange = false.asObservable();

  @override
  void initState() {
    super.initState();
    _outOfRange.attachListener(_onOutOfRangeChanged);
  }

  @override
  void dispose() {
    _outOfRange.detachListener();
    super.dispose();
  }

  void _onOutOfRangeChanged(bool oldValue, bool newValue) {
    final isOutofRangeCompleted = oldValue == true && newValue == false;
    if (isOutofRangeCompleted) {
      widget.outOfRangeCompleted?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        _outOfRange.value = notification.metrics.outOfRange;
        return false;
      },
      child: PageView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: widget.itemCount,
        itemBuilder: widget.itemBuilder,
      ),
    );
  }
}

class ObservableObject<T> {
  T _value;
  void Function(T oldValue, T newValue)? _onChange;

  ObservableObject({
    required T value,
    void Function(T oldValue, T newValue)? didSet,
  })  : _value = value,
        _onChange = didSet;

  T get value => _value;

  set value(T newValue) {
    final oldValue = _value;
    _value = newValue;
    _onChange?.call(oldValue, newValue);
  }

  void attachListener(void Function(T oldValue, T newValue) listener) {
    assert(_onChange == null, "onChange can be initialized only once");
    _onChange = listener;
  }

  void detachListener() {
    _onChange = null;
  }
}

extension _XObject on Object {
  ObservableObject<T> asObservable<T>({
    void Function(T oldValue, T newValue)? didSet,
  }) {
    return ObservableObject<T>(
      value: this as T,
      didSet: didSet,
    );
  }
}
