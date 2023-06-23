import 'package:experiment/story/stories_item.dart';
import 'package:experiment/story/stories_view.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Demo',
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Page"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => SukukStoriesPage(index: 0),
              ),
            );
          },
          child: const Text("Go to Sukuk Stories"),
        ),
      ),
    );
  }
}

class SukukStoriesPage extends StatelessWidget {
  final int index;
  SukukStoriesPage({
    super.key,
    required this.index,
  });

  final storyPages = List.generate(3, (index) => StoryController(index: 0));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StoriesPageView(
        itemCount: storyPages.length,
        outOfRangeCompleted: () {
          Navigator.of(context).pop();
        },
        itemBuilder: (context, storyViewIndex) {
          return StoriesPageItem(
            controller: storyPages[storyViewIndex],
            itemCount: 10,
            durationBuilder: (index) {
              return const Duration(seconds: 5);
            },
            itemBuilder: (context, index, animation) {
              // snap
              return Stack(
                children: [
                  Container(
                    color: Colors.primaries[index % Colors.primaries.length],
                    child: Center(
                      child: Text(
                        "Sukuk Stories $storyViewIndex, story $index",
                        style: Theme.of(context).textTheme.headline3,
                      ),
                    ),
                  ),
                  SafeArea(
                    child: StoryProgressBars(
                      storyIndex: index,
                      storyCount: 10,
                      animation: animation,
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class StoryProgressBars extends StatefulWidget {
  const StoryProgressBars(
      {Key? key,
      required this.storyCount,
      required this.storyIndex,
      required this.animation})
      : super(key: key);

  final int storyCount;
  final int storyIndex;
  final Animation<double> animation;

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
    return SafeArea(
      child: Row(
        children: [
          for (int i = 0; i < widget.storyCount; i++)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 8,
                ),
                child: ProgressIndicator(
                  progress: _getProgress(i),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ProgressIndicator extends StatelessWidget {
  const ProgressIndicator({
    Key? key,
    required this.progress,
  }) : super(key: key);

  final double progress;

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      value: progress,
      valueColor: AlwaysStoppedAnimation<Color>(
        Colors.white,
      ),
      backgroundColor: Colors.grey,
    );
  }
}
