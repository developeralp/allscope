import 'package:allscope/ui/networkImageLoader.dart';
import 'package:flutter/material.dart';

import 'appColors.dart';

class NetworkImageErr extends StatefulWidget {
  final String image;
  final double width;
  final double height;
  final double loadingSize;
  final bool circle;

  NetworkImageErr(
      {Key key,
      this.image,
      this.width,
      this.height,
      this.circle,
      this.loadingSize})
      : super(key: key);

  @override
  _NetworkImageErrState createState() => _NetworkImageErrState();
}

class _NetworkImageErrState extends State<NetworkImageErr> {
  Widget _widget;

  @override
  void initState() {
    super.initState();
    this.checkWidget();
  }

  @override
  Widget build(BuildContext context) {
    return _widget;
  }

  void loadImage(String url) async {
    try {
      var netImg = NetworkImageLoader(url);
      var res = await netImg.load();
      if (mounted) {
        setState(() {
          if (widget.circle) {
            _widget = ClipOval(
              child: Image(
                image: MemoryImage(res),
                width: widget.width,
                height: widget.height,
                fit: BoxFit.cover,
              ),
            );
          } else {
            _widget = ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(6)),
              child: Image(
                image: MemoryImage(res),
                fit: BoxFit.cover,
                //  height: widget.height,
              ),
            );
          }
        });
      }
    } catch (err) {
      if (mounted) {
        setState(() {
          if (widget.circle) {
            _widget = Center(
                child: Icon(
              Icons.person_pin,
              size: (widget.width != null ? widget.width : widget.height),
              color: AppColors.primaryColor,
            ));
          } else {
            _widget = Center(
                child: Icon(
              Icons.error,
              size: (widget.width != null ? widget.width : widget.height),
              color: Colors.red,
            ));
          }
        });
      }
    }
  }

  void checkWidget() {
    _widget = SizedBox(
      width: widget.width,
    );

    if (_widget is SizedBox) {
      loadImage(widget.image);
    }
  }
}
