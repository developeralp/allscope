import 'package:allscope/lang/appLocalization.dart';
import 'package:flutter/material.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'flickMultiManager.dart';

class FeedPlayerPortraitControls extends StatelessWidget {
  const FeedPlayerPortraitControls(
      {Key key, this.flickMultiManager, this.flickManager})
      : super(key: key);

  final FlickMultiManager flickMultiManager;
  final FlickManager flickManager;

  @override
  Widget build(BuildContext context) {
    /* FlickDisplayManager displayManager =
        Provider.of<FlickDisplayManager>(context);*/
    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.symmetric(
          horizontal: ScreenUtil().setWidth(60),
          vertical: ScreenUtil().setWidth(60)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          /*Expanded(
            child: FlickToggleSoundAction(
              toggleMute: () {
                flickMultiManager.toggleMute();
                displayManager.handleShowPlayerControls();
              },
              child: FlickSeekVideoAction(
                child: Center(child: FlickVideoBuffer()),
              ),
            ),
          ),*/
          if (flickManager.flickVideoManager.isVideoEnded ||
              flickManager.flickVideoManager.errorInVideo)
            Positioned.fill(
                child: Center(
              child: Text(
                AppLocalizations.instance.text('stream_ended'),
                style: TextStyle(fontSize: ScreenUtil().setSp(38)),
              ),
            )),

          /*FlickAutoHideChild(
            autoHide: true,
            showIfVideoNotInitialized: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: FlickSoundToggle(
                    toggleMute: () => flickMultiManager.toggleMute(),
                    color: Colors.white,
                  ),
                ),
                // FlickFullScreenToggle(),
              ],
            ),
          ),*/
        ],
      ),
    );
  }
}
