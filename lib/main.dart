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

  final stories = List.generate(3, (index) => StoryController(index: 0));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StoriesView(
        itemCount: stories.length,
        outOfRangeCompleted: () {
          Navigator.of(context).pop();
        },
        itemBuilder: (context, storyViewIndex) {
          return StoriesItem(
            controller: stories[storyViewIndex],
            itemCount: 10,
            itemBuilder: (context, index) {
              return Container(
                color: Colors.primaries[index % Colors.primaries.length],
                child: Center(
                  child: Text(
                    "Sukuk Stories $storyViewIndex, story $index",
                    style: Theme.of(context).textTheme.headline3,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
