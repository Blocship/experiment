import 'package:experiment/story/controller.dart';
import 'package:experiment/story/stories_item.dart';
import 'package:flutter/material.dart';

import 'helper.dart';

typedef StoryItemBuilder = Widget Function(
  BuildContext context,
  int pageIndex,
  int snapIndex,
  Animation<double> animation,
  StoryController controller,
);

typedef DurationBuilder = Duration Function(
  int pageIndex,
  int snapIndex,
);

typedef SnapCountBuilder = int Function(int pageIndex);

class StoriesPageView extends StatefulWidget {
  final int pageCount;
  final StoryItemBuilder itemBuilder;
  final SnapCountBuilder snapInitialIndexBuilder;
  final SnapCountBuilder snapCountBuilder;
  final DurationBuilder durationBuilder;
  final void Function()? outOfRangeCompleted;
  const StoriesPageView({
    super.key,
    required this.pageCount,
    required this.itemBuilder,
    required this.snapInitialIndexBuilder,
    required this.snapCountBuilder,
    required this.durationBuilder,
    this.outOfRangeCompleted,
  });

  @override
  _StoriesPageViewState createState() => _StoriesPageViewState();
}

class _StoriesPageViewState extends State<StoriesPageView> {
  final ObservableObject<bool> _outOfRange = false.asObservable();
  final StoryPageController controller = StoryPageController();

  final List<StoryController> storyControllers = [];

  @override
  void initState() {
    super.initState();
    _outOfRange.attachListener(_onOutOfRangeChanged);
    storyControllers.addAll(
      List.generate(
        widget.pageCount,
        (index) => StoryController(
          index: widget.snapInitialIndexBuilder(index),
        ),
      ),
    );
  }

  @override
  void didUpdateWidget(covariant StoriesPageView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pageCount < widget.pageCount) {
      final newControllers = List.generate(
        widget.pageCount - oldWidget.pageCount,
        (index) => StoryController(
          index: widget.snapInitialIndexBuilder(index),
        ),
      );
      storyControllers.addAll(newControllers);
    } else if (oldWidget.pageCount > widget.pageCount) {
      final extraControllers = List.generate(
        oldWidget.pageCount - widget.pageCount,
        (index) => storyControllers.removeLast(),
      );
      for (var element in extraControllers) {
        element.dispose();
      }
    }
  }

  @override
  void dispose() {
    _outOfRange.detachListener();
    controller.dispose();
    for (var element in storyControllers) {
      element.dispose();
    }
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
    return StoryPageControllerProvider(
      controller: controller,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          _outOfRange.value = notification.metrics.outOfRange;
          return false;
        },
        child: PageView.builder(
          controller: controller,
          physics: const BouncingScrollPhysics(),
          itemCount: widget.pageCount,
          itemBuilder: (context, pageIndex) {
            return StoriesPageItem(
              controller: storyControllers[pageIndex],
              itemCount: widget.snapCountBuilder(pageIndex),
              durationBuilder: (snapIndex) {
                return widget.durationBuilder(pageIndex, snapIndex);
              },
              itemBuilder: (context, snapIndex, animation) {
                return widget.itemBuilder(
                  context,
                  pageIndex,
                  snapIndex,
                  animation,
                  storyControllers[pageIndex],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
