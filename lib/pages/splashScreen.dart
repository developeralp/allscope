import 'package:allscope/api/apiTool.dart';
import 'package:allscope/interfaces/apiCb.dart';
import 'package:allscope/lang/appLocalization.dart';
import 'package:allscope/models/langCodes.dart';
import 'package:allscope/services/nativeBackground.dart';
import 'package:allscope/ui/appColors.dart';
import 'package:allscope/ui/screenHelper.dart';
import 'package:allscope/ui/toaster.dart';
import 'package:allscope/utils/broadcastUtils.dart';
import 'package:allscope/utils/consts.dart';
import 'package:allscope/utils/orientationTool.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'homePage.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin, ApiCallback {
  Animation<double> animation;
  AnimationController controller;

  ApiTool apiTool;
  Animatable<Color> background;

  @override
  void initState() {
    super.initState();
    this.setup();
  }

  @override
  void dispose() {
    this.controller.dispose();
    super.dispose();
  }

  void setup() {
    OrientationTool.handle();

    controller =
        AnimationController(vsync: this, duration: Duration(seconds: 2));
    animation = CurvedAnimation(parent: controller, curve: Curves.easeIn);

    controller.forward().whenComplete(() {});

    background = TweenSequence<Color>(
      [
        TweenSequenceItem(
          weight: 1.0,
          tween: ColorTween(
            begin: AppColors.primaryDarkColor,
            end: AppColors.primaryColor,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    apiTool = ApiTool();

    Locale myLocale = Localizations.localeOf(context);
    apiTool.setup(this, myLocale.languageCode);

    ScreenHelper.init(context);

    return AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          return Scaffold(
            body: Container(
                color: Colors
                    .white /*background
                    .evaluate(AlwaysStoppedAnimation(controller.value))*/
                ,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 4,
                      child: Container(),
                    ),
                    Expanded(
                      flex: 5,
                      child: Column(
                        children: [
                          FadeTransition(
                            opacity: animation,
                            child: Text(
                              Consts.appName,
                              style: TextStyle(
                                  color: AppColors.primaryColor,
                                  fontSize: ScreenUtil().setSp(104),
                                  fontFamily: 'WorkSans',
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                          Padding(
                              padding:
                                  EdgeInsets.all(ScreenUtil().setHeight(100)),
                              child: CircularProgressIndicator(
                                backgroundColor: AppColors.primaryColor,
                              )),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: buildDevelopedBy(),
                    ),
                  ],
                )),
          );
        });
  }

  Widget alpAppsText() {
    return Text(
      'Alp Apps',
      style: TextStyle(
          color: Colors.black87,
          fontFamily: 'WorkSans',
          fontSize: ScreenUtil().setSp(44),
          fontWeight: FontWeight.w800),
    );
  }

  Widget developedByText() {
    return Text(
      AppLocalizations.instance.text('developed_by'),
      style: TextStyle(
          color: Colors.black87,
          fontSize: ScreenUtil().setSp(44),
          fontWeight: FontWeight.w300),
    );
  }

  Widget buildDevelopedBy() {
    Locale myLocale = Localizations.localeOf(context);

    if (myLocale.languageCode == LangCodes.turkish) {
      return FadeTransition(
        opacity: animation,
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          alpAppsText(),
          SizedBox(width: ScreenUtil().setWidth(12)),
          developedByText(),
        ]),
      );
    } else {
      return FadeTransition(
          opacity: animation,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              developedByText(),
              SizedBox(width: ScreenUtil().setWidth(12)),
              alpAppsText(),
            ],
          ));
    }
  }

  bool videoOpened = false;

  @override
  void onReady() async {
    if (mounted) {
      Uri deepLink;
      try {
        final PendingDynamicLinkData data =
            await FirebaseDynamicLinks.instance.getInitialLink();
        deepLink = data?.link;
      } catch (err) {
        //print('err occured : ' + err.toString());
      } finally {
        var result = await NativeBackground().checkNotifications();

        if (deepLink != null) {
          if (!videoOpened) {
            firebaseLinkBase(deepLink);
          }
        } else if (result != 0) {
          var resultParse = result;
          String type = resultParse['type'];
          String broadcastId = resultParse['broadcastId'];
          String channelId = resultParse['channelId'];

          if (type != null && !videoOpened) {
            if (type.isNotEmpty) {
              if (type == 'broadcast' && broadcastId != null) {
                if (broadcastId.isNotEmpty) {
                  videoOpened = true;
                  BroadcastUtils()
                      .onBroadcastFromNotification(context, broadcastId, () {
                    skip(false);
                  });
                }
              } else if (type == 'channel' && channelId != null) {
                if (channelId.isNotEmpty) {
                  videoOpened = true;
                  BroadcastUtils().openChannelId(context, channelId, () {
                    skip(false);
                  });
                }
              }
            }
          }
        } else {
          skip(true);
        }
      }
    }
  }

  void skip(bool show) {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => HomePage(
                  boolShowLoading: show,
                )));
  }

  void firebaseLinkBase(Uri uri) {
    videoOpened = true;
    BroadcastUtils().onDynamicLinkGetted(context, uri, () {
      skip(false);
    });
  }

  @override
  void onNetworkError() {
    Toaster.show('network_err');
  }
}
