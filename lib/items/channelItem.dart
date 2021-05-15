import 'package:allscope/lang/appLocalization.dart';
import 'package:allscope/models/channels.dart';
import 'package:allscope/ui/design.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../ui/appColors.dart';

class ChannelItem extends StatefulWidget {
  final ChannelBroadcasts channel;
  final ValueChanged<ChannelBroadcasts> openChannel;
  final Function openChannel2;

  ChannelItem({Key key, this.channel, this.openChannel, this.openChannel2})
      : super(key: key);

  @override
  _ChannelItemState createState() => _ChannelItemState();
}

class _ChannelItemState extends State<ChannelItem> {
  @override
  Widget build(BuildContext context) {
    if (widget.channel == null) return Container();

    ChannelBroadcasts channel = widget.channel;

    return Card(
      child: InkWell(
          onTap: () {
            if (widget.openChannel != null) {
              widget.openChannel(channel);
            } else if (widget.openChannel2 != null) {
              widget.openChannel2();
            }
          },
          child: Container(
            padding: EdgeInsets.all(ScreenUtil().setWidth(32)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                        child: Text(
                      channel.channel.name,
                      style: TextStyle(
                          fontSize: ScreenUtil().setSp(50),
                          fontWeight: FontWeight.w800),
                    )),
                    Container(
                      margin: EdgeInsets.all(ScreenUtil().setWidth(16)),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: AppColors.liveRed,
                          borderRadius: BorderRadius.circular(8)),
                      height: ScreenUtil().setHeight(Design.liveItemHeight),
                      child: Padding(
                          padding: EdgeInsets.all(ScreenUtil().setWidth(8)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                buildLiveText(channel),
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: ScreenUtil().setSp(36)),
                              ),
                            ],
                          )),
                    ),
                  ],
                ),
                Text(
                  channel.channel.description,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(42),
                  ),
                ),
              ],
            ),
          )),
    );
  }

  String buildLiveText(ChannelBroadcasts channel) {
    return NumberFormat.compact().format(channel.channel.nLive).toString() +
        ' ' +
        AppLocalizations.instance.text('stream_live');
  }
}
