import 'package:allscope/api/apiService.dart';
import 'package:allscope/interfaces/homePageCb.dart';
import 'package:allscope/lang/appLocalization.dart';
import 'package:allscope/models/analytics.dart';
import 'package:allscope/models/broadcastPageTypes.dart';
import 'package:allscope/models/channels.dart';
import 'package:allscope/models/streamStates.dart';
import 'package:allscope/pages/broadcastsPage.dart';
import 'package:allscope/pages/channelsPage.dart';
import 'package:allscope/services/nativeBackground.dart';
import 'package:allscope/ui/design.dart';
import 'package:allscope/ui/dialogs.dart';
import 'package:allscope/ui/homeProvider.dart';
import 'package:allscope/ui/screenHelper.dart';
import 'package:allscope/ui/toaster.dart';
import 'package:allscope/utils/broadcastUtils.dart';
import 'package:allscope/utils/consts.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomePage extends StatefulWidget {
  final boolShowLoading;

  const HomePage({Key key, this.boolShowLoading}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver, HomePageCb {
  final List<Tab> tabs = <Tab>[
    Tab(icon: Icon(Icons.live_tv)),
    Tab(icon: Icon(Icons.cast)),
    Tab(icon: Icon(Icons.cloud_download))
  ];

  TabController tabController;
  BroadcastsPage broadcastsPage;
  ChannelsPage channelsPage;
  BroadcastsPage downloadsPage;

  TextEditingController searchQueryController = TextEditingController();
  bool isSearching = false;
  String searchQuery = "Search query";
  bool interstitialReady = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    this.setup();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    this.tabController.dispose();
    super.dispose();
  }

  Icon actionIcon = Icon(Icons.search);
  GlobalKey<HomePageState> ourKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    ScreenHelper.init(context);

    return HomeProvider(
      child: Scaffold(
        key: ourKey,
        appBar: AppBar(
          title: isSearching ? buildSearchField() : buildTitle(context),
          bottom: TabBar(controller: tabController, tabs: tabs),
          actions: buildActions(),
        ),
        body: TabBarView(
          controller: tabController,
          children: [broadcastsPage, channelsPage, downloadsPage],
        ),
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (broadcastsKey != null) {
      if (broadcastsKey.currentState != null) {
        broadcastsKey.currentState.didChangeAppLifecycleState(state);
      }
    }
    if (downloadsKey != null) {
      if (downloadsKey.currentState != null) {
        downloadsKey.currentState.didChangeAppLifecycleState(state);
      }
    }
  }

  void setup() {
    setupNative();
    initDynamicLinks();
    prepareLists();
  }

  void setupNative() {
    NativeBackground().homePageCb = this;
  }

  GlobalKey<ChannelsPageState> channelsKey = GlobalKey();
  GlobalKey<BroadcastsPageState> broadcastsKey = GlobalKey();
  GlobalKey<BroadcastsPageState> downloadsKey = GlobalKey();

  void prepareLists() {
    tabController = TabController(vsync: this, length: tabs.length);
    broadcastsPage = BroadcastsPage(
      type: BroadcastPageTypes.BROADCASTS,
      key: broadcastsKey,
      openDownloadsPage: openDownloadsPage,
      boolShowLoading: widget.boolShowLoading,
    );
    channelsPage = ChannelsPage(key: channelsKey);
    downloadsPage = BroadcastsPage(
        key: downloadsKey, type: BroadcastPageTypes.SAVED_BROADCASTS);
  }

  void pauseVideos() {
    if (broadcastsKey != null && tabController.index == 0) {
      if (broadcastsKey.currentState != null) {
        broadcastsKey.currentState.pauseVideos();
      }
    }
  }

  void refreshBroadcasts() {
    if (broadcastsKey != null) {
      if (broadcastsKey.currentState != null && tabController.index == 0) {
        broadcastsKey.currentState.refreshBroadcasts();
      }
    }
  }

  void openDownloadsPage() {
    if (mounted && downloadsPage != null && tabController != null) {
      if (tabController.index != tabs.length) {
        tabController.animateTo(tabs.length);
      }
    }
  }

  Widget buildSearchField() {
    return TextField(
      controller: searchQueryController,
      autofocus: true,
      decoration: InputDecoration(
        hintText: AppLocalizations.instance.text('search_streams'),
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.white30),
      ),
      style: TextStyle(
        color: Colors.white,
      ),
      onSubmitted: (query) => searchBroadcasts(query),
    );
  }

  Widget buildTitle(BuildContext context) {
    return Text(Consts.appName,
        style: TextStyle(
            fontSize: ScreenUtil().setSp(Design.appTitleSp), //64
            fontFamily: 'WorkSans',
            fontWeight: FontWeight.w600));
  }

  List<Widget> buildActions() {
    if (isSearching) {
      return <Widget>[
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            pauseVideos();

            if (searchQueryController == null ||
                searchQueryController.text.isEmpty) {
              Navigator.pop(context);
              return;
            }
            clearSearchQuery();
          },
        ),
      ];
    } else {
      return <Widget>[
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: startSearch,
        ),
      ];
    }
  }

  void startSearch() {
    ModalRoute.of(context)
        .addLocalHistoryEntry(LocalHistoryEntry(onRemove: stopSearching));

    setState(() {
      isSearching = true;
    });
  }

  void searchBroadcasts(String query) {
    if (query == null) return;
    if (query.isEmpty) return;

    pauseVideos();

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => BroadcastsPage(
                  type: BroadcastPageTypes.SEARCH_BROADCASTS,
                  search: query,
                )));
    stopSearching();
  }

  void stopSearching() {
    clearSearchQuery();

    setState(() {
      isSearching = false;
    });
  }

  void clearSearchQuery() {
    setState(() {
      searchQueryController.clear();
      // updateSearchQuery("");
    });
  }

  void initDynamicLinks() async {
    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData dynamicLink) async {
          final Uri deepLink = dynamicLink?.link;

          pauseVideos();

          BroadcastUtils().onDynamicLinkGetted(context, deepLink, () {
            refreshBroadcasts();
          });
        },
        onError: (OnLinkErrorException e) async {});
  }

  void playBroadcastFromNotification(String broadcastId) {
    if (broadcastId == null) return;
    if (broadcastId.isEmpty) return;
    BroadcastUtils().onBroadcastFromNotification(context, broadcastId, () {});
  }

  @override
  void setNotifBroadcastId(
      String title, String text, String _broadcastId) async {
    if (_broadcastId == null) return;
    if (_broadcastId.isEmpty) return;

    Toaster.show('please_wait');
    ApiService().getStream(_broadcastId, (value) {
      if (value == null) return;
      pauseVideos();

      Dialogs.showBroadcastNotification(context, title, text, value.broadcast,
          () {
        var now = DateTime.now();

        FirebaseAnalytics().logEvent(
            name: Analytics.playBroadcastNotification,
            parameters: {
              'state': (value.broadcast.state == StreamStates.RUNNING
                  ? 'live'
                  : 'replay')
            });

        BroadcastUtils().play(context, value.broadcast, () {
          onStreamFinishedWatching(now);
        });
      });
    }, true);
  }

  @override
  void setNotifChannelId(String title, String text, String _channelId) {
    if (_channelId == null) return;
    if (_channelId.isEmpty) return;

    ChannelBroadcasts channelSearch =
        BroadcastUtils().findChannelById(_channelId);

    if (channelSearch != null) {
      Toaster.show('please_wait');
      pauseVideos();

      Dialogs.showChannelNotification(
        context,
        title,
        text,
        channelSearch,
        () {
          FirebaseAnalytics().logEvent(name: Analytics.openChannelNotification);

          BroadcastUtils().openChannel(context, channelSearch);
        },
      );
    }
  }

  void onStreamFinishedWatching(var now) {
    var end = DateTime.now();

    int secondsDifference = end.difference(now).inSeconds;
    if (secondsDifference >= Consts.refreshListDuration) {
      this.refreshBroadcasts();
    }
  }
}
