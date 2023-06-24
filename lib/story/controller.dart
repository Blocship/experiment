import 'helper.dart';

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
