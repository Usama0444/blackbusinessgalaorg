import 'dart:convert';

import 'package:bbp/utils/app_colors.dart';
import 'package:bbp/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

class VideoScreen extends StatefulWidget {
  @override
  _VideoScreenState createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  bool _isLoading = true;
  List _videoList = [];

  @override
  void initState() {
    super.initState();
    getVideo();
  }

  showMessage(String message, Color color, IconData iconData) {
    Fluttertoast.showToast(msg: message, toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 1, backgroundColor: Colors.black, textColor: Colors.white, fontSize: 16.0);
  }

  getVideo() async {
    setState(() {
      _isLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, String> requestHeaders = {'era-token': prefs.getString("token") ?? ''};
    var jsonData = null;
    var reponse = await http.get(Uri.parse("${Constants.BASE_URL}/businessvideo/getVideo/videos"), headers: requestHeaders);
    if (reponse.statusCode == 200) {
      jsonData = json.decode(reponse.body);
      var data = jsonData["data"];
      if (jsonData["status"]) {
        _videoList = data as List;
      } else {
        _videoList = [];
        showMessage(jsonData["message"], Colors.red, Icons.error);
      }
      setState(() {
        _isLoading = false;
      });
    } else {
      print(reponse.body);
    }
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return Scaffold(
        // backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            "Watch Videos",
            style: GoogleFonts.poppins(textStyle: TextStyle(color: Colors.black, letterSpacing: .5, fontSize: 22)),
          ),
          backgroundColor: Colors.white,
          elevation: 2.0,
          iconTheme: IconThemeData(color: Colors.black),
        ),
        body: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  backgroundColor: Colors.black,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.gold),
                ),
              )
            : _videoList.isEmpty
                ? Center(
                    child: Text(
                      "Videos not found",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(textStyle: TextStyle(color: Colors.black, letterSpacing: .5, fontSize: 26, fontWeight: FontWeight.w500)),
                    ),
                  )
                : ListView.builder(
                    itemCount: _videoList.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: VideoWidget(height: height, width: width, video: _videoList[index]),
                      );
                    }));
  }
}

class VideoWidget extends StatelessWidget {
  const VideoWidget({Key? key, required this.height, required this.width, required this.video}) : super(key: key);

  final double height;
  final Map<String, dynamic> video;
  final double width;

  @override
  Widget build(BuildContext context) {
    List videoData = video["videos"] as List;
    return Container(
      padding: EdgeInsets.all(10),
      color: Colors.white,
      width: double.infinity,
      height: height * 0.31,
      child: Column(
        children: [
          Row(
            children: [
              ClipOval(child: Image.network(video["category_img"], width: width * 0.15, height: width * 0.15)),
              SizedBox(
                width: 10,
              ),
              Text(
                video["title"],
                style: GoogleFonts.poppins(textStyle: TextStyle(color: Colors.black, letterSpacing: .5, fontWeight: FontWeight.w500, fontSize: 20)),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Expanded(
              child: Container(
            width: width,
            height: height * 0.2,
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: videoData.length,
                itemBuilder: (context, index) {
                  return Padding(
                      padding: EdgeInsets.only(right: 20),
                      child: Card(
                          semanticContainer: true,
                          color: Colors.transparent,
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40.0),
                          ),
                          elevation: 1,
                          child: InkWell(
                            onTap: () {
                              print(videoData[index]);
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => VideoPlayerScreen(video: videoData[index])),
                              );
                            },
                            child: Container(
                              width: width * 0.7,
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                image: NetworkImage(videoData[index]["wv_img"]),
                                fit: BoxFit.cover,
                              )),
                              child: Stack(
                                children: [
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    bottom: 0,
                                    left: 0,
                                    child: Center(
                                        child: CircleAvatar(
                                      radius: 40,
                                      backgroundColor: Colors.black54,
                                      child: Icon(
                                        Icons.play_arrow,
                                        size: width * 0.17,
                                        color: Colors.white70,
                                      ),
                                    )),
                                  )
                                ],
                              ),
                            ),
                          )));
                }),
          ))
        ],
      ),
    );
  }
}

class VideoPlayerScreen extends StatefulWidget {
  VideoPlayerScreen({Key? key, required this.video}) : super(key: key);

  Map<String, dynamic> video;

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? _controller;
  Future<void>? _initializeVideoPlayerFuture;

  @override
  void dispose() {
    // Ensure disposing of the VideoPlayerController to free up resources.
    _controller?.dispose();

    super.dispose();
  }

  @override
  void initState() {
    // Create an store the VideoPlayerController. The VideoPlayerController
    // offers several different constructors to play videos from assets, files,
    // or the internet.
    print('sssssss');
    _controller = VideoPlayerController.network(
      "${widget.video["wv_url"]}",
    );

    _initializeVideoPlayerFuture = _controller?.initialize();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Video",
          style: GoogleFonts.poppins(textStyle: TextStyle(color: Colors.black, letterSpacing: .5, fontSize: 22)),
        ),
        backgroundColor: Colors.white,
        elevation: 2.0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      // Use a FutureBuilder to display a loading spinner while waiting for the
      // VideoPlayerController to finish initializing.
      body: FutureBuilder(
        future: _initializeVideoPlayerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the VideoPlayerController has finished initialization, use
            // the data it provides to limit the aspect ratio of the video.
            return AspectRatio(
              aspectRatio: _controller!.value.aspectRatio,
              // Use the VideoPlayer widget to display the video.
              child: VideoPlayer(_controller!),
            );
          } else {
            // If the VideoPlayerController is still initializing, show a
            // loading spinner.
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Wrap the play or pause in a call to `setState`. This ensures the
          // correct icon is shown.
          setState(() {
            // If the video is playing, pause it.
            if (_controller!.value.isPlaying) {
              _controller!.pause();
            } else {
              // If the video is paused, play it.
              _controller!.play();
            }
          });
        },
        // Display the correct icon depending on the state of the player.
        child: Icon(
          _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
