import 'package:flutter/widgets.dart';

class StoryProgressBars extends StatefulWidget {
  const StoryProgressBars({
    Key? key,
    required this.storyCount,
    required this.storyIndex,
    required this.animation,
    required this.builder,
  }) : super(key: key);

  final int storyCount;
  final int storyIndex;
  final Animation<double> animation;
  final Widget Function(double progress) builder;

  @override
  State<StoryProgressBars> createState() => _StoryProgressBarsState();
}

class _StoryProgressBarsState extends State<StoryProgressBars> {
  @override
  void initState() {
    super.initState();
    widget.animation.addListener(animationListener);
  }

  void animationListener() {
    setState(() {});
  }

  @override
  void dispose() {
    widget.animation.removeListener(animationListener);
    super.dispose();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  double _getProgress(int index) {
    if (index < widget.storyIndex) {
      return 1;
    } else if (index == widget.storyIndex) {
      return widget.animation.value;
    } else {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < widget.storyCount; i++)
          widget.builder(_getProgress(i)),
      ],
    );
  }
}
