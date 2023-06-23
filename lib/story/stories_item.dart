import 'package:flutter/material.dart';

class StoryController extends Listenable {
  int _index;
  final List<VoidCallback> _listeners = [];

  StoryController({
    required int index,
  }) : _index = index;

  int get currentIndex => _index;

  void jumpToNext() {
    _index++;
    _notifyListeners();
  }

  void jumpToPrevious() {
    _index--;
    _notifyListeners();
  }

  @override
  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners() {
    for (var listener in _listeners) {
      listener();
    }
  }
}

class StoriesPageItem extends StatefulWidget {
  final int itemCount;
  final StoryController controller;
  final Widget Function(
      BuildContext context, int index, Animation<double> animation) itemBuilder;
  final Duration Function(int index) durationBuilder;

  const StoriesPageItem({
    super.key,
    required this.controller,
    required this.itemBuilder,
    required this.itemCount,
    required this.durationBuilder,
  });

  @override
  State<StoriesPageItem> createState() => _StoriesPageItemState();
}

class _StoriesPageItemState extends State<StoriesPageItem>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: widget.durationBuilder(widget.controller.currentIndex),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
    _animationController
      ..duration = widget.durationBuilder(
        widget.controller.currentIndex,
      )
      ..addListener(_handleAnimation)
      ..forward();
  }

  @override
  void dispose() {
    _animation.removeListener(_handleAnimation);
    _animationController.dispose();
    super.dispose();
  }

  void _handleAnimation() {
    if (_animation.isCompleted) {
      widget.controller.jumpToNext();
      _animationController
        ..reset()
        ..duration = widget.durationBuilder(
          widget.controller.currentIndex,
        )
        ..forward();
    }
  }

  void onTapNext() {
    _animationController.stop();
    widget.controller.jumpToNext();
    _animationController
      ..reset()
      ..duration = widget.durationBuilder(
        widget.controller.currentIndex,
      )
      ..forward();
  }

  void onTapPrevious() {
    _animationController.stop();
    widget.controller.jumpToPrevious();
    _animationController
      ..reset()
      ..duration = widget.durationBuilder(
        widget.controller.currentIndex,
      )
      ..forward();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListenableBuilder(
          listenable: widget.controller,
          builder: (context, _) {
            return widget.itemBuilder(
                context, widget.controller.currentIndex, _animation);
          },
        ),
        Align(
            alignment: Alignment.centerRight,
            heightFactor: 1,
            child: GestureDetector(
              onTapUp: (details) {
                onTapNext();
              },
            )),
        Align(
          alignment: Alignment.centerLeft,
          heightFactor: 1,
          child: SizedBox(
            width: 70,
            child: GestureDetector(onTap: () {
              onTapPrevious();
            }),
          ),
        ),
      ],
    );
  }
}
