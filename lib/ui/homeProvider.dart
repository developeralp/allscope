import 'package:allscope/models/channels.dart';
import 'package:flutter/material.dart';

class HomeProvider extends InheritedWidget {
  final Widget child;
  final List<ChannelBroadcasts> channels;

  HomeProvider({this.child, this.channels});

  @override
  bool updateShouldNotify(HomeProvider oldWidget) {
    return true;
  }

  static HomeProvider of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<HomeProvider>();
}
