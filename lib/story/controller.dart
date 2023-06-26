import 'package:flutter/widgets.dart';

import 'helper.dart';

class StoryPageController extends PageController {}

class StoryPageControllerProvider extends InheritedWidget {
  final StoryPageController controller;

  const StoryPageControllerProvider({
    super.key,
    required this.controller,
    required super.child,
  });

  @override
  bool updateShouldNotify(covariant StoryPageControllerProvider oldWidget) {
    return controller != oldWidget.controller;
  }

  static StoryPageControllerProvider? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<StoryPageControllerProvider>();
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
