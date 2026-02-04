enum ExternalPlatform { youtube, spotify }

class ExternalContent {
  final String id;
  final String title;
  final String artistOrChannel;
  final String thumbnailUrl;
  final String externalUrl;
  final ExternalPlatform platform;

  ExternalContent({
    required this.id,
    required this.title,
    required this.artistOrChannel,
    required this.thumbnailUrl,
    required this.externalUrl,
    required this.platform,
  });

  factory ExternalContent.fromJson(Map<String, dynamic> json) {
    return ExternalContent(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      artistOrChannel: json['artistOrChannel'] ?? '',
      thumbnailUrl: json['thumbnailUrl'] ?? '',
      externalUrl: json['externalUrl'] ?? '',
      platform: ExternalPlatform.values.firstWhere(
        (e) => e.name.toUpperCase() == json['platform'],
        orElse: () => ExternalPlatform.spotify,
      ),
    );
  }
}
