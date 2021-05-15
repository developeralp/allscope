import 'package:allscope/ui/design.dart';
import 'package:allscope/ui/networkImageErr.dart';
import 'package:flick_video_player/flick_video_player.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'feedPlayerControls.dart';
import 'flickMultiManager.dart';

class FlickMultiPlayer extends StatefulWidget {
  const FlickMultiPlayer({
    Key key,
    this.url,
    this.image,
    this.flickMultiManager,
    this.lastOne,
    this.openStream,
  }) : super(key: key);

  final String url;
  final String image;
  final FlickMultiManager flickMultiManager;
  final bool lastOne;
  final Function openStream;

  @override
  _FlickMultiPlayerState createState() => _FlickMultiPlayerState();
}

class _FlickMultiPlayerState extends State<FlickMultiPlayer> {
  FlickManager flickManager;

  @override
  void initState() {
    flickManager = FlickManager(
      videoPlayerController: VideoPlayerController.network(widget.url)
        ..setLooping(true),
      autoPlay: false,
    );
    widget.flickMultiManager.init(flickManager);

    super.initState();
  }

  @override
  void dispose() {
    widget.flickMultiManager.remove(flickManager);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          if (widget.openStream != null) {
            widget.openStream();
          }
        },
        child: VisibilityDetector(
          key: ObjectKey(flickManager),
          onVisibilityChanged: (visiblityInfo) {
            if (visiblityInfo.visibleFraction >= 1.5) {
              //0.9
              widget.flickMultiManager.play(flickManager);
            } else {
              if (widget.lastOne != null) {
                if (widget.lastOne) {
                  widget.flickMultiManager.pause();
                }
              }
            }
          },
          child: Container(
            child: FlickVideoPlayer(
              flickManager: flickManager,
              flickVideoWithControls: FlickVideoWithControls(
                playerLoadingFallback: Positioned.fill(
                  child: Stack(
                    children: <Widget>[
                      Positioned.fill(
                        child: Container(
                          height: ScreenUtil().setHeight(Design.videoHeight),
                          alignment: Alignment.center,
                          child: NetworkImageErr(
                            image: widget.image,
                            circle: false,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                controls: FeedPlayerPortraitControls(
                  flickMultiManager: widget.flickMultiManager,
                  flickManager: flickManager,
                ),
              ),
            ),
          ),
        ));
  }
}
