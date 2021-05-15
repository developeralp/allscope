import 'package:allscope/models/channels.dart';

class StreamsDb {
  static final StreamsDb streamsDb = StreamsDb._internal();

  factory StreamsDb() {
    return streamsDb;
  }

  StreamsDb._internal();

  Channels channels;
  int apiSource;
}
