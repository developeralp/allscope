import 'package:allscope/api/apiService.dart';
import 'package:allscope/models/broadcast.dart';
import 'package:allscope/models/listItem.dart';
import 'package:allscope/models/userBroadcasts.dart';
import 'package:allscope/models/userDetails.dart';
import 'package:allscope/items/broadcastItemSmall.dart';
import 'package:allscope/ui/design.dart';
import 'package:allscope/ui/toaster.dart';
import 'package:allscope/items/userDetailsItem.dart';
import 'package:allscope/utils/broadcastUtils.dart';
import 'package:allscope/utils/consts.dart';
import 'package:allscope/utils/orientationTool.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UserPage extends StatefulWidget {
  final UserDetails userDetails;

  UserPage({Key key, this.userDetails}) : super(key: key);

  @override
  UserPageState createState() => UserPageState();
}

class UserPageState extends State<UserPage> {
  List<ListItem> list;

  @override
  void initState() {
    super.initState();
    OrientationTool.handle();

    this.setup();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.userDetails == null) return Container();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.userDetails.user.displayName,
          style: TextStyle(fontSize: ScreenUtil().setSp((Design.appTitleSp2))),
        ),
      ),
      body: ListView.builder(
          padding: EdgeInsets.all(ScreenUtil().setWidth(32)),
          itemCount: list.length,
          itemBuilder: (BuildContext context, int index) {
            ListItem item = list[index];
            if (item is UserDetails) {
              return UserDetailsItem(
                userDetails: item,
              );
            } else if (item is Broadcast) {
              return BroadcastItemSmall(
                broadcast: item,
                openStream: openStream,
                downloaded: false,
              );
            }
            return Container();
          }),
    );
  }

  void setup() {
    list = List();
    list.add(widget.userDetails);
    checkSessionId();
  }

  void checkSessionId() {
    Toaster.show('please_wait');
    ApiService().checkSessionId(() {
      getUserBroadcasts();
    });
  }

  void getUserBroadcasts() async {
    if (widget.userDetails == null) return;
    if (widget.userDetails.user == null) return;

    Toaster.show('broadcasts_loading');

    UserBroadcasts userBroadcasts =
        await ApiService().getUserBroadcasts(widget.userDetails.user.id, true);

    if (userBroadcasts != null) {
      if (userBroadcasts.broadcasts != null) {
        if (mounted) {
          setState(() {
            list.addAll(userBroadcasts.broadcasts);
          });
        } else {
          list.addAll(userBroadcasts.broadcasts);
        }
      }
    }
  }

  void openStream(Broadcast broadcast) {
    var now = DateTime.now();

    BroadcastUtils().play(context, broadcast, () {
      onStreamFinishedWatching(now);
    });
  }

  void onStreamFinishedWatching(var now) {
    var end = DateTime.now();

    //Toaster.show(end.difference(now).inSeconds.toString());

    int secondsDifference = end.difference(now).inSeconds;
    if (secondsDifference >= Consts.refreshListDuration) {
      this.getUserBroadcasts();
    }
  }
}
