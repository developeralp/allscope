import 'package:allscope/models/channels.dart';

class BroadcastList {
  List<Broadcasts> broadcasts;

  BroadcastList({this.broadcasts});

  BroadcastList.fromJson(Map<String, dynamic> json) {
    if (json['Broadcasts'] != null) {
      broadcasts = new List<Broadcasts>();
      json['Broadcasts'].forEach((v) {
        broadcasts.add(new Broadcasts.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.broadcasts != null) {
      data['Broadcasts'] = this.broadcasts.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
