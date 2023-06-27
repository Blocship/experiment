import 'package:experiment/story/progress_bar.dart';
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

class Story {
  String data;
  List<Snap> snaps;

  Story({
    required this.data,
    required this.snaps,
  });

  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      data: json['data'],
      snaps: List<Snap>.from(
        json['snaps'].map(
          (snap) => Snap.fromJson(snap),
        ),
      ),
    );
  }
}

class Snap {
  String type;
  String data;
  Duration duration;

  Snap({
    required this.type,
    required this.data,
    required this.duration,
  });

  factory Snap.fromJson(Map<String, dynamic> json) {
    return Snap(
      type: json['type'],
      data: json['data'],
      duration: Duration(seconds: int.parse(json['duration'])),
    );
  }

  bool get snapTypeIsImage {
    return type == "image";
  }

  bool get snapTypeIsVideo {
    return type == "video";
  }

  bool get snapTypeIsText {
    return type == "text";
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
  final List<Story> storiesData = [];

  Future<void> getData() async {
    await Future.delayed(const Duration(seconds: 5));
    storiesData.add(
      Story.fromJson({
        "data": "Story 1",
        "snaps": [
          {
            "type": "text",
            "data": "Hello World",
            "duration": "5",
          },
          {
            "type": "image",
            "data":
                "https://image.ibb.co/cU4WGx/Omotuo-Groundnut-Soup-braperucci-com-1.jpg",
            "duration": "5"
          },
          {
            "type": "video",
            "data":
                "https://test-videos.co.uk/vids/bigbuckbunny/mp4/h264/720/Big_Buck_Bunny_720_10s_1MB.mp4",
            "duration": "10"
          },
        ],
      }),
    );
    storiesData.add(
      Story.fromJson({
        "data": "Story 2",
        "snaps": [
          {
            "type": "image",
            "data":
                "https://image.ibb.co/cU4WGx/Omotuo-Groundnut-Soup-braperucci-com-1.jpg",
            "duration": "5"
          },
          {
            "type": "text",
            "data": "Hello World",
            "duration": "5",
          },
        ],
      }),
    );
    storiesData.add(
      Story.fromJson({
        "data": "Story 3",
        "snaps": [
          {
            "type": "video",
            "data":
                "https://test-videos.co.uk/vids/bigbuckbunny/mp4/h264/720/Big_Buck_Bunny_720_10s_1MB.mp4",
            "duration": "10"
          },
        ],
      }),
    );
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  Widget getChild(
    int storyPageIndex,
    int snapIndex,
    StoryController controller,
  ) {
    final data = storiesData[storyPageIndex].snaps[snapIndex];

    if (data.snapTypeIsText) {
      return SnapWidget(
        snap: data,
        controller: controller,
      );
    } else if (data.snapTypeIsImage) {
      return SnapImage(
        snap: data,
        controller: controller,
      );
    } else if (data.snapTypeIsVideo) {
      return SnapVideo(
        snap: data,
        controller: controller,
      );
    } else {
      return Container(color: Colors.red);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (storiesData.isEmpty) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
      body: StoriesPageView(
        pageCount: storiesData.length,
        outOfRangeCompleted: () {
          Navigator.of(context).pop();
        },
        durationBuilder: (pageIndex, snapIndex) {
          return storiesData[pageIndex].snaps[snapIndex].duration;
        },
        snapCountBuilder: (pageIndex) {
          return storiesData[pageIndex].snaps.length;
        },
        snapInitialIndexBuilder: (pageIndex) {
          return 0;
        },
        itemBuilder: (context, pageIndex, snapIndex, animation, controller) {
          return Stack(
            children: [
              getChild(pageIndex, snapIndex, controller),
              SafeArea(
                child: StoryProgressBars(
                  snapIndex: snapIndex,
                  snapCount: storiesData[pageIndex].snaps.length,
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

class SnapWidget extends StatelessWidget {
  final StoryController controller;
  final Snap snap;

  const SnapWidget({
    super.key,
    required this.controller,
    required this.snap,
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

class SnapImage extends StatelessWidget {
  final StoryController controller;
  final Snap snap;

  const SnapImage({
    super.key,
    required this.controller,
    required this.snap,
  });

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

class SnapVideo extends StatefulWidget {
  final StoryController controller;
  final Snap snap;

  const SnapVideo({
    super.key,
    required this.controller,
    required this.snap,
  });

  @override
  State<SnapVideo> createState() => _SnapVideoState();
}

class _SnapVideoState extends State<SnapVideo> {
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
