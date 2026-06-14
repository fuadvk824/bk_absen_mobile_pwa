class AppVersionModel {
  final String version;
  final String apkUrl;
  final bool forceUpdate;
  final String? message;

  AppVersionModel({
    required this.version,
    required this.apkUrl,
    required this.forceUpdate,
    this.message,
  });

  factory AppVersionModel.fromJson(
      Map<String, dynamic> json) {
    return AppVersionModel(
      version: json['version'],
      apkUrl: json['apk_url'],
      forceUpdate: json['force_update'],
      message: json['message'],
    );
  }
}

