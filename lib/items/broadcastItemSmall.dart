import 'package:allscope/models/broadcast.dart';
import 'package:allscope/models/streamStates.dart';
import 'package:allscope/ui/appColors.dart';
import 'package:allscope/utils/broadcastUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import '../ui/networkImageErr.dart';
import 'broadcastDetails.dart';

class BroadcastItemSmall extends StatefulWidget {
  final Broadcast broadcast;
  final ValueChanged<Broadcast> openStream;
  final ValueChanged<Broadcast> downloadBroadcast;
  final ValueChanged<Broadcast> shareBroadcast;
  final ValueChanged<Broadcast> openBroadcastDialog;
  final ValueChanged<Broadcast> deleteBroadcast;

  final ValueChanged<String> openUser;
  final bool downloaded;

  BroadcastItemSmall(
      {Key key,
      this.broadcast,
      this.openStream,
      this.downloadBroadcast,
      this.openBroadcastDialog,
      this.shareBroadcast,
      this.openUser,
      this.deleteBroadcast,
      this.downloaded})
      : super(key: key);

  @override
  _BroadcastItemSmallState createState() => _BroadcastItemSmallState();
}

class _BroadcastItemSmallState extends State<BroadcastItemSmall> {
  double widgetHeight;

  @override
  Widget build(BuildContext context) {
    if (widget.broadcast == null) return Container();

    Broadcast broadcast = widget.broadcast;
    widgetHeight = calculateWidgetHeight(broadcast);
    return Card(
        child: Container(
            height: widgetHeight,
            child: InkWell(
                onTap: () {
                  if (broadcast != null && widget.openStream != null) {
                    widget.openStream(broadcast);
                  }
                },
                onLongPress: () {
                  if (broadcast != null && widget.openBroadcastDialog != null) {
                    widget.openBroadcastDialog(broadcast);
                  }
                },
                child: Row(
                  children: [
                    Container(
                      width: ScreenUtil().setWidth(280),
                      height: widgetHeight,
                      child: NetworkImageErr(
                        circle: false,
                        image: broadcast.imageUrlMedium,
                        loadingSize: ScreenUtil().setWidth(15),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              if (broadcast.state == StreamStates.RUNNING &&
                                  !widget.downloaded)
                                BroadcastDetails.widthlessLiveItem(broadcast),
                              if (broadcast.state == StreamStates.ENDED)
                                BroadcastDetails.minuteItem(broadcast),
                              Spacer(),
                              buildActsRow(broadcast),
                            ],
                          ),
                          if (broadcast.status != null)
                            if (broadcast.status.isNotEmpty)
                              Padding(
                                padding:
                                    EdgeInsets.all(ScreenUtil().setWidth(16)),
                                child: Container(
                                  child: Linkify(
                                    maxLines: 3,
                                    onOpen: (link) async {
                                      if (await canLaunch(link.url)) {
                                        await launch(link.url);
                                      }
                                    },
                                    text: broadcast.status,
                                    style: TextStyle(
                                        fontSize: ScreenUtil().setSp(44)),
                                  ),
                                ),
                              ),
                          Spacer(),
                          Padding(
                              padding: EdgeInsets.all(ScreenUtil().setWidth(8)),
                              child: Row(
                                children: [
                                  NetworkImageErr(
                                    image: broadcast.profileImageUrl,
                                    width: getProfilePicSize(broadcast),
                                    height: getProfilePicSize(broadcast),
                                    circle: true,
                                  ),
                                  Expanded(
                                      child: Padding(
                                          padding: EdgeInsets.all(
                                              ScreenUtil().setWidth(8)),
                                          child: InkWell(
                                              onTap: () {
                                                if (widget.openUser != null &&
                                                    broadcast != null) {
                                                  widget.openUser(
                                                      broadcast.username);
                                                }
                                              },
                                              child: Column(
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
                                                          fontSize: getTextSize(
                                                              broadcast)),
                                                    ),
                                                  ),
                                                  Container(
                                                    child: Text(
                                                      '@' + broadcast.username,
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          fontSize: getTextSize(
                                                              broadcast)),
                                                    ),
                                                  ),
                                                ],
                                              )))),
                                ],
                              )),
                        ],
                      ),
                    ),
                  ],
                ))));
  }

  double calculateWidgetHeight(Broadcast broadcast) {
    if (broadcast.status != null) {
      if (broadcast.status.isNotEmpty) {
        return ScreenUtil().setHeight(416);
      } else {
        return ScreenUtil().setHeight(312);
      }
    } else {
      return ScreenUtil().setHeight(312);
    }
  }

  double getProfilePicSize(Broadcast broadcast) {
    if (BroadcastUtils().checkIfBroadcastStatusEmpty(broadcast)) {
      return ScreenUtil().setWidth(118);
    } else {
      return ScreenUtil().setWidth(72);
    }
  }

  double getTextSize(Broadcast broadcast) {
    if (BroadcastUtils().checkIfBroadcastStatusEmpty(broadcast)) {
      return ScreenUtil().setSp(44);
    } else {
      return ScreenUtil().setSp(34);
    }
  }

  String profilePhoto(String userId) {
    return 'http://twivatar.glitch.me/$userId';
  }

  Widget buildActsRow(Broadcast broadcast) {
    return (!widget.downloaded
        ? Row(
            children: [
              if (broadcast.state != StreamStates.RUNNING)
                BroadcastDetails.actButton(
                    Icons.cloud_download, AppColors.primaryColor, () {
                  if (broadcast != null && widget.downloadBroadcast != null) {
                    widget.downloadBroadcast(broadcast);
                  }
                }),
              BroadcastDetails.actButton(Icons.share, AppColors.primaryColor,
                  () {
                if (broadcast != null && widget.shareBroadcast != null) {
                  widget.shareBroadcast(broadcast);
                }
              }),
            ],
          )
        : BroadcastDetails.actButton(Icons.delete, Colors.red[600], () {
            if (broadcast != null && widget.deleteBroadcast != null) {
              widget.deleteBroadcast(broadcast);
            }
          }));
  }
}
