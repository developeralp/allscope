import 'package:allscope/items/broadcastDetails.dart';
import 'package:allscope/models/broadcast.dart';
import 'package:allscope/ui/design.dart';
import 'package:allscope/models/streamStates.dart';
import 'package:allscope/ui/appColors.dart';
import 'package:allscope/utils/broadcastUtils.dart';
import 'package:allscope/video/flickMultiManager.dart';
import 'package:allscope/video/flickMultiPlayer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import '../ui/networkImageErr.dart';

class BroadcastItem extends StatefulWidget {
  final Broadcast broadcast;
  final ValueChanged<Broadcast> openStream;
  final ValueChanged<String> openUser;
  final FlickMultiManager flickMultiManager;
  final bool lastLiveStream;
  final Function shareBroadcast;

  BroadcastItem(
      {Key key,
      this.broadcast,
      this.openStream,
      this.openUser,
      this.flickMultiManager,
      this.lastLiveStream,
      this.shareBroadcast})
      : super(key: key);

  @override
  _BroadcastItemState createState() => _BroadcastItemState();
}

class _BroadcastItemState extends State<BroadcastItem> {
  @override
  Widget build(BuildContext context) {
    if (widget.broadcast == null) return Container();
    if (widget.flickMultiManager == null) return Container();

    Broadcast broadcast = widget.broadcast;

    return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Stack(
              children: <Widget>[
                Container(
                  height: ScreenUtil().setHeight(Design.videoHeight), //640
                  alignment: Alignment.center,
                  child: buildVideoPlayer(broadcast),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (broadcast.state == StreamStates.RUNNING)
                      BroadcastDetails.liveItem(broadcast),
                    if (broadcast.nTotalWatching != null)
                      if (broadcast.nTotalWatching != 0)
                        BroadcastDetails.watchingItem(broadcast),
                  ],
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(ScreenUtil().setWidth(25)),
              child: Column(
                children: [
                  if (broadcast.profileImageUrl != null)
                    if (broadcast.profileImageUrl.isNotEmpty)
                      Column(
                        children: [
                          Row(
                            children: [
                              NetworkImageErr(
                                image: broadcast.profileImageUrl,
                                width: ScreenUtil().setWidth(124),
                                height: ScreenUtil().setWidth(124),
                                circle: true,
                                loadingSize: ScreenUtil().setWidth(60),
                              ),
                              Expanded(
                                child: Padding(
                                    padding: EdgeInsets.all(
                                        ScreenUtil().setWidth(8)),
                                    child: GestureDetector(
                                      onTap: () {
                                        if (widget.openUser != null &&
                                            broadcast != null) {
                                          widget.openUser(broadcast.username);
                                        }
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Container(
                                                child: Text(
                                                  broadcast.userDisplayName,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: ScreenUtil()
                                                          .setSp(44)),
                                                ),
                                              ),
                                              Container(
                                                child: Text(
                                                  '@' + broadcast.username,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: ScreenUtil()
                                                          .setSp(44)),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Spacer(),
                                          BroadcastDetails.actButton2(
                                              Icons.share,
                                              AppColors.primaryColor, () {
                                            if (broadcast != null &&
                                                widget.shareBroadcast != null) {
                                              widget.shareBroadcast(broadcast);
                                            }
                                          }),
                                        ],
                                      ),
                                    )),
                              ),
                            ],
                          ),
                        ],
                      ),
                  if (broadcast.status != null)
                    if (broadcast.status.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.all(
                                          ScreenUtil().setWidth(16)),
                                      child: Container(
                                        child: Linkify(
                                          maxLines: 4,
                                          onOpen: (link) async {
                                            if (await canLaunch(link.url)) {
                                              await launch(link.url);
                                            }
                                          },
                                          text: broadcast.status,
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize:
                                                  ScreenUtil().setSp(44)), //44
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                ],
              ),
            ),
          ],
        ));
  }

  String profilePhoto(String userId) {
    return 'http://twivatar.glitch.me/$userId';
  }

  Widget buildVideoPlayer(Broadcast broadcast) {
    return broadcast.stream == null
        ? InkWell(
            onTap: () {
              if (widget.openStream != null && broadcast != null)
                widget.openStream(broadcast);
            },
            child: NetworkImageErr(
              image: broadcast.imageUrl,
              circle: false,
            ))
        : FlickMultiPlayer(
            url: BroadcastUtils().getHlsUrl(broadcast.stream),
            flickMultiManager: widget.flickMultiManager,
            image: broadcast.imageUrl,
            lastOne: widget.lastLiveStream,
            openStream: () {
              if (widget.openStream != null && broadcast != null) {
                widget.openStream(broadcast);
              }
            },
          );
  }
}
