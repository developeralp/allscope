import 'dart:io';

import 'package:allscope/api/apiService.dart';
import 'package:allscope/db/cachedImages.dart';
import 'package:allscope/db/streamsDb.dart';
import 'package:allscope/io/files.dart';
import 'package:allscope/io/ioTool.dart';
import 'package:allscope/items/broadcastItemSmall.dart';
import 'package:allscope/lang/appLocalization.dart';
import 'package:allscope/models/broadcast.dart';
import 'package:allscope/models/broadcastList.dart';
import 'package:allscope/models/broadcastPageTypes.dart';
import 'package:allscope/models/channels.dart';
import 'package:allscope/models/savedBroadcasts.dart';
import 'package:allscope/models/streamStates.dart';
import 'package:allscope/services/nativeBackground.dart';
import 'package:allscope/ui/appColors.dart';
import 'package:allscope/items/broadcastItem.dart';
import 'package:allscope/ui/design.dart';
import 'package:allscope/ui/dialogs.dart';
import 'package:allscope/ui/toaster.dart';
import 'package:allscope/models/analytics.dart';
import 'package:allscope/utils/broadcastUtils.dart';
import 'package:allscope/utils/consts.dart';
import 'package:allscope/utils/listUtils.dart';
import 'package:allscope/utils/networkTool.dart';
import 'package:allscope/utils/orientationTool.dart';
import 'package:allscope/utils/permissions.dart';
import 'package:allscope/video/flickMultiManager.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';

class BroadcastsPage extends StatefulWidget {
  final Channel channel;
  final int type;
  final String search;
  final Function openDownloadsPage;
  final bool boolShowLoading;

  BroadcastsPage(
      {Key key,
      this.channel,
      this.type,
      this.search,
      this.openDownloadsPage,
      this.boolShowLoading = true})
      : super(key: key);

  @override
  BroadcastsPageState createState() => BroadcastsPageState();
}

class BroadcastsPageState extends State<BroadcastsPage> {
  List<Broadcast> broadcasts = List();
  List<Broadcast> liveStreams = List();
  List<Broadcast> liveStreams3 = List();
  bool downloadedInited = false;

  FlickMultiManager flickMultiManager;

  @override
  void initState() {
    super.initState();
    this.setup();
  }

  @override
  void dispose() {
    this.pauseVideos();
    super.dispose();
  }

  void setup() async {
    this.downloadedInited = false;
    await OrientationTool.handle();
    flickMultiManager = FlickMultiManager();
  }

  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      pauseVideos();
    }
    if (askedPermissions) {
      if (state == AppLifecycleState.resumed) {
        askedPermissions = false;
        bool acceptedAll = await Permissions.checkIfAccepted();

        if (acceptedAll) {
          if (widget.type == BroadcastPageTypes.SAVED_BROADCASTS) {
            prepareDownloadedBase();
          } else {
            if (tempDownload != null) {
              downloadBroadcastBase(tempDownload);
              tempDownload = null;
            }
          }
        } else {
          Toaster.show('perm_req_download');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    this.getBroadcasts();

    if (widget.type == BroadcastPageTypes.BROADCASTS ||
        widget.type == BroadcastPageTypes.USER_BROADCASTS ||
        widget.type == BroadcastPageTypes.SAVED_BROADCASTS) {
      return baseOfBroadcastsPage();
    } else {
      return WillPopScope(
          onWillPop: () {
            Navigator.pop(context, 100);
            return Future.value(false);
          },
          child: Scaffold(
              appBar: AppBar(
                title: Text(getTitleForCustom(),
                    style: TextStyle(
                        fontSize: ScreenUtil().setSp(Design.appTitleSp2))),
              ),
              body: baseOfBroadcastsPage()));
    }
  }

  String getTitleForCustom() {
    if (widget.type == BroadcastPageTypes.FROM_CHANNEL &&
        widget.channel != null) {
      return widget.channel.name;
    } else if (widget.type == BroadcastPageTypes.SEARCH_BROADCASTS &&
        widget.search != null) {
      return widget.search;
    }

    return Consts.appName;
  }

  Widget baseOfBroadcastsPage() {
    return broadcasts.length != 0
        ? (widget.type == BroadcastPageTypes.SAVED_BROADCASTS
            ? broadcastPageListView()
            : RefreshIndicator(
                color: AppColors.primaryColor,
                child: broadcastPageListView(),
                onRefresh: refreshBroadcasts,
              ))
        : buildEmptyWidget();
  }

  Widget broadcastPageListView() {
    return ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(ScreenUtil().setWidth(32)),
        itemCount: broadcasts.length,
        shrinkWrap: true,
        itemBuilder: (BuildContext context, int index) {
          Broadcast broadcast = broadcasts[index];
          if (fromLiveStreamsTop3(broadcast)) {
            int i2 = indexOfLastOneLives();
            return BroadcastItem(
              broadcast: broadcast,
              openStream: openStream,
              openUser: openUser,
              shareBroadcast: shareBroadcast,
              flickMultiManager: flickMultiManager,
              lastLiveStream: (i2 == index ? true : false),
            );
          } else {
            return BroadcastItemSmall(
              broadcast: broadcast,
              openStream: openStream,
              openUser: openUser,
              downloadBroadcast: downloadBroadcast,
              shareBroadcast: shareBroadcast,
              openBroadcastDialog: openBroadcastDialog,
              downloaded: (widget.type == BroadcastPageTypes.SAVED_BROADCASTS
                  ? true
                  : false),
              deleteBroadcast: deleteBroadcast,
            );
          }
        });
  }

  Widget buildEmptyWidget() {
    if (widget.type != BroadcastPageTypes.SAVED_BROADCASTS) {
      return Center(
        child: CircularProgressIndicator(
          backgroundColor: AppColors.primaryColor,
        ),
      );
    } else {
      return Center(
        child: Text(
          AppLocalizations.instance.text('broadcast_downloaded_not_exists'),
          style: TextStyle(
              fontSize: ScreenUtil().setSp(44), fontWeight: FontWeight.w600),
        ),
      );
    }
  }

  bool fromLiveStreamsTop3(Broadcast broadcast) {
    if (liveStreams3 == null) return false;
    if (broadcast == null) return false;

    bool value = false;

    for (Broadcast live in liveStreams3) {
      if (live.id == broadcast.id) {
        value = true;
        break;
      }
    }

    return value;
  }

  int indexOfLastOneLives() {
    if (broadcasts == null) return -1;
    if (broadcasts.length == 0) return -1;
    if (liveStreams3 == null) return -1;
    if (liveStreams3.length == 0) return -1;

    if (liveStreams3 != null) {
      Broadcast lastOne = liveStreams3[liveStreams3.length - 1];

      if (lastOne != null) {
        int pos = broadcasts.indexOf(lastOne);
        if (pos != -1 && pos != 0) {
          if (broadcasts[pos] != null) {
            return pos;
          }
        }
      }
    }

    return -1;
  }

  void pauseVideos() {
    if (flickMultiManager != null) {
      flickMultiManager.pause();
    }
  }

  void openUser(String userName) {
    BroadcastUtils()
        .openUserBroadcastPage(userName, flickMultiManager, context);
  }

  void openStream(Broadcast broadcast) async {
    if (broadcast == null) return;

    var now = DateTime.now();

    if (widget.type != BroadcastPageTypes.SAVED_BROADCASTS) {
      doAnalyticsPlay(broadcast);

      BroadcastUtils().play(context, broadcast, () {
        onStreamFinishedWatching(now);
      });
    } else {
      File saved = await IoTool.readFile(broadcast.id + Consts.videoFileExt);
      if (saved != null) {
        BroadcastUtils().playDownloaded(context, saved, broadcast, () {
          onStreamFinishedWatching(now);
        });
      } else {
        Toaster.show('broadcast_not_found');
      }
    }
  }

  void doAnalyticsPlay(Broadcast broadcast) {
    if (broadcast == null) return;
    FirebaseAnalytics().logEvent(name: Analytics.playBroadcast, parameters: {
      'from_page': getBroadcastPageTypeAsString(),
      'state': (broadcast.state == StreamStates.RUNNING ? 'live' : 'replay')
    });
  }

  String getBroadcastPageTypeAsString() {
    if (widget.type == 0) return "";

    String value = '';

    switch (widget.type) {
      case BroadcastPageTypes.BROADCASTS:
        value = 'broadcasts';
        break;
      case BroadcastPageTypes.FROM_CHANNEL:
        value = 'channel';
        break;
      case BroadcastPageTypes.USER_BROADCASTS:
        value = 'user';
        break;
      case BroadcastPageTypes.SEARCH_BROADCASTS:
        value = 'search';
        break;
    }

    return value;
  }

  void onStreamFinishedWatching(var now) {
    var end = DateTime.now();

    //Toaster.show(end.difference(now).inSeconds.toString());

    int secondsDifference = end.difference(now).inSeconds;
    if (secondsDifference >= Consts.refreshListDuration) {
      this.refreshBroadcasts();
    }
  }

  void openBroadcastDialog(Broadcast broadcast) {
    if (broadcast == null) return;

    Dialogs.showBroadcastActs(context, broadcast, () {
      downloadBroadcast(broadcast);
    }, () {
      shareBroadcast(broadcast);
    }, () {
      openUser(broadcast.username);
    });
  }

  Future<void> refreshBroadcasts() async {
    if (broadcasts == null) return;
    if (mounted) {
      setState(() {
        this.broadcasts.clear();
        this.liveStreams.clear();
        this.liveStreams3.clear();
      });
    }
    this.getBroadcasts();
  }

  void getBroadcasts() async {
    if (broadcasts == null) return;
    if (widget.type == null) return;
    if (widget.type != BroadcastPageTypes.SAVED_BROADCASTS) {
      if (broadcasts.length == 0) {
        if (widget.boolShowLoading) {
          //Toaster.show('broadcasts_loading');
        }

        getBroadcastsType(widget.type);
      }
    } else {
      if (!downloadedInited) {
        getBroadcastsType(widget.type);
      }
    }
  }

  void getBroadcastsType(int type) async {
    Channels channels = StreamsDb().channels;

    Locale myLocale = Localizations.localeOf(context);

    if (channels != null) {
      CachedImages.instance.clear();
      List<String> ids = List();

      switch (type) {
        case BroadcastPageTypes.BROADCASTS:
          ids = ListUtils().getBroadcastIds(channels);
          getBroadcastsBase(ids, myLocale.languageCode);
          break;

        case BroadcastPageTypes.FROM_CHANNEL:
          if (widget.channel == null) break;
          BroadcastList broadcastList = await ApiService()
              .getChannelsBroadcasts(widget.channel.cID, true);

          ids = ListUtils().getBroadcastIds2(broadcastList);
          getBroadcastsBase(ids, myLocale.languageCode);
          break;

        case BroadcastPageTypes.SEARCH_BROADCASTS:
          if (widget.search == null) break;

          getBroadcastsBaseSearch(widget.search, myLocale.languageCode);
          break;

        case BroadcastPageTypes.SAVED_BROADCASTS:
          prepareDownloadedBroadcasts();
          break;
      }
    } else {
      int result =
          await ApiService().tryTokenAndGetChannels(myLocale.languageCode);
      if (result == 200) {
        getBroadcasts();
      }
    }
  }

  void getBroadcastsBase(List<String> ids, String langCode) async {
    String idsPrepared = ids.join(',');

    List<Broadcast> list = await ApiService().getBroadcasts(idsPrepared, true);
    list = ListUtils().prepareLive(list, langCode);

    if (list != null) {
      if (mounted) {
        setState(() {
          list.sort((a, b) => a.live.compareTo(b.live));

          broadcasts = list.reversed.toList();
          liveStreams = broadcasts
              .where((item) => item.state == StreamStates.RUNNING)
              .toList();

          prepareLiveStreams3();

          prepareStreams();
        });
      }
    } else {
      Toaster.show('broadcast_list_empty');

      if (widget.type == BroadcastPageTypes.FROM_CHANNEL) {
        Navigator.pop(context);
      }
    }
  }

  void prepareLiveStreams3() {
    liveStreams3.clear();
    if (liveStreams == null) return;
    if (liveStreams.length == 0) return;

    for (int i = 0; i < liveStreams.length; i++) {
      if (i == 0 || i == 1 || i == 2) {
        this.liveStreams3.add(liveStreams[i]);
      }
    }
  }

  void getBroadcastsBaseSearch(String search, String langCode) async {
    if (search == null) return;
    if (search.isEmpty) return;

    List<Broadcast> list =
        await ApiService().searchBroadcasts(search, true, true);
    list = ListUtils().prepareLive(list, langCode);

    if (list != null) {
      if (mounted) {
        setState(() {
          list.sort((a, b) => a.live.compareTo(b.live));

          broadcasts = list.reversed.toList();
          liveStreams = broadcasts
              .where((item) => item.state == StreamStates.RUNNING)
              .toList();

          prepareStreams();
        });
      }
    } else {
      Toaster.show('broadcast_list_empty');
      Navigator.pop(context);
    }
  }

  void prepareStreams() {
    if (broadcasts == null) return;
    if (broadcasts.length == 0) return;

    for (Broadcast broadcast in broadcasts) {
      ApiService().getStream(broadcast.id, (stream) {
        Broadcast broadcastFound = broadcasts
            .where((element) => element.id == stream.broadcast.id)
            .first;

        if (broadcastFound != null) {
          int pos = broadcasts.indexOf(broadcastFound);
          if (pos != null) {
            if (broadcasts[pos] != null) {
              if (mounted) {
                setState(() {
                  broadcasts[pos].stream = stream;
                });
              } else {
                broadcasts[pos].stream = stream;
              }
            }
          }
        }
      }, true);
    }
  }

  bool askedPermissions = false;
  Broadcast tempDownload;

  void deleteBroadcast(Broadcast broadcast) {
    if (broadcast == null) return;

    if (widget.type == BroadcastPageTypes.SAVED_BROADCASTS) {
      BroadcastUtils().delete(context, broadcast, () {
        downloadedInited = false;
        prepareDownloadedBase();
      });
    }
  }

  void downloadBroadcast(Broadcast broadcast) async {
    if (broadcast == null) return;
    if (broadcast.stream == null) return;

    bool storagePerm = await Permissions.checkPermission(Permission.storage);

    if (storagePerm) {
      downloadBroadcastBase(broadcast);
    } else {
      await [Permission.storage].request();
      askedPermissions = true;
      tempDownload = broadcast;
    }
  }

  void downloadBroadcastBase(Broadcast broadcast) async {
    if (!NetworkTool.instance.networkAvailable) {
      Toaster.show('network_down_err');

      return;
    }

    String hlsUrl = BroadcastUtils().getHlsUrl(broadcast.stream);

    if (hlsUrl == null) return;

    Toaster.show('please_wait');

    if (hlsUrl.isNotEmpty) {
      if (!NativeBackground().downloading) {
        NativeBackground().download(broadcast, hlsUrl, () {});
      } else {
        Toaster.show('broadcast_down_one');
      }
    } else {
      Toaster.show('broadcast_cannot_download');
    }
  }

  void shareBroadcast(Broadcast broadcast) {
    if (broadcast == null) return;

    BroadcastUtils().share(broadcast);
  }

  void prepareDownloadedBroadcasts() async {
    bool storagePerm = await Permissions.checkPermission(Permission.storage);

    if (storagePerm) {
      prepareDownloadedBase();
    } else {
      try {
        await [Permission.storage].request();
        askedPermissions = true;
      } catch (err) {}
    }
  }

  void prepareDownloadedBase() async {
    bool exists = await IoTool.fileExists(Files.savedBroadcasts);

    List<Broadcast> newList = List();

    if (exists) {
      downloadedInited = true;
      SavedBroadcasts temp = await BroadcastUtils().readSavedBroadcastsFile();
      if (temp != null) {
        if (temp.broadcasts != null) {
          for (Broadcast broadcast in temp.broadcasts) {
            bool exists =
                await IoTool.fileExists(broadcast.id + Consts.videoFileExt);

            if (exists) {
              newList.add(broadcast);
            }
          }
          SavedBroadcasts temp2 = SavedBroadcasts();
          temp2.broadcasts = newList;
          BroadcastUtils().saveSavedBroadcast(temp2);

          var reversedList = newList.reversed.toList();

          if (mounted) {
            setState(() {
              this.broadcasts = reversedList;
            });
          } else {
            this.broadcasts = reversedList;
          }
        }
      }
    } else {
      await IoTool.checkDirectory();

      downloadedInited = true;
      SavedBroadcasts temp2 = SavedBroadcasts();
      temp2.broadcasts = newList;
      BroadcastUtils().saveSavedBroadcast(temp2);
    }
  }
}
