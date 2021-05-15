import 'package:allscope/items/broadcastDetails.dart';
import 'package:allscope/items/userProfileItem.dart';
import 'package:allscope/lang/appLocalization.dart';
import 'package:allscope/models/broadcast.dart';
import 'package:allscope/models/streamStates.dart';
import 'package:allscope/ui/appColors.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class VideoPlayerControls extends StatefulWidget {
  final Broadcast broadcast;
  final DeviceOrientation orientation;

  VideoPlayerControls({Key key, this.broadcast, this.orientation})
      : super(key: key);

  @override
  _VideoPlayerControlsState createState() => _VideoPlayerControlsState();
}

class _VideoPlayerControlsState extends State<VideoPlayerControls> {
  @override
  Widget build(BuildContext context) {
    if (widget.orientation == null || widget.broadcast == null)
      return Container();

    DeviceOrientation orientation = widget.orientation;
    Broadcast broadcast = widget.broadcast;

    FlickVideoManager flickVideoManager =
        Provider.of<FlickVideoManager>(context);

    double fontSize = (orientation == DeviceOrientation.landscapeLeft
        ? ScreenUtil().setSp(24)
        : ScreenUtil().setSp(44));

    double fontSizeStatus = (orientation == DeviceOrientation.landscapeLeft
        ? ScreenUtil().setSp(26)
        : ScreenUtil().setSp(48));

    double biggerControl = (orientation == DeviceOrientation.landscapeLeft
        ? ScreenUtil().setWidth(92)
        : ScreenUtil().setWidth(144));

    double liveWidth =
        (orientation == DeviceOrientation.landscapeLeft ? 145 : 160);
    double liveHeight =
        (orientation == DeviceOrientation.landscapeLeft ? 180 : 80);
    double liveFont =
        (orientation == DeviceOrientation.landscapeLeft ? 22 : 34);

    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: FlickAutoHideChild(
            child: Container(color: Colors.black38),
          ),
        ),
        if (broadcast != null)
          if (broadcast.status != null)
            Positioned.fill(
              child: FlickAutoHideChild(
                child: Padding(
                  padding: EdgeInsets.all(ScreenUtil().setWidth(32)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          UserProfileItem(
                            broadcast: broadcast,
                            orientation: orientation,
                          ),
                          if (broadcast.state == StreamStates.RUNNING)
                            BroadcastDetails.liveItemStream(
                                broadcast, liveWidth, liveHeight, liveFont),
                        ],
                      ),
                      Text(
                        broadcast.status,
                        style: TextStyle(fontSize: fontSizeStatus),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        if (flickVideoManager.isVideoEnded || flickVideoManager.errorInVideo)
          Positioned.fill(
              top: ScreenUtil().setHeight(320),
              child: Center(
                child: Text(
                  AppLocalizations.instance.text('stream_ended'),
                  style: TextStyle(fontSize: ScreenUtil().setSp(48)),
                ),
              )),
        buildPlayPauseControls(flickVideoManager, biggerControl),
        if (broadcast.state != StreamStates.RUNNING)
          Positioned.fill(
            child: FlickAutoHideChild(
              child: Padding(
                padding: EdgeInsets.all(ScreenUtil().setWidth(32)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            FlickCurrentPosition(
                              fontSize: fontSize,
                            ),
                            Text(
                              ' / ',
                              style: TextStyle(
                                  color: Colors.white, fontSize: fontSize),
                            ),
                            FlickTotalDuration(
                              fontSize: fontSize,
                            ),
                          ],
                        ),
                        Expanded(
                          child: Container(),
                        ),
                      ],
                    ),
                    FlickVideoProgressBar(
                      flickProgressBarSettings: FlickProgressBarSettings(
                        height: ScreenUtil().setHeight(32),
                        handleRadius: 6,
                        curveRadius: 40,
                        backgroundColor: Colors.white24,
                        bufferedColor: Colors.white38,
                        playedColor: AppColors.primaryDarkColor,
                        handleColor: AppColors.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget buildPlayPauseControls(
      FlickVideoManager flickVideoManager, double biggerControl) {
    if (widget.broadcast.state == StreamStates.RUNNING) {
      return _buildForLive(flickVideoManager, biggerControl);
    } else {
      return _buildForReplay(flickVideoManager, biggerControl);
    }
  }

  Widget _buildForLive(
      FlickVideoManager flickVideoManager, double biggerControl) {
    return Positioned.fill(
      child: FlickShowControlsAction(
        child: Center(
          child: flickVideoManager.nextVideoAutoPlayTimer != null
              ? FlickAutoPlayCircularProgress(
                  colors: FlickAutoPlayTimerProgressColors(
                    backgroundColor: Colors.white30,
                    color: AppColors.primaryColor,
                  ),
                )
              : FlickAutoHideChild(
                  child: Visibility(
                      visible: flickVideoManager.isVideoInitialized,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.all(ScreenUtil().setWidth(32)),
                            child: FlickPlayToggle(size: biggerControl),
                          ),
                        ],
                      )),
                ),
        ),
      ),
    );
  }

  Widget _buildForReplay(
      FlickVideoManager flickVideoManager, double biggerControl) {
    return Positioned.fill(
      child: FlickShowControlsAction(
        child: FlickSeekVideoAction(
          child: Center(
            child: flickVideoManager.nextVideoAutoPlayTimer != null
                ? FlickAutoPlayCircularProgress(
                    colors: FlickAutoPlayTimerProgressColors(
                      backgroundColor: Colors.white30,
                      color: AppColors.primaryColor,
                    ),
                  )
                : FlickAutoHideChild(
                    child: Visibility(
                        visible: flickVideoManager.isVideoInitialized,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Padding(
                              padding:
                                  EdgeInsets.all(ScreenUtil().setWidth(32)),
                              child: FlickPlayToggle(size: biggerControl),
                            ),
                          ],
                        )),
                  ),
          ),
        ),
      ),
    );
  }
}
