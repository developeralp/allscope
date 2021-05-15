import 'package:allscope/items/channelItem.dart';
import 'package:allscope/items/userProfileItem.dart';
import 'package:allscope/lang/appLocalization.dart';
import 'package:allscope/models/broadcast.dart';
import 'package:allscope/models/channels.dart';
import 'package:allscope/models/streamStates.dart';
import 'package:allscope/ui/networkImageErr.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'appColors.dart';

class Dialogs {
  static void showBroadcastActs(
      BuildContext context,
      Broadcast broadcast,
      Function downloadBroadcast,
      Function shareBroadcast,
      Function viewProfile) {
    if (context == null ||
        broadcast == null ||
        downloadBroadcast == null ||
        shareBroadcast == null ||
        viewProfile == null) return;

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title:
                Text(AppLocalizations.instance.text('broadcast_dialog_title')),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (broadcast.state != StreamStates.RUNNING)
                  buildActItem(context, 'download', Icons.cloud_download, () {
                    downloadBroadcast();
                  }),
                buildActItem(context, 'share', Icons.share, () {
                  shareBroadcast();
                }),
                buildActItem(context, 'view_profile', Icons.person, () {
                  viewProfile();
                })
              ],
            ),
          );
        });
  }

  static Widget buildActItem(
      BuildContext context, String text, IconData icon, Function onTap) {
    return InkWell(
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
            child: Icon(icon, color: AppColors.primaryColor),
          ),
          Text(AppLocalizations.instance.text(text)),
        ],
      ),
      onTap: () {
        Navigator.of(context).pop();

        onTap();
      },
    );
  }

  static void showDownloadBroadcast(
      BuildContext context, Function broadcastBreak, GlobalKey key) {
    if (context == null || key == null) return;

    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext contex) {
          return AlertDialog(
            key: key,
            title: Text(AppLocalizations.instance.text('please_wait')),
            content: Row(
              children: [
                CircularProgressIndicator(
                  backgroundColor: AppColors.primaryColor,
                ),
                Padding(
                    padding: EdgeInsets.all(ScreenUtil().setWidth(12)),
                    child: Text(AppLocalizations.instance
                        .text('broadcast_downloading'))),
              ],
            ),
            actions: [
              FlatButton(
                child: Text(
                  AppLocalizations.instance.text('cancel'),
                  style: TextStyle(color: Colors.red[600]),
                ),
                onPressed: () {
                  if (broadcastBreak != null) {
                    broadcastBreak();
                    Navigator.pop(context);
                  }
                },
              )
            ],
          );
        });
  }

  static void askQuestion(BuildContext context, String text, Function onYes) {
    if (context == null || onYes == null || text == null) return;

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(AppLocalizations.instance.text('question')),
            content: Text(AppLocalizations.instance.text(text)),
            actions: [
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                  onYes();
                },
                child: Text(
                  AppLocalizations.instance.text('yes'),
                  style: TextStyle(color: AppColors.primaryColor),
                ),
              ),
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  AppLocalizations.instance.text('no'),
                  style: TextStyle(color: AppColors.primaryColor),
                ),
              )
            ],
          );
        });
  }

  static void showBroadcastNotification(BuildContext context, String title,
      String text, Broadcast broadcast, Function playBroadcast) {
    if (context == null || broadcast == null || playBroadcast == null) return;

    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(text),
                Padding(
                    padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
                    child: UserProfileItem(
                      broadcast: broadcast,
                      orientation: DeviceOrientation.portraitUp,
                    )),
                Container(
                  width: ScreenUtil().setWidth(640),
                  height: ScreenUtil().setHeight(480),
                  child: Stack(
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);

                          playBroadcast();
                        },
                        child: Container(
                          height: ScreenUtil().setHeight(480),
                          child: NetworkImageErr(
                            circle: false,
                            image: broadcast.imageUrlMedium,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);

                          playBroadcast();
                        },
                        child: Center(
                          child: Icon(
                            Icons.play_circle_filled,
                            color: Colors.white,
                            size: ScreenUtil().setWidth(144),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                    padding: EdgeInsets.all(ScreenUtil().setWidth(22)),
                    child: Text(broadcast.status)),
              ],
            ),
            actions: [
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  AppLocalizations.instance.text('not_interested'),
                  style: TextStyle(color: AppColors.primaryColor),
                ),
              ),
            ],
          );
        });
  }

  static void showChannelNotification(BuildContext context, String title,
      String text, ChannelBroadcasts channel, Function openChannel) {
    if (context == null || channel == null || openChannel == null) return;

    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  text,
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                SizedBox(
                  height: ScreenUtil().setHeight(48),
                ),
                ChannelItem(
                    channel: channel,
                    openChannel2: () {
                      Navigator.pop(context);
                      openChannel();
                    }),
              ],
            ),
            actions: [
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  AppLocalizations.instance.text('not_interested'),
                  style: TextStyle(color: AppColors.primaryColor),
                ),
              ),
            ],
          );
        });
  }
}
