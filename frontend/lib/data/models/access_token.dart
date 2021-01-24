class AccessToken {
  String token;
  String type;

  AccessToken(this.token, this.type);

  AccessToken.fromJson(Map<String, dynamic> json)
      : token = ArgumentError.checkNotNull(json['access_token']),
        type = ArgumentError.checkNotNull(json['token_type']);
}
