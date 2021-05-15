import 'listItem.dart';

class UserDetails extends ListItem {
  User user;

  UserDetails({this.user});

  UserDetails.fromJson(Map<String, dynamic> json) {
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.user != null) {
      data['user'] = this.user.toJson();
    }
    return data;
  }
}

class User {
  String className;
  String id;
  String createdAt;
  bool isBetaUser;
  bool isEmployee;
  bool isTwitterVerified;
  String twitterScreenName;
  String username;
  String displayName;
  String description;
  List<ProfileImageUrls> profileImageUrls;
  String vip;
  String twitterId;
  String initials;
  int nFollowers;
  int nFollowing;
  int nHearts;

  User(
      {this.className,
      this.id,
      this.createdAt,
      this.isBetaUser,
      this.isEmployee,
      this.isTwitterVerified,
      this.twitterScreenName,
      this.username,
      this.displayName,
      this.description,
      this.profileImageUrls,
      this.vip,
      this.twitterId,
      this.initials,
      this.nFollowers,
      this.nFollowing,
      this.nHearts});

  User.fromJson(Map<String, dynamic> json) {
    className = json['class_name'];
    id = json['id'];
    createdAt = json['created_at'];
    isBetaUser = json['is_beta_user'];
    isEmployee = json['is_employee'];
    isTwitterVerified = json['is_twitter_verified'];
    twitterScreenName = json['twitter_screen_name'];
    username = json['username'];
    displayName = json['display_name'];
    description = json['description'];
    if (json['profile_image_urls'] != null) {
      profileImageUrls = new List<ProfileImageUrls>();
      json['profile_image_urls'].forEach((v) {
        profileImageUrls.add(new ProfileImageUrls.fromJson(v));
      });
    }
    vip = json['vip'];
    twitterId = json['twitter_id'];
    initials = json['initials'];
    nFollowers = json['n_followers'];
    nFollowing = json['n_following'];
    nHearts = json['n_hearts'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['class_name'] = this.className;
    data['id'] = this.id;
    data['created_at'] = this.createdAt;
    data['is_beta_user'] = this.isBetaUser;
    data['is_employee'] = this.isEmployee;
    data['is_twitter_verified'] = this.isTwitterVerified;
    data['twitter_screen_name'] = this.twitterScreenName;
    data['username'] = this.username;
    data['display_name'] = this.displayName;
    data['description'] = this.description;
    if (this.profileImageUrls != null) {
      data['profile_image_urls'] =
          this.profileImageUrls.map((v) => v.toJson()).toList();
    }
    data['vip'] = this.vip;
    data['twitter_id'] = this.twitterId;
    data['initials'] = this.initials;
    data['n_followers'] = this.nFollowers;
    data['n_following'] = this.nFollowing;
    data['n_hearts'] = this.nHearts;
    return data;
  }
}

class ProfileImageUrls {
  String url;
  String sslUrl;
  int width;
  int height;

  ProfileImageUrls({this.url, this.sslUrl, this.width, this.height});

  ProfileImageUrls.fromJson(Map<String, dynamic> json) {
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
