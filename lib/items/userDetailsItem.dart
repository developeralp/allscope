import 'package:allscope/lang/appLocalization.dart';
import 'package:allscope/models/userDetails.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import '../ui/appColors.dart';
import '../ui/networkImageErr.dart';

class UserDetailsItem extends StatefulWidget {
  final UserDetails userDetails;

  UserDetailsItem({Key key, this.userDetails}) : super(key: key);

  @override
  _UserDetailsItemState createState() => _UserDetailsItemState();
}

class _UserDetailsItemState extends State<UserDetailsItem> {
  @override
  Widget build(BuildContext context) {
    return userDetailsItem();
  }

  Widget userDetailsItem() {
    User user = widget.userDetails.user;

    return Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Container(
          padding: EdgeInsets.only(
              top: ScreenUtil().setWidth(36),
              bottom: ScreenUtil().setWidth(36)),
          child: Column(children: [
            if (showTwitterId(user))
              Align(
                alignment: Alignment.bottomRight,
                child: Container(
                    margin: EdgeInsets.only(right: ScreenUtil().setWidth(36)),
                    child: InkWell(
                        onTap: () {
                          var url =
                              'https://twitter.com/${user.twitterScreenName}';
                          launch(url);
                        },
                        child: Image.asset(
                          'assets/images/twitter.png',
                          width: ScreenUtil().setWidth(82),
                        ))),
              ),
            NetworkImageErr(
              image: user.profileImageUrls.first.sslUrl,
              circle: true,
              width: ScreenUtil().setWidth(192),
            ),
            Container(
              padding: EdgeInsets.only(top: ScreenUtil().setWidth(8)),
              child: Text(
                user.displayName,
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: ScreenUtil().setSp(56)),
              ),
            ),
            if (showTwitterId(user))
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '@' + user.twitterScreenName,
                      style: TextStyle(
                          fontWeight: FontWeight.w300,
                          fontSize: ScreenUtil().setSp(44)),
                    ),
                    if (user.isTwitterVerified)
                      Icon(
                        Icons.verified_user,
                        size: ScreenUtil().setWidth(44),
                        color: AppColors.twitterBlue,
                      ),
                  ],
                ),
              ),
            Container(
              padding: EdgeInsets.only(top: ScreenUtil().setWidth(32)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite,
                    size: ScreenUtil().setWidth(52),
                    color: AppColors.liveRed,
                  ),
                  Text(
                    user.nHearts.toString(),
                    style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: ScreenUtil().setSp(48)),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: ScreenUtil().setWidth(52)),
              child: Linkify(
                onOpen: (link) async {
                  if (await canLaunch(link.url)) {
                    await launch(link.url);
                  }
                },
                text: user.description,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: ScreenUtil().setSp(46)),
              ),
            ),
            Container(
                padding: EdgeInsets.only(top: ScreenUtil().setWidth(36)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(ScreenUtil().setWidth(8)),
                      child: Column(
                        children: [
                          Text(AppLocalizations.instance.text('followers'),
                              style: TextStyle(fontWeight: FontWeight.w600)),
                          Text(user.nFollowers.toString()),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(ScreenUtil().setWidth(8)),
                      child: Column(
                        children: [
                          Text(AppLocalizations.instance.text('following'),
                              style: TextStyle(fontWeight: FontWeight.w600)),
                          Text(user.nFollowing.toString()),
                        ],
                      ),
                    ),
                  ],
                )),
          ]),
        ));
  }

  bool showTwitterId(User user) {
    if (user.twitterScreenName == null) return false;
    if (user.twitterScreenName.isEmpty) return false;

    return true;
  }
}
