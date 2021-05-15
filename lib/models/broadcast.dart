import 'listItem.dart';
import 'stream.dart';

class Broadcast extends ListItem {
  String className;
  String id;
  String createdAt;
  String updatedAt;
  String userId;
  String userDisplayName;
  String username;
  String twitterId;
  String twitterUsername;
  String profileImageUrl;
  String state;
  bool isLocked;
  bool friendChat;
  bool privateChat;
  String language;
  int version;
  int replayEditedStartTime;
  int replayEditedThumbnailTime;
  String start;
  String ping;
  String end;
  bool hasModeration;
  String moderatorChannel;
  bool hasModerators;
  bool enabledSparkles;
  bool hasLocation;
  String city;
  String country;
  String countryState;
  String isoCode;
  double ipLat;
  String ipLng;
  int width;
  int height;
  int cameraRotation;
  String imageUrl;
  String imageUrlSmall;
  String imageUrlMedium;
  String status;
  List<String> tags;
  String contentType;
  String broadcastSource;
  bool availableForReplay;
  int expiration;
  String tweetId;
  String mediaKey;
  bool isHighLatency;
  int nTotalWatching;
  int nWatching;
  int nWebWatching;
  int nTotalWatched;
  String live = '';
  bool focus = false;
  Stream stream;

  Broadcast(
      {this.className,
      this.id,
      this.createdAt,
      this.updatedAt,
      this.userId,
      this.userDisplayName,
      this.username,
      this.twitterId,
      this.twitterUsername,
      this.profileImageUrl,
      this.state,
      this.isLocked,
      this.friendChat,
      this.privateChat,
      this.language,
      this.version,
      this.replayEditedStartTime,
      this.replayEditedThumbnailTime,
      this.start,
      this.ping,
      this.end,
      this.hasModeration,
      this.moderatorChannel,
      this.hasModerators,
      this.enabledSparkles,
      this.hasLocation,
      this.city,
      this.country,
      this.countryState,
      this.isoCode,
      this.ipLat,
      this.ipLng,
      this.width,
      this.height,
      this.cameraRotation,
      this.imageUrl,
      this.imageUrlSmall,
      this.imageUrlMedium,
      this.status,
      this.tags,
      this.contentType,
      this.broadcastSource,
      this.availableForReplay,
      this.expiration,
      this.tweetId,
      this.mediaKey,
      this.isHighLatency,
      this.nTotalWatching,
      this.nWatching,
      this.nWebWatching,
      this.nTotalWatched});

  Broadcast.fromJson(Map<String, dynamic> json) {
    className = json['class_name'];
    id = json['id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    userId = json['user_id'];
    userDisplayName = json['user_display_name'];
    username = json['username'];
    twitterId = json['twitter_id'];
    twitterUsername = json['twitter_username'];
    profileImageUrl = json['profile_image_url'];
    state = json['state'];
    isLocked = json['is_locked'];
    friendChat = json['friend_chat'];
    privateChat = json['private_chat'];
    language = json['language'];
    version = json['version'];
    replayEditedStartTime = json['replay_edited_start_time'];
    replayEditedThumbnailTime = json['replay_edited_thumbnail_time'];
    start = json['start'];
    ping = json['ping'];
    end = json['end'];
    hasModeration = json['has_moderation'];
    moderatorChannel = json['moderator_channel'];
    hasModerators = json['has_moderators'];
    enabledSparkles = json['enabled_sparkles'];
    hasLocation = json['has_location'];
    city = json['city'];
    country = json['country'];
    countryState = json['country_state'];
    isoCode = json['iso_code'];
    // ipLat = json['ip_lat'];
    //ipLng = json['ip_lng'];
    width = json['width'];
    height = json['height'];
    cameraRotation = json['camera_rotation'];
    imageUrl = json['image_url'];
    imageUrlSmall = json['image_url_small'];
    imageUrlMedium = json['image_url_medium'];
    status = json['status'];
    tags =
        (json['tags'] != null ? json['tags'].cast<String>() : List<String>());
    contentType = json['content_type'];
    broadcastSource = json['broadcast_source'];
    availableForReplay = json['available_for_replay'];
    expiration = json['expiration'];
    tweetId = json['tweet_id'];
    mediaKey = json['media_key'];
    isHighLatency = json['is_high_latency'];
    nTotalWatching = json['n_total_watching'];
    nWatching = json['n_watching'];
    nWebWatching = json['n_web_watching'];
    nTotalWatched = json['n_total_watched'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['class_name'] = this.className;
    data['id'] = this.id;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['user_id'] = this.userId;
    data['user_display_name'] = this.userDisplayName;
    data['username'] = this.username;
    data['twitter_id'] = this.twitterId;
    data['twitter_username'] = this.twitterUsername;
    data['profile_image_url'] = this.profileImageUrl;
    data['state'] = this.state;
    data['is_locked'] = this.isLocked;
    data['friend_chat'] = this.friendChat;
    data['private_chat'] = this.privateChat;
    data['language'] = this.language;
    data['version'] = this.version;
    data['replay_edited_start_time'] = this.replayEditedStartTime;
    data['replay_edited_thumbnail_time'] = this.replayEditedThumbnailTime;
    data['start'] = this.start;
    data['ping'] = this.ping;
    data['end'] = this.end;
    data['has_moderation'] = this.hasModeration;
    data['moderator_channel'] = this.moderatorChannel;
    data['has_moderators'] = this.hasModerators;
    data['enabled_sparkles'] = this.enabledSparkles;
    data['has_location'] = this.hasLocation;
    data['city'] = this.city;
    data['country'] = this.country;
    data['country_state'] = this.countryState;
    data['iso_code'] = this.isoCode;
    data['ip_lat'] = this.ipLat;
    data['ip_lng'] = this.ipLng;
    data['width'] = this.width;
    data['height'] = this.height;
    data['camera_rotation'] = this.cameraRotation;
    data['image_url'] = this.imageUrl;
    data['image_url_small'] = this.imageUrlSmall;
    data['image_url_medium'] = this.imageUrlMedium;
    data['status'] = this.status;
    data['tags'] = this.tags;
    data['content_type'] = this.contentType;
    data['broadcast_source'] = this.broadcastSource;
    data['available_for_replay'] = this.availableForReplay;
    data['expiration'] = this.expiration;
    data['tweet_id'] = this.tweetId;
    data['media_key'] = this.mediaKey;
    data['is_high_latency'] = this.isHighLatency;
    data['n_total_watching'] = this.nTotalWatching;
    data['n_watching'] = this.nWatching;
    data['n_web_watching'] = this.nWebWatching;
    data['n_total_watched'] = this.nTotalWatched;
    return data;
  }
}
