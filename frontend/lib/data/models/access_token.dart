class AccessToken {
  String token;
  String type;

  AccessToken(this.token, this.type);

  AccessToken.fromJson(Map<String, dynamic> json)
      : token = ArgumentError.checkNotNull(json['details_url']),
        type = ArgumentError.checkNotNull(json['ocr_size']);
}
