import 'broadcast.dart';

class Stream {
  String session;
  String replayUrl;
  bool hlsIsEncrypted;
  bool lhlsIsEncrypted;
  String type;
  String mediaConfiguration;
  String chatToken;
  String lifeCycleToken;
  Broadcast broadcast;
  String shareUrl;
  String hlsUrl;
  String httpsHlsUrl;
  int autoplayViewThreshold;

  Stream(
      {this.session,
      this.replayUrl,
      this.hlsIsEncrypted,
      this.lhlsIsEncrypted,
      this.type,
      this.mediaConfiguration,
      this.chatToken,
      this.lifeCycleToken,
      this.broadcast,
      this.shareUrl,
      this.hlsUrl,
      this.httpsHlsUrl,
      this.autoplayViewThreshold});

  Stream.fromJson(Map<String, dynamic> json) {
    session = json['session'];
    replayUrl = json['replay_url'];
    hlsIsEncrypted = json['hls_is_encrypted'];
    lhlsIsEncrypted = json['lhls_is_encrypted'];
    type = json['type'];
    mediaConfiguration = json['media_configuration'];
    chatToken = json['chat_token'];
    lifeCycleToken = json['life_cycle_token'];
    broadcast = json['broadcast'] != null
        ? Broadcast.fromJson(json['broadcast'])
        : null;
    shareUrl = json['share_url'];
    hlsUrl = json['hls_url'] != null ? json['hls_url'] : '';
    httpsHlsUrl = json['https_hls_url'] != null ? json['https_hls_url'] : '';

    autoplayViewThreshold = json['autoplay_view_threshold'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['session'] = this.session;
    data['replay_url'] = this.replayUrl;
    data['hls_is_encrypted'] = this.hlsIsEncrypted;
    data['lhls_is_encrypted'] = this.lhlsIsEncrypted;
    data['type'] = this.type;
    data['media_configuration'] = this.mediaConfiguration;
    data['chat_token'] = this.chatToken;
    data['life_cycle_token'] = this.lifeCycleToken;
    if (this.broadcast != null) {
      data['broadcast'] = this.broadcast.toJson();
    }
    data['share_url'] = this.shareUrl;
    if (this.hlsUrl != null) {
      data['hls_url'] = this.hlsUrl;
    }
    if (this.httpsHlsUrl != null) {
      data['https_hls_url'] = this.httpsHlsUrl;
    }
    data['autoplay_view_threshold'] = this.autoplayViewThreshold;
    return data;
  }
}
