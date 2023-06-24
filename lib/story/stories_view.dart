import 'package:flutter/material.dart';

import 'helper.dart';

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
