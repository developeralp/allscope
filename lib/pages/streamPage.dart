import 'dart:io';

import 'package:allscope/lang/appLocalization.dart';
import 'package:allscope/models/broadcast.dart';
import 'package:allscope/models/stream.dart';
import 'package:allscope/utils/broadcastUtils.dart';
import 'package:allscope/utils/orientationTool.dart';
import 'package:allscope/video/videoPlayerControls.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class StreamPage extends StatefulWidget {
  final Stream stream;
  final Broadcast broadcast;
  final DeviceOrientation orientation;
  final File downloadedBroadcast;
  final bool downloaded;

  StreamPage(
      {Key key,
      this.stream,
      this.broadcast,
      this.orientation,
      this.downloadedBroadcast,
      this.downloaded})
      : super(key: key);

  @override
  _StreamPageState createState() => _StreamPageState();
}

class _StreamPageState extends State<StreamPage> {
  FlickManager flickManager;

  @override
  void initState() {
    super.initState();
    if (widget.orientation != null && widget.downloaded != null) {
      if (!widget.downloaded) {
        String hls = BroadcastUtils().getHlsUrl(widget.stream);

        flickManager = FlickManager(
            videoPlayerController: VideoPlayerController.network(
              hls,
            ),
            autoPlay: true,
            autoInitialize: true);
      } else {
        if (widget.downloadedBroadcast != null) {
          flickManager = FlickManager(
              videoPlayerController: VideoPlayerController.file(
                widget.downloadedBroadcast,
              ),
              autoPlay: true,
              autoInitialize: true);
        }
      }
    }
  }

  @override
  void dispose() {
    OrientationTool.handle();

    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);

    if (flickManager != null) {
      flickManager.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          Navigator.pop(context, 100);
          return Future.value(false);
        },
        child: Scaffold(
            body: flickManager != null
                ? Container(
                    child: Column(
                      children: <Widget>[
                        Container(
                          height: MediaQuery.of(context).size.height,
                          child: FlickVideoPlayer(
                            preferredDeviceOrientation: [widget.orientation],
                            systemUIOverlay: [SystemUiOverlay.bottom],
                            key: ValueKey(BoxFit.cover),
                            wakelockEnabled: true,
                            flickManager: flickManager,
                            flickVideoWithControls: FlickVideoWithControls(
                              videoFit: BoxFit.cover,
                              controls: buildVideoControls(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Center(
                    child:
                        Text(AppLocalizations.instance.text('please_wait')))));
  }

  void openUser(String userId) {}

  Widget buildVideoControls() {
    if (widget.orientation == null || widget.broadcast == null) {
      return Container();
    } else {
      return VideoPlayerControls(
        broadcast: widget.broadcast,
        orientation: widget.orientation,
      );
    }
  }
}
