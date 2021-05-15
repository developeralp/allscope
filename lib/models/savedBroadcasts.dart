import 'package:allscope/models/broadcast.dart';

class SavedBroadcasts {
  List<Broadcast> broadcasts;

  SavedBroadcasts({this.broadcasts});

  SavedBroadcasts.fromJson(Map<String, dynamic> json) {
    if (json['broadcasts'] != null) {
      broadcasts = new List<Broadcast>();
      json['broadcasts'].forEach((v) {
        broadcasts.add(new Broadcast.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.broadcasts != null) {
      data['broadcasts'] = this.broadcasts.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
