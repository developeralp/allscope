class Channels {
  List<ChannelBroadcasts> channelBroadcasts;

  Channels({this.channelBroadcasts});

  Channels.fromJson(Map<String, dynamic> json) {
    if (json['ChannelBroadcasts'] != null) {
      channelBroadcasts = new List<ChannelBroadcasts>();
      json['ChannelBroadcasts'].forEach((v) {
        channelBroadcasts.add(new ChannelBroadcasts.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.channelBroadcasts != null) {
      data['ChannelBroadcasts'] =
          this.channelBroadcasts.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ChannelBroadcasts {
  Channel channel;
  List<Broadcasts> broadcasts;

  ChannelBroadcasts({this.channel, this.broadcasts});

  ChannelBroadcasts.fromJson(Map<String, dynamic> json) {
    channel =
        json['Channel'] != null ? new Channel.fromJson(json['Channel']) : null;
    if (json['Broadcasts'] != null) {
      broadcasts = new List<Broadcasts>();
      json['Broadcasts'].forEach((v) {
        broadcasts.add(new Broadcasts.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.channel != null) {
      data['Channel'] = this.channel.toJson();
    }
    if (this.broadcasts != null) {
      data['Broadcasts'] = this.broadcasts.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Channel {
  String cID;
  String name;
  String description;
  List<String> universalLocales;
  int nLive;
  bool featured;
  String publicTag;
  String slug;
  List<ThumbnailURLs> thumbnailURLs;
  String createdAt;
  String lastActivity;
  int type;
  String ownerId;
  int nMember;

  Channel(
      {this.cID,
      this.name,
      this.description,
      this.universalLocales,
      this.nLive,
      this.featured,
      this.publicTag,
      this.slug,
      this.thumbnailURLs,
      this.createdAt,
      this.lastActivity,
      this.type,
      this.ownerId,
      this.nMember});

  Channel.fromJson(Map<String, dynamic> json) {
    cID = json['CID'];
    name = json['Name'];
    description = json['Description'];
    universalLocales = (json['UniversalLocales'] != null
        ? json['UniversalLocales'].cast<String>()
        : List<String>());
    nLive = json['NLive'];
    featured = json['Featured'];
    publicTag = json['PublicTag'];
    slug = json['Slug'];
    if (json['ThumbnailURLs'] != null) {
      thumbnailURLs = new List<ThumbnailURLs>();
      json['ThumbnailURLs'].forEach((v) {
        thumbnailURLs.add(new ThumbnailURLs.fromJson(v));
      });
    }
    createdAt = json['CreatedAt'];
    lastActivity = json['LastActivity'];
    type = json['Type'];
    ownerId = json['OwnerId'];
    nMember = json['NMember'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['CID'] = this.cID;
    data['Name'] = this.name;
    data['Description'] = this.description;
    data['UniversalLocales'] = this.universalLocales;
    data['NLive'] = this.nLive;
    data['Featured'] = this.featured;
    data['PublicTag'] = this.publicTag;
    data['Slug'] = this.slug;
    if (this.thumbnailURLs != null) {
      data['ThumbnailURLs'] =
          this.thumbnailURLs.map((v) => v.toJson()).toList();
    }
    data['CreatedAt'] = this.createdAt;
    data['LastActivity'] = this.lastActivity;
    data['Type'] = this.type;
    data['OwnerId'] = this.ownerId;
    data['NMember'] = this.nMember;
    return data;
  }
}

class ThumbnailURLs {
  String url;
  String sslUrl;
  int width;
  int height;

  ThumbnailURLs({this.url, this.sslUrl, this.width, this.height});

  ThumbnailURLs.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    sslUrl = json['ssl_url'];
    width = json['width'];
    height = json['height'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['url'] = this.url;
    data['ssl_url'] = this.sslUrl;
    data['width'] = this.width;
    data['height'] = this.height;
    return data;
  }
}

class Broadcasts {
  String bID;
  bool featured;

  Broadcasts({this.bID, this.featured});

  Broadcasts.fromJson(Map<String, dynamic> json) {
    bID = json['BID'];
    featured = json['Featured'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['BID'] = this.bID;
    data['Featured'] = this.featured;
    return data;
  }
}
