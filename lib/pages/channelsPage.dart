import 'package:allscope/db/streamsDb.dart';
import 'package:allscope/models/channels.dart';
import 'package:allscope/items/channelItem.dart';
import 'package:allscope/utils/broadcastUtils.dart';
import 'package:allscope/utils/orientationTool.dart';
import 'package:flutter/material.dart';

class ChannelsPage extends StatefulWidget {
  ChannelsPage({Key key}) : super(key: key);

  @override
  ChannelsPageState createState() => ChannelsPageState();
}

class ChannelsPageState extends State<ChannelsPage> {
  List<ChannelBroadcasts> channels = List();

  @override
  void initState() {
    super.initState();
    OrientationTool.handle();
  }

  @override
  Widget build(BuildContext context) {
    this.initChannels();

    return ListView.builder(
        itemCount: channels.length,
        itemBuilder: (BuildContext ctxt, int index) {
          ChannelBroadcasts item = channels[index];

          return ChannelItem(channel: item, openChannel: openChannel);
        });
  }

  void initChannels() async {
    if (this.channels.length == 0) {
      Channels channels = StreamsDb().channels;
      if (channels != null && mounted) {
        setState(() {
          this.channels = channels.channelBroadcasts;
        });
      }
    }
  }

  void openChannel(ChannelBroadcasts channelBroadcasts) {
    BroadcastUtils().openChannel(context, channelBroadcasts);
  }
}
