import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';

import '../utils/video_player_utils.dart';
import '../constants/video_player_constants.dart';

class BasicPlayerPage extends StatefulWidget {
  @override
  _BasicPlayerPageState createState() => _BasicPlayerPageState();
}

class _BasicPlayerPageState extends State<BasicPlayerPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Basic player"),
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Basic player created with the simplest factory method. Shows video from URL.",
              style: TextStyle(fontSize: 16),
            ),
          ),
          AspectRatio(
            aspectRatio: 16 / 9,
            child: BetterPlayer.network(
              VideoPlayerConstants.forBiggerBlazesUrl,
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 16),
          //   child: Text(
          //     "Next player shows video from file.",
          //     style: TextStyle(fontSize: 16),
          //   ),
          // ),
          // const SizedBox(height: 8),
          // FutureBuilder<String>(
          //   future: VideoPlayerUtils.getFileUrl(
          //       VideoPlayerConstants.fileTestVideoUrl),
          //   builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          //     if (snapshot.data != null) {
          //       return BetterPlayer.file(snapshot.data);
          //     } else {
          //       return const SizedBox();
          //     }
          //   },
          // ),
        ],
      ),
    );
  }
}