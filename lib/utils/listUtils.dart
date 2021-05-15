import 'package:allscope/models/bannedWords.dart';
import 'package:allscope/models/broadcast.dart';
import 'package:allscope/models/broadcastList.dart';
import 'package:allscope/models/channels.dart';
import 'package:allscope/models/langCodes.dart';
import 'package:allscope/models/streamStates.dart';

class ListUtils {
  List<String> getBroadcastIds(Channels channels) {
    if (channels == null) return List();

    List<String> list = new List();

    for (ChannelBroadcasts channelBroadcasts in channels.channelBroadcasts) {
      if (channelBroadcasts != null) {
        for (Broadcasts broadcasts in channelBroadcasts.broadcasts) {
          list.add(broadcasts.bID);
        }
      }
    }

    return list;
  }

  List<String> getBroadcastIds2(BroadcastList broadcastList) {
    if (broadcastList == null) return List();
    if (broadcastList.broadcasts == null) return List();

    List<String> list = new List();

    for (Broadcasts broadcasts in broadcastList.broadcasts) {
      list.add(broadcasts.bID);
    }

    return list;
  }

  List<Broadcast> prepareLive(List<Broadcast> list, String lang) {
    if (list == null) return null;
    if (list.length == 0) return null;

    List<Broadcast> newList = List();

    for (Broadcast broadcast in list) {
      bool skip = false;

      if (broadcast.language == LangCodes.turkish ||
          broadcast.language == LangCodes.english) {
        bool banned = bannedWordsContains(broadcast.status, broadcast.language);
        if (banned) {
          skip = true;
        }
      }

      if (broadcast.state == StreamStates.RUNNING && !skip) {
        broadcast.live += 'live';

        if (broadcast.language == lang) {
          broadcast.live += lang + lang + lang;
        }

        if (broadcast.nTotalWatching != null) {
          broadcast.live += broadcast.nTotalWatching.toString() +
              broadcast.nTotalWatching.toString();
        }

        if (!skip) {
          newList.add(broadcast);
        }
      } else {
        if (!skip) {
          newList.add(broadcast);
        }
      }
    }
    return newList;
  }

  bool bannedWordsContains(String text, String langCode) {
    if (text == null) return false;
    if (text.isEmpty) return false;
    bool result = false;
    List<String> banned = getBannedWordsByLang(langCode);

    for (String one in banned) {
      if (text.contains(one)) {
        result = true;
        break;
      }
    }

    return result;
  }

  List<String> getBannedWordsByLang(String langCode) {
    if (langCode == LangCodes.turkish) {
      return BannedWords.turkish;
    } else {
      return BannedWords.english;
    }
  }
}
