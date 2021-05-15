import 'package:allscope/models/broadcast.dart';
import 'package:allscope/ui/networkImageErr.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UserProfileItem extends StatefulWidget {
  final Broadcast broadcast;
  final DeviceOrientation orientation;
  UserProfileItem({Key key, this.broadcast, this.orientation})
      : super(key: key);

  @override
  _UserProfileItemState createState() => _UserProfileItemState();
}

class _UserProfileItemState extends State<UserProfileItem> {
  @override
  Widget build(BuildContext context) {
    double fontSize = (widget.orientation == DeviceOrientation.landscapeLeft
        ? ScreenUtil().setSp(24)
        : ScreenUtil().setSp(44));

    double imgSize = (widget.orientation == DeviceOrientation.landscapeLeft
        ? ScreenUtil().setWidth(72)
        : ScreenUtil().setWidth(136));

    double fontSizeSmall =
        (widget.orientation == DeviceOrientation.landscapeLeft
            ? ScreenUtil().setSp(22)
            : ScreenUtil().setSp(36));

    Broadcast broadcast = widget.broadcast;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (broadcast.profileImageUrl != null)
            NetworkImageErr(
              image: broadcast.profileImageUrl,
              circle: true,
              width: imgSize,
            ),
          Padding(
            padding: EdgeInsets.only(right: ScreenUtil().setWidth(12)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (broadcast.userDisplayName != null)
                  Container(
                    padding: EdgeInsets.only(top: ScreenUtil().setWidth(8)),
                    child: Text(
                      broadcast.userDisplayName,
                      style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: fontSize),
                    ),
                  ),
                if (broadcast.twitterUsername != null)
                  Container(
                    child: Text(
                      '@' + broadcast.twitterUsername,
                      style: TextStyle(
                          fontWeight: FontWeight.w300, fontSize: fontSizeSmall),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
