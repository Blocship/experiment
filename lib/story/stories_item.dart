import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';

class StoryController {
  int _index;

  final _streamController = StreamController<int>.broadcast();

  StoryController({
    required int index,
  }) : _index = index;

  int get currentIndex => _index;
  Stream<int> get stream => _streamController.stream;

  void jumpToNext() {
    log(_index.toString());
    _index++;
    _streamController.add(_index);
  }

  void jumpToPrevious() {
    _index--;
    _streamController.add(_index);
  }
}

class StoriesItem extends StatelessWidget {
  final int itemCount;
  final StoryController controller;
  final Widget Function(BuildContext context, int index) itemBuilder;

  const StoriesItem({
    super.key,
    required this.controller,
    required this.itemBuilder,
    required this.itemCount,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        controller.jumpToNext();
      },
      child: StreamBuilder<int>(
        stream: controller.stream,
        builder: (context, snapshot) {
          return itemBuilder(context, snapshot.data!);
        },
      ),
    );
  }
}
