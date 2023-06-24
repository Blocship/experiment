import 'dart:async';

import 'package:flutter/material.dart';

class StreamSubject<T> {
  late T _value;
  late StreamController<T> _controller;

  StreamSubject.seeded(T initialValue) {
    _value = initialValue;
    _controller = StreamController<T>.broadcast(
      sync: true,
      onListen: () => _controller.add(_value),
    );
  }

  Stream<T> get stream => _controller.stream;
  T get value => _value;

  void add(T data) {
    _value = data;
    _controller.add(data);
  }

  void close() {
    _controller.close();
  }
}

enum PlayBackState {
  playing,
  paused,
  completed,
}

class StoryController {
  late final StreamSubject<int> _indexSubject;
  late final StreamSubject<PlayBackState> _playBackStateSubject;

  StoryController({
    required int index,
  })  : _indexSubject = StreamSubject.seeded(index),
        _playBackStateSubject = StreamSubject.seeded(PlayBackState.paused);

  int get currentIndex => _indexSubject.value;
  PlayBackState get playBackState => _playBackStateSubject.value;
  Stream<int> get indexStream => _indexSubject.stream;
  Stream<PlayBackState> get playBackStateStream => _playBackStateSubject.stream;

  void jumpToNext() {
    _indexSubject.add(_indexSubject.value + 1);
  }

  void jumpToPrevious() {
    _indexSubject.add(_indexSubject.value - 1);
  }

  void play() {
    _playBackStateSubject.add(PlayBackState.playing);
  }

  void pause() {
    _playBackStateSubject.add(PlayBackState.paused);
  }

  void dispose() {
    _indexSubject.close();
    _playBackStateSubject.close();
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
  late final AnimationController _animationController;
  late final Animation<double> _animation;
  late final StreamSubscription<PlayBackState> _playBackStateSubscription;

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
      ..addListener(_handleAnimation);
    // ..forward();
    _playBackStateSubscription =
        widget.controller.playBackStateStream.listen((playBackState) {
      if (playBackState == PlayBackState.playing) {
        _animationController.forward();
      } else {
        _animationController.stop();
      }
    });
  }

  @override
  void dispose() {
    _animation.removeListener(_handleAnimation);
    _animationController.dispose();
    _playBackStateSubscription.cancel();
    super.dispose();
  }

  void _handleAnimation() {
    if (_animation.isCompleted) {
      widget.controller.jumpToNext();
      _animationController
        ..reset()
        ..duration = widget.durationBuilder(
          widget.controller.currentIndex,
        );
      // ..forward();
    }
  }

  void onTapNext() {
    _animationController.stop();
    widget.controller.jumpToNext();
    _animationController
      ..reset()
      ..duration = widget.durationBuilder(
        widget.controller.currentIndex,
      );
    // ..forward();
  }

  void onTapPrevious() {
    _animationController.stop();
    widget.controller.jumpToPrevious();
    _animationController
      ..reset()
      ..duration = widget.durationBuilder(
        widget.controller.currentIndex,
      );
    // ..forward();
  }

  @override
  Widget build(BuildContext context) {
    Offset tapOffset = Offset.zero;
    return Listener(
      onPointerUp: (event) {
        tapOffset = event.position;
      },
      child: GestureDetector(
        onTap: () {
          // 20% of the screen width from the left
          final screenWidth20 = MediaQuery.of(context).size.width / 5;
          final isTappedOnLeft = tapOffset.dx < screenWidth20;
          if (isTappedOnLeft) {
            onTapPrevious();
          } else {
            onTapNext();
          }
        },
        child: StreamBuilder(
          stream: widget.controller.indexStream,
          builder: (context, _) {
            return widget.itemBuilder(
                context, widget.controller.currentIndex, _animation);
          },
        ),
      ),
    );
  }
}
