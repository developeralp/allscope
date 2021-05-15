import 'package:allscope/models/broadcast.dart';

class UserBroadcasts {
  List<Broadcast> broadcasts;
  String cursor;

  UserBroadcasts({this.broadcasts, this.cursor});

  UserBroadcasts.fromJson(Map<String, dynamic> json) {
    if (json['broadcasts'] != null) {
      broadcasts = new List<Broadcast>();
      json['broadcasts'].forEach((v) {
        broadcasts.add(new Broadcast.fromJson(v));
      });
    }
    cursor = json['cursor'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.broadcasts != null) {
      data['broadcasts'] = this.broadcasts.map((v) => v.toJson()).toList();
    }
    data['cursor'] = this.cursor;
    return data;
  }
}
