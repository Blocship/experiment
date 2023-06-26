import 'package:experiment/story/progress_bar.dart';
import 'package:experiment/story/stories_item.dart';
import 'package:experiment/story/stories_view.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'story/controller.dart';

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
                builder: (context) => const SukukStoriesPage(index: 0),
              ),
            );
          },
          child: const Text("Go to Sukuk Stories"),
        ),
      ),
    );
  }
}

class SukukStoriesPage extends StatefulWidget {
  final int index;
  const SukukStoriesPage({
    super.key,
    required this.index,
  });

  @override
  State<SukukStoriesPage> createState() => _SukukStoriesPageState();
}

class _SukukStoriesPageState extends State<SukukStoriesPage> {
  late final storyPagesController = List.generate(
    storyPagesData.length,
    (index) => StoryController(index: 0),
  );

  final storyPagesData = [
    {
      "type": "image",
      "data":
          "https://image.ibb.co/cU4WGx/Omotuo-Groundnut-Soup-braperucci-com-1.jpg",
    },
    {
      "type": "text",
      "data": "Hello World",
    },
    {
      "type": "video",
      "data":
          "https://test-videos.co.uk/vids/bigbuckbunny/mp4/h264/720/Big_Buck_Bunny_720_10s_1MB.mp4",
    },
  ];

  Widget getChild(int index, StoryController controller) {
    final data = storyPagesData[index]["type"];

    if (data == "text") {
      return WidgetStory(controller: controller);
    } else if (data == "image") {
      return ImageStory(controller: controller);
    } else if (data == "video") {
      return VideoStory(controller: controller);
    } else {
      return Container(color: Colors.red);
    }
  }

  @override
  void dispose() {
    for (var element in storyPagesController) {
      element.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StoriesPageView(
        itemCount: storyPagesData.length,
        outOfRangeCompleted: () {
          Navigator.of(context).pop();
        },
        itemBuilder: (context, storyViewIndex) {
          return StoriesPageItem(
            controller: storyPagesController[storyViewIndex],
            itemCount: storyPagesData.length,
            durationBuilder: (index) {
              return const Duration(seconds: 5);
            },
            itemBuilder: (context, index, animation) {
              return Stack(
                children: [
                  getChild(index, storyPagesController[storyViewIndex]),
                  SafeArea(
                    child: StoryProgressBars(
                      storyIndex: index,
                      storyCount: storyPagesData.length,
                      animation: animation,
                      builder: (progress) {
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 8,
                            ),
                            child: ProgressIndicator(
                              progress: progress,
                            ),
                          ),
                        );
                      },
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
      valueColor: const AlwaysStoppedAnimation<Color>(
        Colors.white,
      ),
      backgroundColor: Colors.grey,
    );
  }
}

class WidgetStory extends StatelessWidget {
  final StoryController controller;

  const WidgetStory({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.yellow,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Story Widget can pause and play",
              style: Theme.of(context).textTheme.headline3,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    controller.pause();
                  },
                  child: const Icon(Icons.pause),
                ),
                IconButton(
                  onPressed: () {
                    controller.play();
                  },
                  icon: const Icon(Icons.play_arrow),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ImageStory extends StatelessWidget {
  final StoryController controller;

  const ImageStory({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Image.network(
      "https://image.ibb.co/cU4WGx/Omotuo-Groundnut-Soup-braperucci-com-1.jpg",
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (frame != null) {
          print('frame: $frame');
          controller.play();
        }
        return child;
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress != null) {
          print('loadingProgress: $loadingProgress');
          controller.pause();
        }

        if (loadingProgress == null) {
          return child;
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}

class VideoStory extends StatefulWidget {
  final StoryController controller;

  const VideoStory({super.key, required this.controller});

  @override
  State<VideoStory> createState() => _VideoStoryState();
}

class _VideoStoryState extends State<VideoStory> {
  final _videoController = VideoPlayerController.network(
    "https://test-videos.co.uk/vids/bigbuckbunny/mp4/h264/720/Big_Buck_Bunny_720_10s_1MB.mp4",
  );

  @override
  void initState() {
    super.initState();
    _videoController.initialize().then((value) {
      print("viedo initialised");
      widget.controller.play();
    });

    _videoController.addListener(() {});
    _videoController.play();
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VideoPlayer(_videoController);
  }
}
